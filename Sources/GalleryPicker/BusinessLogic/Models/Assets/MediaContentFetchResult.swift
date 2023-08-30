//
//  Created by Anton K on 27.10.2020.
//

import AVFoundation
import UIKit

public enum MediaContentFetchResult {
    case image(UIImage)
    case asset(AVAsset)
    case error(Error)
}
