//
//  DateModel.swift
//  Wheely
//
//  Created by Student on 2020-04-10.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class SessionModel: NSObject {
    var startDate: Date?
    var endDate: Date?
}

class DateModel {
    
    var datePicker: UIPickerView?
    var sessions: [SessionModel]?
    var title: String?
    
}
