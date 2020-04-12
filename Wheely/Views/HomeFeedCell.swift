//
//  HomeFeedCell.swift
//  Wheely
//
//  Created by Student on 2020-04-05.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class HomeFeedCell: FeedCell {
    
    let homeFeedCellIds = ["startAndStopCell"]
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: homeFeedCellIds[0])
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let id = homeFeedCellIds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! HomeCell
        cell.home = homeModels[indexPath.item]
        cell.homeController = homeController

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeModels.count
    }
}
