//
//  Created by Anton K on 27.10.2020.
//

import Foundation
import Photos

public final class MediaItemFilter {
    public enum MediaType {
        case all
        case photo
        case video
    }

    public var supportedMediaTypes: MediaType = .all
    public var shouldTreatLivePhotosAsVideos: Bool = true
    public var auxiliaryPredicate: NSPredicate? = nil

    var fetchOptions: PHFetchOptions {
        let options = PHFetchOptions()
        options.predicate = predicate
        options.includeAssetSourceTypes = [.typeCloudShared, .typeiTunesSynced, .typeUserLibrary]
        options.includeAllBurstAssets = true
        return options
    }
    
    var predicate: NSPredicate? {
        let mainPredicate: NSPredicate?
        switch supportedMediaTypes {
        case .photo:
            mainPredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        case .video:
            if shouldTreatLivePhotosAsVideos {
                mainPredicate = NSPredicate(format: "mediaType = %d OR mediaSubtype = %d",
                                            PHAssetMediaType.video.rawValue,
                                            PHAssetMediaSubtype.photoLive.rawValue)
            }
            else {
                mainPredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            }
        default:
            mainPredicate = nil
        }

        if let auxiliaryPredicate = auxiliaryPredicate {
            if let mainPredicate = mainPredicate {
                return NSCompoundPredicate(andPredicateWithSubpredicates: [mainPredicate, auxiliaryPredicate])
            }
            
            return auxiliaryPredicate
        }

        return mainPredicate
    }
    
    public init() {}

    func ignoringAuxiliaryPredicate() -> MediaItemFilter {
        let copy = MediaItemFilter()
        copy.supportedMediaTypes = supportedMediaTypes
        copy.shouldTreatLivePhotosAsVideos = shouldTreatLivePhotosAsVideos
        return copy
    }
}
