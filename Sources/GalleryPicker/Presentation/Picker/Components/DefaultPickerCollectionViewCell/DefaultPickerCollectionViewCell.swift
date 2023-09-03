import UIKit
import CoreUI

open class DefaultPickerCollectionViewCell: HighlightedCollectionViewCell, PickerCell {
    
    // MARK: - Static Properties

    public class var identifier: String {
        return "DefaultPickerCollectionViewCell"
    }

    public class func register(in collectionView: UICollectionView) {
        collectionView.register(DefaultPickerCollectionViewCell.self, forCellWithReuseIdentifier: Self.identifier)
    }

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
        [imageView, floatingElementsContainer, selectionView].forEach {
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
        contentView.roundCorners(to: .custom(8))
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
            livePhotoBadgeImageView.trailingAnchor.constraint(equalTo: floatingElementsContainer.trailingAnchor, constant: -5),
   
            // DurationLabel
            durationLabel.bottomAnchor.constraint(equalTo: floatingElementsContainer.bottomAnchor, constant: -5),
            durationLabel.trailingAnchor.constraint(equalTo: floatingElementsContainer.trailingAnchor, constant: -6),
            
            // FavoriteBadgeImageView
            favoriteBadgeImageView.bottomAnchor.constraint(equalTo: floatingElementsContainer.bottomAnchor, constant: -5),
            favoriteBadgeImageView.leadingAnchor.constraint(equalTo: floatingElementsContainer.leadingAnchor, constant: 5)
        ])

       
    }

    // MARK: - Cell Lifecycle

    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    // MARK: - Configuration

    public func configure(with item: MediaItem, selectCount: Int, shouldDisplayLivePhotoBage: Bool) {
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
        
        let isSelected = selectCount > 0
        selectionView.backgroundColor = colorScheme?.title.withAlphaComponent(0.3)
        selectionView.alpha = isSelected ? 1 : 0
        
        contentView.layer.borderWidth = isSelected ? 2.5 : 0
        contentView.layer.borderColor = colorScheme?.title.cgColor
    }
    
    public func reloadThumbnail() {
        imageView.image = item?.thumbnail
    }
}

