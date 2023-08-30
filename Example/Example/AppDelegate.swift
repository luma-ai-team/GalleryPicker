//
//  AppDelegate.swift
//  Example
//
//  Created by Roi Mulia on 21/07/2020.
//  Copyright © 2020 socialkit. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var appCoordinator: AppCoordinator = .init()

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        appCoordinator.start()

        return true
    }

}
 
