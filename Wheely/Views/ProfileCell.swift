//
//  ProfileCell.swift
//  Wheely
//
//  Created by Student on 2020-04-14.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    var profile: ProfileModel? {
        didSet {
            guard let profile = profile else {
                return
            }
            
            weightView.text = profile.weight
            ageView.text = profile.age
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(weightTitle)
        addSubview(weightView)
        addSubview(ageTitle)
        addSubview(ageView)
        addSubview(saveButton)
        
        _ = weightTitle.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 100, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 25)
        
        _ = weightView.anchor(weightTitle.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
        _ = ageTitle.anchor(weightView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 18, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 25)
        
        _ = ageView.anchor(ageTitle.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
        _ = saveButton.anchor(ageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let weightTitle: UITextView = {
        let weightTitle = UITextView()
        weightTitle.text = "Weight/kg"
        weightTitle.isEditable = false
        weightTitle.textAlignment = .center
        return weightTitle
    }()
    
    let weightView: UITextField = {
        let textField = UITextField()
        textField.text = ""
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.textAlignment = .center
        return textField
    }()
    
    let ageTitle: UITextView = {
        let ageTitle = UITextView()
        ageTitle.text = "Age"
        ageTitle.isEditable = false
        ageTitle.textAlignment = .center
        return ageTitle
    }()
    
    let ageView: UITextField = {
        let textField = UITextField()
        textField.text = ""
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.textAlignment = .center
        return textField
    }()
    
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .orange
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: ProfileControllerDelegate?
    
    @objc func handleSave() {
        print("Handling save...")
        guard let weight = Int(weightView.text ?? "0") else {
            delegate?.alert(field: "weight")
            return
        }
        guard let age = Int(ageView.text ?? "0") else {
            delegate?.alert(field: "age")
            return
        }
        print("Returns handled")
        delegate?.hasSavedData(weight: weight, age: age)
    }
    
    
}
