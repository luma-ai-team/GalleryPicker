//
//  FilterCategoryPickerViewCell.swift
//
//  Created by Anton Kormakov on 15.11.2022.
//

import UIKit
import CoreUI

public class CategoryItem: AdaptiveCollectionViewItem {
    let category: MediaItemCategory
    let colorScheme: ColorScheme

    public var title: String {
        return category.title
    }

    public static func == (lhs: CategoryItem, rhs: CategoryItem) -> Bool {
        return lhs.category == rhs.category
    }

    init(category: MediaItemCategory, colorScheme: ColorScheme) {
        self.category = category
        self.colorScheme = colorScheme
    }
}

open class FilterCategoryPickerViewCell: AdaptiveSingleLabelCollectionViewCell, AdaptiveTitleCollectionViewCell {
    public typealias Item = CategoryItem

    public static var identifier: String = "FilterCategoryPickerViewCell"

    public var category: MediaItemCategory?

    public static func create() -> any AdaptiveTitleCollectionViewCell {
        return Self()
    }

    open override func commonInit() {
        labelHeight = 32
        labelPadding = 13
        super.commonInit()
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 28).isActive = true
        titleLabel.textAlignment = .center

    }

    public static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(FilterCategoryPickerViewCell.self, forCellWithReuseIdentifier: "FilterCategoryPickerViewCell")
    }

    open func configureCell(with item: Item, isSelected: Bool) {
        let colorScheme = item.colorScheme
        titleLabel.text = item.category.title
        titleLabel.font = UIFont.roundedFont(size: 16, weight: .medium)
        titleLabel.textColor =  isSelected ? colorScheme.ctaForeground : colorScheme.title
        gradientView.gradient = isSelected ? colorScheme.gradient : .solid(colorScheme.foreground)
        setNeedsLayout()
        layoutIfNeeded()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(to: .rounded)
        clipsToBounds = true
    }

}

