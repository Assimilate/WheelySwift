//
//  ProfileController.swift
//  Wheely
//
//  Created by Student on 2020-04-14.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

protocol ProfileControllerDelegate: class {
    func hasSavedData(weight: Int, age: Int, wheelchairWeight: Int)
    func alert(field: String)
}

class ProfileController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, ProfileControllerDelegate {
    
    var database: Database?
    
    let profileCellId = "profileCellId"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        registerCells()
    }
    
    func registerCells() {
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellId)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellId, for: indexPath) as! ProfileCell
        cell.delegate = self
        cell.ageView.delegate = self
        cell.weightView.delegate = self
        cell.wheelchairWeightView.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as! NSString).replacingCharacters(in: range, with: string)
        
        if(text.count == 0) {return true}

        if Int(text) != nil {
            // Text field converted to an Int
            return true
        } else {
            return false
        }
    }
    
    func hasSavedData(weight: Int, age: Int, wheelchairWeight: Int) {
        
        
        let objects = database!.getAllData(entity: "Profile", type: "profile")
        if objects.count >= 1 {
            database!.deleteAllDataFromEntity(entity: "Profile")
            database!.saveData(age: age, weight: weight, wheelchairWeight: wheelchairWeight, date: Date(), entity: "Profile")
        } else {
            database!.saveData(age: age, weight: weight, wheelchairWeight: wheelchairWeight, date: Date(), entity: "Profile")
        }
        UserDefaults.standard.setProfile(value: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    func alert(field: String) {
        let alert = UIAlertController(title: "Oops!", message: field + " needs to be filled in.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
