//
//  Slot.swift
//  Example
//
//  Created by Roi on 15/08/2023.
//  Copyright © 2023 socialkit. All rights reserved.
//

import Foundation
import GalleryPicker

class Slot {
    let time: CGFloat
    var mediaItem: MediaItem?
    
    init(time: CGFloat, mediaItem: MediaItem? = nil) {
        self.time = time
        self.mediaItem = mediaItem
    }
}
