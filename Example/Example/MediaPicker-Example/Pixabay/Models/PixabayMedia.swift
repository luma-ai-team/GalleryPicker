//
//  Models.swift
//  Pixabay
//
//  Created by Roi on 05/08/2023.
//

import Foundation
import UIKit
import GalleryPicker

enum PixabayMedia: Equatable {

    case video(PixabayVideoMedia)
    case image(PixabayImageMedia)
    
    var previewURL: URL? {
        switch self {
        case .video(let pixabayVideoMedia):
            let previewImageURL = "https://i.vimeocdn.com/video/"
            let size = "\(pixabayVideoMedia.videos.tiny.width)x\(pixabayVideoMedia.videos.tiny.height)"
            let url = URL(string: "\(previewImageURL)\(pixabayVideoMedia.picture_id)_\(size).jpg")!
            return url

        case .image(let pixabayImageMedia):
            return pixabayImageMedia.previewURL
        }
    }
    
    var size: CGSize {
        switch self {
        case .video(let pixabayVideoMedia):
            return .init(width: pixabayVideoMedia.videos.small.width, height: pixabayVideoMedia.videos.small.height)
        case .image(let pixabayImageMedia):
            return .init(width: pixabayImageMedia.imageWidth, height: pixabayImageMedia.imageHeight)
        }
    }
    
    var id: Int {
        switch self {
        case .video(let pixabayVideoMedia):
            return pixabayVideoMedia.id
        case .image(let pixabayImageMedia):
            return pixabayImageMedia.id
        }
    }
}

