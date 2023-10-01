//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import UIKit
import CoreUI

final class AlbumsViewModel {
    let albums: [Album]
    let filter: MediaItemFilter
    let colorScheme: ColorScheme

    init(state: AlbumsState) {
        albums = state.albums
        filter = state.configuration.filter
        colorScheme = state.configuration.colorScheme
    }
}
