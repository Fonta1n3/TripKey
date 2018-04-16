//
//  ArrivalInfoWindow.swift
//  TripKey2
//
//  Created by Peter on 1/10/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class ArrivalInfoWindow: UIView {
    
    @IBOutlet weak var flightDragged: UIPanGestureRecognizer!
    @IBOutlet var directions: UIButton!
    @IBOutlet var flightAmenities: UIButton!
    @IBOutlet var share: UIButton!
    @IBOutlet var call: UIButton!
    @IBOutlet var deleteFlight: UIButton!
    

    @IBOutlet var terminalLabel: UILabel!
   
    @IBOutlet var baggageLabel: UILabel!
    @IBOutlet var gateLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var arrivalWeatherImage: UIImageView!
    
    @IBOutlet var arrivalFlightNumber: UILabel!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var midView: UIView!
    @IBOutlet var arrivalFlightDurationLabel: UILabel!
    @IBOutlet var arrivalTemperature: UILabel!
    @IBOutlet var topView: UIView!
    
    @IBOutlet var arrivalAirportCode: UILabel!
    
    @IBOutlet var arrivalStatus: UILabel!
    
    @IBOutlet var arrivalTime: UILabel!
    
    @IBOutlet var arrivalDistance: UILabel!
    
    @IBOutlet var arrivalDelayTime: UILabel!

    @IBOutlet var arrivalCoutdownView: UIView!
    @IBOutlet var arrivalMins: UILabel!
    @IBOutlet var arrivalHours: UILabel!
    @IBOutlet var arrivalHoursLabel: UILabel!
    @IBOutlet var arrivalMonths: UILabel!
    
    @IBOutlet var arrivaldays: UILabel!
    
    @IBOutlet var arrivalMonthsLabel: UILabel!
    
    @IBOutlet var arrivalMinsLabel: UILabel!
    
    @IBOutlet var arrivalSeconds: UILabel!
    
    @IBOutlet var arrivalSecondsLabel: UILabel!
    
    @IBOutlet var arrivalDaysLabel: UILabel!
    
    @IBOutlet var arrivalGate: UILabel!
    
    @IBOutlet var arrivalCountdownLabel: UILabel!
    
    @IBOutlet var arrivalBaggageClaim: UILabel!
    @IBOutlet var arrivalFlightDuration: UILabel!
    @IBOutlet var arrivalTerminal: UILabel!
}
