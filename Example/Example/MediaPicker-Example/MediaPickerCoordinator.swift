//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import AVFoundation
import GalleryPicker
import PermissionKit

import Photos
import CoreUI

final class MediaPickerCoordinator: BaseCoordinator<UIViewController> {
    
    private let pickerModule: PickerModule
    private let albumsModule: AlbumsModule
    private let basketModule: BasketModule
    private let mediaPickerViewController: MediaPickerViewController
    private let pickerNavigationController: UINavigationController
    private let pixabayModule: PixabayModule
    private var slots: [Slot]
    
    override init(rootViewController: UIViewController) {
        slots = (0...10).map { _ in Slot(time: CGFloat.random(in: 0.1...2), mediaItem: nil) }
        
        let galleryPickerConfig = GalleryPickerConfiguration(colorScheme: Constants.colorScheme)
        let galleryPickerModule = GalleryPickerModule(state: GalleryPickerState(galleryPickerConfiguration: galleryPickerConfig))
        galleryPickerModule.input.state.galleryPickerConfiguration.pickerConfiguration.selectionLimit = slots.count
        galleryPickerModule.input.state.galleryPickerConfiguration.pickerConfiguration.enableSystemGallery = false
        
        self.pickerModule = galleryPickerModule.input.pickerModule
        self.albumsModule = galleryPickerModule.input.albumsModule
        self.pixabayModule = PixabayModule(state: .init())
        self.basketModule = BasketModule(state: .init(slots: slots))
        
        let pickerViewController = pickerModule.viewController
        let unsplashPhotoPickerViewController = pixabayModule.viewController
        
        self.mediaPickerViewController = MediaPickerViewController(
            pickerViewController: pickerViewController,
            unsplashPhotoPickerViewController: unsplashPhotoPickerViewController,
            basketViewController: basketModule.viewController,
            with: "Recents"
        )
        
        let nvc = StyledNavigationController(rootViewController: mediaPickerViewController,  appeareance: .init(style: .solidColor(Constants.colorScheme.background), isStatusBarHidden: false, statusBarStyle: .lightContent))
                                                                        
        self.pickerNavigationController = nvc
        
        super.init(rootViewController: rootViewController)
        
        albumsModule.output = self
        pickerModule.output = self
        basketModule.output = self
        pixabayModule.output = self
        mediaPickerViewController.delegate = self
    }
    
    override func start() {
        pickerModule.input.activate()
        pickerNavigationController.modalPresentationStyle = .fullScreen
        rootViewController.present(pickerNavigationController, animated: true, completion: nil)
    }
}

// MARK: - PixabayModuleOutput

extension MediaPickerCoordinator: PixabayModuleOutput {
    func pixabayModule(_ moduleInput: PixabayModuleInput, wantsToSelectPixabayMedia pixabayMedia: PixabayMedia, thumbnail: UIImage?) {
        let totalSelectedItems = pickerModule.input.state.selectedItems.count
        guard totalSelectedItems < pickerModule.input.state.pickerConfiguration.selectionLimit else {
            print("too many picks, can't sorry..")
            return
        }
        let mediaItem = PixabayMediaItem(with: pixabayMedia, thumbnail: thumbnail)
        pickerModule.input.state.selectedItems.append(mediaItem)
        moduleInput.state.selectedItems = pickerModule.input.state.selectedItems
        moduleInput.update(force: false, animated: false)
        pickerModule.input.update(force: false, animated: false)
        Haptic.selection.generate()
        basketModule.input.insertMediaItem(mediaItem: mediaItem)
    }
}

// MARK: - BasketModuleOutput

extension MediaPickerCoordinator: BasketModuleOutput {
    func basketModule(_ moduleInput: BasketModuleInput, wantsToDeleteMediaItem mediaItem: MediaItem?) {
        if let index = pickerModule.input.state.selectedItems.firstIndex(where: { $0 === mediaItem }) {
            pickerModule.input.state.selectedItems.remove(at: index)
        }
        pickerModule.input.update(force: false, animated: false)
        pixabayModule.input.state.selectedItems = pickerModule.input.state.selectedItems
        pixabayModule.input.update(force: false, animated: false)
    }
    
    func basketModuleDoneTapped(_ moduleInput: BasketModuleInput) {
        print("done tapped")
    }
}

// MARK: - PickerModuleOutput

extension MediaPickerCoordinator: PickerModuleOutput {
    func pickerModuleDidFetchContent(_ moduleInput: PickerModuleInput) {}
    func pickerModule(_ moduleInput: PickerModuleInput, didSelect mediaItem: MediaItem) {
        basketModule.input.insertMediaItem(mediaItem: mediaItem)
    }
    func pickerModule(_ moduleInput: PickerModuleInput, didDeselect mediaItem: MediaItem) {}
    func pickerModuleDidRequestActivate(_ moduleInput: PickerModuleInput) {}
    func pickerModuleWantsToOpenFullAccessSettings(_ moduleInput: PickerModuleInput) {}
    func pickerModuleDidRequestSystemPicker(_ moduleInput: PickerModuleInput) {}
}

// MARK: - AlbumsModuleOutput

extension MediaPickerCoordinator: AlbumsModuleOutput {
    func albumsModule(didSelect album: Album) {
        mediaPickerViewController.setAlbumLabel(title: album.title ?? "Gallery")
        pickerModule.input.update(with: album)
        mediaPickerViewController.dismiss(animated: true, completion: nil)
    }
    
    func albumsModuleWillDismiss(_ sender: AlbumsModuleInput) {
        mediaPickerViewController.albumsDismissed()
    }
}

// MARK: - MediaPickerViewControllerDelegate

extension MediaPickerCoordinator: MediaPickerViewControllerDelegate {
    func mediaPickerNavigationControllerWantsToOpenAlbums(_ mediaPickerViewController: MediaPickerViewController) {
        Haptic.selection.generate()
        guard PermissionKit.PhotoLibraryPermission.currentStatus(for: .readWrite).isAuthorized else {
            return
        }
        mediaPickerViewController.present(albumsModule.viewController, animated: true, completion: nil)
    }
    func mediaPickerNavigationControllerDonePressed(_ mediaPickerViewController: MediaPickerViewController) {}
}
