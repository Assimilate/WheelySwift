//
//  TermsCell.swift
//  Wheely
//
//  Created by Student on 2020-04-13.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class TermsCell: UICollectionViewCell {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchImage")
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.text = "This app is meant to be used in my thesis project."
        textView.isEditable = false
        textView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.textAlignment = .center
        return textView
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .orange
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: LoginControllerDelegate?
    
    @objc func handleAccept() {
        delegate?.acceptedTerms()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(logoImageView)
        addSubview(textView)
        addSubview(acceptButton)
        
        _ = logoImageView.anchor(centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: -200, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 160)
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = textView.anchor(logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 18, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
        _ = acceptButton.anchor(textView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
