//
//  File.swift
//  
//
//  Created by Roi on 12/08/2023.
//

import UIKit


public enum PickerSelectionStyle: Equatable {
    case selection(limit: Int, cellClass: PickerCell.Type = DefaultPickerCollectionViewCell.self)
    case addOnly(limit: Int, cellClass: PickerCell.Type = AddOnlyPickerCollectionViewCell.self)
    
    public var limit: Int {
        switch self {
        case .selection(let limit, _), .addOnly(let limit, _):
            return limit
        }
    }

    var cellClass: PickerCell.Type {
        switch self {
        case .selection(_, let cellClass), .addOnly(_, let cellClass):
            return cellClass
        }
    }
    
    public static func == (lhs: PickerSelectionStyle, rhs: PickerSelectionStyle) -> Bool {
         switch (lhs, rhs) {
         case (.selection(let lhsLimit, let lhsCellClass), .selection(let rhsLimit, let rhsCellClass)):
             return lhsLimit == rhsLimit && String(describing: lhsCellClass) == String(describing: rhsCellClass)
         case (.addOnly(let lhsLimit, let lhsCellClass), .addOnly(let rhsLimit, let rhsCellClass)):
             return lhsLimit == rhsLimit && String(describing: lhsCellClass) == String(describing: rhsCellClass)
         default:
             return false
         }
     }
}
