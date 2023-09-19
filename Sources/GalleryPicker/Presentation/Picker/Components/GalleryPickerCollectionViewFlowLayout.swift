//
//  UICollectionViewFlowLayout+CellSize.swift
//  highlight
//
//  Created by Anton K on 20.02.2020.
//  Copyright © 2020 TrendyPixel. All rights reserved.
//

import UIKit

public class GalleryPickerCollectionViewFlowLayout: UICollectionViewFlowLayout {
    public var itemsInRow: Int = 3
    public var ratio: CGFloat = 1
    
    public override init() {
        super.init()
        sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 2
        minimumInteritemSpacing = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GalleryPickerCollectionViewFlowLayout  {

    public func cellSize(in collectionView: UICollectionView) -> CGSize {
        let minWidth = 320.0 / CGFloat(itemsInRow)
        let maxWidth = 520.0 / CGFloat(itemsInRow)

        let referenceCellWidth = minWidth + 0.5 * (maxWidth - minWidth)
        let collectionViewWidth = collectionView.bounds.width

        let numberOfColumns = round(collectionViewWidth / referenceCellWidth)
        let contentWidth: CGFloat = collectionViewWidth - (sectionInset.left + sectionInset.right)
        let width = floor((contentWidth - minimumInteritemSpacing * (numberOfColumns - 1)) / numberOfColumns)
        let height = width * (1 / ratio)
        return CGSize(width: width, height: height)
    }
}
