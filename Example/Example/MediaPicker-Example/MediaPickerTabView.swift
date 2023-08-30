//
//  CustomSegmentView.swift
//  CustomSegment
//
//  Created by Roi Mulia on 11/12/2019.
//  Copyright © 2019 Craftiz. All rights reserved.
//

import UIKit
import CoreUI
import GalleryPicker


protocol MediaPickerTabViewDelegate: AnyObject {
    func mediaPickerTabView(_ view: MediaPickerTabView, isFocusingOnType type: MediaPickerTabView.MediaPickerTabButtonType)
    
    func mediaPickerTabView(_ view: MediaPickerTabView, isSelectingType type: MediaPickerTabView.MediaPickerTabButtonType)

}

class MediaPickerTabView: UIView {
    
    enum MediaPickerTabButtonType: Int {
        case gallery = 0
        case stock = 1
    }

    var focusedType = MediaPickerTabButtonType.gallery {
        didSet {
            updateButtonAppearance()
        }
    }
    
    let selectedColor = Constants.colorScheme.title
    var notSelectedColor: UIColor {
        selectedColor.withAlphaComponent(0.5)
    }

    
    weak var delegate: MediaPickerTabViewDelegate?
    
    // Create a gallery button with action
    lazy var galleryButton: AlbumsRotatableButton = {
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            if self.focusedType == .gallery {
                self.delegate?.mediaPickerTabView(self, isSelectingType: .gallery)
            } else {
                Haptic.selection.generate()
            }
            self.delegate?.mediaPickerTabView(self, isFocusingOnType: .gallery)
        }
        let button = AlbumsRotatableButton(type: .custom, primaryAction: action)
        button.titleLabel?.textAlignment = .center
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    // Create a stock button with action
    lazy var stockButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.mediaPickerTabView(self, isFocusingOnType: .stock)
            Haptic.selection.generate()

        }
        let button = BounceButton(type: .custom, primaryAction: action)
        button.adjustsImageWhenHighlighted = false
        button.setTitle("Stock", for: .normal)
        return button
    }()
    
    
    
    // Create a stack view to hold the buttons
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    let indicatorView = UIView()
    var progress: CGFloat = 0
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup the view with stack view and buttons
    private func setupView() {
        // Add buttons to the stack view
        buttonStackView.addArrangedSubview(galleryButton)
        buttonStackView.addArrangedSubview(stockButton)
        
        // Add stack view to the view
        addSubview(buttonStackView)
        
        buttonStackView.bindMarginsToSuperview()
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = notSelectedColor
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        addSubview(indicatorView)
        indicatorView.backgroundColor = selectedColor
        
        for btn in [galleryButton, stockButton] {
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorView.bounds.size = .init(width: bounds.width / 2, height: 2)
        indicatorView.frame.origin.y = buttonStackView.frame.maxY - indicatorView.bounds.height
        
        indicatorView.frame.origin.x = progress * (buttonStackView.bounds.width - indicatorView.bounds.width)
        
        focusedType = progress >= 0.5 ? .stock : .gallery
    }
    
    private func updateButtonAppearance() {
     
        let gallerySelectedColor: UIColor = focusedType == .gallery ? selectedColor : notSelectedColor
        let stockSelectedColor: UIColor = focusedType == .stock ? selectedColor : notSelectedColor
        galleryButton.tintColor = gallerySelectedColor
        galleryButton.setTitleColor(gallerySelectedColor, for: .normal)
        stockButton.tintColor = stockSelectedColor
        stockButton.setTitleColor(stockSelectedColor, for: .normal)
    }
    
}


