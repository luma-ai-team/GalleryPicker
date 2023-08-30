//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import CoreUI

public enum FetchState {
    case local
    case fetching(String, Float)
    case failed
    
    public var isRemoteAsset: Bool {
        switch self {
            case .local:
                return false
            default:
                return true
        }
    }
}

open class AssetFetchState {
    public var mediaItem: MediaItem?
    public let context: UIViewController?
    public var fetchState: FetchState = .local
    public var colorScheme: ColorScheme
    public init(mediaItem: MediaItem, colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        self.mediaItem = mediaItem
        context = nil
    }

    public init(context: UIViewController?, colorScheme: ColorScheme) {
        self.context = context
        self.colorScheme = colorScheme
    }
}
