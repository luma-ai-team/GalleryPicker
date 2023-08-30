//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import AVFoundation
import GalleryPicker

import Photos
import CoreUI

final class ClassicGalleryPickerCoordinator: BaseCoordinator<UIViewController> {
    
    lazy var galleryPickerModule: GalleryPickerModule = GalleryPickerModuleBuilder.create(target: self, settingsSelector: #selector(self.settingsTapped))
    
    @objc private func settingsTapped() {
        Haptic.selection.generate()
    }
    
    override func start() {
        self.galleryPickerModule.input.activate()
        rootViewController.present(galleryPickerModule.viewController, animated: true)
    }
}


// MARK: - AssetFetchModuleOutput

extension ClassicGalleryPickerCoordinator: AssetFetchModuleOutput {
    
    func assetFetchModuleDidUpdatePermissions(_ moduleInput: AssetFetchModuleInput) {
        //
    }
    
    func assetFetchModuleFinishedOperation(_ moduleInput: AssetFetchModuleInput, image: UIImage, for item: GalleryPicker.MediaItem) {
        //
    }
    
    func assetFetchModuleCancelledOperation(_ moduleInput: AssetFetchModuleInput) {
        galleryPickerModule.input.finalize()
    }

    func assetFetchModuleFinishedOperation(_ moduleInput: AssetFetchModuleInput, asset: AVAsset, for item: GalleryPicker.MediaItem) {
        print(asset)
        galleryPickerModule.input.finalize()

    }
}

