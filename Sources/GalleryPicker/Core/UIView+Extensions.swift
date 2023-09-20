//
//  File.swift
//  
//
//  Created by OZ on 9/20/23.
//

import UIKit

extension UIView {
    func bounceAnimation(duration: TimeInterval = 0.2, scale: CGFloat = 0.95) {
        // Scale up
        UIView.animate(withDuration: duration / 2, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            // Scale down
            UIView.animate(withDuration: duration / 2, animations: {
                self.transform = CGAffineTransform.identity
            })
        })
    }
}
