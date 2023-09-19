//
//  Activate.swift
//  NewActivateScreen
//
//  Created by Roi Mulia on 11/11/2022.
//

import UIKit
import CoreUI

class NoPermissionsView: UIView, PermissionsPlaceholderView {
    
    static func create(with colorScheme: ColorScheme) -> NoPermissionsView {
        let v: NoPermissionsView = NoPermissionsView.fromNib(bundle: .module)
        v.colorScheme = colorScheme
        return v
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ctaButton: ShimmerButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
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
        containerView.clipsToBounds = true
        
        containerView.roundCorners(to: .custom(20))
        containerView.backgroundColor = colorScheme.foreground
        
        titleLabel.textColor = colorScheme.title
        subtitleLabel.textColor = colorScheme.subtitle
        ctaButton.titleGradient = .solid(colorScheme.ctaForeground)
        ctaButton.backgroundGradient = colorScheme.gradient        
    }
    
    @IBAction func ctaTapped(_ sender: Any) {
        delegate?.permissionsPlaceholderViewDidRequestSettings(self)
    }

}
