//
//  Created by Roi Mulia on 08/08/2019.
//  Copyright © 2019 Craftiz. All rights reserved.
//

import UIKit
import CoreUI

class AlbumCell: UITableViewCell {
    
    var album: Album?

    
    let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let albumNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    let AlbumAssetsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        contentView.addSubview(albumImageView)
        
        let stackView = UIStackView(arrangedSubviews: [albumNameLabel, AlbumAssetsCountLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            albumImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            albumImageView.widthAnchor.constraint(equalTo: albumImageView.heightAnchor),
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            stackView.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 12),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with album: Album, colorScheme: ColorScheme) {
        self.album = album
        albumImageView.image = album.thumbnail
        albumNameLabel.text = album.title
        AlbumAssetsCountLabel.text = "\(album.estimatedAssetCount)"
        albumNameLabel.textColor = colorScheme.title
        AlbumAssetsCountLabel.textColor = colorScheme.subtitle
        albumImageView.backgroundColor = colorScheme.background
        contentView.backgroundColor = colorScheme.foreground
        albumImageView.clipsToBounds = true
        albumImageView.roundCorners(to: .custom(10))
    }
}
