//
//  File.swift
//  
//
//  Created by Roi Mulia on 03/12/2020.
//

import UIKit
import CoreUI

class DrawerCell: UITableViewCell {
        
    let drawerImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(drawerImageView)
        drawerImageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .regular))
        drawerImageView.image = image
        drawerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -3).isActive = true
        drawerImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
