//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Photos
import UIKit


final class PickerViewModel {
    let fetchResult: PHFetchResult<PHAsset>?
    var selectedItems: [MediaItem]
    let permissionStatus: PHAuthorizationStatus
    let enableSystemGallery: Bool
    let categories: [MediaItemCategory]
    let selectionLimit: Int
    let shouldTreatLivePhotosAsVideos: Bool
    let noMedia: Bool
    let appearance: PickerAppearance
    
    init(state: PickerState) {
        appearance = state.pickerConfiguration.appearance
        fetchResult = state.mediaItemFetchResult?.fetchResult
        selectedItems = state.selectedItems
        permissionStatus = state.permissionStatus

        
        categories = state.pickerConfiguration.categories

        selectionLimit = state.pickerConfiguration.selectionLimit
        
        shouldTreatLivePhotosAsVideos = state.pickerConfiguration.filter.shouldTreatLivePhotosAsVideos
        noMedia = state.noMedia
        enableSystemGallery = state.pickerConfiguration.enableSystemGallery

    }
}
