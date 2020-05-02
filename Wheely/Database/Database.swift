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
    
    // Entities
    
    let entities = [String: NSManagedObject]()
    
    // Save velocities to entity.
    
    let appDelegate: AppDelegate?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        
    }
    
    
    func saveData(velocityNumber: Double, distance: Double, altitude: Double, timeDate: Date, entityName: String) {
        
        
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(velocityNumber, forKeyPath: "velocity")
        object.setValue(timeDate, forKeyPath: "time")
        object.setValue(distance, forKey: "distance")
        if(entityName == "GPS") {
            object.setValue(altitude, forKey: "altitude")
        }
        
        do {
            try managedContext.save()
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // Save push count data to entity.
    
    func saveData(pushCount: Double, timeDate: Date, entityName: String) {
        
        print("Push count saved: \(pushCount)")
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(pushCount, forKeyPath: "pushCount")
        object.setValue(timeDate, forKey: "time")
        
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
    
    // Save sessions date data.
    
    func saveData(startDate: Date, endDate:Date, entity: String) {
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(startDate, forKeyPath: "startDate")
        object.setValue(endDate, forKeyPath: "endDate")
        
        do {
            try managedContext.save()
            
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // Save heart-rate data to entity.
    
    func saveData(heartRate: Double, timeDate: Date, entity: String) {
        
        print("Saving heart rate \(heartRate)")
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(heartRate, forKeyPath: "heartRate")
        object.setValue(timeDate, forKeyPath: "time")
        
        do {
            try managedContext.save()
            
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveData(age: Int, weight: Int, wheelchairWeight: Int, date: Date, entity: String) {
        
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(weight, forKeyPath: "weight")
        object.setValue(age, forKeyPath: "age")
        object.setValue(wheelchairWeight, forKey: "wheelchairWeight")
        object.setValue(date, forKey: "date")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveData(entity: String, energy: Double, alternativeEnergy: Double, startDate: Date, endDate: Date) {
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(energy, forKey: "energyExpenditure")
        object.setValue(alternativeEnergy, forKey: "alternativeEnergyExpenditure")
        object.setValue(startDate, forKey: "startTime")
        object.setValue(endDate, forKey: "endTime")
        
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
                managedContext.delete(data)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not read. \(error), \(error.userInfo)")
        }
    }
    
    func readDataBetweenDates(entity: String, startDate: NSDate, endDate: NSDate, sortDescriptorKey: String) -> [NSManagedObject] {
        
        
        let managedContext = self.appDelegate!.persistentContainer.viewContext
        
        let readRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        let sort = NSSortDescriptor(key: sortDescriptorKey, ascending: true)
        readRequest.sortDescriptors = [sort]
        readRequest.predicate = NSPredicate(format: "(\(sortDescriptorKey) >= %@) AND (\(sortDescriptorKey) <= %@)", startDate, endDate)
        var objectDataToReturn = [NSManagedObject]()
        do {
            
            objectDataToReturn = try managedContext.fetch(readRequest)
            
            
        } catch let error as NSError {
            print("Could not read. \(error), \(error.userInfo)")
        }
        return objectDataToReturn
    }
    
    func getAllData(entity: String, type: String) -> [NSManagedObject] {
        let managedContext: NSManagedObjectContext = self.appDelegate!.persistentContainer.viewContext
        
        var key = "time"
        
        if(entity == "Session") {
            key = "startDate"
        }
        
        let readRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if(entity != "Profile") {
            let sort: NSSortDescriptor = NSSortDescriptor(key: key, ascending: true)
            readRequest.sortDescriptors = [sort]
        }
        var objectDataToReturn: [NSManagedObject] = [NSManagedObject]()
        managedContext.performAndWait {
            
            do {
                
                let isEqualAcceleration = (type == "acceleration")
                let isEqualVelocity = (type == "velocity")
                let isEqualHeartRate = (type == "heartRate")
                let isEqualSession = (type == "session")
                let isEqualProfile = (type == "profile")
                
                if(isEqualVelocity) {
                    let velocities = try managedContext.fetch(readRequest)
                    objectDataToReturn = velocities
                } else if(isEqualAcceleration) {
                    let accelerations = try managedContext.fetch(readRequest)
                    objectDataToReturn = accelerations
                } else if(isEqualHeartRate) {
                    let heartRates = try managedContext.fetch(readRequest)
                    objectDataToReturn = heartRates
                } else if(isEqualSession) {
                    let sessions: [NSManagedObject] = try managedContext.fetch(readRequest) as! [Session]
                    objectDataToReturn = sessions
                } else if(isEqualProfile) {
                    let profiles: [NSManagedObject] = try managedContext.fetch(readRequest)
                    objectDataToReturn = profiles
                }
                
            } catch let error as NSError {
                print("Could not read. \(error), \(error.userInfo)")
            }
        }
        
        
        return objectDataToReturn
    }
    
    
    
    
    
    //<-- End of Reading/Writing using CoreData.
    
}
