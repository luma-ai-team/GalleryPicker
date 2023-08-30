//
//  MediaItemCategory.swift
//
//  Created by Anton Kormakov on 08.08.2022.
//

import Foundation
import Photos

public final class MediaItemCategory {
    public let title: String
    public let predicate: NSPredicate?

    public init(title: String, predicate: NSPredicate?) {
        self.title = title
        self.predicate = predicate
    }
}

extension MediaItemCategory: Equatable {
    public static func == (lhs: MediaItemCategory, rhs: MediaItemCategory) -> Bool {
        return lhs.title == rhs.title
    }
}
