//
//  InterfaceController.swift
//  WheelyWatch Extension
//
//  Created by Student on 2020-03-24.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import HealthKit
class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var labelReceivedWatch: WKInterfaceLabel!
    
    @IBAction func buttonWatchSend() {
        print("Sampling...")
        querySingleSample()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // This function is a delegate function an works as a way to delegate between the iPhone and the AppleWatch.
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received activation message")
        if let messageReceived = message["activate"] as? Bool {
            if(messageReceived) {
                
                
                configureWorkout()
            } else {
                stopWorkout()
            }
        } else {
            
        }
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        configureWatchSession()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func configureWatchSession() {
        if(WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        
    }
    
    
    
    let healthStore = HKHealthStore()
    
    func sendDataToiPhone() {
        
        guard WCSession.default.isReachable else {
            let error = "Phone is not reachable"
            print(error)
            return
        }
        
        DispatchQueue.main.async {
            let message = ["heartRateBPM": "50"]
            
            WCSession.default.sendMessage(message, replyHandler:nil, errorHandler: { (error) in
                print("Error in send message : \(error)")
            })
        }
        
    }
    
    func startCollectingData() {
        
        DispatchQueue.main.async{
            self.labelReceivedWatch.setText("Collecting data...")
        }
        
        
    }
    
    var anchoredQuery: HKAnchoredObjectQuery?
    
    func getHeartRateData() {
        print("Getting HR Data...")
        // Creating the predicates for the HKQuery.
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let startDate: Date = calendar.date(from: components)!
        let endDate: Date = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate as Date)! // Adding 1 day to the current date. Meaning 1 day ahead.
        
        let sampleType : HKSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate : NSPredicate =  HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let anchor: HKQueryAnchor = HKQueryAnchor(fromValue: 0)
        
        self.anchoredQuery = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error ) in
            
            if samples != nil {
                
                self.collectCurrentHeartRateSample(currentSampleType: samples!, deleted: deletedObjects!)
                
            }
        }
        
        anchoredQuery!.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.collectCurrentHeartRateSample(currentSampleType: samples!, deleted: deletedObjects!)
        }
        
        self.healthStore.execute(anchoredQuery!)
        
    }
    
    func stopHeartRateData() {
        self.healthStore.stop(self.anchoredQuery!)
    }
    
    var currentHeartRateSample : [HKSample]?
    
    var currentHeartLastSample : HKSample?
    
    var currentHeartRateBPM = Double()
    
    //Retrived necessary parameter from HK Sample
    func collectCurrentHeartRateSample(currentSampleType : [HKSample]?, deleted : [HKDeletedObject]?){
        
        print("Collecting HR Data...")
        
        self.currentHeartRateSample = currentSampleType
        
        //Get Last Sample of Heart Rate
        self.currentHeartLastSample = self.currentHeartRateSample?.last
        
        if self.currentHeartLastSample != nil {
            
            let lastHeartRateSample = self.currentHeartLastSample as! HKQuantitySample
            
            self.currentHeartRateBPM = lastHeartRateSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let heartRateStartDate = lastHeartRateSample.startDate
            let heartRateEndDate = lastHeartRateSample.endDate
            
            //Send Heart Rate Data Using Send Messge
            
            print("HR Data: \(self.currentHeartRateBPM)")
            
            self.labelReceivedWatch.setText("\(self.currentHeartRateBPM)")
            
            DispatchQueue.main.async {
                
                let message = [
                    "HeartRateBPM" : self.currentHeartRateBPM,
                    "HeartRateStartDate" : heartRateStartDate,
                    "HeartRateEndDate" : heartRateEndDate
                    ] as [String : Any]
                
                print("HR Data: \(self.currentHeartRateBPM)")
                
                //Transfer data from watch to iPhone
                WCSession.default.sendMessage(message, replyHandler:nil, errorHandler: { (error) in
                    print("Error in send message : \(error)")
                })
                
            }
            
        }
        
    }
    
    var workoutSession: HKWorkoutSession?
    
    func configureWorkout() {
        print("Configuring workout...")
        let healthStore = HKHealthStore()
        
        
        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = .wheelchairWalkPace
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfig)
            workoutSession?.delegate = self as? HKWorkoutSessionDelegate
            workoutSession?.startActivity(with: Date())
       
            getHeartRateData()
            
            
        } catch {
            print(error)
        }
    }
    
    func stopWorkout() {
        print("Stopping workout...")
        self.workoutSession?.stopActivity(with: Date())
        self.stopHeartRateData()
    }
    
    func querySingleSample() {
        let sampleTypeSingle = HKSampleType.quantityType(forIdentifier: .heartRate)
        let query = HKSampleQuery.init(sampleType: sampleTypeSingle!, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            
            print(results)
            
        }
        self.healthStore.execute(query)
    }
    
    
    
    
    
}
