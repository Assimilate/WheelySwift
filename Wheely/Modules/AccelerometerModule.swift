//
//  AccelerometerModel.swift
//  Wheely
//
//  Created by Student on 2020-04-01.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import Foundation
import CoreMotion

class AccelerometerModule {
    
    // Initializer.
    
    var viewController: HomeController?
    var database: Database?
    
    init(viewController: HomeController, database: Database) {
        self.viewController = viewController
        self.database = database
    }
    
    //--> Accelerometer related.
    
    let motionManager = CMMotionManager()
    var accelerationX = Double()
    var accelerationY = Double()
    var accelerationZ = Double()
    var dateAccelerometer = Date()
    func startAccelerometer() {
        
        motionManager.deviceMotionUpdateInterval = 1
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion {
                self.accelerationX = motion.userAcceleration.x;
                self.accelerationY = motion.userAcceleration.y;
                self.accelerationZ = motion.userAcceleration.z;
                self.dateAccelerometer = self.getCurrentTimeAccelerometer()
                
                DispatchQueue.main.async {
                    if(self.accelerationX != nil && self.accelerationY != nil && self.accelerationZ != nil) {
                        self.database!.saveData(accelerationX: self.accelerationX, accelerationY: self.accelerationX, accelerationZ: self.accelerationX, timeDate: self.dateAccelerometer, entity: "Accelerometer")
                    }
                    
                    self.viewController?.updateFromAccelerometerModel(acceleration: "\(self.accelerationY)")
                }
            }
            
        }
    }
    
    func stopAccelerometer() {
        print("Stopping accelerometer...")
        motionManager.stopDeviceMotionUpdates()
    }
    
    // Accelerometer
    
    var currentDateAccelerometer = Date()
    
    func getCurrentTimeAccelerometer() -> Date {
        let currentDateAccelerometer = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDateAccelerometer)
        let minute = calendar.component(.minute, from: currentDateAccelerometer)
        return currentDateAccelerometer
    }
    
    //<-- End accelerometer related.
    
}
