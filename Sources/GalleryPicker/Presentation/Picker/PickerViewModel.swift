//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import Photos
import UIKit


final class PickerViewModel {
    let fetchResult: PHFetchResult<PHAsset>?
    var selectedItems: [MediaItem]
    let permissionStatus: PHAuthorizationStatus

    let cellClass: PickerCell.Type
    let enableSystemGallery: Bool
    let categories: [MediaItemCategory]
    let pickerSelectionStyle: PickerSelectionStyle
    let shouldTreatLivePhotosAsVideos: Bool
    let noMedia: Bool
    let appearance: PickerAppearance
    
    init(state: PickerState) {
        appearance = state.pickerConfiguration.appearance
        fetchResult = state.mediaItemFetchResult?.fetchResult
        selectedItems = state.selectedItems
        permissionStatus = state.permissionStatus

        cellClass = state.pickerConfiguration.cellClass
        
        categories = state.pickerConfiguration.categories

        pickerSelectionStyle = state.pickerConfiguration.pickerSelectionStyle
        shouldTreatLivePhotosAsVideos = state.pickerConfiguration.filter.shouldTreatLivePhotosAsVideos
        noMedia = state.noMedia
        enableSystemGallery = state.pickerConfiguration.enableSystemGallery

    }
}
