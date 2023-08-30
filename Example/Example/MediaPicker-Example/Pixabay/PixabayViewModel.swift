//
//  Copyright © 2021 SocialKit. All rights reserved.
//
import UIKit
import GalleryPicker

final class PixabayViewModel {
 
    let medias: [PixabayMedia]
    let selectedItems: [MediaItem]
    let fetchState: PixabayFetchState
    init(state: PixabayState) {
        self.medias = state.medias
        self.selectedItems = state.selectedItems
        fetchState = state.fetchState
       
        
    }
}
