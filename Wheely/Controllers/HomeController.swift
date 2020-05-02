//
//  ViewController.swift
//  Wheely
//
//  Created by Student on 2020-03-24.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit
import WatchConnectivity
import HealthKit
import CoreData
import Charts
import MessageUI

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate {
    
    
    //-> Variables and functions relating to UI components.
    
    // Buttons.
    
    
    // Labels.
    
    
    // Charts.
    
    // Collection view variables.
    
    let ids = ["homeFeedCellId", "graphFeedCellId", "energyFeedCellId", "dateFeedCellId"]
    let modelNames = ["Tacx", "GPS", "Accelerometer", "PushRate", "HeartRate"]
    
    var cellsDictionary = [String: UICollectionViewCell]()
    
    //<-- End of IB related variables and functions.
    
    // Declaring the module class variables.
    
    var gpsModule: GPSModule? = nil
    var accelerometerModule: AccelerometerModule? = nil
    var tacxModule: TacxModule? = nil
    var heartRateModule: AppleWatchModule? = nil
    var physicsModule: PhysicsModule? = nil
    
    // Declaring the model class variables.
    
    // Models in home feed
    var homeModel: HomeModel? = nil
    
    // Models in graph feed
    var tacxModelVelocity: SensorModel? = nil
    var gpsModelVelocity: SensorModel? = nil
    var gpsModelAltitude: SensorModel? = nil
    var accelerometerModel: SensorModel? = nil
    var heartRateModel: SensorModel? = nil
    var pushRateModel: SensorModel? = nil
    
    // Models in energy feed
    var physicsModelTacx: PhysicsModel? = nil
    var physicsModelGPS: PhysicsModel? = nil
    var physicsModelEnergy: PhysicsModel? = nil
    var physicsModelActiveEnergy: PhysicsModel? = nil
    var physicsModelEnergyAlternative: PhysicsModel? = nil
    
    // Models in date feed
    var dateModel: DateModel? = nil
    
    // Declaring the database class variable.
    var database: Database? = nil
    
    var feedTypes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialization of view window characteristics.
        
        navigationController?.navigationBar.isTranslucent = false
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-32, height: view.frame.height))
        titleLabel.text = "  Home"
        titleLabel.textColor = .white
        navigationItem.titleView = titleLabel
        
        // Initialize the classes.
        
        setupModules()
        
        setupMenuBar()
        setupNavBarButtons()
        setupModels()
        setupCollectionView()
        
        
    }
    
    // UI related functions.
    
    lazy var menuBar: MenuBar = {
        let menuBar = MenuBar()
        menuBar.homeController = self
        return menuBar
    }()
    private func setupMenuBar() {
        view.addSubview(menuBar)
        menuBar.addConstraintsWithFormat(format: "H:|[v0]|", views: menuBar)
        menuBar.addConstraintsWithFormat(format: "V:|[v0(50)]", views: menuBar)
    }
    
    var homeModels = [HomeModel]()
    var sensorModels = [SensorModel]()
    var physicsModels = [PhysicsModel]()
    var dateModels = [DateModel]()
    
    private func setupModules() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        database = Database(appDelegate: appDelegate)
        tacxModule = TacxModule(viewController: self, database: database!)
        gpsModule = GPSModule(viewController: self, database: database!)
        accelerometerModule = AccelerometerModule(viewController: self, database: database!)
        heartRateModule = AppleWatchModule(viewController: self, database: database!)
        physicsModule = PhysicsModule(database: database!)
    }
    
    private func setupModels() {
        
        homeModel = HomeModel()
        homeModels.append(homeModel!)
        
        tacxModelVelocity = SensorModel()
        gpsModelVelocity = SensorModel()
        gpsModelAltitude = SensorModel()
        accelerometerModel = SensorModel()
        pushRateModel = SensorModel()
        heartRateModel = SensorModel()
        
        sensorModels.append(tacxModelVelocity!)
        sensorModels.append(gpsModelVelocity!)
        sensorModels.append(gpsModelAltitude!)
        sensorModels.append(accelerometerModel!)
        sensorModels.append(pushRateModel!)
        sensorModels.append(heartRateModel!)
        
        physicsModelTacx = PhysicsModel()
        physicsModelGPS = PhysicsModel()
        physicsModelEnergy = PhysicsModel()
        physicsModelActiveEnergy = PhysicsModel()
        physicsModelEnergyAlternative = PhysicsModel()
        physicsModels.append(physicsModelTacx!)
        physicsModels.append(physicsModelGPS!)
//      physicsModels.append(physicsModelEnergy!)
        physicsModels.append(physicsModelActiveEnergy!)
        physicsModels.append(physicsModelEnergyAlternative!)
        
        dateModel = DateModel()
        dateModels.append(dateModel!)
        
    }
    
    private func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        collectionView?.isPagingEnabled = true
        
        collectionView?.backgroundColor = .systemGray6
        
        collectionView?.register(HomeFeedCell.self, forCellWithReuseIdentifier: ids[0])
        collectionView?.register(GraphFeedCell.self, forCellWithReuseIdentifier: ids[1])
        collectionView?.register(EnergyFeedCell.self, forCellWithReuseIdentifier: ids[2])
        collectionView?.register(DateFeedCell.self, forCellWithReuseIdentifier: ids[3])
        
        collectionView?.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = ids[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! FeedCell
        cellsDictionary[id] = cell
        updateAllBetweenDates(startDate: startDate, endDate: endDate)
        cell.homeModels = self.homeModels
        cell.sensorModels = self.sensorModels
        cell.physicsModels = self.physicsModels
        cell.dateModels = self.dateModels
        cell.homeController = self
        cell.collectionView.reloadData()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.leftHorizontalBarAnchorConstraint?.constant = scrollView.contentOffset.x / 4
        collectionView.reloadData()
    }
    
    let titles = ["Home", "Graphs", "Energy","Date"]
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = Int(targetContentOffset.move().x / view.frame.width)
        let indexPath = NSIndexPath(item: index, section: 0)
        
        
        menuBar.collectionView.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: [])
        changeTitleForIndex(index: Int(index))
    }
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: [], animated: true)
        changeTitleForIndex(index: menuIndex)
        
    }
    
    func changeTitleForIndex(index: Int) {
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "  \(titles[index])"
        }
    }
    
    //--> Functions related to getting updates from the models.
    
    var lineChartEntry = [ChartDataEntry]()
    func makeLineChartEntry(data: [NSManagedObject], key: String) -> [ChartDataEntry]{
        lineChartEntry.removeAll()
        var counter = 1
        var startTime = 0
        let calendar = Calendar.current
        for object in data {
            let date = object.value(forKey: "time")
            
            let currentTimeInSeconds = getTotalSecondsFromDate(seconds: calendar.component(.second, from: date as! Date), minutes: calendar.component(.minute, from: date as! Date), hours: calendar.component(.hour, from: date as! Date))
            
            if(counter == 1) {
                startTime = Int(currentTimeInSeconds)
            }
            
            // Handle different entities
            
            var value = ChartDataEntry()
            
            let valueOfObject = object.value(forKey: key)
            value = ChartDataEntry(x: Double(Int(currentTimeInSeconds) - startTime + 1), y: valueOfObject as! Double)
            
            
            lineChartEntry.append(value)
            counter+=1
        }
        return self.lineChartEntry
    }
    
    func getTotalSecondsFromDate(seconds: Int, minutes: Int, hours: Int) -> Double {
        
        let totalSeconds = (seconds) + (minutes * 60) + (hours * 3600)
        return Double(totalSeconds)
    }
    
    func updateGraphWithValues(indexOfModel: Int) {
        let lineOne = LineChartDataSet(entries: lineChartEntry, label: modelNames[indexOfModel])
        lineOne.colors = [NSUIColor.blue]
        
        let data = LineChartData()
        data.addDataSet(lineOne)
        
        sensorModels[indexOfModel].data = data
        sensorModels[indexOfModel].title = modelNames[indexOfModel]
    }
    
    func setupNavBarButtons() {
        let settingsImage = UIImage(named: "wrench")
        
        let settingsBarButtonItem = UIBarButtonItem(image: settingsImage, style: .plain, target: self, action: #selector(handleSettings))
        settingsBarButtonItem.tintColor = UIColor(ciColor: .white)
        navigationItem.rightBarButtonItems = [settingsBarButtonItem]
    }
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    @objc func handleSettings() {
        settingsLauncher.showSettings()
    }
    
    var startDate = Date()
    var endDate = Date()
    
    var calendar = Calendar.current
    
    func startSession() {
        print("Session started")
        startDate = Date()
        DispatchQueue.main.async {
            //self.setupModules()
            
            self.tacxModule?.startBLE()
            self.gpsModule?.startGPS()
            self.accelerometerModule?.startAccelerometer()
            self.heartRateModule?.startWatchSession()
        }
        
    }
    
    func endSession() {
        print("Session ended")
        endDate = Date()
        tacxModule?.stopBLE()
        gpsModule?.stopGPS()
        accelerometerModule?.stopAccelerometer()
        heartRateModule?.stopWatchSession(endDate: self.endDate)
        saveSessionToDatabase()
        physicsModule?.calculateEnergyExpenditure(startDate: startDate, endDate: endDate)
        DispatchQueue.main.async {
            self.connectionNotReady()
        }
        
    }
    
    func deleteAllData() {
        print("Delete data...")
        tacxModule?.deleteTacxData()
        gpsModule?.deleteGPSData()
        accelerometerModule?.deleteAccelerometerData()
        heartRateModule?.deleteHeartRateData()
        database!.deleteAllDataFromEntity(entity: "Session")
        scrollToMenuIndex(menuIndex: 0)
    }
    
    func saveSessionToDatabase() {
        database!.saveData(startDate: startDate, endDate: endDate, entity: "Session")
    }
    
    func makeSessionModelFromDatabase() -> [SessionModel] {
        
        var sessions = [SessionModel]()
        
        let objects = self.database!.getAllData(entity: "Session", type: "session")
        
        for dates in objects {
            let startDate = dates.value(forKey: "startDate") as! Date
            let endDate = dates.value(forKey: "endDate") as! Date
            
            let session = SessionModel()
            session.startDate = startDate
            session.endDate = endDate
            sessions.append(session)
        }
        
        return sessions
    }
    
    func makeSensorModelFromDatabase(entity: String, type: String, startDate: Date, endDate: Date, indexOfModule: Int, key: String) -> SensorModel {
        let model = SensorModel()
        
        let newData = database!.readDataBetweenDates(entity: entity, startDate: startDate as NSDate, endDate: endDate as NSDate, sortDescriptorKey: "time")
        
        var lineOne: LineChartDataSet?
        
        if(newData.count == 0) {
            var entries = [ChartDataEntry]()
            let value = ChartDataEntry(x: 0, y: 0)
            entries.append(value)
            lineOne = LineChartDataSet(entries: entries, label: modelNames[indexOfModule])
        } else {
            lineOne = LineChartDataSet(entries: makeLineChartEntry(data: newData, key: key), label: modelNames[indexOfModule])
        }
        
        lineOne!.colors = [NSUIColor.blue]
        
        let data = LineChartData()
        data.addDataSet(lineOne)
        
        model.data = data
        model.title = modelNames[indexOfModule] + " - " + type
        
        return model
    }
    
    func makePhysicsModelFromDatabase(entity: String, type: String, startDate: Date, endDate: Date, indexOfModule: Int, key: String, sortDescriptorKey: String, title: String) -> PhysicsModel {
        let model = PhysicsModel()
        
        let data = database!.readDataBetweenDates(entity: entity, startDate: startDate as NSDate, endDate: endDate as NSDate, sortDescriptorKey: sortDescriptorKey)
        
        var totalValue = Double()

        for object in data {
            let value = object.value(forKey: key) as! Double
            totalValue += value
        }
        model.value = totalValue
        model.title = title
        return model
    }
    
    func updateAll() {
        // Date
        // Create new model to update cell with.
        let dateModel = DateModel()
        dateModel.sessions = makeSessionModelFromDatabase()
        self.dateModels.removeAll()
        self.dateModels.append(dateModel)
    }
    
    func updateAllBetweenDates(startDate: Date, endDate: Date) {
        // Updating date cell
        self.startDate = startDate
        self.endDate = endDate
        
        DispatchQueue.main.async {
            let dateModel = DateModel()
            dateModel.sessions = self.makeSessionModelFromDatabase()
            dateModel.title = "Choose dates"
            self.dateModels.removeAll()
            self.dateModels.append(dateModel)
            
            let tacxModelVelocity = self.makeSensorModelFromDatabase(entity: "Tacx", type: "Velocity vs Time", startDate: startDate, endDate: endDate, indexOfModule: 0, key: "velocity")
            let gpsModelVelocity = self.makeSensorModelFromDatabase(entity: "GPS", type: "Velocity vs Time", startDate: startDate, endDate: endDate, indexOfModule: 1, key: "velocity")
            let gpsModelAltitude = self.makeSensorModelFromDatabase(entity: "GPS", type: "Altitude vs Time", startDate: startDate, endDate: endDate, indexOfModule: 1, key: "altitude")
            let accelerometerModel = self.makeSensorModelFromDatabase(entity: "Accelerometer", type: "Acceleration vs Time", startDate: startDate, endDate: endDate, indexOfModule: 2, key: "accelerationY")
            let pushRateModel = self.makeSensorModelFromDatabase(entity: "PushCount", type: "Pushes vs Time", startDate: startDate, endDate: endDate, indexOfModule: 3, key: "pushCount")
            let heartRateModel = self.makeSensorModelFromDatabase(entity: "HeartRate", type: "BPM vs Time", startDate: startDate, endDate: endDate, indexOfModule: 4, key: "heartRate")
            
            self.sensorModels.removeAll()
            self.sensorModels.append(tacxModelVelocity)
            self.sensorModels.append(gpsModelVelocity)
            self.sensorModels.append(gpsModelAltitude)
            self.sensorModels.append(accelerometerModel)
            self.sensorModels.append(pushRateModel)
            self.sensorModels.append(heartRateModel)
            
            let physicsModelTacx = self.makePhysicsModelFromDatabase(entity: "Tacx", type: "velocity", startDate: startDate, endDate: endDate, indexOfModule: 0, key: "distance", sortDescriptorKey: "time", title: "Tacx distance travelled")
            let physicsModelGPS = self.makePhysicsModelFromDatabase(entity: "GPS", type: "velocity", startDate: startDate, endDate: endDate, indexOfModule: 1, key: "distance", sortDescriptorKey: "time", title: "GPS distance travelled")
//            let physicsModelEnergy = self.makePhysicsModelFromDatabase(entity: "Energy", type: "energyExpenditure", startDate: startDate, endDate: endDate, indexOfModule: 2, key: "energyExpenditure", sortDescriptorKey: "startTime", title: "Tacx energy Expenditure")
            let physicsModelActiveEnergy = self.makePhysicsModelFromDatabase(entity: "ActiveEnergy", type: "energyExpenditure", startDate: startDate, endDate: endDate, indexOfModule: 3, key: "energyExpenditure", sortDescriptorKey: "startTime", title: "Apple Energy Expenditure")
            let physicsModelAlternativeEnergy = self.makePhysicsModelFromDatabase(entity: "Energy", type: "alternativeEnergyExpenditure", startDate: startDate, endDate: endDate, indexOfModule: 3, key: "alternativeEnergyExpenditure", sortDescriptorKey: "startTime", title: "Tacx Energy Expenditure")
            
            self.physicsModels.removeAll()
            self.physicsModels.append(physicsModelTacx)
            self.physicsModels.append(physicsModelGPS)
//          self.physicsModels.append(physicsModelEnergy)
            self.physicsModels.append(physicsModelActiveEnergy)
            self.physicsModels.append(physicsModelAlternativeEnergy)

        }
    }
    
    func exportAllData() -> String? {
//        let exportDataTacx = createExportString(entity: "Tacx", type: "Tacx - Velocity",key: "velocity", sortDescriptorKey: "time")
//        let exportDataTacxDistance = createExportString(entity: "Tacx", type: "Tacx - Distance covered at time", key: "distance", sortDescriptorKey: "time")
//        let exportDataGPS = createExportString(entity: "GPS", type: "GPS - Velocity", key: "velocity", sortDescriptorKey: "time")
//        let exportDataGPSDistance = createExportString(entity: "GPS", type: "GPS - Distance covered at time", key: "distance", sortDescriptorKey: "time")
//        let exportDataGPSAltitude = createExportString(entity: "GPS", type: "GPS - Altitude", key: "distance", sortDescriptorKey: "time")
//        let exportDataAccelerometer = createExportString(entity: "Accelerometer", type: "Accelerometer - Acceleration", key: "accelerationY", sortDescriptorKey: "time")
//        let exportDataHeartRate = createExportString(entity: "HeartRate", type: "Apple Watch - Heart-rate", key: "heartRate", sortDescriptorKey: "time")
////        let exportDataEnergyExpenditure = createExportString(entity: "Energy", type: "Energy expenditure", key: "energyExpenditure", sortDescriptorKey: "startTime")
//        let exportDataEnergyExpenditureAlternative = createExportString(entity: "Energy", type: "Energy expenditure alternative", key: "alternativeEnergyExpenditure", sortDescriptorKey: "startTime")
//        let exportDataEnergyExpenditureApple = createExportString(entity: "ActiveEnergy", type: "Energy expenditure Apple", key: "energyExpenditure", sortDescriptorKey: "startTime")
//        let exportDataPushCount = createExportString(entity: "PushCount", type: "Push count at time", key: "pushCount", sortDescriptorKey: "time")
        
//        let allExportData = (exportDataTacx! + exportDataGPS! + exportDataAccelerometer! + exportDataHeartRate! + exportDataPushCount! + exportDataGPSAltitude! + exportDataTacxDistance! + exportDataGPSDistance! + exportDataEnergyExpenditureAlternative! + exportDataEnergyExpenditureApple!) as String
        
        let sessions = makeSessionModelFromDatabase()
        
        guard sessions.count > 0 else {
            return nil
        }
        
        let composer = MFMailComposeViewController()
        composer.setToRecipients(["abelladaniel1@gmail.com"])
        
       
            
        
        
        var entityDataArrayForSession = [String]()
        
        var entities = ["Tacx", "GPSV", "GPSA", "Accelerometer", "HeartRate", "PushCount"]
        var key = ["velocity", "velocity", "altitude", "accelerationY", "heartRate", "pushCount"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        
        var counterSession = 1
        for session in sessions {
            entityDataArrayForSession = (createNewExportData(session: session))
            
            for i in 0..<entityDataArrayForSession.count {
                composer.addAttachmentData(entityDataArrayForSession[i].data(using: .utf8)!, mimeType: "text/csv", fileName: entities[i] + dateFormatter.string(from: session.startDate!) + ".csv")
            }
            counterSession += 1
        }
        
//        let allExportData = createNewExportData()!
        
//        let data = allExportData.data(using: .utf8)!
        
        
        
        
//        composer.addAttachmentData(data, mimeType: "text/csv", fileName: "sensorData.csv")
        composer.mailComposeDelegate = self
        
        self.present(composer, animated: true, completion: nil)
        
        return "Done"
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createNewExportData(session: SessionModel) -> [String] {
        // Each session needs to be handled.
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd - HH:mm:ss"
        
        
        
        var totalExportContent = ""
        var csvHeader = "T1, TACXV, T2, GPSV, T3, GPSA, T4, ACC, T5, HR, T6, PR" + "\n"
        var csvHeaders = ["T1, TACXV", "T2, GPSV", "T3, GPSA", "T4, ACC", "T5, HR", "T6, PR"]
        var entities = ["Tacx", "GPS", "GPS", "Accelerometer", "HeartRate", "PushCount"]
        var key = ["velocity", "velocity", "altitude", "accelerationY", "heartRate", "pushCount"]
        
        var entityContents = [String]()
        
        var entityString = [String]()
        
            for i in 0 ..< entities.count {
                let entityExport = createExportString(entity: entities[i], key: key[i], sortDescriptorKey: "time", session: session)!
                entityString.append(entityExport)
            }
        
        
        for i in 0..<entityString.count {
            entityContents.append(csvHeaders[i] + "\n" + entityString[i])
        }
        
        return entityContents
    }
    
    func createExportString(entity: String, key: String, sortDescriptorKey: String, session: SessionModel) -> String? {
        // Each session needs to be handled.
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd - HH:mm:ss"
        
        var totalExportContent = ""
        
            let startDate = session.startDate!
            let endDate = session.endDate!
            
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            let objectsInSession = database!.readDataBetweenDates(entity: entity, startDate: startDate as NSDate, endDate: endDate as NSDate, sortDescriptorKey: sortDescriptorKey)
            
            var value = Double()
            var date = Date()
            
            var startDateValue = Date()
            var endDateValue = Date()
            
            var csvContent = ""
       
            if((entity != "Energy") && (entity != "ActiveEnergy")) {
                var currentDate = Date()
                var counter = 0
                var timeAt = 0.0
                for object in objectsInSession {
                    
                    value = object.value(forKey: key) as! Double
                    date = object.value(forKey: "time") as! Date
                    if(counter == 0) {
                        currentDate = date
                    }
                    
                    let timeSinceLastDate = (date.timeIntervalSince(currentDate))
                    timeAt += timeSinceLastDate
                    let currentTimeAt = timeAt.string
                    currentDate = date
                    let valueString = String(value)
                    counter += 1
//                    let dateString = dateFormatter.string(from: date)
                    
                    csvContent += currentTimeAt + "," + valueString + "\n"
                }
            } else {
                
                if(entity == "Energy") {
                    for object in objectsInSession {
                        value = object.value(forKey: "energyExpenditure") as! Double
                        let alternativeValue = object.value(forKey: "alternativeEnergyExpenditure") as! Double
                        startDateValue = object.value(forKey: "startTime") as! Date
                        endDateValue = object.value(forKey: "endTime") as! Date
                        let valueString = String(value)
                        let alternativeValueString = String(alternativeValue)
                        let dateStringStart = dateFormatter.string(from: startDate)
                        let dateStringEnd = dateFormatter.string(from: endDate)
                        
                        csvContent += valueString + "," + alternativeValueString + "\n"
                    }
                } else { // Active energy
                    for object in objectsInSession {
                        
                        value = object.value(forKey: "energyExpenditure") as! Double
                        startDateValue = object.value(forKey: "startTime") as! Date
                        endDateValue = object.value(forKey: "endTime") as! Date
                        let valueString = String(value)
                        let dateStringStart = dateFormatter.string(from: startDate)
                        let dateStringEnd = dateFormatter.string(from: endDate)
                        
                        csvContent += valueString + "," + dateStringStart + "\n"
                    }
                }

            }
            
            totalExportContent = (csvContent)
        
        return totalExportContent
    }
    
    func createSessionBasedString(session: SessionModel, entities: [String], key: [String]) {
        
        var objects = [[NSManagedObject]]()
        
        let startDate = session.startDate!
        let endDate = session.endDate!
        
        // Import all the objects that need to be evaluated. Tacx, GPS, Acc etc..
        
        for i in 0..<entities.count {
            let object = database!.readDataBetweenDates(entity: entities[i], startDate: startDate as NSDate, endDate: endDate as NSDate, sortDescriptorKey: "time")
            objects.append(object)
        }
        
        var csvHeaders = ["T1, TACXV", "T2, GPSV", "T3, GPSA", "T4, ACC", "T5, HR"]
        
        
            for i in 0..<csvHeaders.count {
                
                
            }
        
        
        
        
    }
    
    
    
    func showUserProfile() {
        let profileController = ProfileController()
        profileController.database = self.database
        profileController.modalPresentationStyle = .fullScreen
        present(profileController, animated: true) {
            // Might use later.
        }
    }
    
    func showTutorial() {
        let launchController = LaunchController(homeController: self)
        launchController.modalPresentationStyle = .fullScreen
        present(launchController, animated: true)
    }
    
    var tacxModuleReady = false
    var accelerometerModuleReady = false
    var gpsModuleReady = false
    var heartRateModuleReady = false
    
    func connectionReady(moduleName: String, ready: Bool) {
        switch(moduleName) {
        case "Tacx":
            print("Tacx ready")
            tacxModuleReady = true
            break
        case "Accelerometer":
            print("Accelerometer ready")
            accelerometerModuleReady = true
            break
        case "GPS":
            print("GPS ready")
            gpsModuleReady = true
            break
        case "HeartRate":
            print("HeartRate ready")
            heartRateModuleReady = true
            break
        default:
            break
        }
        
        if(tacxModuleReady && gpsModuleReady && heartRateModuleReady && accelerometerModuleReady) {
            let homeModel = homeModels[0]
            homeModel.ready = true
            homeModels.removeAll()
            homeModels.append(homeModel)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
            }
        }
        
    }
    
    func connectionNotReady() {
        tacxModuleReady = false
        tacxModule?.ready = false
        gpsModuleReady = false
        gpsModule?.ready = false
        accelerometerModuleReady = false
        accelerometerModule?.ready = false
        heartRateModuleReady = false
        heartRateModule?.ready = false
        
        let homeModel = homeModels[0]
        homeModel.ready = false
        homeModels.removeAll()
        homeModels.append(homeModel)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    var activeEnergy = 0.0
    func updateActiveEnergyBurned(activeEnergy: Double) {
        DispatchQueue.main.async {
            self.database!.saveData(entity: "ActiveEnergy", energy: activeEnergy, alternativeEnergy: 0.0, startDate: self.startDate, endDate: self.endDate)
        }
    }
}




