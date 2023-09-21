//
//  Activate.swift
//  NewActivateScreen
//
//  Created by Roi Mulia on 11/11/2022.
//

import UIKit
import CoreUI

import UIKit

class EnablePermissionView: UIView {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Can't Access Photos"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enable All Photos access in Settings\nto edit your media."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ctaButton: ShimmerButton = {
        let button = ShimmerButton()
        button.setTitle("Open Settings", for: .normal)
        button.titleLabel?.font = UIFont.roundedFont(size: 20, weight: .semibold)
        button.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        button.setTitleColor(.link, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(ctaButton)
        
        ctaButton.addTarget(self, action: #selector(ctaButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            ctaButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            ctaButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: ctaButton.bottomAnchor, constant: 28),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    @objc func ctaButtonTapped() {
        Haptic.selection.generate()
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
    func applyColor(colorScheme: ColorScheme) {
        containerView.backgroundColor = colorScheme.foreground
        titleLabel.textColor = colorScheme.title
        subtitleLabel.textColor = colorScheme.subtitle
        ctaButton.backgroundGradient = colorScheme.gradient
        ctaButton.titleGradient = .solid(colorScheme.ctaForeground)
        
        containerView.clipsToBounds = true
        containerView.roundCorners(to: .custom(20))
    }
}
