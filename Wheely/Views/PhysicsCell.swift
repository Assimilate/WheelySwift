//
//  PhysicsCell.swift
//  Wheely
//
//  Created by Student on 2020-04-05.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class PhysicsCell: BaseCell {
    
    var energy: PhysicsModel? {
        didSet {
            valueLabel.text = energy?.distance?.string
            descriptionLabel.text = energy?.title
            self.reloadInputViews()
        }
    }
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray6
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray6
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(valueLabel)
        addSubview(descriptionLabel)
        addSubview(separatorView)
        
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: valueLabel)
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: descriptionLabel)
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
        
        addConstraintsWithFormat(format: "V:|-16-[v0]-[v1(==v0)]-[v2(1)]|", views: descriptionLabel, valueLabel, separatorView)
        
        
    }
}
