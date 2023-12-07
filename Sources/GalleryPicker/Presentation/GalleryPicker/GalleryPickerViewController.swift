//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import UIKit
import CoreUI
import PhotosUI

protocol GalleryPickerViewInput: AnyObject {
    func update(with viewModel: GalleryPickerViewModel, force: Bool, animated: Bool)
    func dismiss()

    func addLeftBarButtonAction(_ action: (() -> Void)?)
    func addRightBarButtonAction(_ action: (() -> Void)?)
}

protocol GalleryPickerViewOutput: AnyObject {
    func albumsButtonTapped()
    func viewDidLoad()
    func dismissEventTriggered()
    func fallbackPickerCompletionEvenTriggered(items: [MediaItem])
}

public final class GalleryPickerViewController: StyledNavigationController {
        
    private var viewModel: GalleryPickerViewModel
    private let output: GalleryPickerViewOutput

    private var fallbackPickerViewController: UIViewController?
    
    public lazy var albumsRotatableButton: AlbumsRotatableButton = {
        let albumsRotatableButton = AlbumsRotatableButton()
        albumsRotatableButton.updateAppearanceWithColorScheme(colorScheme: viewModel.galleryPickerConfiguration.appearance.colorScheme)
        albumsRotatableButton.setTitle("Recents", for: .normal)
        albumsRotatableButton.sizeToFit()
        albumsRotatableButton.addTarget(self, action: #selector(self.showAlbums), for: .touchUpInside)
        return albumsRotatableButton
    }()
    
    private var leftBarButtonHandler: (() -> Void)?
    private var rightBarButtonHandler: (() -> Void)?

    private var navigationBarAlpha: CGFloat = 0.0 {
        didSet {
            updateNavigationBarAlpha()
        }
    }

    public override var childForStatusBarStyle: UIViewController? {
        return nil
    }
    
    // MARK: - Lifecycle
    
    init(viewModel: GalleryPickerViewModel, output: GalleryPickerViewOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(appeareance: viewModel.galleryPickerConfiguration.appearance.navigationBarStyle)

        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
        output.viewDidLoad()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNavigationBarAlpha()
    }

    private func updateNavigationBarAlpha() {
        navigationBar.subviews.forEach({ (view: UIView) in
            view.alpha = navigationBarAlpha
        })
    }

    @objc func showAlbums() {
        Haptic.selection.generate()
        output.albumsButtonTapped()
    }
    
    @objc private func leftBarButtonTapped() {
        leftBarButtonHandler?()
    }

    @objc private func rightBarButtonTapped() {
        rightBarButtonHandler?()
    }
}

// MARK: - GalleryPickerViewInput

extension GalleryPickerViewController: GalleryPickerViewInput, ForceViewUpdate {
    func addLeftBarButtonAction(_ action: (() -> Void)?) {
        if let button = navigationBar.topItem?.leftBarButtonItem?.customView as? UIButton {
            self.leftBarButtonHandler = action
            button.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
        }
    }

    func addRightBarButtonAction(_ action: (() -> Void)?) {
        if let button = navigationBar.topItem?.rightBarButtonItem?.customView as? UIButton {
            self.rightBarButtonHandler = action
            button.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        }
    }

    func update(with viewModel: GalleryPickerViewModel, force: Bool, animated: Bool) {
        let oldViewModel = self.viewModel
        self.viewModel = viewModel

        let appearance = viewModel.galleryPickerConfiguration.appearance

        let leftBarButtonItems = appearance.leftBarButtons.map { (button: UIButton) -> UIBarButtonItem in
            return .init(customView: button)
        }
        if leftBarButtonItems.isEmpty == false {
            navigationBar.topItem?.leftBarButtonItems = leftBarButtonItems
        }

        let rightBarButtonItems = appearance.rightBarButtons.map { (button: UIButton) -> UIBarButtonItem in
            return .init(customView: button)
        }
        navigationBar.topItem?.rightBarButtonItems = rightBarButtonItems
        
        update(new: viewModel, old: oldViewModel, keyPath: \.permissionStatus, force: force) { permissionStatus in
            let albumsAccessView: UIView?
            switch permissionStatus {
            case .authorized:
                albumsAccessView = albumsRotatableButton
            default:
                albumsAccessView = nil
            }
            
            if navigationBar.topItem?.leftBarButtonItems == nil,
               let albumsAccessView = albumsAccessView {
                navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: albumsAccessView)
            }
            else {
                navigationBar.topItem?.titleView = albumsAccessView
            }
        }

        update(new: viewModel, old: oldViewModel, keyPath: \.album, force: force) { (album: String) in
            albumsRotatableButton.setTitle(album, for: .normal)
            albumsRotatableButton.sizeToFit()
        }
        
        update(new: viewModel, old: oldViewModel, keyPath: \.isAlbumsModuleVisible, force: force) { (isVisible: Bool) in
            albumsRotatableButton.isAlbumPresented = isVisible
        }
        
        if oldViewModel.hasContent == false,
           viewModel.galleryPickerConfiguration.appearance.hidesNavigationBarInEmptyState {
            navigationBarAlpha = 0.0
        }
        
        update(new: viewModel, old: oldViewModel, keyPath: \.hasContent, force: force) { (hasContent: Bool) in
            UIView.animate(withDuration: 0.25) {
                if hasContent == false,
                   viewModel.galleryPickerConfiguration.appearance.hidesNavigationBarInEmptyState {
                    self.navigationBarAlpha = 0.0
                }
                else {
                    self.navigationBarAlpha = 1.0
                }
            }
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
        output.dismissEventTriggered()
    }
}

extension GalleryPickerViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        output.dismissEventTriggered()
    }
}
