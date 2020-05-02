//
//  PhysicsModule.swift
//  Wheely
//
//  Created by Student on 2020-04-17.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class PhysicsModule {
    var database: Database?
    var energyExpenditure = Double()
    var alternativeEnergyExpenditure = Double()
    
    init(database: Database) {
        self.database = database
    }
    
    func calculateEnergyExpenditure(startDate: Date, endDate: Date) {
        // Retrieve the velocity data from the Tacx module
        let velocityData = database!.readDataBetweenDates(entity: "Tacx", startDate: startDate as NSDate, endDate: endDate as NSDate, sortDescriptorKey: "time")
        let profileData = database!.getAllData(entity: "Profile", type: "profile")
        
        // Retrieve profile values such as mass of person, age of person and mass of wheelchair.
        
        let k = 0.0042 // Wooden floor
        var mOfPerson = Double()
        var mOfWheelchair = Double() // The mass of the wheelchair
        var ageOfPerson = Double()
        
        for profile in profileData {
            print(profile)
            mOfPerson = profile.value(forKey: "weight") as! Double
            mOfWheelchair = profile.value(forKey: "wheelchairWeight") as! Double
            ageOfPerson = profile.value(forKey: "age") as! Double
        }
        
        print("M of W: \(mOfWheelchair) M of P: \(mOfPerson)")
        
        
        let totalm = mOfPerson + mOfWheelchair
        
        if(velocityData.count > 0) {
            // Retrieve the corresponding time and date variables into arrays which each index of time corresponding the velocity at that same index.
            
            var velocities = [Double]()
            var timeOfVelocityRecorded = [Date]()
            var velocityAtTime = [Date : Double]()
            var changeInTimeAtTime = [Date: Double]()
            
            for data in velocityData {
                let time = (data.value(forKey: "time") as? Date)!
                let velocity = (data.value(forKey: "velocity") as? Double)!
        
                print("Velocity: \(velocity) at time: \(time)")
                
                timeOfVelocityRecorded.append(time)
                velocityAtTime[time] = velocity
                velocities.append(velocity)
            }
            
            // Calculate the acceleration at each time interval
            
            var currentAcceleration = Double()
            var accelerationAtTime = [Date : Double]()

            for i in 0..<(velocities.count-1) {

                    let changeInTimeValue = getDateDiff(start: timeOfVelocityRecorded[i], end: timeOfVelocityRecorded[i+1])
                if(i == 0) {
                    currentAcceleration = 0
                } else {
                    currentAcceleration = (velocities[i+1] - velocities[i]) / changeInTimeValue
                }
                    print ("Velocity t2: \(velocities[i+1]) : Velocity t1: \(velocities[i]) : deltaT: \(changeInTimeValue)")
                    print("Current acceleration \(currentAcceleration) at time: \(timeOfVelocityRecorded[i])")
                    accelerationAtTime[timeOfVelocityRecorded[i]] = currentAcceleration
                    changeInTimeAtTime[timeOfVelocityRecorded[i+1]] = changeInTimeValue
            }
            changeInTimeAtTime[timeOfVelocityRecorded[0]] = getDateDiff(start: startDate, end: timeOfVelocityRecorded[0])
            
            
            var pushingForce = Double()
            var pushingForceAlternative = Double()
            
            var pushingForceAtTime = [Date : Double]()
            var pushingForceAlternativeAtTime = [Date: Double]()
            
            let c1 = 0.0042 // u for wooden floor
            let c2 = 0.000003 // k tested experimentally
            let g = 9.81 // g
            
            // Calculate the pushing force by assuming that ma(t) = F(t) - kv(t)
            // Or alternatively ma(t) = F(t) - (c1(mg) + c2(kv^2))
            
            for (date, acceleration) in accelerationAtTime {
                pushingForce = abs(totalm*(acceleration) + k*(velocityAtTime[date]!))
                pushingForceAlternative = abs(totalm*(acceleration) + (c1*totalm*g) + (c2*totalm*g*pow((velocityAtTime[date]!), 2)))
                pushingForceAtTime[date] = pushingForce
                pushingForceAlternativeAtTime[date] = pushingForceAlternative
            }
            
            // Calculate the power at each instance of time generated with the pushing force. P(t) = F(t)v(t)
            var power = Double()
            var powerAlternative = Double()
            var powerAtTime = [Date : Double]()
            var powerAlternativeAtTime = [Date : Double]()
            for(date, pushingForce) in pushingForceAtTime {
                power = pushingForce * velocityAtTime[date]!
                powerAlternative = pushingForceAlternative * velocityAtTime[date]!
                powerAtTime[date] = power
                powerAlternativeAtTime[date] = power
            }
            
            // Sum up the indidiual contributions of power to get the total energy expenditure.
            var totalEnergyExpenditure = Double()
            var totalAlternativeEnergyExpenditure = Double()
            var counter = 0
            
            var firstDate = Date()
            
            for(date, power) in powerAtTime {
                if(date.timeIntervalSince(firstDate) < 0) {
                    firstDate = date
                }
            }
            
            for(date, power) in powerAtTime {
                if(date.compare(firstDate).rawValue == 0) {
                    totalEnergyExpenditure += power * 0
                } else {
                    totalEnergyExpenditure += power * changeInTimeAtTime[date]!
                }
                counter += 1
            }
            
            // Alternative sum up of individual contributions.
            counter = 0
            for(date, alternativePower) in powerAlternativeAtTime {
                if(date.compare(firstDate).rawValue == 0) {
                    let changeInTime = getDateDiff(start: startDate, end: date)
                    totalAlternativeEnergyExpenditure += alternativePower * changeInTime
                } else {
                    totalAlternativeEnergyExpenditure += alternativePower * changeInTimeAtTime[date]!
                }
                counter += 1
            }
            

            
            // Convert the total energy expenditure into kcal
            
            let calorie = 4184.0 // Joules
            let totalTimeDifference = getDateDiff(start: startDate, end: endDate)
            

            
            let totalJoules = totalEnergyExpenditure * totalTimeDifference
            let totalJoulesAlternative = totalAlternativeEnergyExpenditure * totalTimeDifference

            
            let totalCalories = totalJoules / calorie
            let totalCaloriesAlternative = totalJoulesAlternative / calorie
            
            self.energyExpenditure = totalCalories
            self.alternativeEnergyExpenditure = totalCaloriesAlternative
            saveEnergyExpenditure(startDate: startDate, endDate: endDate)
            
            print("\(totalCalories) calories")
            print("\(totalCaloriesAlternative) calories alternative")
        }
    }
    
    func getDateDiff(start: Date, end: Date) -> Double  {
        
        let seconds = end.timeIntervalSince(start) as Double
        
        return Double(seconds)
    }
    
    func getEnergyExpenditure() -> Double {
        return self.energyExpenditure
    }
    
    func saveEnergyExpenditure(startDate: Date, endDate: Date) {
        self.database!.saveData(entity: "Energy", energy: getEnergyExpenditure(), alternativeEnergy: self.alternativeEnergyExpenditure, startDate: startDate, endDate: endDate)
    }
}
