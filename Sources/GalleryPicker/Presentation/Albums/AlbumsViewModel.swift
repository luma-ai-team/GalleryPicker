//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import UIKit

final class AlbumsViewModel {
    let albums: [Album]
    let filter: MediaItemFilter
    let albumsAppearance: AlbumsAppearance

    init(state: AlbumsState) {
        albums = state.albums
        filter = state.configuration.filter
        albumsAppearance = state.configuration.appearance
    }
}
