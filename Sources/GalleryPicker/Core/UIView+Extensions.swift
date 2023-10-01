//
//  File.swift
//  
//
//  Created by OZ on 9/20/23.
//

import UIKit

public extension UICollectionViewCell {
    func bounceCellAnimation(duration: TimeInterval = 0.2, scale: CGFloat = 0.94) {
        // Scale up
        UIView.animate(withDuration: duration / 2,
                       delay: 0,
                       options: [.allowUserInteraction],
                       animations: {
                        self.transform = CGAffineTransform(scaleX: scale, y: scale)
                       },
                       completion: { _ in
                        // Scale down
                        UIView.animate(withDuration: duration / 2,
                                       delay: 0,
                                       options: [.allowUserInteraction],
                                       animations: {
                                        self.transform = CGAffineTransform.identity
                                       },
                                       completion: nil)
                       })
    }
}
