//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import AVFoundation
import UIKit
import CoreUI

final class VideoAssetFetchPresenter: AssetFetchPresenter {
    enum Constants {
        static let iCloudImport: String = "Importing From iCloud"
        static let livePhotoImport: String = "Fetching Live Photo"
    }
    
    weak var videoFetchOutput: VideoAssetFetchModuleOutput?
    
    override init(state: AssetFetchState, dependencies: AssetFetchPresenter.Dependencies) {
        super.init(state: state, dependencies: dependencies)
        self.output = self
    }
    
    override func fetchItemContent() {
        state.fetchState = .local
        update(animated: true)
        guard let mediaItem = state.mediaItem else {
            return
        }
        
        guard mediaItem.type.isVideo || mediaItem.type.isLivePhoto else {
            state.mediaItem = nil
            view?.dismiss()
            return
        }
        
        if mediaItem.isRemote {
            state.fetchState = .fetching(Constants.iCloudImport, 0.0)
            update(animated: true)
        }
        
        GalleryAssetService.shared.fetchVideoAsset(for: mediaItem, progressHandler: { [weak self] (_, progress: Float) in
            guard let self = self else { return }
            if progress < 1.0 || self.state.fetchState.isRemoteAsset {
                if mediaItem.type.isLivePhoto, self.state.fetchState.isRemoteAsset {
                    self.state.fetchState = .fetching(Constants.iCloudImport, progress)
                } else if mediaItem.type.isLivePhoto && !self.state.fetchState.isRemoteAsset {
                    self.state.fetchState = .fetching(Constants.livePhotoImport, progress)
                    // Return if we want to ignore the Live Photo fetching.
                    return
                } else {
                    self.state.fetchState = .fetching(Constants.iCloudImport, progress)
                }
                self.update(animated: true)
            }
        }, completion: { [weak self] (asset: AVAsset?) in
            guard let self = self else { return }
            
            self.state.mediaItem = nil
            if let asset = asset {
                self.view?.dismiss()
                self.videoFetchOutput?.assetFetchModuleFinishedOperation(self, asset: asset, for: mediaItem)
            }
            else {
                self.state.fetchState = .failed
                self.update(animated: true)
                self.videoFetchOutput?.assetFetchModuleCancelledOperation(self)
            }
        })
    }
}

extension VideoAssetFetchPresenter: AssetFetchModuleOutput {
    func assetFetchModuleCancelledOperation(_ moduleInput: AssetFetchModuleInput) {
        videoFetchOutput?.assetFetchModuleCancelledOperation(self)
    }
    
    func assetFetchModuleFinishedOperation(_ moduleInput: AssetFetchModuleInput, asset: AVAsset, for item: MediaItem) {
        videoFetchOutput?.assetFetchModuleFinishedOperation(self, asset: asset, for: item)
    }
    
    func assetFetchModuleFinishedOperation(_ moduleInput: AssetFetchModuleInput, image: UIImage, for item: MediaItem) {
        videoFetchOutput?.assetFetchModuleCancelledOperation(self)
    }

    func assetFetchModuleDidUpdatePermissions(_ moduleInput: AssetFetchModuleInput) {
        //
    }
}
