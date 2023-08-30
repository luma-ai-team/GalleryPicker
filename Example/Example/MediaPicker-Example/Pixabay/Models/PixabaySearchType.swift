//
//  s.swift
//  Example
//
//  Created by Roi on 13/08/2023.
//  Copyright © 2023 socialkit. All rights reserved.
//

import Foundation
import UIKit

enum PixabaySearchType: String, CaseIterable {
    case video = "Videos"
    case image = "Photos"
    
    var baseUrlString: String {
        switch self {
        case .video:
            return "https://pixabay.com/api/videos/"
        case .image:
            return "https://pixabay.com/api/"
        }
    }
    
    var extraArguments: String {
        switch self {
        case .video:
            return "&video_type=film"
        case .image:
            return "&image_type=photo"
        }
    }
    
    var image: UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        switch self {
        case .video:
            return UIImage(systemName: "video.fill", withConfiguration: config)
        case .image:
            return UIImage(systemName: "photo.fill", withConfiguration: config)
        }
    }
}
