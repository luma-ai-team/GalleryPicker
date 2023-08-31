//
//  File.swift
//  Example
//
//  Created by Roi on 14/08/2023.
//  Copyright © 2023 socialkit. All rights reserved.
//

import UIKit
import GalleryPicker
import Photos
import CoreUI


class GalleryPickerModuleBuilder {
    
    static func create (target: AssetFetchModuleOutput, settingsSelector: Selector) -> GalleryPickerModule {
        let galleryPickerService = GalleryPickerFactory(colorScheme: Constants.colorScheme)
        
        let configuration = galleryPickerService.createGalleryPickerConfiguration()
        configuration.filter.shouldTreatLivePhotosAsVideos = true
        configuration.appearance.navigationBarStyle = .init(style: .solidColor(Constants.colorScheme.background), isStatusBarHidden: false, statusBarStyle: .darkContent)
        configuration.filter.supportedMediaTypes = .all
        configuration.pickerConfiguration.categories = [
            .init(title: "All", predicate: nil),
            .init(title: "Videos", predicate: .init(format: "mediaType = %d", PHAssetMediaType.video.rawValue)),
            .init(title: "Live Photos", predicate: .init(format: "mediaSubtype = %d", PHAssetMediaSubtype.photoLive.rawValue)),
        ]
        
        let settingsButton = BounceButton(type: .custom)
        let settingsImage = UIImage(named: "settings")
        settingsButton.setImage(settingsImage, for: .normal)
        settingsButton.tintColor = Constants.colorScheme.title
        settingsButton.contentEdgeInsets = .init(top: 8.0, left: 8.0, bottom: 8.0, right: 0.0)
        settingsButton.addTarget(target, action: settingsSelector, for: .touchUpInside)
        
        configuration.appearance.rightBarButtons = [settingsButton]
        
        let galleryPickerModule = GalleryPickerModule(state: .init(galleryPickerConfiguration: configuration))
       
        
        galleryPickerService.connectAssetFetchOutout(galleryPickerModule: galleryPickerModule, assetFetchOutput: target)
        
        return galleryPickerModule
    }

}
