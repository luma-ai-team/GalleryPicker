//
//  Created by Roi Mulia on 08/08/2019.
//  Copyright © 2019 Craftiz. All rights reserved.
//

import UIKit
import CoreUI

open class AddOnlyPickerCollectionViewCell: DefaultPickerCollectionViewCell {
    
    public class override var identifier: String { "AddOnlyPickerCollectionViewCell"
    }

    var countLabel = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.isUserInteractionEnabled = false
        countLabel.backgroundColor = .red
        countLabel.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        countLabel.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        countLabel.setTitleColor(.white, for: .normal)
        countLabel.contentEdgeInsets = .init(top: 3, left: 4, bottom: 3, right: 4)
        countLabel.clipsToBounds = true
        countLabel.roundCorners(to: .custom(2))
        countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6).isActive = true
        countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override class func register(in collectionView: UICollectionView) {
        collectionView.register(AddOnlyPickerCollectionViewCell.self, forCellWithReuseIdentifier: Self.identifier)
    }
    
    
    public override func configure(with item: MediaItem, selectCount: Int, representativeIndex: Int? , shouldDisplayLivePhotoBage: Bool) {
        super.configure(with: item, selectCount: selectCount, representativeIndex: representativeIndex, shouldDisplayLivePhotoBage: shouldDisplayLivePhotoBage)
        
        countLabel.setTitle("\(selectCount)x", for: .normal)
        
        countLabel.alpha = selectCount > 0 ? 1 : 0
        // reset top propperties
        contentView.layer.borderWidth = 0
        selectionView.alpha = 0
    }

}
