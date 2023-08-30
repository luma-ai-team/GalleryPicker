//
//  Copyright © 2020 Craftiz. All rights reserved.
//

public final class AlbumsState {
    public internal(set) var albums: [Album] = []
    let configuration: AlbumsConfiguration

    var observer: Observer = .init()

    public init(configuration: AlbumsConfiguration) {
        self.configuration = configuration
    }
}
