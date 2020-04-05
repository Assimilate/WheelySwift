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
    
    init(viewController: HomeController, database: Database) {
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
    
    //--> BLE related functions and variables, communicating with the TacX Speed and Cadence sensor.
    
    
    func startBLE() {
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.wheely.centralQueue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func stopBLE() {
        centralManager?.cancelPeripheralConnection(peripheralDevice!)
        updateController()
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
        print(peripheral.name!)
        decodePeripheralState(peripheralState: peripheral.state)
        peripheralDevice = peripheral
        peripheralDevice?.delegate = self
        centralManager?.stopScan()
        centralManager?.connect(peripheralDevice!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralDevice?.discoverServices([BLE_Cycling_Speed_And_Cadence_Service])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected.")
        centralManager?.scanForPeripherals(withServices: [BLE_Cycling_Speed_And_Cadence_Service])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == BLE_Cycling_Speed_And_Cadence_Service {
                print("Service: \(service)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print(characteristic)
            
            if characteristic.uuid == BLE_CSC_Measurement_Characteristic {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
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
    var currentAmountOfRevolutions = 1
    
    func deriveTotalRotations(using BLE_CSC_Measurement_Characteristic: CBCharacteristic) {
        let packet = BLE_CSC_Measurement_Characteristic.value!
        let buffer = [UInt8](packet)
        
        // Extracting the 32 bits of data related to total amount of wheel revolutions.
        
        self.previousAmountOfRevolutions = self.currentAmountOfRevolutions
        
        let totalRotationsBytes: [UInt8] = [buffer[1], buffer[2], buffer[3], buffer[4]]
        let totalRotations = UnsafePointer(totalRotationsBytes).withMemoryRebound(to: UInt32.self, capacity: 1) {
            $0.pointee
        }
        
        self.currentAmountOfRevolutions = Int(totalRotations)
        
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
        
        // <--
        DispatchQueue.main.async {
            // self.rotationsLabel.text = "Rotations: \(self.currentAmountOfRevolutions)"
            // self.rotationTimeLabel.text = "Rotation time: \(self.timeSinceLastRevolutionCurrent)"
        }
        
        let doubleTimeSinceLastRevolution = Double(timeSinceLastRevolutionCurrent)
        let doubleDifferenceInRotations = Double(differenceInRotations)
        
        deriveVelocityForTacx(doubleTimeSinceLastRevolution: doubleTimeSinceLastRevolution, doubleDifferenceInRotations: doubleDifferenceInRotations)
        
    }
    
    var currentVelocity = Double(1)
    var previousVelocity = Double(0)
    let wheelDiameter = Double(0.6096) // 24 inches in metres.
    var BLEDate = Date()
    
    
    // The velocity is equal to the distance/time which in this case is (wheelDiameter*PI*nrOfRotations) / (timeTaken)
    
    func deriveVelocityForTacx(doubleTimeSinceLastRevolution: Double, doubleDifferenceInRotations: Double) {
        
        let wheelCircumference = self.wheelDiameter * Double.pi
        
        previousVelocity = currentVelocity
        currentVelocity = ((wheelCircumference * doubleDifferenceInRotations)/((doubleTimeSinceLastRevolution) / 1000)) // m/s
        
        if(currentVelocity != nil && currentVelocity > 0) {
            database!.saveData(velocityNumber: self.currentVelocity, timeDate: self.BLEDate, entity: "Tacx")
            
        }
        
        
        self.BLEDate = self.getCurrentTimeBLE()
        
        
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
        DispatchQueue.main.async {
            self.viewController?.updateFromTacx(data: self.database!.getData(entity: "Tacx", type: "velocity"))
        }
    }
    
}
