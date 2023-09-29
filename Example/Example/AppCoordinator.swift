//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import AVFoundation
import GalleryPicker
import CoreUI


final class AppCoordinator: BaseCoordinator<UIViewController> {


    var window: UIWindow?
    let root = PickerSelectionViewController()
    
    init() {
        super.init(rootViewController: root)
        root.delegate = self
    }

    override func start() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        UIApplication.shared.isIdleTimerDisabled = true
        
        DispatchQueue.main.async {
            self.didSelectPixabayGalleryPicker()
        }
    }
}

extension AppCoordinator: PickerSelectionDelegate {
    
    func didSelectClassicGalleryPicker() {
        let coordinator = ClassicGalleryPickerCoordinator(rootViewController: root)
        append(child: coordinator)
        coordinator.start() 
    }
    
    func didSelectPixabayGalleryPicker() {
        let coordinator = MediaPickerCoordinator(rootViewController: root)
        append(child: coordinator)
        coordinator.start()
    }
    
    
}
