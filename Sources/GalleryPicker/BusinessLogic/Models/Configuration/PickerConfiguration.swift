//
//  File.swift
//  
//
//  Created by Roi Mulia on 08/11/2022.
//

import Foundation
import UIKit
import CoreUI

// MARK: - Picker

public class PickerConfiguration {
   
    public var selectionLimit = 1
    public var enableSystemGallery: Bool = true
    public var categories: [MediaItemCategory] = []
    var filter: MediaItemFilter = .init()

    public var appearance: PickerAppearance
   

    public init(colorScheme: ColorScheme) {
        self.appearance = .init(colorSceme: colorScheme)
    }
 
}




open class PickerAppearance {
    public var cellLayout = GalleryPickerCollectionViewFlowLayout()
    public var colorScheme: ColorScheme
    public init(colorSceme: ColorScheme) {
        self.colorScheme = colorSceme
    }
}

