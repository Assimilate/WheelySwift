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
    }
    
    var locationPrevious = CLLocation()
    
    var currentTimeGPS = Date()
    var previousTimeGPS = Date()
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentTimeGPS = self.getCurrentTimeGPS()
            DispatchQueue.main.async {
                //print("New location is \(location)")
                
                self.deriveGPSDistance(latitudeFrom: self.locationPrevious.coordinate.latitude, longitudeFrom: self.locationPrevious.coordinate.longitude, latitudeTo: location.coordinate.latitude, longitudeTo: location.coordinate.longitude)
                
                
                
                self.locationPrevious = location
            }
            
            
        }
    }
    
    var distanceInMetres = Double()
    
    func deriveGPSDistance(latitudeFrom: Double, longitudeFrom: Double, latitudeTo: Double, longitudeTo: Double) {
        let coordinateFrom = CLLocation(latitude: latitudeFrom, longitude: longitudeFrom)
        let coordinateTo = CLLocation(latitude: latitudeTo, longitude: longitudeTo)
        
        //        print("LatFrom: \(latitudeFrom)")
        //        print("LongFrom: \(longitudeFrom)")
        //        print("LatTo: \(latitudeTo)")
        //        print("LongTo: \(longitudeTo)")
        
        distanceInMetres = coordinateTo.distance(from: coordinateFrom)
        print("Distance: \(distanceInMetres)")
        
            
        self.deriveVelocityGPS(distance: self.distanceInMetres)
        
        
    }
    var currentVelocityGPS = Double()
    func deriveVelocityGPS(distance: Double) {
        
        let timeIntervalBetweenPoints = currentTimeGPS.timeIntervalSince(previousTimeGPS)
        
        currentVelocityGPS = distanceInMetres/timeIntervalBetweenPoints
        
        DispatchQueue.main.async {
            if(self.currentVelocityGPS != nil && self.currentVelocityGPS > 0) {
                self.database!.saveData(velocityNumber: self.currentVelocityGPS, timeDate: self.currentTimeGPS, entity: "GPS")
            }
            
            self.viewController?.updateFromGPSModel(velocity: "\(self.currentVelocityGPS)")
           
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
    
    //<-- End of GPS related variables and functions.
    
}
