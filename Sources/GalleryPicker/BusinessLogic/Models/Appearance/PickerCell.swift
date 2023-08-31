//
//  File.swift
//  
//
//  Created by Roi Mulia on 22/07/2020.
//

import UIKit
import CoreUI

public protocol PickerCell: UICollectionViewCell {
    static var identifier: String { get }
    var item: MediaItem? { get set }
    var imageView: UIImageView { get set }
    var colorScheme: ColorScheme? { get set }
    static func register(in collectionView: UICollectionView)
    func configure(with item: MediaItem, selectCount: Int, shouldDisplayLivePhotoBage: Bool)
    func reloadThumbnail()
}
