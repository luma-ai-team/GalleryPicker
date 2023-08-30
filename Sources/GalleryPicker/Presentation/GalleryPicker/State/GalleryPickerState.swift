//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Photos

public final class GalleryPickerState {
    public let galleryPickerConfiguration: GalleryPickerConfiguration
    var permissionStatus: PHAuthorizationStatus = .notDetermined
    var isAlbumsModuleVisible: Bool = false
    var hasContent: Bool = false
    public var album: Album?

    public init(galleryPickerConfiguration: GalleryPickerConfiguration) {
        self.galleryPickerConfiguration = galleryPickerConfiguration
    }
}
