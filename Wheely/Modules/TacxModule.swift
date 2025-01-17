//
//  TacxModel.swift
//  Wheely
//
//  Created by Student on 2020-04-01.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import Foundation
import CoreBluetooth

class TacxModule: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Initializer.
    
    var viewController: HomeController?
    var database: Database?
    
    var ready = false
    var flag = false
    
    init(viewController: HomeController, database: Database) {
        super.init()
        self.viewController = viewController
        self.database = database
        
    }
    
    // Variables.
    
    // Service id of rotational sensor.
    let BLE_Cycling_Speed_And_Cadence_Service = CBUUID(string: "0x1816")

    // Characteristics id of rotational sensor. [Related to measurement data: Total number of rotations and time since last rotation]
    let BLE_CSC_Measurement_Characteristic = CBUUID(string: "0x2A5B")
    
    var centralManager: CBCentralManager?
    var peripheralDevice: CBPeripheral?
    
    let centralQueue: DispatchQueue = DispatchQueue(label: "com.wheely.centralQueue", attributes: .concurrent)
    
    var singletonSet = false
    var sessionOn = false

    //--> BLE related functions and variables, communicating with the TacX Speed and Cadence sensor.
    
    
    func startBLE() {
        if(singletonSet == false) {
            sessionOn = true
            centralManager = CBCentralManager(delegate: self, queue: centralQueue)
            singletonSet = true
        } else {
            sessionOn = true
            centralManager?.scanForPeripherals(withServices: [BLE_Cycling_Speed_And_Cadence_Service])
        }
    }
    
    func stopBLE() {
            sessionOn = false
            self.flag = false
            
            self.currentDistance = 0
            updateController()
            print("Total amount of revolutions: \(currentAmountOfRevolutions - startAmountOfRotations)")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .poweredOn:
            print("BLE ON!")
            centralManager?.scanForPeripherals(withServices: [BLE_Cycling_Speed_And_Cadence_Service])
        case .unknown:
            print("BLE Unknown!")
        case .resetting:
            print("BLE Resett!")
        case .unsupported:
            print("BLE UnSupp!")
        case .unauthorized:
            print("BLE UnAuth!")
        case .poweredOff:
            print("BLE OFF!")
        @unknown default:
            print("BLE Unknown!")
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Scanning for peripherals")
        decodePeripheralState(peripheralState: peripheral.state)
        peripheralDevice = peripheral
        peripheralDevice?.delegate = self
        centralManager?.stopScan()
        centralManager?.connect(peripheralDevice!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected.")
        peripheralDevice?.discoverServices([BLE_Cycling_Speed_And_Cadence_Service])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected.")
        print(sessionOn)
        if(sessionOn == true) {
            centralManager?.scanForPeripherals(withServices: [BLE_Cycling_Speed_And_Cadence_Service])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == BLE_Cycling_Speed_And_Cadence_Service {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            
            if characteristic.uuid == BLE_CSC_Measurement_Characteristic {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        if(!self.ready) {
            self.viewController?.connectionReady(moduleName: "Tacx", ready: true)
            self.ready = true
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.viewController?.connectionReady(moduleName: "Tacx", ready: true)
        if characteristic.uuid == BLE_CSC_Measurement_Characteristic {
            deriveTotalRotations(using: characteristic)
        }
        
    }
    
    // Variables and functions related to calculating total amount of revolutions/rotations.
    
    let maxTime = 65535
    var currentTime = 1;
    var previousTime = 0;
    var timeSinceLastRevolutionCurrent = 0
    
    var previousAmountOfRevolutions = 0
    var currentAmountOfRevolutions = 0
    
    var startAmountOfRotations = 0
    
    func deriveTotalRotations(using BLE_CSC_Measurement_Characteristic: CBCharacteristic) {
        let packet = BLE_CSC_Measurement_Characteristic.value!
        let buffer = [UInt8](packet)
        
        // Extracting the 32 bits of data related to total amount of wheel revolutions.
        
        print("Rotations: \(self.currentAmountOfRevolutions)")
        
        self.previousAmountOfRevolutions = self.currentAmountOfRevolutions
        
        let totalRotationsBytes: [UInt8] = [buffer[1], buffer[2], buffer[3], buffer[4]]
        let totalRotations = UnsafePointer(totalRotationsBytes).withMemoryRebound(to: UInt32.self, capacity: 1) {
            $0.pointee
        }
        
        
        if(self.previousAmountOfRevolutions == 0) {
            self.currentAmountOfRevolutions = Int(totalRotations)
            self.previousAmountOfRevolutions = self.currentAmountOfRevolutions
        } else {
            self.currentAmountOfRevolutions = Int(totalRotations)
        }
        
        let differenceInRotations = self.currentAmountOfRevolutions - self.previousAmountOfRevolutions
        
        // Extracting the 16 bits of data related to the counter variable (1-2^16 milliseconds).
        // -->
        
        let timeCounterBytes: [UInt8] = [buffer[5], buffer[6]]
        let timeCounter = UnsafePointer(timeCounterBytes).withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee
        }
        
        
    
        self.currentTime = Int(timeCounter)
        
        
        
        /*  The time between two data points is currentTime-lastTime. When the count rolls over to zero again it has to be handled differently. Then the time between two data points is instead (currentTime + ((2^16-lastTime)). For example: Time1 = 55 seconds, Time 2 = 2 seconds, TimeMax = 2^16 = 65 seconds -> (2 + (65-55)) = 12 seconds. */
        
        
        if(self.currentTime < self.previousTime) {
            self.timeSinceLastRevolutionCurrent = self.currentTime + self.maxTime - self.previousTime
        } else {
            self.timeSinceLastRevolutionCurrent = self.currentTime - self.previousTime
        }
        
        self.previousTime = self.currentTime
        
        if(self.flag == false) {
            self.startAmountOfRotations = self.currentAmountOfRevolutions
            self.flag = true
        }
        
        // <--
        
            
            // self.rotationTimeLabel.text = "Rotation time: \(self.timeSinceLastRevolutionCurrent)"
        
        
        let doubleTimeSinceLastRevolution = Double(timeSinceLastRevolutionCurrent)
        let doubleDifferenceInRotations = Double(differenceInRotations)
        
        deriveVelocityForTacx(doubleTimeSinceLastRevolution: doubleTimeSinceLastRevolution, doubleDifferenceInRotations: doubleDifferenceInRotations)
        
    }
    
    var currentVelocity = Double(1)
    var previousVelocity = Double(0)
    let wheelDiameter = Double(0.57) // Should be 24 inches in metres but i 57cm.
    var currentDistance = Double()
    var BLEDate = Date()
    
    
    // The velocity is equal to the distance/time which in this case is (wheelDiameter*PI*nrOfRotations) / (timeTaken)
    var totalDistance = Double()
    func deriveVelocityForTacx(doubleTimeSinceLastRevolution: Double, doubleDifferenceInRotations: Double) {
        
        let wheelCircumference = self.wheelDiameter * Double.pi
        
        previousVelocity = currentVelocity
        currentVelocity = ((wheelCircumference * doubleDifferenceInRotations)/((doubleTimeSinceLastRevolution) / 1000)) // m/s
        print("Diff in rotations: \(doubleDifferenceInRotations)")
        currentDistance = Double(doubleDifferenceInRotations)*wheelCircumference
        totalDistance += currentDistance
        self.BLEDate = self.getCurrentTimeBLE()
        
        if(currentVelocity != nil && currentVelocity > 0 && currentVelocity.isNaN != true && currentDistance.isNaN != true) {
            database!.saveData(velocityNumber: self.currentVelocity, distance: Double(self.currentDistance), altitude: 0.0, timeDate: Date(), entityName: "Tacx")
        }
        
        
    }
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connecting:
            print("Peripheral state: connecting")
        case .connected:
            print("Peripheral state: connected")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        @unknown default:
            print("Peripheral state: default")
        }
    }
    
    // BLE.
    
    var currentDateBLE = Date()
    
    func getCurrentTimeBLE() -> Date {
        let currentDateBLE = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDateBLE)
        let minute = calendar.component(.minute, from: currentDateBLE)
        return currentDateBLE
    }
    
    //<-- End of BLE related functions and variables.
    
    //--> Functions related to updating the controller with new values.
    
    func updateController() {
       
    }
    
    func deleteTacxData() {
        self.database!.deleteAllDataFromEntity(entity: "Tacx")
    }
    
}
