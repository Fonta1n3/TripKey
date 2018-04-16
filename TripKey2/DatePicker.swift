//
//  DatePicker.swift
//  TripKey
//
//  Created by Peter on 7/1/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class DatePicker: UIView {
    
    var save: ((UIView) -> Void)?
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var exit: UIButton!

    @IBOutlet var saveButton: UIButton!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
