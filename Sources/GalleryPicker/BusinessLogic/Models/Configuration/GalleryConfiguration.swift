//
//  Created by Roi Mulia on 28/07/2020.
//

import Foundation
import UIKit
import CoreUI
// MARK: - GalleryPicker Configuration


public class GalleryPickerConfiguration {
    
    public let pickerConfiguration: PickerConfiguration
    public var albumsConfiguration: AlbumsConfiguration
    public var appearance: GalleryPickerAppearance
    
    public var filter: MediaItemFilter = .init() {
        didSet {
            pickerConfiguration.filter = filter
            albumsConfiguration.filter = filter
        }
    }
    
    public init(colorScheme: ColorScheme) {
        appearance = .init(colorScheme: colorScheme)
        pickerConfiguration = .init(colorScheme: colorScheme)
        albumsConfiguration = .init(colorScheme: colorScheme)
        pickerConfiguration.filter = filter
        albumsConfiguration.filter = filter
    }
}



public class GalleryPickerAppearance {
    
    public var colorScheme: ColorScheme
    public var leftBarButtons: [UIButton]
    public var rightBarButtons: [UIButton]
    public var navigationBarStyle: StyledNavigationController.SNCAppeareance
    public var hidesNavigationBarInEmptyState: Bool = true

    public init(
        colorScheme: ColorScheme,
        leftBarButtons: [UIButton] = [],
        rightBarButtons: [UIButton] = []
    ) {
        self.colorScheme = colorScheme
        self.leftBarButtons = leftBarButtons
        self.rightBarButtons = rightBarButtons        
        self.navigationBarStyle = .init(
            style: .solidColor(colorScheme.background),
            isStatusBarHidden: false,
            statusBarStyle: .darkContent)
    }
    
}

