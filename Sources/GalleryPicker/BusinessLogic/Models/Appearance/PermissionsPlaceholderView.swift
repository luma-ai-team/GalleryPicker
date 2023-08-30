//
//  PermissionsPlaceholderView.swift
//  
//
//  Created by Anton K on 24.11.2020.
//

import UIKit

public protocol PermissionsPlaceholderViewDelegate: AnyObject {
    func permissionsPlaceholderViewDidRequestActivate(_ sender: PermissionsPlaceholderView)
    func permissionsPlaceholderViewDidRequestSettings(_ sender: PermissionsPlaceholderView)
}

public protocol PermissionsPlaceholderView: UIView {
    var delegate: PermissionsPlaceholderViewDelegate? { get set }
}
