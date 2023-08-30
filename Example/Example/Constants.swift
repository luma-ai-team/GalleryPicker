//
//  Constants.swift
//  Example
//
//  Created by Roi on 08/08/2023.
//  Copyright © 2023 socialkit. All rights reserved.
//

import CoreUI
import UIKit

enum Constants {
    static var colorScheme = ColorScheme(
        active: UIColor(named: "active")!,
        title: UIColor(named: "title")!,
        subtitle:  UIColor(named: "subtitle")!,
        notActive: UIColor(named: "notActive")!,
        background: UIColor(named: "background")!,
        foreground: UIColor(named: "foreground")!,
        disabled: UIColor(named: "disabled")!,
        ctaForeground: UIColor(named: "ctaForeground")!,
        gradient: .init(direction: .horizontal,
                        colors: [
                           UIColor(hex: "FE7FA7"),
                           UIColor(hex: "FF5757")
                        ]))
    
    
    
}
