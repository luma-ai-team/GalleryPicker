//
//  asd.swift
//  Example
//
//  Created by Roi on 13/08/2023.
//  Copyright © 2023 socialkit. All rights reserved.
//

import Foundation


struct PixabayImageMedia: PixabayBaseModel {
    var id: Int
    let imageWidth: Int
    let imageHeight: Int
    private var webformatURL: URL
    let largeImageURL: URL
    
    var previewURL: URL {
        let originalUrlString = webformatURL.absoluteString
        let newUrlString = originalUrlString.replacingOccurrences(of: "_640", with: "_340")
        let newUrl = URL(string: newUrlString) ?? webformatURL
        return newUrl
    }
}


struct PixabayResponse: Codable {
    let total: Int
    let hits: [PixabayVideoSize]
}
