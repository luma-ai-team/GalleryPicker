//
//  File.swift
//  
//
//  Created by Roi Mulia on 24/12/2020.
//

import UIKit
import CoreUI

class GallerySharedResources {
    
    static var shared = GallerySharedResources()
    
    private init() {}
    
    var cellGradientImage: UIImage?

    func configureCellGradient(for size: CGSize) {
        
        guard cellGradientImage == nil else {
            return
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.preferredRange = .standard
        format.scale = UIScreen.main.scale
        let gradient = Gradient(
            direction: .vertical,
            colors: [
                UIColor.black.withAlphaComponent(0.3),
                UIColor.black.withAlphaComponent(0)].reversed()
        )
        
        let gradientView = GradientView(gradient: gradient)
        gradientView.frame.size = size
        gradientView.layoutSubviews()
        
        let renderer = UIGraphicsImageRenderer(bounds: gradientView.bounds, format: format)
        let image = renderer.image { (context) in
            let cgContext = context.cgContext
            gradientView.layer.render(in: cgContext)
        }
        cellGradientImage = image
    }
    
}






