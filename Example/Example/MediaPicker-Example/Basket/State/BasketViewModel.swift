//
//  Copyright © 2019 Rosberry. All rights reserved.
//
import UIKit
import GalleryPicker

final class BasketViewModel {

    let slots: [Slot]
    let selectedSlot: Slot?
    init(state: BasketState) {
        self.slots = state.slots
        selectedSlot = state.selectedSlot
    }
}
