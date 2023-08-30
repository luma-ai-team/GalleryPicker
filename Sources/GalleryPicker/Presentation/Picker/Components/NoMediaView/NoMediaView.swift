//
//  NoMediaView.swift
//  
//
//  Created by Eilon Krauthammer on 14/06/2021.
//

import UIKit

final class NoMediaView: UIView {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setTint(tintColor: UIColor) {
        thumbnailImageView.tintColor = tintColor
        titleLabel.textColor = tintColor
    }
}
