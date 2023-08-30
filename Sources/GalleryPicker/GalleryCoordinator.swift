//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import AVFoundation
import PhotosUI
import CoreUI
import PermissionKit




final class GalleryCoordinator: BaseCoordinator<UINavigationController> {
    let configuration: GalleryPickerConfiguration
    let pickerModule: PickerModule
    let albumsModule: AlbumsModule
    weak var galleryPickerPresenter: GalleryPickerPresenter?
    

    init(rootViewController: UINavigationController, galleryPickerConfiguration: GalleryPickerConfiguration, albumsModule: AlbumsModule, pickerModule: PickerModule) {

        self.configuration = galleryPickerConfiguration
        self.pickerModule = pickerModule
        self.albumsModule = albumsModule
        
        super.init(rootViewController: rootViewController)
    }
    
    override func start() {
        rootViewController.viewControllers = [pickerModule.viewController]
    }
    
    func presentAlbumsViewController() {
        rootViewController.present(albumsModule.viewController, animated: true, completion: nil)
    }
    
    func dismissAlbumsViewController() {
        rootViewController.dismiss(animated: true, completion: nil)
    }
    
    func openFullAccessSettings() {
        PhotoLibraryPermission.redirectToSettings()
    }
    
    
    func pickerModuleDidRequestSystemPicker(_ moduleInput: GalleryPickerModuleInput) {
        let state = moduleInput.state
        var pickerConfiguration = PHPickerConfiguration()
        pickerConfiguration.selectionLimit = state.galleryPickerConfiguration.pickerConfiguration.pickerSelectionStyle.limit
        
        switch state.galleryPickerConfiguration.filter.supportedMediaTypes {
        case .all:
            pickerConfiguration.filter = .any(of: [.images, .livePhotos, .videos])
        case .photo:
            if state.galleryPickerConfiguration.filter.shouldTreatLivePhotosAsVideos {
                pickerConfiguration.filter = .images
            }
            else {
                pickerConfiguration.filter = .any(of: [.livePhotos, .images])
            }
        case .video:
            if state.galleryPickerConfiguration.filter.shouldTreatLivePhotosAsVideos {
                pickerConfiguration.filter = .any(of: [.livePhotos, .videos])
            }
            else {
                pickerConfiguration.filter = .videos
            }
        }
        
        let fallbackPickerViewController = PHPickerViewController(configuration: pickerConfiguration)
        fallbackPickerViewController.delegate = self
        rootViewController.present(fallbackPickerViewController, animated: true)
    }
    
}

// MARK: - PHPickerViewControllerDelegate

extension GalleryCoordinator: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard results.isEmpty == false else {
            picker.dismiss(animated: true)
            return
        }

        let items = results.map(MediaItem.init)
        galleryPickerPresenter?.fallbackPickerCompletionEvenTriggered(items: items)
    }
}
