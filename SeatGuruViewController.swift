//
//  SeatGuruViewController.swift
//  TripKey2
//
//  Created by Peter on 12/28/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import MapKit

class SeatGuruViewController: UIViewController {
    
    var selectedFlight:[String:Any]!
    var carrierCode:String!
    var flightNumber:String!
    var departureDate:String!
    var airlineName:String!
    @IBOutlet var webView: UIWebView!
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "userSwipedBack")
        getSeatGuru()
    }

    func getSeatGuru() {
        carrierCode = selectedFlight["airlineCode"] as! String
        flightNumber = selectedFlight["flightNumber"] as! String
        let departureDateUnformatted = selectedFlight["publishedDeparture"] as! String
        departureDate = formatDate(date: departureDateUnformatted)
        let departureAirportCode = selectedFlight["departureAirport"] as! String
        let arrivalAirportCode = selectedFlight["arrivalAirportCode"] as! String
        let url = URL(string: "https://www.google.com/flights/#search;f=" + departureAirportCode + ";t=" + arrivalAirportCode + ";d=" + departureDate + ";r=;tt=o;sel=" + departureAirportCode + arrivalAirportCode + "0" + flightNumber)
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
}
