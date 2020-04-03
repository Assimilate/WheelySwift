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


class ViewController: UIViewController {
    
    
    //-> IB related variables and functions relating to UI components.
    
    // Buttons.
    
    
    // Labels.
    
    
    // Charts.
    
    @IBOutlet weak var chartView: LineChartView!
    
    
    
    
    //<-- End of IB related variables and functions.
    
    // Declaring the model class variables.
    
    var gpsModel: GPSModel? = nil
    var accelerometerModel: AccelerometerModel? = nil
    var tacxModel: TacxModel? = nil
    var heartRateModel: HeartRateModel? = nil
    var physicsModel: PhysicsModel? = nil
    
    // Declaring the database class variable.
    var database: Database? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the classes.
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        database = Database(appDelegate: appDelegate)
        tacxModel = TacxModel(viewController: self, database: database!)
        gpsModel = GPSModel(viewController: self, database: database!)
        accelerometerModel = AccelerometerModel(viewController: self, database: database!)
        heartRateModel = HeartRateModel(viewController: self, database: database!)
        
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
        
        chartView.data = data
        chartView.chartDescription?.text = "Tacx"
        
    }
    
}

