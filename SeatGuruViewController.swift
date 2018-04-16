//
//  SeatGuruViewController.swift
//  TripKey2
//
//  Created by Peter on 12/28/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds

class SeatGuruViewController: UIViewController {
    
    var selectedFlight:Dictionary<String,String>!
    var carrierCode:String!
    var flightNumber:String!
    var departureDate:String!
    var airlineName:String!
    var flights:[Dictionary<String,String>]!
    @IBOutlet var webView: UIWebView!
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //googleBanner.adUnitID = "ca-app-pub-1006371177832056/4508293729"
        //googleBanner.rootViewController = self
        //googleBanner.load(GADRequest())
        
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        
        if UserDefaults.standard.object(forKey: "selectedFlight") != nil {
            
            
            selectedFlight = UserDefaults.standard.object(forKey: "selectedFlight") as! Dictionary<String, String>!
            
        }
        
        if UserDefaults.standard.object(forKey: "flights") != nil {
            
            
            flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String, String>]!
            
        }

        getSeatGuru()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getSeatGuru() {
        
        carrierCode = selectedFlight["Airline Code"]!
        flightNumber = selectedFlight["Flight Number"]!
        let departureDateUnformatted = selectedFlight["Published Departure"]!
        departureDate = formatDate(date: departureDateUnformatted)
        let departureAirportCode = selectedFlight["Departure Airport Code"]!
        let arrivalAirportCode = selectedFlight["Arrival Airport Code"]!
       
        
        let url = URL(string: "https://www.google.com/flights/#search;f=" + departureAirportCode + ";t=" + arrivalAirportCode + ";d=" + departureDate + ";r=;tt=o;sel=" + departureAirportCode + arrivalAirportCode + "0" + carrierCode + flightNumber)
        
        let request = NSURLRequest(url: url!)
        
        webView.loadRequest(request as URLRequest)
        
    }
    
    func formatDate(date: String) -> String {
        
        let datearray = date.components(separatedBy: "T")
        let dateOnly = datearray[0]
        let dateComponents = dateOnly.components(separatedBy: "-")
        let year = dateComponents[0]
        let month = dateComponents[1]
        let day = dateComponents[2]
        
        let departureDateURL = "\(year)-\(month)-\(day)"
        
        return departureDateURL
    }
    
    func didFlightAlreadyTakeoff (departureDate: String, utcOffset: String) -> (Bool) {
        
        // here we set the current date to UTC
        let date = NSDate()
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        var utcInterval = secondsFromGMT
        
        if utcInterval < 0 {
            
            utcInterval = abs(utcInterval)
            
        } else if utcInterval > 0 {
            
            utcInterval = utcInterval * -1
            
        } else if utcInterval == 0 {
            
            utcInterval = 0
        }
        
        //here we set arrival date to utc and convert from string to date and compare the dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let currentDateUtc = date.addingTimeInterval(TimeInterval(utcInterval))
        let departureDateUtc = self.getUtcTime(time: departureDate, utcOffset: utcOffset)
        
        let departureDateUtcDate = dateFormatter.date(from: departureDateUtc)
        
        if departureDateUtcDate! < currentDateUtc as Date {
            
            return true
            
        } else {
            
            return false
        }
        
    }

    func getUtcTime(time: String, utcOffset: String) -> (String) {
        
        //here we change departure date to UTC time
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        let departureDateTime = departureDateFormatter.date(from: time)
        
        var utcInterval = (Double(utcOffset)! * 60 * 60)
        
        if utcInterval < 0 {
            
            utcInterval = abs(utcInterval)
            
        } else if utcInterval > 0 {
            
            utcInterval = utcInterval * -1
            
        } else if utcInterval == 0 {
            
            utcInterval = 0
        }
        
        let departureDateUtc = departureDateTime!.addingTimeInterval(utcInterval)
        let utcTime = departureDateFormatter.string(from: departureDateUtc)
        
        return utcTime
    }

}
