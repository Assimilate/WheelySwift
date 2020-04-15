//
//  PageCell.swift
//  Wheely
//
//  Created by Student on 2020-04-13.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var page: PageModel? {
        didSet {
            guard let page = page else {
                return
            }
            
            let color = UIColor(white: 0.2, alpha: 1)
            
            imageView.image = UIImage(named: page.imageName)
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium), NSAttributedString.Key.foregroundColor: color])
            
            attributedText.append(NSAttributedString(string: "\n\n\(page.message)",attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: color]))
            
            let length = attributedText.string.count
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))
            
            textView.attributedText = attributedText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.image = UIImage(named: "launchImage") 
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Sample text"
        textView.isEditable = false
        textView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        return textView
    }()
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return view
    }()
    
    func setupViews() {
        backgroundColor = .white
        
        addSubview(imageView)
        addSubview(textView)
        addSubview(lineSeparatorView)
   
        textView.anchorWithConstantsToTop(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 16)
        
        textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        
        imageView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: textView.topAnchor, right: rightAnchor, topConstant: 50, leftConstant: 50, bottomConstant: 50, rightConstant: 50)
        
        lineSeparatorView.anchorToTop(nil, left: leftAnchor, bottom: textView.topAnchor, right: rightAnchor)
        lineSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
