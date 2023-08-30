//
//  SavedView.swift
//  highlight
//
//  Created by Roi Mulia on 12/02/2020.
//  Copyright © 2020 TrendyPixel. All rights reserved.
//

import UIKit
import CoreUI

class ImportingFromICloudView: UIView {
    @IBOutlet weak var progressView: GradientProgressBar!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
}

extension ImportingFromICloudView: ContentableView {
    func postAppearanceActions() {
        
    }
}
