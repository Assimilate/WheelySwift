//
//  Database.swift
//  Wheely
//
//  Created by Student on 2020-04-01.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import Foundation
import CoreData

class Database {
    
    //--> Reading/Writing using CoreData.
    
    // Save velocities to entity.
    
    let appDelegate: AppDelegate?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    
    func saveData(velocityNumber: Double, timeDate: Date, entity: String) {
        
        
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(velocityNumber, forKeyPath: "velocity")
        object.setValue(timeDate, forKeyPath: "time")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // Save accelertion data to entity.
    
    func saveData(accelerationX: Double, accelerationY: Double, accelerationZ: Double, timeDate: Date, entity: String) {
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(accelerationX, forKeyPath: "accelerationX")
        object.setValue(accelerationY, forKeyPath: "accelerationY")
        object.setValue(accelerationX, forKeyPath: "accelerationZ")
        object.setValue(timeDate, forKeyPath: "time")
        
        do {
            try managedContext.save()
            
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // Save heart-rate data to entity.
    
    func saveData(heartRate: Double, timeDate: Date, entity: String) {
        
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(heartRate, forKeyPath: "heartRate")
        print("Saving date: \(timeDate)")
        object.setValue(timeDate, forKeyPath: "time")
        
        do {
            try managedContext.save()
            
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllDataFromEntity(entity: String ) {
        
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let readRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        print("Deleting...")
        do {
            
            let velocities = try managedContext.fetch(readRequest)
            for data in velocities as [NSManagedObject]{
                let managedObjectData:NSManagedObject = data
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Could not read. \(error), \(error.userInfo)")
        }
    }
    
    func readData(entity: String, type: String) {
        
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let readRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        
        do {
            
            let isEqualAcceleration = (type == "acceleration")
            let isEqualVelocity = (type == "velocity")
            let isEqualHeartRate = (type == "heartRate")
            
            if(isEqualVelocity) {
                print("Reading velocity...")
                let velocities = try managedContext.fetch(readRequest)
                for data in velocities as [NSManagedObject]{
                    print(data.value(forKey: "velocity") as! Double)
                    print(data.value(forKey: "time") as! Date)
                }
            } else if(isEqualAcceleration) {
                print("Reading acceleration...")
                let accelerations = try managedContext.fetch(readRequest)
                for data in accelerations as [NSManagedObject]{
                    print(data.value(forKey: "accelerationX") as! Double)
                    print(data.value(forKey: "accelerationY") as! Double)
                    print(data.value(forKey: "accelerationZ") as! Double)
                    print(data.value(forKey: "time") as! Date)
                }
            } else if(isEqualHeartRate) {
                print("Reading heart rate...")
                let heartRates = try managedContext.fetch(readRequest)
                for data in heartRates as [NSManagedObject]{
                    print(data.value(forKey: "heartRate") as! Double)
                    print(data.value(forKey: "time") as! Date)
                }
            }
            
        } catch let error as NSError {
            print("Could not read. \(error), \(error.userInfo)")
        }
    }
    
    func getData(entity: String, type: String) -> [NSManagedObject] {
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let readRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        var objectDataToReturn = [NSManagedObject]()
        do {
            
            let isEqualAcceleration = (type == "acceleration")
            let isEqualVelocity = (type == "velocity")
            let isEqualHeartRate = (type == "heartRate")
            
            if(isEqualVelocity) {
                print("Reading velocity...")
                let velocities = try managedContext.fetch(readRequest)
                objectDataToReturn = velocities;
            } else if(isEqualAcceleration) {
                print("Reading acceleration...")
                let accelerations = try managedContext.fetch(readRequest)
                objectDataToReturn = accelerations
            } else if(isEqualHeartRate) {
                print("Reading heart rate...")
                let heartRates = try managedContext.fetch(readRequest)
                objectDataToReturn = heartRates
            }
            
        } catch let error as NSError {
            print("Could not read. \(error), \(error.userInfo)")
        }
        return objectDataToReturn
    }
    
    //<-- End of Reading/Writing using CoreData.
    
}
