import UIKit


class PixabayLoadingView: UIView {

    // MARK: - Properties

    private var stackView: UIStackView!
    private var loadingIndicator: UIActivityIndicatorView!
    private var label: UILabel!

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Initialize loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.startAnimating()

        // Initialize label
        label = UILabel()
        label.textAlignment = .center

        // Initialize stack view
        stackView = UIStackView(arrangedSubviews: [loadingIndicator, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    // MARK: - Set Tint Color

    func setTintColor(_ color: UIColor) {
        loadingIndicator.color = color
        label.textColor = color
    }
    
    func showOnlyLoading() {
        if label.isHidden == false {
            label.isHidden = true
        }
        stackView.layoutIfNeeded()
    }
    
    func setError(string: String) {
        if label.isHidden {
            label.isHidden = false
        }
        
        if loadingIndicator.isHidden == false {
            loadingIndicator.isHidden = true
        }
        
        label.text = string
        stackView.layoutIfNeeded()
    }
}
