//
//  PixabayVideoMedia.swift
//  Example
//
//  Created by Roi on 13/08/2023.
//  Copyright © 2023 socialkit. All rights reserved.
//

import Foundation


protocol PixabayBaseModel: Codable, Equatable {
    var id: Int { get set }    
}

extension PixabayBaseModel {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

class PixabayVideoMedia: PixabayBaseModel {
    let videos: PixabayVideoSize
    var picture_id: String
    var id: Int
    let duration: Int
}


class PixabayVideoSize: Codable {
    
    let large, medium, small, tiny: PixabayVideoInfo

    init(large: PixabayVideoInfo, medium: PixabayVideoInfo, small: PixabayVideoInfo, tiny: PixabayVideoInfo) {
        self.large = large
        self.medium = medium
        self.small = small
        self.tiny = tiny
    }
}

// MARK: - Large
class PixabayVideoInfo: Codable {
    
    let url: String
    let width, height, size: Int

    init(url: String, width: Int, height: Int, size: Int) {
        self.url = url
        self.width = width
        self.height = height
        self.size = size
    }
}
