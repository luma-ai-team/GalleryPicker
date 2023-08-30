//
//  File.swift
//  
//
//  Created by Anton K on 23.07.2020.
//

import Photos
import UIKit.UIImage
import PhotosUI

open class MediaItem {

    public enum SourceType {
        case unknown
        case photo
        case video(TimeInterval)
        case sloMoVideo(TimeInterval)
        case livePhoto

        var isUnknown: Bool {
            switch self {
            case .unknown:
                return true
            default:
                return false
            }
        }

        var isVideo: Bool {
            switch self {
            case .video, .sloMoVideo:
                return true
            default:
                return false
            }
        }

        var isLivePhoto: Bool {
            switch self {
            case .livePhoto:
                return true
            default:
                return false
            }
        }
    }

    public let identifier: String
    public var asset: PHAsset?

    // We still support iOS 13, so we're keeping it as Any for now
    public var content: Any?

    public weak var thumbnail: UIImage?

    public var size: CGSize = .zero
    public var type: SourceType = .unknown
    public var duration: TimeInterval? {
        if let asset = asset, asset.duration > 0 {
            return asset.duration
        }
        
        switch type {
        case .unknown, .photo, .livePhoto:
            return nil
        case .video(let duration):
            return duration
        case .sloMoVideo(let duration):
            return duration
        }
    }

    public var isRemote: Bool {
        guard let asset = asset else {
            return false
        }

        let resources = PHAssetResource.assetResources(for: asset)
        let isAvailableLocally = (resources.first?.value(forKey: "locallyAvailable") as? Bool) ?? false
        return !isAvailableLocally
    }

    public var isFavorite: Bool {
        guard let asset = asset else {
            return false
        }

        return asset.isFavorite
    }

    public init(identifier: String, type: SourceType, size: CGSize) {
        self.identifier = identifier
        self.type = type
        self.size = size
    }
}

extension MediaItem {

    static func mediaItemType(for asset: PHAsset) -> SourceType {
        switch asset.mediaType {
        case .image:
            if asset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            else {
                return .photo
            }
        case .video:
            if asset.mediaSubtypes.contains(.videoHighFrameRate) {
                return .sloMoVideo(asset.duration)
            }
            else {
                return .video(asset.duration)
            }
        default:
            return .unknown
        }
    }

    convenience init(asset: PHAsset) {
        let identifier = asset.localIdentifier
        self.init(identifier: identifier, type: .unknown, size: .zero)
        self.asset = asset
    }

    @available(iOS 14, *)
    convenience init(pickerResult: PHPickerResult) {
        let type: SourceType = {
            if pickerResult.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                return .video(0.0)
            }
            if pickerResult.itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
                return .livePhoto
            }
            return .photo
        }()
        
        self.init(identifier: pickerResult.assetIdentifier ?? UUID().uuidString, type: type, size: .zero)
        self.content = pickerResult
    }

    public convenience init(content: Any) {
        self.init(identifier: UUID().uuidString, type: .unknown, size: .zero)
        self.content = content
    }
    
    public func updateAssetMetadata() {
        guard let asset = asset else {
            return
        }
        
        type = MediaItem.mediaItemType(for: asset)
        size = .init(width: asset.pixelWidth, height: asset.pixelHeight)
    }
}

extension MediaItem: Equatable {

    public static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
