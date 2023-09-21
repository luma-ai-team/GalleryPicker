//
//  Example
//
//  Created by Roi Mulia on 02/12/2020.
//  Copyright © 2020 socialkit. All rights reserved.
//

import UIKit
import CoreUI


protocol SearchScopeCollectionHeaderCellOutput: AnyObject {
    func searchScopeCollectionHeaderCell(_ searchScopeCollectionHeaderCell: SearchScopeCollectionHeaderCell, didSelect category: MediaItemCategory)
}

class SearchScopeCollectionHeaderCell: UICollectionReusableView {

    @IBOutlet weak var collectionContainer: UIView!
    
    static var identifier: String = "SearchScopeCollectionHeaderCell"
    
    weak var output: SearchScopeCollectionHeaderCellOutput?
    
    lazy var categoryPickerCollectionView: AdaptiveTitleCollectionView<FilterCategoryPickerViewCell> = {
        let view = AdaptiveTitleCollectionView<FilterCategoryPickerViewCell>.init(
            items: [],
            layout: AdaptiveCollectionViewFlowLayout(spacing: 8, sectionInset: .init(top: 0, left: 12, bottom: 0, right: 12)))
        
        view.backgroundColor = .clear
        view.didTap = { [weak self] indexPath, item in
            guard let self = self else { return }
            self.output?.searchScopeCollectionHeaderCell(self, didSelect: item.category)
        }
        
        return view
    }()

   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        collectionContainer.addSubview(categoryPickerCollectionView)
        categoryPickerCollectionView.bindMarginsToSuperview()
    }
}
