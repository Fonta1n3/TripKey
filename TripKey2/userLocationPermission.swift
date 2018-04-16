//
//  userLocationPermission.swift
//  TripKey
//
//  Created by Peter on 6/7/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class userLocationPermission: UIView {
    
    var update: ((UIView) -> Void)?

    @IBOutlet var disclaimerLabel: UILabel!
    
    @IBOutlet var shareLocation: UISwitch!
    
    @IBOutlet var save: UIButton!
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
