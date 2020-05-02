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

class AppleWatchModule: NSObject, WCSessionDelegate {
    
    // Initializer.
    
    var viewController: HomeController?
    var database: Database?
    
    var ready = false
    
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
    
    var heartRateDateSecond = Date()
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any])  {
        if let messageReceivedDate = message["HeartRateDateRecorded"] as? Date {
            self.heartRateDateSecond = (messageReceivedDate as? Date)!
        }
        if let messageReceivedHeartRate = message["HeartRateBPM"] as? Double {
            print("Message received \(messageReceivedHeartRate)")
            let dateReceived = Date()
            DispatchQueue.main.async{
                if(messageReceivedHeartRate.isNaN != true) {
                    self.database!.saveData(heartRate: messageReceivedHeartRate, timeDate: self.heartRateDateSecond, entity: "HeartRate")
                    if(!self.ready) {
                        self.viewController?.connectionReady(moduleName: "HeartRate", ready: true)
                    }
                }
            }
        }

        if let messageReceivedPushCount = message["PushCount"] as? Dictionary<Date,Double> {

            DispatchQueue.main.async {
                if(messageReceivedPushCount.count > 0) {
                    for(date, pushes) in messageReceivedPushCount {

                        self.database!.saveData(pushCount: pushes, timeDate: date, entityName: "PushCount")
                    }
                }
            }
        }
        
        if let messageReceivedActiveEnergyBurned = message["ActiveEnergy"] as? Double {
            print("Energy message received \(messageReceivedActiveEnergyBurned).")
            DispatchQueue.main.async {
                self.viewController?.updateActiveEnergyBurned(activeEnergy: messageReceivedActiveEnergyBurned)
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
    
    func stopWatchSession(endDate: Date) {
            deactivateCollectionInWatch(endDate: endDate)
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
            let energyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
            let workout = HKObjectType.workoutType()
            
            // Prepare a list of the data types to read/write from the health store.
            
            let sampleTypesToWrite: Set<HKSampleType> = [heartRate!, pushCount!, wheelchairDistance!, energyBurned!, workout]
            let sampleTypesToRead: Set<HKObjectType> = [heartRate!, pushCount!, wheelchairDistance!, energyBurned!, workout]
            
            
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
        if(session.isReachable) {
            DispatchQueue.main.async {
                let message = ["activate" : true]
                
                self.session.sendMessage(message, replyHandler:nil, errorHandler: nil)
            }
        }
    }
    
    func deactivateCollectionInWatch(endDate: Date) {

        if(session.isReachable) {

            DispatchQueue.main.async {
                let message = ["activate" : false]
                self.session.sendMessage(message, replyHandler:nil, errorHandler: nil)
            }
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
