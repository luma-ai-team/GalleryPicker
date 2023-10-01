//
//  RotatableButton.swift
//  
//
//  Created by Roi Mulia on 03/12/2020.
//

import Foundation
import UIKit
import CoreUI

public class AlbumsRotatableButton: BounceButton {

    
    private let arrowView = UIImageView()

    public var isAlbumPresented = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.arrowView.transform = self.isAlbumPresented ?
                                                                 CGAffineTransform(rotationAngle: 180 * CGFloat(Double.pi / 180)) :
                                                                 .identity
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    
    private func setup() {
        contentHorizontalAlignment = .left
        addSubview(arrowView)
        arrowView.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    func updateAppearanceWithColorScheme(colorScheme: ColorScheme) {
        arrowView.tintColor = colorScheme.title
        setTitleColor(colorScheme.title, for: .normal)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let text = titleLabel?.text
        if text == nil {
            arrowView.alpha = 0
        }
        else {
            arrowView.alpha = 1
        }
        
        arrowView.sizeToFit()
        arrowView.center.y = bounds.height / 2 + 1
        arrowView.frame.origin.x = (titleLabel?.frame.maxX ?? 0) + 2
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var originalSize = super.sizeThatFits(size)
        
        arrowView.sizeToFit()
        originalSize.width += arrowView.bounds.width + 3.0
        return originalSize
    }
}
