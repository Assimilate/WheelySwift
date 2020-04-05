//
//  FeedCell.swift
//  Wheely
//
//  Created by Student on 2020-04-05.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class FeedCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Sensor objects.
    
    var sensorModels: [SensorModel]?
    var physicsModels: [PhysicsModel]?
    
    var sensorModelsDictionary = [String: SensorModel]()
    
    var type = "None"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    let cellId = "cellId"
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        sensorModels = [SensorModel]()
        physicsModels = [PhysicsModel]()
        
        if(type == "Sensor") {
            let sensorModel1 = SensorModel()
            var key = ""
            sensorModel1.title = "Tacx - Sensor"
            sensorModel1.type = "Tacx"
            //sensorModel.graphView?.data = data
            //sensorModel.graphView?.chartDescription?.text = "Tacx"
            key = "Tacx"
            sensorModelsDictionary[key] = sensorModel1
            sensorModels?.append(sensorModel1)
            
            let sensorModel2 = SensorModel()
            sensorModel2.title = "GPS - Sensor"
            sensorModel2.type = "GPS"
            //sensorModel.graphView?.data = data
            //sensorModel.graphView?.chartDescription?.text = "Tacx"
            key = "GPS"
            sensorModelsDictionary[key] = sensorModel2
            sensorModels?.append(sensorModel2)
            
            let sensorModel3 = SensorModel()
            sensorModel3.title = "Accelerometer - Sensor"
            sensorModel3.type = "Accelerometer"
            //sensorModel.graphView?.data = data
            //sensorModel.graphView?.chartDescription?.text = "Tacx"
            key = "Accelerometer"
            sensorModelsDictionary[key] = sensorModel3
            sensorModels?.append(sensorModel3)
            
            let sensorModel4 = SensorModel()
            sensorModel4.title = "HeartRate - Sensor"
            sensorModel4.type = "HeartRate"
            //sensorModel.graphView?.data = data
            //sensorModel.graphView?.chartDescription?.text = "Tacx"
            key = "HeartRate"
            sensorModelsDictionary[key] = sensorModel4
            sensorModels?.append(sensorModel4)
            
            collectionView.register(SensorCell.self, forCellWithReuseIdentifier: cellId)
        } else if (type == "Energy") {

            let physicsModel = PhysicsModel()
            physicsModel.title = "Energy Expenditure"
            physicsModels?.append(physicsModel)
            collectionView.register(PhysicsCell.self, forCellWithReuseIdentifier: cellId)
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.type == "Sensor") {
            return sensorModels?.count ?? 0
        } else if(self.type == "Energy") {
            return physicsModels?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        if(self.type == "Sensor") {
            let cellSensor = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! SensorCell
            cellSensor.sensor = sensorModels?[indexPath.item]
            return cellSensor
        } else if(self.type == "Energy") {
            let physicsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PhysicsCell
            physicsCell.energy = physicsModels?[indexPath.item]
            return physicsCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: frame.height - 50 + 40)
    }
    
    
    
}
