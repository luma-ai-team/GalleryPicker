import UIKit

protocol PickerSelectionDelegate: AnyObject {
    func didSelectClassicGalleryPicker()
    func didSelectPixabayGalleryPicker()
}


class PickerSelectionViewController: UIViewController {
    
    weak var delegate: PickerSelectionDelegate?
    
    private lazy var classicButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Classic Gallery Picker", for: .normal)
        button.addTarget(self, action: #selector(handleClassicButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var pixabayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pixabay Gallery Picker", for: .normal)
        button.addTarget(self, action: #selector(handlePixabayButtonTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        DispatchQueue.main.async {
            //self.delegate?.didSelectClassicGalleryPicker()
            //self.delegate?.didSelectPixabayGalleryPicker()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        // StackView to arrange buttons vertically
        let stackView = UIStackView(arrangedSubviews: [classicButton, pixabayButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // Center the stack view in the middle of the view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func handleClassicButtonTap() {
        delegate?.didSelectClassicGalleryPicker()
    }
    
    @objc private func handlePixabayButtonTap() {
        delegate?.didSelectPixabayGalleryPicker()
    }
}
