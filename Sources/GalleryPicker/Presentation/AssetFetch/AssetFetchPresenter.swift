//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import AVFoundation
import UIKit
import CoreUI
import Photos

open class AssetFetchPresenter {
    enum Constants {
        static let iCloudImport: String = "Importing From iCloud"
    }

    public typealias Dependencies = Any

    public weak var view: AssetFetchViewInput?
    public weak var output: AssetFetchModuleOutput?

    public var state: AssetFetchState

    private let dependencies: Dependencies

    public init(state: AssetFetchState, dependencies: Dependencies) {
        self.state = state
        self.dependencies = dependencies
        fetchItemContent()
    }
    
    public func fetchItemContent() {
        state.fetchState = .local
        update(animated: true)
        guard let mediaItem = state.mediaItem else {
            return
        }
        
        if mediaItem.isRemote {
            state.fetchState = .fetching(Constants.iCloudImport, 0.0)
            update(animated: true)
        }
        
        GalleryAssetService.shared.fetchContent(for: [mediaItem]) { [weak self] (_, progress: Float) in
            if (progress < 1.0) || (self?.state.fetchState.isRemoteAsset == true) {
                self?.state.fetchState = .fetching(Constants.iCloudImport, progress)
                self?.update(animated: true)
            }
        } completion: { [weak self] (results: [MediaContentFetchResult]) in
            guard let self = self,
                  let result = results.first else {
                return
            }
            self.state.mediaItem = nil
            switch result {
            case .error:
                self.state.fetchState = .failed
                self.update(animated: true)
                self.output?.assetFetchModuleCancelledOperation(self)
            case .asset(let asset):
                self.view?.dismiss()
                self.output?.assetFetchModuleFinishedOperation(self, asset: asset, for: mediaItem)
            case .image(let image):
                self.view?.dismiss()
                self.output?.assetFetchModuleFinishedOperation(self, image: image, for: mediaItem)
            }

        }
    }

    open func handleItemSelection(_ item: MediaItem, from moduleInput: GalleryPickerModuleInput) {
        guard state.mediaItem == nil else { return }

        state.mediaItem = item
        fetchItemContent()

        if moduleInput.pickerModule.input.state.selectedItems.isEmpty == false {
            moduleInput.pickerModule.input.state.selectedItems = []
            moduleInput.pickerModule.input.update(force: false, animated: false)
        }
    }

    open func handleItemDeselection(_ item: MediaItem, from moduleInput: GalleryPickerModuleInput) {

    }

    open func handleDismiss() {
        GalleryAssetService.shared.cancelPendingRequest()
        view?.dismiss()
    }
}

// MARK: - AssetFetchViewOutput

extension AssetFetchPresenter: AssetFetchViewOutput {
   
    public func viewDidLoad() {
        update(force: true, animated: false)
    }
    
    public func dismissTapped() {
        handleDismiss()
    }
    
    public func viewTapGesture() {
        switch state.fetchState {
            case .failed:
                dismissTapped()
            default:
                break
        }
    }
}

extension AssetFetchPresenter: GalleryPickerModuleOutput {
    
    public func galleryPickerModuleCanSelectMoreMedia(_ moduleInput: GalleryPickerModuleInput) -> Bool {
        return false
    }
    
    public func galleryPickerModule(_ moduleInput: GalleryPickerModuleInput, didSelect mediaItem: MediaItem) {
        handleItemSelection(mediaItem, from: moduleInput)
    }

    public func galleryPickerModule(_ moduleInput: GalleryPickerModuleInput, didDeselect mediaItem: MediaItem) {
        handleItemDeselection(mediaItem, from: moduleInput)
    }

    public func galleryPickerModuleDidDismiss(_ moduleInput: GalleryPickerModuleInput) {
        handleDismiss()
    }

    public func galleryPickerModuleDidUpdatePermissions(_ moduleInput: GalleryPickerModuleInput,
                                                        status: PHAuthorizationStatus) {
        output?.assetFetchModuleDidUpdatePermissions(self)
    }
}

// MARK: - AssetFetchModuleInput

extension AssetFetchPresenter: AssetFetchModuleInput {

    public func dismiss() {
        handleDismiss()
    }

    public func update(force: Bool = false, animated: Bool) {
        let viewModel = AssetFetchViewModel(state: state)
        view?.update(with: viewModel, force: force, animated: animated)
    }
}
