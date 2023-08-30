//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import AVFoundation
import UIKit
import GalleryPicker

final class BasketPresenter {
    weak var view: BasketViewInput?
    weak var output: BasketModuleOutput?
    
    var state: BasketState

    init(state: BasketState) {
        self.state = state
    }
}       

// MARK: - BasketViewOutput

extension BasketPresenter: BasketViewOutput {
  
    func wantsToSelectSlot(slot: Slot) {
        state.selectedSlot = slot
        update(animated: false)
    }
    
    func wantsToDeleteSlot(slot: Slot) {
        output?.basketModule(self, wantsToDeleteMediaItem: slot.mediaItem)
        if let index = state.slots.firstIndex(where: { $0 === slot }) {
            state.slots[index].mediaItem = nil
        }
        state.selectedSlot = slot
        update(animated: false)
    }
    
    func viewDidLoad() {
        update(force: true, animated: false)
    }
    
    func doneTapped() {
        output?.basketModuleDoneTapped(self)
    }
    
    func findNextNilIndex(from currentIndex: Int) -> Int? {
        let arr = state.slots
        var nextIndex = (currentIndex + 1) % arr.count
        
        // Loop through the array starting from the next index
        while nextIndex != currentIndex {
            if arr[nextIndex].mediaItem == nil {
                return nextIndex
            }
            nextIndex = (nextIndex + 1) % arr.count
        }
        
        // Check the current index
        if arr[currentIndex].mediaItem == nil {
            return currentIndex
        }
        
        return nil
    }
}

// MARK: - BasketModuleInput

extension BasketPresenter: BasketModuleInput {
    func triggerMaxSelectionAnimation() {
        view?.maxSelectionAnimation()
    }
    
 
    func insertMediaItem(mediaItem: MediaItem) {
        if let selectedSlot = state.selectedSlot {
            selectedSlot.mediaItem = mediaItem
        }
        
        if let currentSlotIndex = state.slots.firstIndex(where:  {$0 === state.selectedSlot} ),
           let nextNilIndex = findNextNilIndex(from: currentSlotIndex)
        {
            state.selectedSlot = state.slots[nextNilIndex]
        }
        update(animated: false)
    }

    func update(force: Bool = false, animated: Bool) {
        let viewModel = BasketViewModel(state: state)
        view?.update(with: viewModel, force: force, animated: animated)
    }
}
