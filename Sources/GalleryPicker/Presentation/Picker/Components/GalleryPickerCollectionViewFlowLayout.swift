//
//  UICollectionViewFlowLayout+CellSize.swift
//  highlight
//
//  Created by Anton K on 20.02.2020.
//  Copyright © 2020 TrendyPixel. All rights reserved.
//

import UIKit

public class GalleryPickerFlowLayout: UICollectionViewFlowLayout {
    public var itemsPerRow: Int = 3
    public var aspectRatio: CGFloat = 1
    
    public override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 2
        minimumInteritemSpacing = 2
    }
}

extension GalleryPickerFlowLayout {
    public func getCellSize(for collectionView: UICollectionView) -> CGSize {
        let minWidth = 320.0 / CGFloat(itemsPerRow)
        let maxWidth = 520.0 / CGFloat(itemsPerRow)
        
        let referenceCellWidth = minWidth + 0.5 * (maxWidth - minWidth)
        let contentWidth = collectionView.bounds.width - (sectionInset.left + sectionInset.right)

        let collectionViewWidth = collectionView.bounds.width

        let numberOfColumns = round(collectionViewWidth / referenceCellWidth)
        let width = ((contentWidth - minimumInteritemSpacing * (numberOfColumns - 1)) / numberOfColumns)
        let height = width * (1 / aspectRatio)
        return CGSize(width: width, height: height)
    }
}
