//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Photos
import UIKit

public final class PickerState {
    
    public var pickerConfiguration: PickerConfiguration
    public var album: Album?
    public var selectedItems: [MediaItem] = []
    public internal(set) var permissionStatus: PHAuthorizationStatus = .notDetermined
    var mediaItemFetchResult: MediaItemFetchResult?
    var selectedCategory: MediaItemCategory?
    var observer: Observer = .init()
    
    var noMedia: Bool = false

    public init(pickerConfiguration: PickerConfiguration) {
        self.pickerConfiguration = pickerConfiguration
        selectedCategory = pickerConfiguration.categories.first
    }
}
