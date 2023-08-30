//
//  Created by Roi Mulia on 08/08/2019.
//  Copyright © 2019 Craftiz. All rights reserved.
//

import UIKit
import CoreUI

final class AlbumsTableViewCell: UITableViewCell {
   
    
    static var identifier: String = "AlbumsTableViewCell"

    var album: Album?

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    func configure(with album: Album, and appearance: AlbumsAppearance) {
        self.album = album
        let colorScheme = appearance.colorScheme
        thumbnailImageView.image = album.thumbnail
        titleLabel.text = album.title
        countLabel.text = "\(album.estimatedAssetCount)"
        titleLabel.font = UIFont.roundedFont(size: 17, weight: .semibold)
        titleLabel.textColor = colorScheme.title
        countLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        countLabel.textColor = colorScheme.subtitle
        thumbnailImageView.roundCorners(to: .custom(10))
    }
}
