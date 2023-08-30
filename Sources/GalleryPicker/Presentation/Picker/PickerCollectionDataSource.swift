//
//  PickerCollectionDataSource.swift
//  
//
//  Created by Anton K on 24.07.2020.
//

import UIKit
import Photos
import CoreUI

protocol PickerCollectionDataSourceOutput: AnyObject {
    func collectionView(_ collectionView: UICollectionView, didSelect mediaItem: MediaItem)
    func collectionView(didSelect category: MediaItemCategory)
    func collectionView(_ collectionView: UICollectionView, didDeselect mediaItem: MediaItem)
    func collectionViewDidRequestHeaderAction(_ sender: PickerCollectionDataSource)
}

final class PickerCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Header {
        case limitedAcces(ColorScheme)
        case searchScope([MediaItemCategory], ColorScheme)
        case none
        
        var identifier: String {
            switch self {
            case .limitedAcces:
                return LimitedAccessCollectionHeaderCell.identifier
            case .searchScope:
                return SearchScopeCollectionHeaderCell.identifier
            case .none:
                return ""
            }
        }
    }
    
    let fetchResult: PHFetchResult<PHAsset>
    let header: Header
    let cellReuseIdentifier: String
    var pickerSelectionStyle: PickerSelectionStyle = .selection(limit: 1)
    var shouldPreloadMetadata: Bool
    var colorScheme: ColorScheme
    var items: [IndexPath: MediaItem] = [:]
    var selectedItems: [MediaItem] = []
    weak var output: PickerCollectionDataSourceOutput?
    
    private let assetCount: Int
    
    init(fetchResult: PHFetchResult<PHAsset>,
         cellReuseIdentifier: String = DefaultPickerCollectionViewCell.identifier,
         shouldPreloadItemMetadata: Bool,
         header: Header,
         colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        self.header = header
        self.fetchResult = fetchResult
        self.cellReuseIdentifier = cellReuseIdentifier
        self.shouldPreloadMetadata = shouldPreloadItemMetadata
        assetCount = fetchResult.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                            for: indexPath) as? PickerCell else {
            return .init()
        }

        cell.colorScheme = colorScheme
        let item: MediaItem
        if let cachedItem = items[indexPath] {
            item = cachedItem
        }
        else {
            let asset = fetchResult.object(at: assetCount - indexPath.row - 1)
            item = MediaItem(asset: asset)
            
            if shouldPreloadMetadata {
                item.updateAssetMetadata()
            }
            
            items[indexPath] = item
        }
        
        
        let scale = UIScreen.main.scale
        let baseSize = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
        let scaledSize = baseSize.applying(.init(scaleX: scale, y: scale))
        
        GallerySharedResources.shared.configureCellGradient(for: .init(width: baseSize.width, height: 31))
        
        let selectCount = selectedItems.filter { $0 == item }.count
        cell.gradientImage = GallerySharedResources.shared.cellGradientImage
        cell.configure(with: item, selectCount: selectCount, shouldDisplayLivePhotoBage: shouldPreloadMetadata)
        
        GalleryAssetService.shared.fetchThumbnail(for: item, size: scaledSize) { (image: UIImage?) in
            if item.identifier == cell.item?.identifier {
                return cell.reloadThumbnail()
            }

            for case let cell as PickerCell in collectionView.visibleCells where cell.item?.identifier == item.identifier {
                return cell.reloadThumbnail()
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mediaItem = items[indexPath] else {
            return
        }

        mediaItem.updateAssetMetadata()
                
        switch pickerSelectionStyle {
        case .selection(let limit, _):
            if let index = selectedItems.firstIndex(of: mediaItem) {
                selectedItems.remove(at: index)
                output?.collectionView(collectionView, didDeselect: mediaItem)
            }
            else if selectedItems.count < limit {
                selectedItems.append(mediaItem)
                output?.collectionView(collectionView, didSelect: mediaItem)
            }

        case .addOnly(let limit,  _):
             if selectedItems.count < limit {
                selectedItems.append(mediaItem)
                output?.collectionView(collectionView, didSelect: mediaItem)
            }
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PickerCell {
            let selectedCount = selectedItems.filter { $0 == mediaItem }.count
            cell.configure(with: mediaItem, selectCount: selectedCount, shouldDisplayLivePhotoBage: shouldPreloadMetadata)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? GalleryPickerCollectionViewFlowLayout else {
            return .zero
        }
        
        return layout.cellSize(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return .init()
        }
        
        let myHeaderView: UICollectionReusableView
        
        switch header {
        case .none:
            myHeaderView = .init()
        case .limitedAcces(let colorScheme):
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: header.identifier, for: indexPath) as? LimitedAccessCollectionHeaderCell
            headerView?.output = self
            headerView?.configure(with: colorScheme)
            headerView?.backgroundColor = colorScheme.background
            myHeaderView = headerView ?? .init()
        case .searchScope(let categories, let colorScheme):
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: header.identifier, for: indexPath) as? SearchScopeCollectionHeaderCell
            headerView?.categoryPickerCollectionView.items = categories.map { (category: MediaItemCategory) -> CategoryItem in
                return .init(category: category, colorScheme: colorScheme)
            }
            headerView?.output = self
            headerView?.backgroundColor = colorScheme.background
            myHeaderView = headerView ?? .init()
            
        }
        
        return myHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch header {
        case .none:
            return .zero
        case .limitedAcces:
            return .init(width: collectionView.bounds.width, height: 64)
        case .searchScope:
            return .init(width: collectionView.bounds.width, height: 48)
        }
    }
}

// MARK: - ContextPreview

extension PickerCollectionDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let mediaItem = items[indexPath] else {
            return nil
        }
        
        mediaItem.updateAssetMetadata()
        let previewProvider: UIContextMenuContentPreviewProvider = { () -> UIViewController? in
            return PeekPreviewViewController(with: .mediaItem(mediaItem))
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

// MARK: - LimitedAccessHeaderViewOutput

extension PickerCollectionDataSource: LimitedAccessCollectionHeaderCellDelegate {
    func limitedAccessCollectionHeaderCellActionRequested(_ limitedAccessCollectionHeaderCell: LimitedAccessCollectionHeaderCell) {
        output?.collectionViewDidRequestHeaderAction(self)
    }
}

// MARK: - SearchScopeCollectionHeaderCellOutput

extension PickerCollectionDataSource: SearchScopeCollectionHeaderCellOutput {
    func searchScopeCollectionHeaderCell(_ searchScopeCollectionHeaderCell: SearchScopeCollectionHeaderCell, didSelect category: MediaItemCategory) {
        output?.collectionView(didSelect: category)
    }
}



