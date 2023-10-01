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
    public var colorScheme: ColorScheme
    public init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
}


