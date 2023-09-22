//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Photos
import PermissionKit

final class PickerPresenter {
    weak var view: PickerViewInput?
    weak var output: PickerModuleOutput?
    
    var state: PickerState

    init(state: PickerState) {
        self.state = state
    }
}

// MARK: - PickerViewOutput

extension PickerPresenter: PickerViewOutput {
    
    func activationRequestEventTriggered() {
        output?.pickerModuleDidRequestActivate(self)
    }

    func systemPickerEventTriggered() {
        output?.pickerModuleDidRequestSystemPicker(self)
    }
    
    func mediaItemSelectionEventTriggered(mediaItem: MediaItem) {
        state.selectedItems.append(mediaItem)
        update(force: false, animated: false)
        output?.pickerModule(self, didSelect: mediaItem)
    }

    func mediaItemDeselectionEventTriggered(mediaItem: MediaItem) {
        if let index = state.selectedItems.firstIndex(of: mediaItem) {
            state.selectedItems.remove(at: index)
        }
        update(force: false, animated: false)
        output?.pickerModule(self, didDeselect: mediaItem)
    }

    func categorySelectionEventTriggered(category: MediaItemCategory) {
        state.selectedCategory = category
        fetchContent()
        update(force: false, animated: true)
    }
    
    func viewDidLoad() {
        update(force: true, animated: false)
    }

    private func fetchContent() {
        GalleryAssetService.shared.observe(state.observer)
        if let album = state.album {
            return fetchPhotos(in: album)
        }

        state.pickerConfiguration.filter.auxiliaryPredicate = nil
        GalleryAssetService.shared.fetchAlbums(filter: state.pickerConfiguration.filter) { [weak self] (albums: [Album]) in
            guard let self = self else {
                return
            }

            guard let album = albums.first else {
                self.state.noMedia = true
                self.update(force: false, animated: false)
                self.output?.pickerModuleDidFetchContent(self)
                return
            }

            self.state.album = album
            self.fetchPhotos(in: album)
        }
    }

    private func fetchPhotos(in album: Album) {
        let filter = state.pickerConfiguration.filter
        filter.auxiliaryPredicate = state.selectedCategory?.predicate
        GalleryAssetService.shared.fetchMediaItemList(in: album,
                                                      filter: filter) { [weak self] (result: MediaItemFetchResult) in
            guard let self = self else {
                return
            }
            
            self.state.noMedia = result.fetchResult.count == 0
            self.state.mediaItemFetchResult = result
            self.update(force: true, animated: false)
            self.output?.pickerModuleDidFetchContent(self)
        }
    }
}

// MARK: - PickerModuleInput

extension PickerPresenter: PickerModuleInput {
    
    func update(with album: Album) {
        state.album = album
        state.mediaItemFetchResult = nil
        update(force: true, animated: false)

        fetchPhotos(in: album)
    }

    func update(force: Bool = false, animated: Bool) {
        let viewModel = PickerViewModel(state: state)
        state.observer.handler = { [weak self] (change: PHChange) in
            guard let fetchResult = self?.state.mediaItemFetchResult?.fetchResult,
                  let details = change.changeDetails(for: fetchResult),
                  details.fetchResultAfterChanges.count != details.fetchResultBeforeChanges.count else {
                return
            }
        
            self?.state.noMedia = details.fetchResultAfterChanges.count == 0

            self?.state.mediaItemFetchResult?.fetchResult = details.fetchResultAfterChanges
            self?.update(animated: false)
        }
        
        view?.update(with: viewModel, force: force, animated: animated)
    }

    public func activate() {
        PhotoLibraryPermission.requestPermission(for: .readWrite) {  [weak self] (permissionStatus) in
                self?.state.permissionStatus = permissionStatus
                self?.update(force: true, animated: false)

                if permissionStatus != .denied {
                    self?.fetchContent()
                }
            }
    }
}
