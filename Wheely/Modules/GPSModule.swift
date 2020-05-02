//
//  GPSModel.swift
//  Wheely
//
//  Created by Student on 2020-04-01.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import Foundation
import CoreLocation

class GPSModule: NSObject, CLLocationManagerDelegate{
    
    // Initializer.
    
    var viewController: HomeController?
    var database: Database?
    
    var ready = false
    
    init(viewController: HomeController, database: Database) {
        self.viewController = viewController
        self.database = database
    }
    
    //--> GPS related variables and functions.
    
    var locationManager: CLLocationManager!
    
    func startGPS() {
        
        print("Configuring GPS...")
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        
    }
    
    func stopGPS() {
        print("Stopping GPS...")
        self.locationManager.stopUpdatingLocation()
        updateController()
    }
    
    var locationPrevious = CLLocation()
    var currentAltitude = Double()
    
    var currentTimeGPS = Date()
    var previousTimeGPS = Date()
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentTimeGPS = self.getCurrentTimeGPS()
            DispatchQueue.main.async {
                
                self.deriveGPSDistance(latitudeFrom: self.locationPrevious.coordinate.latitude, longitudeFrom: self.locationPrevious.coordinate.longitude, latitudeTo: location.coordinate.latitude, longitudeTo: location.coordinate.longitude)
                self.currentAltitude = location.altitude
                
                
                self.locationPrevious = location
            }
            if(!ready) {
                self.viewController?.connectionReady(moduleName: "GPS", ready: true)
                ready = true
            }
            
        }
    }
    
    var distanceInMetres = Double(0)
    var totalDistance = Double()
    
    func deriveGPSDistance(latitudeFrom: Double, longitudeFrom: Double, latitudeTo: Double, longitudeTo: Double) {
        let coordinateFrom = CLLocation(latitude: latitudeFrom, longitude: longitudeFrom)
        let coordinateTo = CLLocation(latitude: latitudeTo, longitude: longitudeTo)
        
        distanceInMetres = coordinateTo.distance(from: coordinateFrom)
        if(distanceInMetres < 1000) {
            totalDistance += distanceInMetres
        }
        print("Distance: \(distanceInMetres)")
        
        
        self.deriveVelocityGPS(distance: self.distanceInMetres)
        
        
    }
    var currentVelocityGPS = Double()
    func deriveVelocityGPS(distance: Double) {
        
        let timeIntervalBetweenPoints = currentTimeGPS.timeIntervalSince(previousTimeGPS)
        
        currentVelocityGPS = distanceInMetres/timeIntervalBetweenPoints
        
        DispatchQueue.main.async {
            if(self.currentVelocityGPS < 100) { // In case insane values pop in.
                if(self.currentVelocityGPS.isNaN != true && self.currentVelocityGPS.isNaN != true) {
                    self.database!.saveData(velocityNumber: self.currentVelocityGPS, distance: self.distanceInMetres, altitude: self.currentAltitude, timeDate: self.currentTimeGPS, entityName: "GPS")
                }
            }
            
            
            self.previousTimeGPS = self.currentTimeGPS
        }
    }
    
    // GPS
    
    var currentDateGPS = Date()
    
    func getCurrentTimeGPS() -> Date {
        let currentDateGPS = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDateGPS)
        let minute = calendar.component(.minute, from: currentDateGPS)
        return currentDateGPS
    }
    
    //--> Functions related to updating the controller with new values.
    
    func updateController() {

    }
    
    func deleteGPSData() {
        self.database!.deleteAllDataFromEntity(entity: "GPS")
    }
    
    //<-- End of GPS related variables and functions.
    
}
