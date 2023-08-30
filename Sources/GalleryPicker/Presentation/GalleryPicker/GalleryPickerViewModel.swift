//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Photos

final class GalleryPickerViewModel {
    let galleryPickerConfiguration: GalleryPickerConfiguration
    let permissionStatus: PHAuthorizationStatus
    let isAlbumsModuleVisible: Bool
    let hasContent: Bool
    let album: String

    init(state: GalleryPickerState) {
        self.galleryPickerConfiguration = state.galleryPickerConfiguration
        self.permissionStatus = state.permissionStatus
        self.isAlbumsModuleVisible = state.isAlbumsModuleVisible
        self.hasContent = state.hasContent
        self.album = state.album?.title ?? ""
    }
}
