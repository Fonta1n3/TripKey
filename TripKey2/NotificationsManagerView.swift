//
//  NotificationsManagerView.swift
//  TripKey2
//
//  Created by Peter on 2/11/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class NotificationsManagerView: UIView {
    
    
    @IBAction func twoDaysBeforeFlight(_ sender: Any) {
        
        print("twoDaysBeforeFlight = \(twoDays.isOn)")
        UserDefaults.standard.set(twoDays.isOn, forKey: "twoDays")
        print("twoDays = \(UserDefaults.standard.bool(forKey: "twoDays"))")
    }
    
    @IBOutlet var twoDays: UISwitch!
    @IBOutlet var fourHours: UISwitch!
    @IBOutlet var twoHours: UISwitch!
    @IBOutlet var oneHour: UISwitch!
    @IBOutlet var takeOff: UISwitch!
    @IBOutlet var landing: UISwitch!
    
    @IBAction func landingNotificationAction(_ sender: Any) {
        
        print("landingNotificationAction = \(landing.isOn)")
        UserDefaults.standard.set(landing.isOn, forKey: "landing")
        print("landing = \(UserDefaults.standard.bool(forKey: "landing"))")
        
        
    }
    
    @IBAction func takeOffNotificationAction(_ sender: Any) {
        
        print("takeOffNotificationAction = \(takeOff.isOn)")
        UserDefaults.standard.set(takeOff.isOn, forKey: "takeOff")
        print("takeOff = \(UserDefaults.standard.bool(forKey: "takeOff"))")
        
    }
    @IBAction func fourHoursBeforeFlight(_ sender: Any) {
        print("fourHoursBeforeFlight = \(fourHours.isOn)")
        UserDefaults.standard.set(fourHours.isOn, forKey: "fourHours")
        print("fourHours = \(UserDefaults.standard.bool(forKey: "fourHours"))")
        
    }
    
    @IBAction func twoHoursBeforeFlight(_ sender: Any) {
        print("twoHoursBeforeFlight = \(twoHours.isOn)")
        UserDefaults.standard.set(twoHours.isOn, forKey: "twoHours")
        print("twoHours = \(UserDefaults.standard.bool(forKey: "twoHours"))")
    }
    
    @IBAction func oneHourBeforeFlight(_ sender: Any) {
        print("oneHourBeforeFlight = \(oneHour.isOn)")
        UserDefaults.standard.set(oneHour.isOn, forKey: "oneHour")
        print("oneHour = \(UserDefaults.standard.bool(forKey: "oneHour"))")

    }

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
