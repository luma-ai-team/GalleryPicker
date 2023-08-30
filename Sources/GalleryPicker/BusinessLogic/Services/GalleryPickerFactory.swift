//
//  File.swift
//  
//
//  Created by Roi Mulia on 13/11/2022.
//

import Foundation
import CoreUI
import UIKit
import Photos


public class GalleryPickerFactory {
    let colorScheme: ColorScheme
    
    public init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
        
    public func createGalleryPickerConfiguration() -> GalleryPickerConfiguration {
        // MARK: - Gallery Appearance
        let galleryPickerAppearance = GalleryPickerAppearance(colorScheme: colorScheme)

        // MARK: - Gallery Configuration
        let galleryPickerConfiguration = GalleryPickerConfiguration(colorScheme: colorScheme)
        galleryPickerConfiguration.filter.shouldTreatLivePhotosAsVideos = false
        galleryPickerConfiguration.filter.supportedMediaTypes = .all
        galleryPickerConfiguration.pickerConfiguration.pickerSelectionStyle = .selection(limit: 1)
        galleryPickerConfiguration.appearance = galleryPickerAppearance
        return galleryPickerConfiguration
    }
    

    // MARK: -  AssetFetchOutput
    
    public func connectAssetFetchOutout(galleryPickerModule: GalleryPickerModule,
                                        assetFetchOutput: AssetFetchModuleOutput) {
        let assetFetchViewController: UIViewController
        switch galleryPickerModule.input.state.galleryPickerConfiguration.filter.supportedMediaTypes {
        case .video:
            let fetchModule = videoAssetFetchModule(context: galleryPickerModule.viewController)
            fetchModule.output = assetFetchOutput
            galleryPickerModule.output = fetchModule.input
            assetFetchViewController = fetchModule.viewController
        case .photo, .all:
            let fetchModule = assetFetchModule(context: galleryPickerModule.viewController)
            fetchModule.output = assetFetchOutput
            galleryPickerModule.output = fetchModule.input
            assetFetchViewController = fetchModule.viewController
        }

        objc_setAssociatedObject(galleryPickerModule.viewController,
                                 &galleryPickerModule.output,
                                 assetFetchViewController,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func videoAssetFetchModule(context: UIViewController) -> VideoAssetFetchModule {
        let assetFetchState = AssetFetchState(context: context, colorScheme: colorScheme)
        return VideoAssetFetchModule(state: assetFetchState)
    }
    
    public func assetFetchModule(context: UIViewController) -> AssetFetchModule {
        let assetFetchState = AssetFetchState(context: context, colorScheme: colorScheme)
        return AssetFetchModule(state: assetFetchState)
    }
}
