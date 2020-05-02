//
//  DateFeedCell.swift
//  Wheely
//
//  Created by Student on 2020-04-10.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class DateFeedCell: FeedCell {
    
    let dateFeedCellIds = ["dateFeedCellId"]
    
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: dateFeedCellIds[0])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let id = self.dateFeedCellIds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! DateCell
        cell.date = self.dateModels[indexPath.item]
        cell.homeController = homeController
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateModels.count
    }
    
}
