//
//  GraphFeedCell.swift
//  Wheely
//
//  Created by Student on 2020-04-05.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class GraphFeedCell: FeedCell {
    
    let graphFeedCellIds = ["tacxId", "gpsVelocityId", "gpsAltitudeId", "accelerometerId", "pushRateId", "heartRateId"]
    
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)

        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        collectionView.register(SensorCell.self, forCellWithReuseIdentifier: graphFeedCellIds[0])
        collectionView.register(SensorCell.self, forCellWithReuseIdentifier: graphFeedCellIds[1])
        collectionView.register(SensorCell.self, forCellWithReuseIdentifier: graphFeedCellIds[2])
        collectionView.register(SensorCell.self, forCellWithReuseIdentifier: graphFeedCellIds[3])
        collectionView.register(SensorCell.self, forCellWithReuseIdentifier: graphFeedCellIds[4])
        collectionView.register(SensorCell.self, forCellWithReuseIdentifier: graphFeedCellIds[5])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Updating sensor feed cell")
        let id = graphFeedCellIds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! SensorCell
        cell.sensor = sensorModels[indexPath.item]
        cell.homeController = homeController
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sensorModels.count
    }
    
}
