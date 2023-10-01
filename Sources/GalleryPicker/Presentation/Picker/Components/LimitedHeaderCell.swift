//
//  LimitedAccessCollectionReusableView.swift
//  Example
//
//  Created by Roi Mulia on 02/12/2020.
//  Copyright © 2020 socialkit. All rights reserved.
//

import UIKit
import CoreUI


class LimitedHeaderCell: UICollectionReusableView {
        
    lazy var button: ShimmerButton = {
        let btn = ShimmerButton()
        btn.bounceStyle = .soft
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Allow Access to All Photos →", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        btn.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.systemGreen
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    @objc func buttonTapped() {
        Haptic.selection.generate()
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
    func applyColor(colorScheme: ColorScheme) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .clear
        button.tintColor = colorScheme.ctaForeground
        
        button.backgroundGradient = colorScheme.gradient
        button.titleGradient = .solid(colorScheme.ctaForeground)
    
    }
    
}
