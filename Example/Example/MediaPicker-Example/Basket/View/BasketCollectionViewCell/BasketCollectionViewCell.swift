//
//  BasketCollectionViewCell.swift
//  SuperPicker
//
//  Created by Roi Mulia on 12/12/2019.
//  Copyright © 2019 Craftiz. All rights reserved.
//

import UIKit
import CoreUI


protocol BasketCollectionViewCellDelegate: AnyObject {
    func basketCollectionViewCell(_ basketCollectionViewCell: BasketCollectionViewCell, wantsDeleteWithSlot slot: Slot)
}

class BasketCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: BasketCollectionViewCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deleteButton: BounceButton!
    
    @IBOutlet weak var selectionView: UIView!
    var slot: Slot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        imageView.roundCorners(to: .custom(8))
        imageView.backgroundColor = .green
        selectionView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        selectionView.clipsToBounds = true
        selectionView.roundCorners(to: .custom(8))
        deleteButton.tintColor = Constants.colorScheme.title.withAlphaComponent(0.6)
        backgroundColor = .brown
    }
    
    
    @IBAction func deleteTapped(_ sender: Any) {
        
        guard let slot = slot else {
            return
        }
        Haptic.selection.generate()
        delegate?.basketCollectionViewCell(self, wantsDeleteWithSlot: slot)
    }
    
}
