//
//  File.swift
//  
//
//  Created by Roi Mulia on 03/12/2020.
//

import UIKit
import CoreUI

class DrawerTableVieWCell: UITableViewCell {
    
    static let identifier = "DrawerTableViewHeaderView"
    
    let drawerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        drawerView.translatesAutoresizingMaskIntoConstraints = false
        drawerView.backgroundColor = .red
        
        contentView.addSubview(drawerView)

        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
        NSLayoutConstraint.activate([
            drawerView.widthAnchor.constraint(equalToConstant: 36),
            drawerView.heightAnchor.constraint(equalToConstant: 5),
            drawerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            drawerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawerView.layer.roundCorners(to: .rounded)
        drawerView.layer.masksToBounds = true
        drawerView.clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        drawerView.layer.roundCorners(to: .rounded)
        drawerView.layer.masksToBounds = true
        drawerView.clipsToBounds = true
    }
}
