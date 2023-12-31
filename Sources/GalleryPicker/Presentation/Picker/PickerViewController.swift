//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import UIKit
import Photos
import CoreUI
import PermissionKit

protocol PickerViewInput: AnyObject {
    func update(with viewModel: PickerViewModel, force: Bool, animated: Bool)
}

protocol PickerViewOutput: AnyObject {
    func viewDidLoad()

    func activationRequestEventTriggered()
    func systemPickerEventTriggered()

    func mediaItemSelectionEventTriggered(mediaItem: MediaItem)
    func mediaItemDeselectionEventTriggered(mediaItem: MediaItem)
}

public final class PickerViewController: UIViewController {
        
    private var viewModel: PickerViewModel
    private let output: PickerViewOutput
    private var didPerformInitialAnimation: Bool = false

    private lazy var enablePermissionView: EnablePermissionView = {
        let view = EnablePermissionView()
        view.applyColor(colorScheme: viewModel.appearance.colorScheme)
        view.alpha = 0
        return view
    }()
    
    private lazy var openGalleryContainerView: UIView = {
        let contaienrView = UIView()
        contaienrView.backgroundColor = viewModel.appearance.colorScheme.foreground
        view.addSubview(contaienrView)
        contaienrView.translatesAutoresizingMaskIntoConstraints = false
        contaienrView.clipsToBounds = true
        contaienrView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        contaienrView.roundCorners(to: .custom(24))
        
        let btn = GradientButton()
        btn.addBounce()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        btn.contentEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(" Open Gallery", for: .normal)
        btn.setImage(UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        btn.addTarget(self, action: #selector(openGalleryTapped), for: .touchUpInside)
        btn.backgroundColor = .clear
        var reducedGradeint = viewModel.appearance.colorScheme.gradient
        let colors = reducedGradeint.colors.map { $0.withAlphaComponent(0.1)}
        let gradeint = Gradient(direction: reducedGradeint.direction, colors: colors)
        btn.backgroundGradient = .solid(viewModel.appearance.colorScheme.background)
        btn.titleGradient = .solid(viewModel.appearance.colorScheme.title)
        btn.cornerRadiusStyle = .custom(16)
        btn.clipsToBounds = true
        contaienrView.addSubview(btn)
        
        NSLayoutConstraint.activate([
            contaienrView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contaienrView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contaienrView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btn.heightAnchor.constraint(equalToConstant: 54),
            btn.bottomAnchor.constraint(equalTo: contaienrView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            btn.topAnchor.constraint(equalTo: contaienrView.topAnchor, constant: 16),
            
            btn.centerXAnchor.constraint(equalTo: contaienrView.centerXAnchor)

        ])
        return contaienrView
    }()

    private lazy var noMediaView: NoMediaFoundView = {
        let noMediaView = NoMediaFoundView()
        noMediaView.setTintColor(tintColor: viewModel.appearance.colorScheme.title)
        view.addSubview(noMediaView)
        noMediaView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noMediaView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noMediaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70)
        ])
        return noMediaView
    }()
    

    public lazy var collectionView: UICollectionView = {
        let cellLayout = viewModel.appearance.cellLayout
        cellLayout.sectionHeadersPinToVisibleBounds = true
        let view = UICollectionView(frame: .zero, collectionViewLayout: cellLayout)
        view.bounces = true
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var dataSource: PickerCollectionDataSource = .init(fetchResult: .init(), shouldPreloadItemMetadata: false, header: .none, colorScheme: viewModel.appearance.colorScheme)

    // MARK: - Lifecycle

    init(viewModel: PickerViewModel, output: PickerViewOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(nibName: nil, bundle: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     // MARK: - UIViewController life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = viewModel.appearance.colorScheme.background
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.panGestureRecognizer.delaysTouchesBegan = false
        collectionView.panGestureRecognizer.delaysTouchesEnded = false
        // collectionView.delaysContentTouches = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.addSubview(enablePermissionView)
        view.addSubview(noMediaView)
        view.sendSubviewToBack(noMediaView)
            
        collectionView.register(LimitedHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LimitedHeaderCell")

        collectionView.register(PickerCollectionViewCell.self, forCellWithReuseIdentifier: "PickerCollectionViewCell")
        output.viewDidLoad()
    }

//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        update(with: viewModel, force: false, animated: false)
//    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        enablePermissionView.frame = view.bounds
        view.bringSubviewToFront(openGalleryContainerView)
    }
    
    @objc public func openGalleryTapped() {
        Haptic.selection.generate()
        output.systemPickerEventTriggered()
    }
}

// MARK: - PickerViewInput

extension PickerViewController: PickerViewInput, ForceViewUpdate {
    
    func update(with viewModel: PickerViewModel, force: Bool, animated: Bool) {
        let oldViewModel = self.viewModel
        self.viewModel = viewModel

        

        var shouldUpdateDataSource: Bool = false
        update(new: viewModel, old: oldViewModel, keyPath: \.fetchResult, force: force) { fetchResult in
            shouldUpdateDataSource = true
        }

        update(new: viewModel, old: oldViewModel, keyPath: \.selectionLimit, force: force) { _ in
            shouldUpdateDataSource = true
        }

        update(new: viewModel, old: oldViewModel, keyPath: \.noMedia, force: force) { noMedia in
            noMediaView.alpha = noMedia ? 1 : 0
            shouldUpdateDataSource = true
        }
        
        
        update(new: viewModel, old: oldViewModel, keyPath: \.selectedItems, force: force) { _ in
            shouldUpdateDataSource = true
        }
        
        if shouldUpdateDataSource {
            let fetchResult = viewModel.fetchResult ?? .init()
            let shouldAnimateCollectionUpdate = (fetchResult.count != 0) && (didPerformInitialAnimation == false)
            let shouldDisplayHeader = shouldAnimateCollectionUpdate || didPerformInitialAnimation || viewModel.noMedia
            var header: PickerCollectionDataSource.Header {
                switch viewModel.permissionStatus {
                case .limited:
                    return .limitedAcces(viewModel.appearance.colorScheme)
                case .authorized:
                    return .none
                default:
                    return .none
                }
            }
                                
            dataSource = PickerCollectionDataSource(
                fetchResult: fetchResult,
                shouldPreloadItemMetadata: viewModel.shouldTreatLivePhotosAsVideos,
                header: shouldDisplayHeader ? header : .none,
                colorScheme: viewModel.appearance.colorScheme
            )
            
            dataSource.selectionLimit = viewModel.selectionLimit
            dataSource.selectedItems = viewModel.selectedItems
            dataSource.output = self

            collectionView.dataSource = dataSource
            collectionView.delegate = dataSource
            collectionView.reloadData()

            if shouldAnimateCollectionUpdate {
                view.layoutIfNeeded()
                didPerformInitialAnimation = true
                UIView.transition(with: collectionView,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: collectionView.layoutIfNeeded,
                                  completion: nil)
            }
        }
        
        update(new: viewModel, old: oldViewModel, keyPath: \.selectedItems, force: force) { _ in
            dataSource.selectedItems = viewModel.selectedItems
            collectionView.reloadData()
        }
        
        update(new: viewModel, old: oldViewModel, keyPath: \.permissionStatus, force: force) { (status) in
            switch status {
            case .denied, .restricted:
                enablePermissionView.alpha = 1
                openGalleryContainerView.alpha = 1
            case .limited:
                enablePermissionView.alpha = 0
                openGalleryContainerView.alpha = 1
            case .authorized, .notDetermined:
                enablePermissionView.alpha = 0
                openGalleryContainerView.alpha = 0
            @unknown default:
                break
            }
            
            if viewModel.enableSystemGallery == false  {
                openGalleryContainerView.alpha = 0
            }
        }

    }
}

// MARK: - PickerCollectionDataSourceOutput

extension PickerViewController: PickerCollectionDataSourceOutput {
 
    func collectionView(_ collectionView: UICollectionView, didSelect mediaItem: MediaItem) {
        Haptic.selection.generate()
        output.mediaItemSelectionEventTriggered(mediaItem: mediaItem)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselect mediaItem: MediaItem) {
        Haptic.selection.generate()
        output.mediaItemDeselectionEventTriggered(mediaItem: mediaItem)
    }
}
