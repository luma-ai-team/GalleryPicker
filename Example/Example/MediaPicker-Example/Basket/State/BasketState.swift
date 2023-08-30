//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import AVFoundation
import Photos
import GalleryPicker

final class BasketState {
    var slots: [Slot]
    
    var selectedSlot: Slot?
    init(slots: [Slot]) {
        self.slots = slots
        selectedSlot = slots.first
    }
}
