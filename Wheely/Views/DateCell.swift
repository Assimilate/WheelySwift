//
//  DateCell.swift
//  Wheely
//
//  Created by Student on 2020-04-10.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class DateCell: BaseCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var dateFormatter: DateFormatter?
    var selectedRow = 0
    
    var date: DateModel? {
        didSet {
            //self.datePicker = date?.datePicker as! UIDatePicker
            print("Did set date model")
            self.dateButton.titleLabel?.text = date?.title
            self.sessions = date?.sessions
        }
    }
    
    var sessions: [SessionModel]? {
        didSet {
            self.datePicker.reloadAllComponents()
        }
    }
    
    var datePicker: UIPickerView = {
        let datePicker = UIPickerView()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.backgroundColor = .systemGray6
        return datePicker
    }()
    
    let dateButton: UIButton = {
        let dateButton = UIButton(type: .system)
        dateButton.backgroundColor = .systemGray5
        dateButton.setTitle("Choose dates", for: .normal)
        dateButton.setTitleColor(.black, for: .normal)
        return dateButton
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(datePicker)
        addSubview(separatorView)
        addSubview(dateButton)
        
        dateButton.addTarget(self, action: #selector(datePicked), for: .touchUpInside)
        datePicker.delegate = self
        datePicker.dataSource = self
    
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: datePicker)
        addConstraintsWithFormat(format: "H:|-16-[v0(40)]-16-|", views: dateButton)
        addConstraintsWithFormat(format: "V:|-16-[v0]-16-[v1(40)]-[v2(1)]|", views: datePicker, dateButton, separatorView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
    }
    
    @objc func datePicked() {
        if(sessions!.count > 0) {
            self.homeController?.updateAllBetweenDates(startDate: (self.sessions?[selectedRow].startDate)! , endDate: (self.sessions?[selectedRow].endDate)!)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = sessions?.count ?? 0
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var info = UILabel()
        if let view = view {
            info = view as! UILabel
        }
        info.font = UIFont.systemFont(ofSize: 13)
        info.textColor = .black
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .short
        dateFormatter.timeZone = .current
        
        let startDate = dateFormatter.string(from: (sessions?[row].startDate)!)
        let endDate = dateFormatter.string(from: (sessions?[row].endDate)!)
        
        let dateString = startDate + " - " + endDate
        
        info.text = dateString
        info.textAlignment = .center
        
        return info
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
    }
    

    
}
