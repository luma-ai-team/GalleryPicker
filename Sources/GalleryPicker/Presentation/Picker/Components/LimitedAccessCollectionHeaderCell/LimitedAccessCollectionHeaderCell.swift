//
//  LimitedAccessCollectionReusableView.swift
//  Example
//
//  Created by Roi Mulia on 02/12/2020.
//  Copyright © 2020 socialkit. All rights reserved.
//

import UIKit
import CoreUI

protocol LimitedAccessCollectionHeaderCellDelegate: AnyObject {
    func limitedAccessCollectionHeaderCellActionRequested(_ limitedAccessCollectionHeaderCell: LimitedAccessCollectionHeaderCell)
}

class LimitedAccessCollectionHeaderCell: UICollectionReusableView {

    @IBOutlet weak var button: GradientButton!
    
    weak var output: LimitedAccessCollectionHeaderCellDelegate?
    
    static var identifier: String = "LimitedAccessCollectionHeaderCell"
    
    override func layoutSubviews() {
        UIView.performWithoutAnimation {
            super.layoutSubviews()
            button.clipsToBounds = true
            button.roundCorners(to: .custom(16))
        }
        
        button.semanticContentAttribute = .forceRightToLeft
    }
    
    // MARK: - Actions

    @IBAction func buttonTapped(_ sender: Any) {
        Haptic.selection.generate()
        output?.limitedAccessCollectionHeaderCellActionRequested(self)
    }
    
    
    func configure(with colorScheme: ColorScheme) {
        button.addBounce()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .clear
        button.tintColor = colorScheme.ctaForeground
        
        button.backgroundGradient = colorScheme.gradient
        button.titleGradient = .solid(colorScheme.ctaForeground)
    
    }
    
    
}
