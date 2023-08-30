//
//  s.swift
//  Pixabay
//
//  Created by Roi on 06/08/2023.
//

import UIKit
import CoreUI


protocol SearchViewDelegate: AnyObject {
    func searchTapped(withText text: String)
    func clearTapped()
    func contentTypeChanged(to contentType: PixabaySearchType)
}


class PixabaySearchView: UIView {

    let textField = UITextField()
    let stackView = UIStackView()
    var buttonsStackView = UIStackView()
    let textFieldContainer = UIView()

    var selectedSearchType: PixabaySearchType? {
        didSet {
            updateButtonStates()
        }
    }
    
    weak var delegate: SearchViewDelegate?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // TextField setup
        textField.backgroundColor = .clear
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search

        let magnifierImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        magnifierImageView.tintColor = .white
        magnifierImageView.contentMode = .left
        magnifierImageView.translatesAutoresizingMaskIntoConstraints = false
        magnifierImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        textField.leftView = magnifierImageView
        textField.leftViewMode = .always

        textFieldContainer.backgroundColor = .orange
        textFieldContainer.addSubview(textField)
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        textField.bindMarginsToSuperview(insets: .init(top: 8, left: 8, bottom: -8, right: -8))
        textField.placeholder = "Search Pixabay"
        
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldSearchTapped), for: .editingDidEndOnExit)

        stackView.addArrangedSubview(textFieldContainer)

        // ButtonsStackView setup
        buttonsStackView.distribution = .fill
        buttonsStackView.alignment = .fill
        buttonsStackView.spacing = 0

        selectedSearchType = PixabaySearchType.allCases.first
        
        for type in PixabaySearchType.allCases {
            let action = UIAction(image: type.image, handler: { [weak self] action in
                self?.selectedSearchType = type
                self?.delegate?.contentTypeChanged(to: type)
                Haptic.selection.generate()
                
            })
            let button = BounceButton(primaryAction: action)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = Constants.colorScheme.title
            button.alpha = type == PixabaySearchType.allCases.first ? 1 : 0.42
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
            buttonsStackView.addArrangedSubview(button)
        }

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        buttonsStackView.insertArrangedSubview(separator, at: 1)

        stackView.addArrangedSubview(buttonsStackView)

        // Main StackView setup
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        stackView.bindMarginsToSuperview(insets: .init(top: 5, left: 16, bottom: -8, right: -16))
        
        
        backgroundColor = Constants.colorScheme.background
        
        for v in [buttonsStackView, textFieldContainer] {
            v.clipsToBounds = true
            v.roundCorners(to: .custom(10))
            v.backgroundColor = Constants.colorScheme.foreground
        }
        separator.backgroundColor = Constants.colorScheme.background
        textField.textColor = Constants.colorScheme.title
        let elementColors = Constants.colorScheme.title.withAlphaComponent(0.4)
        textField.attributedPlaceholder =
        NSAttributedString(string: "Search Pixabay", attributes: [NSAttributedString.Key.foregroundColor : elementColors])
        textField.tintColor = elementColors
        magnifierImageView.tintColor = elementColors
        
        if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = elementColors  // Change this to your desired tint color
        }
    }


    @objc func textFieldEditingChanged() {
           // Check if the textField is empty
           if textField.text?.isEmpty == true {
               delegate?.clearTapped()
           }
       }
       
    @objc func textFieldSearchTapped() {
        if let text = textField.text, !text.isEmpty {
            delegate?.searchTapped(withText: text)
            Haptic.selection.generate()
        }
    }
    
    
    private func updateButtonStates() {
        for view in buttonsStackView.arrangedSubviews {
            // Assuming every alternate view is a button, due to the separators
            if let button = view as? BounceButton {
                if selectedSearchType?.image == button.currentImage {
                    button.alpha = 1
                } else {
                    button.alpha = 0.5
                }
            }
        }
    }
    
    
}
