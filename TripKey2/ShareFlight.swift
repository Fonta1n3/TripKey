//
//  ShareFlight.swift
//  TripKey
//
//  Created by Peter on 07/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import Parse

class ShareFlight {
    
    static let sharedInstance = ShareFlight()
    var errorBool = Bool()
    
    func shareFlight(flightToShare: [String:Any], toUserID: String, completion: @escaping () -> Void) {
        
        let flight = FlightStruct(dictionary: flightToShare)
        let departureDate = convertDateTime(date: flight.departureDate)
        let flightNumber = flight.flightNumber
        let airlineCode = flight.airlineCode
        
        let sharedFlight = PFObject(className: "SharedFlight")
        sharedFlight["shareToUsername"] = toUserID
        sharedFlight["shareFromUsername"] = PFUser.current()?.username
        sharedFlight["departureDate"] = departureDate
        sharedFlight["airlineCode"] = airlineCode
        sharedFlight["flightNumber"] = flightNumber
        sharedFlight["flightDictionary"] = flightToShare
        
        sharedFlight.saveInBackground(block: { (success, error) in
            
            if error != nil {
                
                self.errorBool = true
                completion()
                
            } else {
                
                self.errorBool = false
                completion()
                
            }
        })
        
    }
    
    private init() {
        
    }
}
