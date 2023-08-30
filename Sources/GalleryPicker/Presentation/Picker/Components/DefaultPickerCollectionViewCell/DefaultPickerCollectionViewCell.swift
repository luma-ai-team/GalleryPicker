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
    public var gradientImage: UIImage?
    public var colorScheme: ColorScheme?

    // MARK: - Views

    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var livePhotoBadgeImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "livephoto", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)))
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var gradientView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Label"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public lazy var favoriteBadgeImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)))
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
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
        [imageView, gradientView, livePhotoBadgeImageView, durationLabel, favoriteBadgeImageView, selectionView].forEach { view in
            contentView.addSubview(view)
            view.isUserInteractionEnabled = false
        }

        contentView.clipsToBounds = true
        clipsToBounds = true
        // Assuming `roundCorners(to:)` is a function or extension you have defined elsewhere
        contentView.roundCorners(to: .custom(8))
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ImageView
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // LivePhotoBadgeImageView
            livePhotoBadgeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            livePhotoBadgeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
   
            // GradientView
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 43),
            
            // DurationLabel
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            
            // FavoriteBadgeImageView
            favoriteBadgeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            favoriteBadgeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
        ])

        selectionView.bindMarginsToSuperview()
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
            gradientView.isHidden = false
            gradientView.image = gradientImage
        } else {
            durationLabel.isHidden = true
            gradientView.isHidden = true
            gradientView.image = nil
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

