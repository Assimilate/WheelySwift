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
class InterfaceController: WKInterfaceController, WCSessionDelegate, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    
    var startDate: Date?
    var endDate: Date?
    
    @IBOutlet weak var labelReceivedWatch: WKInterfaceLabel!
    
    @IBAction func buttonWatchSend() {
        print("Sampling...")
//        let dateReference = Date()
//        self.startDate = Calendar.current.date(byAdding: .second, value: -5, to: dateReference)
//        self.endDate = dateReference
        getActiveEnergy()
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // This function is a delegate function an works as a way to delegate between the iPhone and the AppleWatch.
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let messageReceived = message["activate"] as? Bool {
            if(messageReceived) {
                startDate = Date()
                configureWorkout()
            } else {
                endDate = Date()
                stopWorkout(endDate: endDate!)
            }
        }
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        configureWatchSession()
        labelReceivedWatch.setTextColor(.darkGray)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    let session = WCSession.default
    func configureWatchSession() {
        self.startDate = Date()
        if(WCSession.isSupported()) {
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
            
            self.session.sendMessage(message, replyHandler:nil, errorHandler: nil)
        }
        
    }
    
    func startCollectingData() {
        
        DispatchQueue.main.async{
            self.labelReceivedWatch.setText("Collecting data...")
        }
        
        
    }
    
    var anchoredQueryHeartRate: HKAnchoredObjectQuery?
    
    func getHeartRateData() {
        // Creating the predicates for the HKQuery.
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let startDate: Date = calendar.date(from: components)!
        let endDate: Date = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate as Date)! // Adding 1 day to the current date. Meaning 1 day ahead.
        
        let sampleType : HKSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate : NSPredicate =  HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let anchor: HKQueryAnchor = HKQueryAnchor(fromValue: 0)
        
        self.anchoredQueryHeartRate = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error ) in
            
            if samples != nil {
                
                self.collectCurrentHeartRateSample(currentSampleType: samples!, deleted: deletedObjects!)
                
            }
        }
        
        anchoredQueryHeartRate!.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.collectCurrentHeartRateSample(currentSampleType: samples!, deleted: deletedObjects!)
        }
        
        self.healthStore.execute(anchoredQueryHeartRate!)
        
    }
    
    var anchoredQueryPushCount: HKAnchoredObjectQuery?
    
    func getPushCountData() {
        // Creating the predicates for the HKQuery.
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let startDate: Date = calendar.date(from: components)!
        let endDate: Date = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate as Date)! // Adding 1 day to the current date. Meaning 1 day ahead.
        
        let sampleType : HKSampleType = HKObjectType.quantityType(forIdentifier: .pushCount)!
        let predicate : NSPredicate =  HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let anchor: HKQueryAnchor = HKQueryAnchor(fromValue: 0)
        
        self.anchoredQueryPushCount = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error ) in
            
            if samples != nil {
                
                self.collectCurrentPushRateSample(currentSampleType: samples!, deleted: deletedObjects!)
                
            }
        }
        
        anchoredQueryPushCount!.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.collectCurrentPushRateSample(currentSampleType: samples!, deleted: deletedObjects!)
        }
        
        self.healthStore.execute(anchoredQueryPushCount!)
        
    }
    
    func stopHeartRateAndPushCountData() {
        DispatchQueue.main.async {
            self.healthStore.stop(self.anchoredQueryHeartRate!)
            self.healthStore.stop(self.anchoredQueryPushCount!)
        }
    }
    
    var currentHeartRateSample : [HKSample]?
    
    var currentHeartLastSample : HKSample?
    
    var currentHeartRateBPM = Double()
    
    //Retrived necessary parameter from HK Sample
    func collectCurrentHeartRateSample(currentSampleType : [HKSample]?, deleted : [HKDeletedObject]?){
        
        
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
            
            self.labelReceivedWatch.setText("\(Int(self.currentHeartRateBPM))")
            
            let dateRecorded = Date()
            if(session.isReachable) {
                DispatchQueue.main.async {
                    
                    let message = [
                        "HeartRateBPM" : self.currentHeartRateBPM,
                        "HeartRateStartDate" : heartRateStartDate,
                        "HeartRateEndDate" : heartRateEndDate,
                        "HeartRateDateRecorded" : dateRecorded
                        ] as [String : Any]
                    
                    print("HR Data: \(self.currentHeartRateBPM)")
                    
                    //Transfer data from watch to iPhone
                    if(self.session.isReachable) {
                        self.session.sendMessage(message, replyHandler:nil, errorHandler: nil)
                    }
                    
                    
                }
            }
            
        }
        
    }
    
    var currentPushRateSample : [HKSample]?
    
    var currentPushLastSample : HKSample?
    
    var currentPushRateBPM = Double()
    
    //Retrived necessary parameter from HK Sample
    func collectCurrentPushRateSample(currentSampleType : [HKSample]?, deleted : [HKDeletedObject]?){
        
        self.currentPushRateSample = currentSampleType
        
        //Get Last Sample of Heart Rate
        self.currentPushLastSample = self.currentPushRateSample?.last
        
        if self.currentPushLastSample != nil {
            
            let lastPushRateSample = self.currentPushLastSample as! HKQuantitySample
            
            self.currentPushRateBPM = lastPushRateSample.quantity.doubleValue(for: HKUnit(from: "count"))
            let heartRateStartDate = lastPushRateSample.startDate
            let heartRateEndDate = lastPushRateSample.endDate
            
            //Send Heart Rate Data Using Send Messge
            
            print("Push Data: \(self.currentPushRateBPM)")
            
            self.labelReceivedWatch.setText("\(self.currentPushRateBPM)")
            
//            DispatchQueue.main.async {
//                print("Push Data: \(self.currentPushRateBPM)")
//            }
            
        }
        
    }
    
    var workoutSession: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    func configureWorkout() {
        print("Configuring workout...")
        
        let startDate = Date()
        
        let healthStore = HKHealthStore()
        
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .wheelchairWalkPace
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = workoutSession?.associatedWorkoutBuilder()
            
        } catch {
            dismiss()
            return
        }
        
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        workoutSession?.startActivity(with: self.startDate!)
        
        builder?.beginCollection(withStart: self.startDate!, completion: { (success, error) in
            
        })
        getHeartRateData()
        getPushCountData()
        
    }
    
    func stopWorkout(endDate: Date) {
        print("Stopping workout...")
        
        self.stopHeartRateAndPushCountData()
        self.importPushCountHistory(endDate: endDate)
        self.getActiveEnergy()
        
        self.workoutSession?.stopActivity(with: endDate)
        self.workoutSession?.end()
        builder?.endCollection(withEnd: endDate, completion: { (success, error) in
            DispatchQueue.main.async {
                self.dismiss()
            }
        })
        
        
       
    }
    
    func querySingleSample() {
        let sampleTypeSingle = HKSampleType.quantityType(forIdentifier: .heartRate)
        let query = HKSampleQuery.init(sampleType: sampleTypeSingle!, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            
            print(results)
            
        }
        self.healthStore.execute(query)
    }
    
    func importPushCountHistory(endDate: Date) {
        
        let pushQuantityType = HKQuantityType.quantityType(forIdentifier: .pushCount)!
        
        let now = Date()
        
        var interval = DateComponents()
        interval.second = 4
        
        
        let anchorComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: now)
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let predicate = HKQuery.predicateForSamples(withStart: self.startDate!, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: pushQuantityType,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard let results = results else { return }
            
            var dictionaryArray = [Dictionary<Date, Double>]()
            var tempDictionary = Dictionary<Date, Double>()
            
            results.enumerateStatistics(from: self.startDate!, to: endDate) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let pushes = sum.doubleValue(for: HKUnit.count())
                    print("Push count: \(pushes), Sdate: \(statistics.startDate) Edate: \(statistics.endDate)")
                    print("Startdate: \(self.startDate) EndDate: \(endDate)")
                    
                    tempDictionary[statistics.endDate] = pushes
                    dictionaryArray.append(tempDictionary)
                }
            }
            if(self.session.isReachable) {
                DispatchQueue.main.async {
                    let message = ["PushCount" : tempDictionary] as [String : Any]
                    //Transfer data from watch to iPhone
                    self.session.sendMessage(message, replyHandler:nil, errorHandler: nil)
                }
            }
            
        }
        
        healthStore.execute(query)
        
    }
    var totalActiveEnergy = 0.0
    func getActiveEnergy () {

        let energySampleType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: [.strictStartDate, .strictEndDate])

        let query = HKSampleQuery(sampleType: energySampleType!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                print("There was an error running the query: \(error)")
            }
            var totalEnergy = Double()
            DispatchQueue.main.async {
                
                for activity in results as! [HKQuantitySample]
                {
                    let currentEnergy = (activity.quantity.doubleValue(for: HKUnit.kilocalorie()))
                        totalEnergy += currentEnergy
                    print(">>>>>", currentEnergy)
                }
                print(totalEnergy)
                
                let message = ["ActiveEnergy" : totalEnergy] as [String : Any]
                //Transfer data from watch to iPhone
                self.session.sendMessage(message, replyHandler:nil, errorHandler: nil)
                
                print("Total kcal: \(totalEnergy)")

            }
        })
        self.healthStore.execute(query)
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        print("Did collect data...")
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("Did collect event...")
    }
    
}
