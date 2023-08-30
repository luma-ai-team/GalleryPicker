//
//  Activate.swift
//  NewActivateScreen
//
//  Created by Roi Mulia on 11/11/2022.
//

import UIKit
import CoreUI

class NoPermissionsBasicView: UIView, PermissionsPlaceholderView {
    
    static func create(with colorScheme: ColorScheme) -> NoPermissionsBasicView {
        let v: NoPermissionsBasicView = NoPermissionsBasicView.fromNib(bundle: .module)
        v.colorScheme = colorScheme
        return v
    }
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var fullAccessButton: GradientButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var fakeTableContainer: UIView!
    @IBOutlet weak var iphoneMockup: UIImageView!
    @IBOutlet weak var cardContainerView: UIView!
    
    var delegate: PermissionsPlaceholderViewDelegate?
    var colorScheme: ColorScheme?

    override func layoutSubviews() {
        super.layoutSubviews()
        configure()
    }
    
    func configure() {
        guard let colorScheme = colorScheme else {
            return
        }
        
        backgroundColor = colorScheme.background
        iphoneMockup.clipsToBounds = true
        iphoneMockup.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        iphoneMockup.roundCorners(to: .custom(43))
        cardContainerView.backgroundColor = colorScheme.foreground
        cardContainerView.clipsToBounds = true
        cardContainerView.roundCorners(to: .custom(14))
        
        fakeTableContainer.clipsToBounds = true
        fakeTableContainer.roundCorners(to: .custom(10))
        
        gradientView.backgroundColor = .clear
        let bgColor = cardContainerView.backgroundColor ?? .white
        gradientView.gradient = .init(direction: .vertical, colors: [bgColor.withAlphaComponent(0), bgColor, bgColor])
        
        titleLabel.textColor = colorScheme.title
        subtitleLabel.textColor = colorScheme.subtitle
        fullAccessButton.titleGradient = .solid(colorScheme.ctaForeground)
        fullAccessButton.backgroundGradient = colorScheme.gradient
        fullAccessButton.applyBounceAnimation(style: .medium)
        fullAccessButton.addBounce()
        
    }
    
    @IBAction func ctaTapped(_ sender: Any) {
        delegate?.permissionsPlaceholderViewDidRequestSettings(self)
    }

}
