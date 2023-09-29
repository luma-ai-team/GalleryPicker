//
//  Copyright © 2021 SocialKit. All rights reserved.
//

import UIKit

import AVFoundation
import CoreUI
import StoreKit
import SDWebImage
import GalleryPicker

protocol PixabayViewInput: AnyObject {
    func update(with viewModel: PixabayViewModel, force: Bool, animated: Bool)
}

protocol PixabayViewOutput: AnyObject {
    func viewDidLoad()
    func textUpdated(text: String)
    func contentTypeUpdated(type: PixabaySearchType)
    func wantsToSelect(pixabayMedia: PixabayMedia, thumbnail: UIImage?)
    func searchTapped()
}

final class PixabayViewController: UIViewController {
    
    private var viewModel: PixabayViewModel
    private let output: PixabayViewOutput
    var collectionView: UICollectionView!
    
    
    var loadingView = PixabayLoadingView()
    
    init(viewModel: PixabayViewModel, output: PixabayViewOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output.viewDidLoad()
    }
    
    func setupUI() {
        let pixabaySearchView = PixabaySearchView()
        pixabaySearchView.delegate = self
        pixabaySearchView.translatesAutoresizingMaskIntoConstraints = false
        pixabaySearchView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.headerHeight = 0.0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.delaysContentTouches = true
        collectionView.register(PickerCollectionViewCell.self, forCellWithReuseIdentifier: "PickerCollectionViewCell")
        collectionView.keyboardDismissMode = .onDrag
        
        let stackView = UIStackView(arrangedSubviews: [pixabaySearchView, collectionView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        view.addSubview(stackView)
        stackView.bindMarginsToSuperview()
        
        collectionView.backgroundColor = Constants.colorScheme.background
        
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        loadingView.center(in: view)
        loadingView.setTintColor(Constants.colorScheme.title)
    }
    
}


extension PixabayViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickerCollectionViewCell", for: indexPath) as? PickerCollectionViewCell else {
            fatalError("Unable to dequeue a CustomCell")
        }
        let pixabayMedia = viewModel.medias[indexPath.item]
        let pixabayMediaItem = PixabayMediaItem(with: pixabayMedia, thumbnail: nil)
                
        let representativeIndex = viewModel.selectedItems.firstIndex(where: {$0.identifier == String(pixabayMedia.id)})
        cell.configure(with: pixabayMediaItem,  representativeIndex: representativeIndex, shouldDisplayLivePhotoBage: false)

        cell.contentView.backgroundColor = Constants.colorScheme.foreground
        
        cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator()
        cell.imageView.sd_imageTransition = .fade
        cell.imageView.sd_setImage(with: pixabayMedia.previewURL, completed: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.medias.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pixabayMedia = viewModel.medias[indexPath.item]
        let cell = collectionView.cellForItem(at: indexPath) as! PickerCollectionViewCell
        output.wantsToSelect(pixabayMedia: pixabayMedia, thumbnail: cell.imageView.image)
    }
}

// MARK: - ContextPreview

extension PixabayViewController {
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let pixabayMedia = viewModel.medias[indexPath.item]
        let vc: PeekViewController?
        let ratio = pixabayMedia.size.width / pixabayMedia.size.height
        switch pixabayMedia {
        case .image:
            vc = .init(with: .image(UIImage()), ratio: ratio)
            vc?.loadViewIfNeeded()
            vc?.imageView.sd_imageIndicator = SDWebImageProgressIndicator()
            vc?.imageView.sd_setImage(with: pixabayMedia.previewURL)
            // load image
        case .video(let videoItem):
            guard let url = URL(string: videoItem.videos.medium.url) else {
                vc = nil
                return nil
            }
            vc = .init(with: .video(AVAsset(url: url)), ratio: ratio)
        }
    
        
        let previewProvider: UIContextMenuContentPreviewProvider = { () -> UIViewController? in
            return vc
        }
        
        let actionProvider: UIContextMenuActionProvider = { _ -> UIMenu? in
            let action = UIAction(title: "Select",
                                  image: UIImage(systemName: "plus.circle.fill"),
                                  identifier: nil) { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                self.collectionView(collectionView, didSelectItemAt: indexPath)
            }
            return .init(title: .init(), image: nil, identifier: nil, children: [action])
        }
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath,
                                          previewProvider: previewProvider,
                                          actionProvider: actionProvider)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath else {
            return
        }
        
        animator.addCompletion { [weak self] in
            guard let self = self else {
                return
            }
            
            self.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
}


extension PixabayViewController: WaterfallLayoutDelegate {
    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        return .waterfall(column: 2, distributionMethod: .balanced)
    }

    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let preview = viewModel.medias[indexPath.item]
        return preview.size
    }
}


extension PixabayViewController: SearchViewDelegate {
    func searchTapped(withText text: String) {
        output.textUpdated(text: text)
        output.searchTapped()
    }
    
    func clearTapped() {
        output.textUpdated(text: "")
        output.searchTapped()
    }
    
    func contentTypeChanged(to contentType: PixabaySearchType) {
        output.contentTypeUpdated(type: contentType)
        output.searchTapped()
    }
}



// MARK: - CanvasViewInput
extension PixabayViewController: PixabayViewInput, ForceViewUpdate {
  
    
    func update(with viewModel: PixabayViewModel, force: Bool, animated: Bool) {
        let oldViewModel = self.viewModel
        self.viewModel = viewModel
        
        switch viewModel.fetchState {
        case .loading:
            collectionView.alpha = 0
            loadingView.alpha = 1
            loadingView.showOnlyLoading()
        case .showingResult:
            collectionView.alpha = 1
            loadingView.alpha = 0
        case .showingError(text: let string):
            loadingView.setError(string: string)
            collectionView.alpha = 0
            loadingView.alpha = 1
        }
        
        if viewModel.medias != oldViewModel.medias {
            collectionView.contentOffset.y = 0
            collectionView.reloadData()
        }
        
        if viewModel.selectedItems != oldViewModel.selectedItems {
            collectionView.reloadData()
        }
    }
    
}


