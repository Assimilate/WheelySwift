//
//  SettingsCell.swift
//  Wheely
//
//  Created by Student on 2020-04-06.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class SettingsCell: BaseCell {
    
    var settingsModel: SettingsModel? {
        didSet {
            nameLabel.text = settingsModel?.name
            nameLabel.font = UIFont.systemFont(ofSize: 13)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .darkGray : .white
            nameLabel.textColor = isHighlighted ? .white : .black
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Delete data"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addConstraintsWithFormat(format: "H:|-16-[v0]|", views: nameLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
    }
}
