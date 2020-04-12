//
//  EnergyFeedCell.swift
//  Wheely
//
//  Created by Student on 2020-04-05.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class EnergyFeedCell: FeedCell {
    
    
    let energyFeedCellIds = ["energyExpenditureId"]
    
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)
            
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)

        collectionView.register(PhysicsCell.self, forCellWithReuseIdentifier: energyFeedCellIds[0])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = self.energyFeedCellIds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! PhysicsCell
        cell.energy = physicsModels[indexPath.item]
        cell.homeController = homeController
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return physicsModels.count
    }
}
