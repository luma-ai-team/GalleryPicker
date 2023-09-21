import UIKit
import CoreUI

open class PickerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties

    public var item: MediaItem?
    public var colorScheme: ColorScheme?

    // MARK: - Views
    public lazy var floatingElementsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var livePhotoBadgeImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "livephoto", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)))
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()

    public lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Label"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = .clear
        return label
    }()

    public lazy var favoriteBadgeImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)))
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()
    
    public lazy var selectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Label"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        label.clipsToBounds = true
        return label
    }()
    
    public let selectionView = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        backgroundColor = .clear
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        [imageView, floatingElementsContainer, selectionView, selectionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
            $0.isUserInteractionEnabled = false
        }
        
        [favoriteBadgeImageView, durationLabel, livePhotoBadgeImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            floatingElementsContainer.addSubview($0)
        }
        
        floatingElementsContainer.applyShadow(color: .black, radius: 10, opacity: 1, offsetY: 0, offsetX: 0)

        contentView.clipsToBounds = true
        clipsToBounds = true
        contentView.roundCorners(to: .custom(0))
    }

    private func setupConstraints() {
        floatingElementsContainer.bindMarginsToSuperview()
        selectionView.bindMarginsToSuperview()
        
        NSLayoutConstraint.activate([
            // ImageView
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // LivePhotoBadgeImageView
            livePhotoBadgeImageView.topAnchor.constraint(equalTo: floatingElementsContainer.topAnchor, constant: 5),
            livePhotoBadgeImageView.leadingAnchor.constraint(equalTo: floatingElementsContainer.leadingAnchor, constant: 5),
   
            // DurationLabel
            durationLabel.bottomAnchor.constraint(equalTo: floatingElementsContainer.bottomAnchor, constant: -5),
            durationLabel.trailingAnchor.constraint(equalTo: floatingElementsContainer.trailingAnchor, constant: -6),
            
            // FavoriteBadgeImageView
            favoriteBadgeImageView.bottomAnchor.constraint(equalTo: floatingElementsContainer.bottomAnchor, constant: -5),
            favoriteBadgeImageView.leadingAnchor.constraint(equalTo: floatingElementsContainer.leadingAnchor, constant: 5),
            
            // SelectionLabel
            selectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            selectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7)
        ])
        
        selectionLabel.widthAnchor.constraint(equalToConstant: 36).isActive = true
        selectionLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
       
    }

    // MARK: - Cell Lifecycle

    open override func layoutSubviews() {
        super.layoutSubviews()
        selectionLabel.roundCorners(to: .rounded)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    // MARK: - Configuration

    public func configure(with item: MediaItem, selectCount: Int, representativeIndex: Int? ,  shouldDisplayLivePhotoBage: Bool) {
        self.item = item
        imageView.image = item.thumbnail
        
        item.updateAssetMetadata()
        livePhotoBadgeImageView.alpha = item.type.isLivePhoto && shouldDisplayLivePhotoBage ? 1 : 0
        favoriteBadgeImageView.isHidden = item.isFavorite == false
        if let duration = item.duration, duration > 0 {
            durationLabel.text = duration.toReadableMinutesAndSecondsString()
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        
        selectionLabel.text = "\((representativeIndex ?? 0) + 1)"
        
        let isSelected = selectCount > 0
        selectionView.backgroundColor = colorScheme?.background.withAlphaComponent(0.4)
        selectionView.alpha = isSelected ? 1 : 0
        selectionLabel.alpha = selectionView.alpha
        
        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = colorScheme?.title.cgColor
        selectionLabel.textColor = colorScheme?.background
        selectionLabel.backgroundColor = colorScheme?.title
    }
    
    public func reloadThumbnail() {
        imageView.image = item?.thumbnail
    }
}

