//
//  HeartRateModel.swift
//  Wheely
//
//  Created by Student on 2020-04-01.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import Foundation
import HealthKit
import WatchConnectivity

class HeartRateModule: NSObject, WCSessionDelegate {
    
    // Initializer.
    
    var viewController: HomeController?
    var database: Database?
    
    let session = WCSession.default
    
    init(viewController: HomeController, database: Database) {
        self.viewController = viewController
        self.database = database
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    var heartRateDateFirst = Date()
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let messageReceivedDate = message["HeartRateStartDate"] as? Date {
            self.heartRateDateFirst = (messageReceivedDate as? Date)!
        }
        if let messageReceivedHeartRate = message["HeartRateBPM"] as? Double {
            DispatchQueue.main.async{
                if(messageReceivedHeartRate.isNaN != true) {
                    self.database!.saveData(heartRate: messageReceivedHeartRate, timeDate: self.heartRateDateSecond, entity: "HeartRate")
                }
            }
        }
    }
    var heartRateDateSecond = Date()
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let messageReceivedDate = message["HeartRateStartDate"] as? Date {
            self.heartRateDateSecond = (messageReceivedDate as? Date)!
        }
        if let messageReceivedHeartRate = message["HeartRateBPM"] as? Double {
            DispatchQueue.main.async{
                if(messageReceivedHeartRate.isNaN != true) {
                    self.database!.saveData(heartRate: messageReceivedHeartRate, timeDate: self.heartRateDateSecond, entity: "HeartRate")
                }
            }
        }
    }
    
    //--> Healthkit related.
    
    func startWatchSession() {
        
        if WCSession.isSupported() {
            
            self.session.delegate = self
            self.session.activate()
        }
        authorizeDataCollection()
        activateCollectionInWatch()
    }
    
    func stopWatchSession() {
        deactivateCollectionInWatch()
        updateController()
    }
    
    let healthStore = HKHealthStore()
    
    func authorizeDataCollection() {
        
        
        
        // Check to see if HealthKit is available on this device.
        
        if(HKHealthStore.isHealthDataAvailable()) {
            
            // Prepare data types to be read/written.
            
            let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
            let pushCount = HKObjectType.quantityType(forIdentifier: .pushCount)
            let wheelchairDistance = HKObjectType.quantityType(forIdentifier: .distanceWheelchair)
            
            // Prepare a list of the data types to read/write from the health store.
            
            let sampleTypesToWrite: Set<HKSampleType> = [heartRate!, pushCount!, wheelchairDistance!]
            let sampleTypesToRead: Set<HKObjectType> = [heartRate!, pushCount!, wheelchairDistance!]
            
            
            // Authorize the app to collect health data.
            
            
            
            healthStore.requestAuthorization(toShare: sampleTypesToWrite, read: sampleTypesToRead) { (success, error) in
                if !success {
                    // Handle the error here.
                    let error = "Authorization unsuccessful!"
                    print(error)
                }
            }
            
        } else { // HealthKit not available on device.
            let error = "HealthKit not available on device."
            print(error)
        }
    }
    
    //<-- End of HealtKit related variables and functions.
    
    func activateCollectionInWatch() {
        DispatchQueue.main.async {
            let message = ["activate" : true]
            
            WCSession.default.sendMessage(message, replyHandler:nil, errorHandler: { (error) in
                print("Error sending from Phone to Watch : \(error)")
            })
        }
    }
    
    func deactivateCollectionInWatch() {
        DispatchQueue.main.async {
            let message = ["activate" : false]
            
            WCSession.default.sendMessage(message, replyHandler:nil, errorHandler: { (error) in
                print("Error sending from Phone to Watch : \(error)")
            })
        }
    }
    
    //--> Getting the current date. Individual functions for BLE, GPS, Heart-rate and Accelerometer. This is to make it thread safe and so that no function accesses this function at the same time.
    
    // Heart-rate
    
    var currentDateHeartRate = Date()
    
    func getCurrentTimeHeartRate() -> Date {
        let currentDateHeartRate = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDateHeartRate)
        let minute = calendar.component(.minute, from: currentDateHeartRate)
        return currentDateHeartRate
    }
    
    func updateController() {
       
    }
    
    func deleteHeartRateData() {
        self.database!.deleteAllDataFromEntity(entity: "HeartRate")
    }
    
}
