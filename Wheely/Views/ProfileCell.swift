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
        addSubview(wheelchairWeightTitle)
        addSubview(wheelchairWeightView)
        addSubview(saveButton)
        
        _ = weightTitle.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 100, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 25)
        
        _ = weightView.anchor(weightTitle.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
        _ = ageTitle.anchor(weightView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 18, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 25)
        
        _ = ageView.anchor(ageTitle.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
        _ = wheelchairWeightTitle.anchor(ageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 18, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 25)
        
        _ = wheelchairWeightView.anchor(wheelchairWeightTitle.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
        _ = saveButton.anchor(wheelchairWeightView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
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
    
    let wheelchairWeightTitle: UITextView = {
        let wheelchairWeightTitle = UITextView()
        wheelchairWeightTitle.text = "Wheelchair weight"
        wheelchairWeightTitle.isEditable = false
        wheelchairWeightTitle.textAlignment = .center
        return wheelchairWeightTitle
    }()
    
    let wheelchairWeightView: UITextField = {
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

        guard let weight = Int(weightView.text ?? "0") else {
            delegate?.alert(field: "weight")
            return
        }
        guard let age = Int(ageView.text ?? "0") else {
            delegate?.alert(field: "age")
            return
        }
        guard let wheelchairWeight = Int(wheelchairWeightView.text ?? "0") else {
            delegate?.alert(field: "wheelchairWeight")
            return
        }

        delegate?.hasSavedData(weight: weight, age: age, wheelchairWeight: wheelchairWeight)
    }
    
    
}
