//
//  collectionObject.swift
//  Smartcollection
//
//  Created by Roi Mulia on 7/18/17.
//  Copyright © 2017 Roi Mulia. All rights reserved.
//

import UIKit
import Photos

public final class Album {

    public let identifier: String
    public let title: String?
    public var estimatedAssetCount: Int = 0
    public var thumbnail: UIImage?

    init(identifier: String, title: String?) {
        self.identifier = identifier
        self.title = title
    }
}

extension Album {
    convenience init(collection: PHAssetCollection, title: String?) {
        self.init(identifier: collection.localIdentifier, title: title ?? collection.localizedTitle)
        estimatedAssetCount = collection.estimatedAssetCount
    }
}

extension Album: Equatable {
    public static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
