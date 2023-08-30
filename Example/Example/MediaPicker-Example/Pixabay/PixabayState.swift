//
//  Copyright © 2021 SocialKit. All rights reserved.
//
import UIKit

import GalleryPicker

enum PixabayFetchState {
    case loading
    case showingResult
    case showingError(text: String)
}

final class PixabayState {
    
    var mediaType = PixabaySearchType.video
    var medias: [PixabayMedia] = []
    var selectedItems : [MediaItem] = []
    var text = ""
    var fetchState: PixabayFetchState = .loading
    
    init() {
        
    }
    
    
}
