//
//  File.swift
//  
//
//  Created by Roi Mulia on 08/11/2022.
//

import UIKit
import CoreUI

// MARK: - Albums

public class AlbumsConfiguration {
    public var filter: MediaItemFilter = .init()
    public var appearance: AlbumsAppearance
    public init(colorScheme: ColorScheme) {
        appearance = AlbumsAppearance(colorScheme: colorScheme)
    }
}


open class AlbumsAppearance {
    public let colorScheme: ColorScheme
    public let cellHeight: CGFloat
    
    public init( colorScheme: ColorScheme,
                 cellHeight: CGFloat = 100.0
    ) {
        self.colorScheme = colorScheme
        self.cellHeight = cellHeight
    }
}

