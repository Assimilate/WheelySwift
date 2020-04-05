//
//  ViewController.swift
//  Wheely
//
//  Created by Student on 2020-03-24.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit
import WatchConnectivity
import HealthKit
import CoreData
import Charts


class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    //-> IB related variables and functions relating to UI components.
    
    // Buttons.
    
    
    // Labels.
    
    
    // Charts.
    
    // Collection view variables.
    
    let cellId = "cellId"
    
    var cellsDictionary = [String: FeedCell]()
    
    //<-- End of IB related variables and functions.
    
    // Declaring the model class variables.
    
    var gpsModule: GPSModule? = nil
    var accelerometerModule: AccelerometerModule? = nil
    var tacxModule: TacxModule? = nil
    var heartRateModule: HeartRateModule? = nil

    
    // Declaring the database class variable.
    var database: Database? = nil
    
    var feedTypes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialization of view window characteristics.
        navigationItem.title = "Home"
        
        navigationController?.navigationBar.isTranslucent = false
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-32, height: view.frame.height))
        titleLabel.text = "Home"
        titleLabel.textColor = .white
        navigationItem.titleView = titleLabel
        setupCollectionView()
        setupMenuBar()
        setupNavBarButtons()
        
        // Initialize the classes.
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        database = Database(appDelegate: appDelegate)
        tacxModule = TacxModule(viewController: self, database: database!)
        gpsModule = GPSModule(viewController: self, database: database!)
        accelerometerModule = AccelerometerModule(viewController: self, database: database!)
        heartRateModule = HeartRateModule(viewController: self, database: database!)
        
    }
    
    // UI related functions.
    
    lazy var menuBar: MenuBar = {
        let menuBar = MenuBar()
        menuBar.homeController = self
        return menuBar
    }()
    private func setupMenuBar() {
        view.addSubview(menuBar)
        menuBar.addConstraintsWithFormat(format: "H:|[v0]|", views: menuBar)
        menuBar.addConstraintsWithFormat(format: "V:|[v0(50)]", views: menuBar)
        
    }
    
    private func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        collectionView?.isPagingEnabled = true
        
        collectionView?.backgroundColor = .systemGray6
        
        feedTypes.append("Home")
        feedTypes.append("Sensor")
        feedTypes.append("Energy")
        
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: self.cellId)
        collectionView?.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        cell.type = feedTypes[indexPath.item]
        cell.setupViews()
        
        let key = cell.type
        cellsDictionary[key] = cell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.leftHorizontalBarAnchorConstraint?.constant = scrollView.contentOffset.x / 3
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = Int(targetContentOffset.move().x / view.frame.width)
        let indexPath = NSIndexPath(item: index, section: 0)
        
        menuBar.collectionView.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: [])
    }
    

    
    //--> Functions related to getting updates from the models.
    
    var lineChartEntry = [ChartDataEntry]()
    
    func updateFromTacx(data: [NSManagedObject]) {
        let calendar = Calendar.current
        for object in data {
            let date = object.value(forKey: "time")
            let velocity = object.value(forKey: "velocity")
            let value = ChartDataEntry(x: getTotalSecondsFromDate(seconds: calendar.component(.second, from: date as! Date), minutes: calendar.component(.minute, from: date as! Date), hours: calendar.component(.hour, from: date as! Date)), y: velocity as! Double)
            lineChartEntry.append(value)
        }
        
        updateGraphWithValues()
    }
    
    func updateFromGPSModel(velocity: String) {
        //self.gpsVelocityLabel.text = velocity
    }
    
    func updateFromAccelerometerModel(acceleration: String) {
        //self.accelerometerLabel.text = acceleration
    }
    
    func updateFromHeartRateModel(heartRate: String) {
        //self.heartRateLabel.text = heartRate
    }
    
    func updateFromPhysicsModel(energyExpenditure: String) {
        // TODO
    }
    
    func getTotalSecondsFromDate(seconds: Int, minutes: Int, hours: Int) -> Double {
        let totalSeconds = (seconds) + (minutes * 60) + (hours * 3600)
        return Double(totalSeconds)
    }
    
    func updateGraphWithValues() {
        print("Updating graph")
        let lineOne = LineChartDataSet(entries: lineChartEntry, label: "Tacx")
        lineOne.colors = [NSUIColor.blue]
        
        let data = LineChartData()
        data.addDataSet(lineOne)
        
        let feedCell = cellsDictionary["Sensor"]
        let key = "Tacx"
        
        let sensorModel = feedCell?.sensorModelsDictionary[key]
        sensorModel?.graphView?.data = data
        sensorModel?.graphView?.chartDescription?.text = "Tacx"
        feedCell?.setupViews()
    }
    
    func setupNavBarButtons() {
        let settingsImage = UIImage(named: "wrench")
        
        let settingsBarButtonItem = UIBarButtonItem(image: settingsImage, style: .plain, target: self, action: #selector(handleSearch))
        settingsBarButtonItem.tintColor = UIColor(ciColor: .white)
        navigationItem.rightBarButtonItems = [settingsBarButtonItem]
    }
    
    @objc func handleSearch() {
        print(123)
    }
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: [], animated: true)
    }
    
}




