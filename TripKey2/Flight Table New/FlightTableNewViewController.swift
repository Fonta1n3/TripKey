//
//  FlightTableNewViewController.swift
//  TripKey
//
//  Created by Peter on 12/11/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import Parse

class FlightTableNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    @IBOutlet var actionLabel: UILabel!
    @IBOutlet var callLabel: UILabel!
    let pointOfInterest = UIView()
    var formattedFlightNumber:String!
    var formattedDepartureDate:String!
    var users = [String: String]()
    var userNames = [String]()
    var activityIndicator:UIActivityIndicatorView!
    var flights = [Dictionary<String,String>]()
    var airlineCodeURL:String!
    var flightNumberURL:String!
    var departureDateURL:String!
    var departureAirportCodeURL:String!
    var flightStatusFormatted:String!
    var flightStatusUnformatted:String!
    var selectedRow:Int!
    var cellArray:[String] = []
    var downlineFlightId:String! = ""
    var currentDateWhole:String!
    var refresher:UIRefreshControl!
    var publishedDeparture:String!
    var actualDeparture:String!
    var publishedArrival:String!
    var actualArrival:String!
    var timer:Timer!
    var flightId:Double! = 0
    let gradientLayer = CAGradientLayer()
    var sortedFlights = [Dictionary<String,String>]()
    var departureDatesStringArray: [String] = []
    var departureDateString:String!
    var flightTookOff:Bool!
    var flightLanded:Bool!
    var flightEstimatedArrivalString:String!
    var flightActualDepartureString:String!
    @IBOutlet weak var flightTable: UITableView!
    let button = UIButton()
    let addButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFlightStatusOffline()
        flightTable.delegate = self
        flightTable.dataSource = self
        addBackButton()
        addAddButton()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Checking for shared flights")
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        flightTable.addSubview(refresher)
    }
    

    func addBackButton() {
        button.frame = CGRect(x: 10, y: 40, width: 25, height: 25)
        let backButtonImage = UIImage(named: "backButton.png")
        button.setImage(backButtonImage, for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func addAddButton() {
        addButton.frame = CGRect(x: view.frame.maxX - 35, y: 40, width: 25, height: 25)
        let backButtonImage = UIImage(named: "Add Pin - Trip key.png")
        addButton.setImage(backButtonImage, for: .normal)
        addButton.addTarget(self, action: #selector(addFlight), for: .touchUpInside)
        view.addSubview(addButton)
    }
    
    @objc func addFlight() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToAddFlight", sender: self)
        }
    }
    
    
    
    @objc func goBack() {
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
        flightTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = flightTable.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath) as! TableViewCell
        cell.backgroundView?.isHidden = true
        
        cell.terminalLabel.text = NSLocalizedString("Terminal", comment: "")
        cell.gateLabel.text = NSLocalizedString("Gate", comment: "")
        cell.arrivalGateLabel.text = NSLocalizedString("Gate", comment: "")
        cell.arrivalBaggageLabel.text = NSLocalizedString("Baggage", comment: "")
        cell.arrivalTerminalLabel.text = NSLocalizedString("Terminal", comment: "")
        
        cell.slider.setThumbImage(UIImage(named: "newPlaneRotated.png"), for: UIControlState.normal)
        cell.slider.maximumValue = 1.0
        cell.slider.minimumValue = 0.0
        cell.slider.value = cell.slider.minimumValue
        cell.countdownView.isHidden = true
        
        cell.tapShareAction = {
            
            (cell) in self.shareFlight(indexPath: (tableView.indexPath(for: cell)!.row))
            
        }
        
        DispatchQueue.main.async {
            
            let departureDate = self.flights[indexPath.row]["Published Departure"]!
            let arrivalDate = self.flights[indexPath.row]["Published Arrival"]!
            let departureOffset = self.flights[indexPath.row]["Departure Airport UTC Offset"]!
            let arrivalOffset = self.flights[indexPath.row]["Arrival Airport UTC Offset"]!
            
            let flightDuration = self.getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
            cell.flightDuration.text = flightDuration
            //Below is info that is provided by schedules and or constants
            if self.flights[indexPath.row]["Flight Status"] == "" {
                
                cell.status.text = NSLocalizedString("Tap to update", comment: "")
                
            } else {
                
                cell.status.text = "\(self.flights[indexPath.row]["Flight Status"]!)"
            }
            
            if self.flights[indexPath.row]["Updated Flight Equipment"] != "" {
                
                
                cell.aircraftType.text = self.flights[indexPath.row]["Updated Flight Equipment"]!
                
                
            } else {
                
                cell.aircraftType.text = self.flights[indexPath.row]["Aircraft Type Name"]!
                
            }
            
            //constants from schedules
            cell.airlineName.text = "\(self.flights[indexPath.row]["Airline Name"]!) \(self.flights[indexPath.row]["Airline Code"]! + self.flights[indexPath.row]["Flight Number"]!)"
            
            //departure info
            //cell.departureAirportCode.text = self.flights[indexPath.row]["Departure Airport Code"]!
            cell.departureCity.text = self.flights[indexPath.row]["Departure City"]! + " (\(self.flights[indexPath.row]["Departure Airport Code"]!))"
            
            //arrival info
            //cell.arrivalAirportCode.text = self.flights[indexPath.row]["Arrival Airport Code"]!
            cell.arrivalCity.text = self.flights[indexPath.row]["Arrival City"]! + " (\(self.flights[indexPath.row]["Arrival Airport Code"]!))"
            
            var cellDepartureTime:String!
            cell.departureTerminal.text = self.flights[indexPath.row]["Airport Departure Terminal"]!
            cell.departureGate.text = self.flights[indexPath.row]["Departure Gate"]!
            
            
            var cellArrivalTime:String!
            cell.arrivalTerminal.text = self.flights[indexPath.row]["Airport Arrival Terminal"]!
            cell.arrivalGate.text = self.flights[indexPath.row]["Arrival Gate"]!
            cell.baggageClaim.text = self.flights[indexPath.row]["Baggage Claim"]!
            
            var arrivalTime:String!
            var departureTime:String!
            
            //Departure heirarchy
            if self.flights[indexPath.row]["Converted Published Departure"]! != "" {
                
                cellDepartureTime = self.flights[indexPath.row]["Converted Published Departure"]!
                self.publishedDeparture = self.flights[indexPath.row]["Published Departure"]!
                self.actualDeparture = self.flights[indexPath.row]["Published Departure"]!
                departureTime = self.flights[indexPath.row]["Published Departure"]!
            }
            
            if self.flights[indexPath.row]["Converted Scheduled Gate Departure"]! != "" {
                
                cellDepartureTime = self.flights[indexPath.row]["Converted Scheduled Gate Departure"]!
                self.actualDeparture = self.flights[indexPath.row]["Scheduled Gate Departure"]!
                departureTime = self.flights[indexPath.row]["Scheduled Gate Departure"]!
            }
            
            if self.flights[indexPath.row]["Converted Estimated Gate Departure"]! != "" {
                
                cellDepartureTime = self.flights[indexPath.row]["Converted Estimated Gate Departure"]!
                self.actualDeparture = self.flights[indexPath.row]["Estimated Gate Departure"]!
                departureTime = self.flights[indexPath.row]["Estimated Gate Departure"]!
            }
            
            if self.flights[indexPath.row]["Converted Actual Runway Departure"]! != "" {
                
                cellDepartureTime = self.flights[indexPath.row]["Converted Actual Runway Departure"]!
                self.flightActualDepartureString = self.flights[indexPath.row]["Actual Runway Departure UTC"]!
                self.actualDeparture = self.flights[indexPath.row]["Actual Runway Departure"]!
                departureTime = self.flights[indexPath.row]["Actual Runway Departure"]!
            }
            
            if self.flights[indexPath.row]["Converted Actual Gate Departure"]! != "" {
                
                cellDepartureTime = self.flights[indexPath.row]["Converted Actual Gate Departure"]!
                self.flightActualDepartureString = self.flights[indexPath.row]["Actual Gate Departure UTC"]!
                self.actualDeparture = self.flights[indexPath.row]["Actual Gate Departure"]!
                departureTime = self.flights[indexPath.row]["Actual Gate Departure"]!
            }
            
            //Arrival heirarchy
            if self.flights[indexPath.row]["Converted Published Arrival"]! != "" {
                
                cellArrivalTime = self.flights[indexPath.row]["Converted Published Arrival"]!
                self.publishedArrival = self.flights[indexPath.row]["Published Arrival"]!
                self.actualArrival = self.flights[indexPath.row]["Published Arrival"]!
                arrivalTime = self.flights[indexPath.row]["Published Arrival"]!
                
            }
            
            if self.flights[indexPath.row]["Converted Scheduled Gate Arrival"]! != "" {
                
                cellArrivalTime = self.flights[indexPath.row]["Converted Scheduled Gate Arrival"]!
                self.actualArrival = self.flights[indexPath.row]["Scheduled Gate Arrival"]!
                arrivalTime = self.flights[indexPath.row]["Scheduled Gate Arrival"]!
            }
            
            if self.flights[indexPath.row]["Converted Estimated Runway Arrival"]! != "" {
                
                cellArrivalTime = self.flights[indexPath.row]["Converted Estimated Runway Arrival"]!
                self.flightEstimatedArrivalString = self.flights[indexPath.row]["Estimated Runway Arrival UTC"]!
                self.actualArrival = self.flights[indexPath.row]["Estimated Runway Arrival"]!
                arrivalTime = self.flights[indexPath.row]["Estimated Runway Arrival"]!
            }
            
            if self.flights[indexPath.row]["Converted Estimated Gate Arrival"]! != "" {
                
                cellArrivalTime = self.flights[indexPath.row]["Converted Estimated Gate Arrival"]!
                self.flightEstimatedArrivalString = self.flights[indexPath.row]["Estimated Gate Arrival UTC"]!
                self.actualArrival = self.flights[indexPath.row]["Estimated Gate Arrival"]!
                arrivalTime = self.flights[indexPath.row]["Estimated Gate Arrival"]!
            }
            
            if self.flights[indexPath.row]["Converted Actual Runway Arrival"]! != "" {
                
                cellArrivalTime = self.flights[indexPath.row]["Converted Actual Runway Arrival"]!
                self.actualArrival = self.flights[indexPath.row]["Actual Runway Arrival"]!
                arrivalTime = self.flights[indexPath.row]["Actual Runway Arrival"]!
            }
            
            if self.flights[indexPath.row]["Converted Actual Gate Arrival"]! != "" {
                
                cellArrivalTime = self.flights[indexPath.row]["Converted Actual Gate Arrival"]!
                self.actualArrival = self.flights[indexPath.row]["Actual Gate Arrival"]!
                arrivalTime = self.flights[indexPath.row]["Actual Gate Arrival"]!
            }
            
            
            if self.flights.count <= 3 {
                
                if self.flights[indexPath.row]["Converted Actual Runway Departure"]! == "" && self.flights[indexPath.row]["Converted Actual Gate Departure"]! == "" || self.flights[indexPath.row]["Flight Status"]! != "Departed" || self.flights[indexPath.row]["Took off"] == "false" {
                    
                    print("cell = \(indexPath.row) departureTime =  \(departureTime)")
                    print("cell = \(indexPath.row) departureOffset =  \(departureOffset)")
                    cell.countdownView.isHidden = true
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                        (_) in
                        
                        DispatchQueue.main.async {
                            
                            cell.countDownLabel.text = NSLocalizedString("till departure", comment: "")
                            
                            let monthsLeft = self.countDown(departureDate: departureTime, departureUtcOffset: departureOffset).months
                            let daysLeft = self.countDown(departureDate: departureTime, departureUtcOffset: departureOffset).days
                            let hoursLeft = self.countDown(departureDate: departureTime, departureUtcOffset: departureOffset).hours
                            let minutesLeft = self.countDown(departureDate: departureTime, departureUtcOffset: departureOffset).minutes
                            let secondsLeft = self.countDown(departureDate: departureTime, departureUtcOffset: departureOffset).seconds
                            
                            cell.months.text = "\(monthsLeft)"
                            cell.days.text = "\(daysLeft)"
                            cell.hours.text = "\(hoursLeft)"
                            cell.mins.text = "\(minutesLeft)"
                            cell.secs.text = "\(secondsLeft)"
                            
                            if monthsLeft == 0 {
                                
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                //cell.countdownView.isHidden = false
                                
                            }
                            
                            if daysLeft == 0 && monthsLeft == 0 {
                                
                                cell.days.isHidden = true
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                cell.daysLabel.isHidden = true
                                //cell.countdownView.isHidden = false
                                
                            }
                            
                            if hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                                
                                cell.hours.isHidden = true
                                cell.days.isHidden = true
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                cell.daysLabel.isHidden = true
                                cell.hoursLabel.isHidden = true
                                //cell.countdownView.isHidden = false
                                
                            }
                            
                            if minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                                
                                cell.mins.isHidden = true
                                cell.hours.isHidden = true
                                cell.days.isHidden = true
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                cell.daysLabel.isHidden = true
                                cell.hoursLabel.isHidden = true
                                cell.minsLabel.isHidden = true
                                
                            }
                            
                            if secondsLeft == 0 && minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0  {
                                
                                
                                cell.countdownView.isHidden = true
                                cell.countDownLabel.isHidden = true
                                
                            } else {
                                
                                cell.countdownView.isHidden = false
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    
                } else if self.flights[indexPath.row]["Took off"]! == "true" {
                    
                    print("cell = \(indexPath.row) arrivalTime =  \(arrivalTime)")
                    print("cell = \(indexPath.row) arrivalOffset =  \(arrivalOffset)")
                    cell.countdownView.isHidden = true
                    
                    
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                        (_) in
                        
                        DispatchQueue.main.async {
                            
                            cell.countDownLabel.text = NSLocalizedString("till arrival", comment: "")
                            
                            let monthsLeft = self.countDown(departureDate: arrivalTime, departureUtcOffset: arrivalOffset).months
                            let daysLeft = self.countDown(departureDate: arrivalTime, departureUtcOffset: arrivalOffset).days
                            let hoursLeft = self.countDown(departureDate: arrivalTime, departureUtcOffset: arrivalOffset).hours
                            let minutesLeft = self.countDown(departureDate: arrivalTime, departureUtcOffset: arrivalOffset).minutes
                            let secondsLeft = self.countDown(departureDate: arrivalTime, departureUtcOffset: arrivalOffset).seconds
                            cell.months.text = "\(monthsLeft)"
                            cell.days.text = "\(daysLeft)"
                            cell.hours.text = "\(hoursLeft)"
                            cell.mins.text = "\(minutesLeft)"
                            cell.secs.text = "\(secondsLeft)"
                            
                            if monthsLeft == 0 {
                                
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                
                            }
                            
                            if daysLeft == 0 && monthsLeft == 0 {
                                
                                cell.days.isHidden = true
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                cell.daysLabel.isHidden = true
                                
                            }
                            
                            if hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                                
                                cell.hours.isHidden = true
                                cell.days.isHidden = true
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                cell.daysLabel.isHidden = true
                                cell.hoursLabel.isHidden = true
                                
                            }
                            
                            if minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                                
                                cell.mins.isHidden = true
                                cell.hours.isHidden = true
                                cell.days.isHidden = true
                                cell.months.isHidden = true
                                cell.monthsLabel.isHidden = true
                                cell.daysLabel.isHidden = true
                                cell.hoursLabel.isHidden = true
                                cell.minsLabel.isHidden = true
                                
                            }
                            
                            if secondsLeft == 0 && minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0  {
                                
                                cell.countdownView.isHidden = true
                                cell.countDownLabel.isHidden = true
                                
                            } else {
                                
                                cell.countdownView.isHidden = false
                                
                            }
                            
                        }
                        
                    }
                }
            }
            
            
            
            cell.departureDate.text = cellDepartureTime!
            cell.arrivalDate.text = cellArrivalTime!
            
        }
        
        cell.slider.maximumValue = 1.0
        cell.slider.minimumValue = 0.0
        cell.slider.value = cell.slider.minimumValue
        
        if flights[indexPath.row]["Flight Status"]! == "" {
            
            DispatchQueue.main.async {
                
                cell.status.text = NSLocalizedString("Tap to update", comment: "")
                cell.slider.maximumValue = 1.0
                cell.slider.minimumValue = 0.0
                cell.slider.value = cell.slider.minimumValue
            }
            
        } else if flights[indexPath.row]["Flight Status"]! == "Scheduled" {
            
            DispatchQueue.main.async {
                
                cell.status.text =  "\(self.flights[indexPath.row]["Flight Status"]!)"
                let flightDurationScheduled = self.flights[indexPath.row]["Flight Duration Scheduled"]!
                let convertedDuration = self.convertDuration(flightDurationScheduled: flightDurationScheduled)
                cell.flightDuration.text = convertedDuration
                
                let departureTimeDifference = self.getTimeDifference(publishedTime: self.publishedDeparture, actualTime: self.actualDeparture)
                
                if departureTimeDifference == "0min" {
                    
                    cell.landingOnTimeDelayed.text = NSLocalizedString("Departing on time", comment: "")
                    
                } else if self.flights[indexPath.row]["Scheduled Gate Departure Whole Number"]! != "" && self.flights[indexPath.row]["Estimated Gate Departure Whole Number"]! != "" {
                    
                    if Double(self.flights[indexPath.row]["Scheduled Gate Departure Whole Number"]!)! < Double(self.flights[indexPath.row]["Estimated Gate Departure Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Departure delayed by", comment: "")) \(departureTimeDifference)"
                        
                        
                    } else if Double(self.flights[indexPath.row]["Scheduled Gate Departure Whole Number"]!)! > Double(self.flights[indexPath.row]["Estimated Gate Departure Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        
                    }
                    
                } else if self.flights[indexPath.row]["Scheduled Runway Departure Whole Number"]! != "" && self.flights[indexPath.row]["Estimated Runway Departure Whole Number"]! != "" {
                    
                    if Double(self.flights[indexPath.row]["Scheduled Runway Departure Whole Number"]!)! < Double(self.flights[indexPath.row]["Estimated Runway Departure Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Departure delayed by", comment: "")) \(departureTimeDifference)"
                        
                        
                    } else if Double(self.flights[indexPath.row]["Scheduled Runway Departure Whole Number"]!)! > Double(self.flights[indexPath.row]["Estimated Runway Departure Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        
                    }
                    
                }
                
            }
            
        } else if flights[indexPath.row]["Flight Status"]! == "Departed" || flights[indexPath.row]["Flight Status"]! == "Redirected" || flights[indexPath.row]["Flight Status"]! == "Diverted" {
            
            DispatchQueue.main.async {
                
                cell.status.text = "\(self.flights[indexPath.row]["Flight Status"]!)"
                
                
                let arrivalTimeDifference = self.getTimeDifference(publishedTime: self.publishedArrival, actualTime: self.actualArrival)
                let departureTimeDifference = self.getTimeDifference(publishedTime: self.publishedDeparture, actualTime: self.actualDeparture)
                
                let departureOffset = self.flights[indexPath.row]["Departure Airport UTC Offset"]!
                let arrivalOffset = self.flights[indexPath.row]["Arrival Airport UTC Offset"]!
                
                let flightDuration = self.getFlightDuration(departureDate: self.actualDeparture, arrivalDate: self.actualArrival, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                
                cell.flightDuration.text = flightDuration
                
                if arrivalTimeDifference == "0min" {
                    
                    cell.landingOnTimeDelayed.text = NSLocalizedString("Arriving on time", comment: "")
                    
                } else if self.flights[indexPath.row]["Estimated Gate Arrival Whole Number"]! != "" && self.flights[indexPath.row]["Scheduled Gate Arrival Whole Number"]! != "" {
                    
                    if Double(self.flights[indexPath.row]["Scheduled Gate Arrival Whole Number"]!)! < Double(self.flights[indexPath.row]["Estimated Gate Arrival Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Arrival delayed by", comment: "")) \(arrivalTimeDifference)"
                        
                    } else if Double(self.flights[indexPath.row]["Scheduled Gate Arrival Whole Number"]!)! > Double(self.flights[indexPath.row]["Estimated Gate Arrival Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Arriving", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        
                    }
                    
                } else if self.flights[indexPath.row]["Estimated Runway Arrival Whole Number"]! != "" && self.flights[indexPath.row]["Scheduled Runway Arrival Whole Number"]! != "" {
                    
                    if Double(self.flights[indexPath.row]["Scheduled Runway Arrival Whole Number"]!)! < Double(self.flights[indexPath.row]["Estimated Runway Arrival Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Arrival delayed by", comment: "")) \(arrivalTimeDifference)"
                        
                    } else if Double(self.flights[indexPath.row]["Scheduled Runway Arrival Whole Number"]!)! > Double(self.flights[indexPath.row]["Estimated Runway Arrival Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Arriving", comment: "")) \(arrivalTimeDifference) early"
                        
                    }
                    
                }
                
                let timeTillLanding = self.secondsTillLanding(arrivalDateUTC: self.flightEstimatedArrivalString)
                print("timeTillLanding = \(timeTillLanding)")
                let timeSinceTakeOff = self.secondsSinceTakeOff(departureDateUTC: self.flightActualDepartureString)
                print("timeSinceTakeOff = \(timeSinceTakeOff)")
                cell.slider.maximumValue = Float(timeSinceTakeOff + timeTillLanding)
                cell.slider.minimumValue = Float(0)
                cell.slider.value = Float(timeSinceTakeOff)
                
                
                
            }
            
        } else if flights[indexPath.row]["Flight Status"]! == "Landed" || flights[indexPath.row]["Actual Gate Arrival Whole"]! != "" || flights[indexPath.row]["Actual Runway Arrival Whole Number"]! != "" {
            
            DispatchQueue.main.async {
                cell.status.text = NSLocalizedString("Landed", comment: "")
                
                let arrivalTimeDifference = self.getTimeDifference(publishedTime: self.publishedArrival, actualTime: self.actualArrival)
                
                if arrivalTimeDifference == "0min" {
                    
                    cell.landingOnTimeDelayed.text = NSLocalizedString("Landed on time", comment: "")
                    
                } else if self.flights[indexPath.row]["Scheduled Gate Arrival Whole Number"]! != "" && self.flights[indexPath.row]["Actual Gate Arrival Whole"]! != "" {
                    
                    if Double(self.flights[indexPath.row]["Scheduled Gate Arrival Whole Number"]!)! < Double(self.flights[indexPath.row]["Actual Gate Arrival Whole"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("late", comment: ""))"
                        
                    } else if Double(self.flights[indexPath.row]["Scheduled Gate Arrival Whole Number"]!)! > Double(self.flights[indexPath.row]["Actual Gate Arrival Whole"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        
                    }
                    
                } else if self.flights[indexPath.row]["Actual Runway Arrival Whole Number"]! != "" {
                    
                    if Double(self.flights[indexPath.row]["Arrival Date Number"]!)! < Double(self.flights[indexPath.row]["Actual Runway Arrival Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("late", comment: ""))"
                        
                    } else if Double(self.flights[indexPath.row]["Arrival Date Number"]!)! > Double(self.flights[indexPath.row]["Actual Runway Arrival Whole Number"]!)! {
                        
                        cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        
                    }
                    
                }
                
                let departureOffset = self.flights[indexPath.row]["Departure Airport UTC Offset"]!
                let arrivalOffset = self.flights[indexPath.row]["Arrival Airport UTC Offset"]!
                
                let flightDuration = self.getFlightDuration(departureDate: self.actualDeparture, arrivalDate: self.actualArrival, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                
                cell.flightDuration.text = flightDuration
                cell.slider.maximumValue = 1.0
                cell.slider.minimumValue = 0.0
                cell.slider.value = cell.slider.maximumValue
                
            }
            
        } else if flights[indexPath.row]["Flight Status"]! == "Cancelled" {
            
            cell.status.text = NSLocalizedString("Cancelled", comment: "")
            cell.slider.maximumValue = 1.0
            cell.slider.minimumValue = 0.0
            cell.slider.value = cell.slider.minimumValue
            
        }
        
        
        
        cell.backgroundView?.isHidden = false
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flights.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let departureDateTime = flights[indexPath.row]["Published Departure UTC"]
        
        if isDepartureDate72HoursAwayOrLess(date: departureDateTime!) == true {
            
            parseLeg2Only(dictionary: flights[indexPath.row], index: indexPath.row)
            
        } else {
            
            let alert = UIAlertController(title: NSLocalizedString("Flight Status Not Updated", comment: ""), message: NSLocalizedString("Flight statuses do not update until 72 hours before departure.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func addActivityIndicatorCenter() {
        
        self.activityLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        self.activityLabel.center = CGPoint(x: self.view.frame.width/2 , y: self.view.frame.height/1.815)
        self.activityLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        self.activityLabel.textColor = UIColor.white
        self.activityLabel.textAlignment = .center
        self.activityLabel.alpha = 0
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.isUserInteractionEnabled = true
        activityIndicator.startAnimating()
        self.activityIndicator.alpha = 0
        
        blurEffectViewActivity.frame = CGRect(x: 0, y: 0, width: 150, height: 120)
        blurEffectViewActivity.center = CGPoint(x: self.view.center.x, y: ((self.view.center.y) + 14))
        blurEffectViewActivity.alpha = 0
        blurEffectViewActivity.layer.cornerRadius = 30
        blurEffectViewActivity.clipsToBounds = true
        
        view.addSubview(self.blurEffectViewActivity)
        view.addSubview(self.activityLabel)
        view.addSubview(activityIndicator)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blurEffectViewActivity.alpha = 1
            self.activityIndicator.alpha = 1
            self.activityLabel.alpha = 1
            
        })
        
        
    }
    
    func parseLeg2Only(dictionary: Dictionary<String,String>, index: Int) {
        
        self.activityLabel.text = NSLocalizedString("Updating Flight", comment: "")
        addActivityIndicatorCenter()
        self.activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var url:URL!
        let arrivalDateURL = flights[index]["URL Arrival Date"]!
        let arrivalAirport = flights[index]["Arrival Airport Code"]!
        self.airlineCodeURL = flights[index]["Airline Code"]!
        self.flightNumberURL = flights[index]["Flight Number"]!
        
        url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + (self.airlineCodeURL!) + "/" + (self.flightNumberURL!) + "/arr/" + (arrivalDateURL) + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87&utc=false&airport=" + (arrivalAirport) + "&extendedOptions=useinlinedreferences")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonFlightStatusData = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            //print("jsonFlightStatusData =\n\(jsonFlightStatusData)")
                            
                            //check status
                            
                            if let flightStatusesArray = jsonFlightStatusData["flightStatuses"] as? NSArray {
                                
                                if flightStatusesArray.count == 0 {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.activityIndicator.stopAnimating()
                                        self.activityLabel.removeFromSuperview()
                                        self.blurEffectViewActivity.removeFromSuperview()
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        
                                        let alert = UIAlertController(title: NSLocalizedString("Flight not yet updated", comment: ""), message: NSLocalizedString("Try again in a few hours.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                        
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                            
                                        }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                    
                                } else if flightStatusesArray.count > 0 {
                                    
                                    self.flightStatusUnformatted = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["status"] as? String
                                    print("flightStatusUnformatted = \(self.flightStatusUnformatted!)")
                                    
                                    if self.flightStatusUnformatted! == "S" {
                                        
                                        self.flightStatusFormatted = "Scheduled"
                                        
                                    } else if self.flightStatusUnformatted! == "A" {
                                        
                                        self.flightStatusFormatted = "Departed"
                                        
                                    } else if self.flightStatusUnformatted! == "D" {
                                        
                                        self.flightStatusFormatted = "Diverted"
                                        
                                    } else if self.flightStatusUnformatted! == "DN" {
                                        
                                        self.flightStatusFormatted = "Data Source Needed"
                                        
                                    } else if self.flightStatusUnformatted! == "L" {
                                        
                                        self.flightStatusFormatted = "Landed"
                                        
                                    } else if self.flightStatusUnformatted! == "NO" {
                                        
                                        self.flightStatusFormatted = "Not Operational"
                                        
                                    } else if self.flightStatusUnformatted! == "R" {
                                        
                                        self.flightStatusFormatted = "Redirected"
                                        
                                    } else if self.flightStatusUnformatted! == "U" {
                                        
                                        self.flightStatusFormatted = "Unknown"
                                        
                                    } else if self.flightStatusUnformatted! == "C" {
                                        
                                        self.flightStatusFormatted = "Cancelled"
                                        
                                        DispatchQueue.main.async {
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Flight has been Cancelled!", comment: ""), message: NSLocalizedString("Contact your airline to get replacement flight number.", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                    } else {
                                        
                                        print("Error formatting flight status")
                                        
                                    }
                                    
                                    //unambiguos data
                                    var baggageClaim = "-"
                                    var irregularOperationsMessage1:String = ""
                                    var irregularOperationsMessage2:String = ""
                                    var irregularOperationsType1:String = ""
                                    var irregularOperationsType2:String = ""
                                    var updatedFlightEquipment:String! = ""
                                    var confirmedIncidentDate:String! = ""
                                    var confirmedIncidentTime:String! = ""
                                    var confirmedIncidentMessage:String! = ""
                                    var flightDurationScheduled:String! = ""
                                    var replacementFlightId:Double! = 0
                                    var primaryCarrier:String = ""
                                    
                                    if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                        
                                        baggageClaim = baggageCheck
                                    }
                                    
                                    if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                        
                                        primaryCarrier = primaryCarrierCheck
                                    }
                                    
                                    if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: scheduledFlightEquipment)
                                        
                                    }
                                    
                                    if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: actualFlightEquipment)
                                    }
                                    
                                    //must add in code to check if the count is greater then one or not and to handle one or two different items
                                    if let irregularOperations = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["irregularOperations"] as? NSArray {
                                        
                                        if irregularOperations.count > 1 {
                                            
                                            if let irregularOperationsMessage1Check = (irregularOperations[0] as? NSDictionary)?["message"] as? String {
                                                
                                                irregularOperationsMessage1 = irregularOperationsMessage1Check
                                            }
                                            
                                            if let irregularOperationsMessage2Check = (irregularOperations[1] as? NSDictionary)?["message"] as? String {
                                                
                                                irregularOperationsMessage2 = irregularOperationsMessage2Check
                                            }
                                            
                                            irregularOperationsType1 = ((irregularOperations[0] as? NSDictionary)?["type"] as? String)!
                                            irregularOperationsType2 = ((irregularOperations[1] as? NSDictionary)?["type"] as? String)!
                                            
                                            if irregularOperationsType2 == "REPLACED_BY" {
                                                
                                                replacementFlightId = ((irregularOperations[1] as? NSDictionary)?["relatedFlightId"] as? Double)!
                                                self.flightId = replacementFlightId
                                                
                                            }
                                            
                                        } else if irregularOperations.count == 1 {
                                            
                                            if let irregularOperationsMessage1Check = (irregularOperations[0] as? NSDictionary)?["message"] as? String {
                                                
                                                irregularOperationsMessage1 = irregularOperationsMessage1Check
                                            }
                                            
                                            irregularOperationsType1 = ((irregularOperations[0] as? NSDictionary)?["type"] as? String)!
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    if let confirmedIncidentMessageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["confirmedIncident"] as? NSDictionary)?["message"] as? String {
                                        
                                        var confirmedIncidentDate = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["confirmedIncident"] as? NSDictionary)?["publishedDate"] as? String
                                        
                                        confirmedIncidentMessage = confirmedIncidentMessageCheck
                                        
                                    }
                                    
                                    if let flightDurationScheduledCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightDurations"] as? NSDictionary)?["scheduledBlockMinutes"] as? Int {
                                        
                                        flightDurationScheduled = String(flightDurationScheduledCheck)
                                    }
                                    
                                    //departure data
                                    var departureTerminal:String!
                                    var departureGate:String!
                                    
                                    if let departureTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureTerminal"] as? String {
                                        
                                        departureTerminal = departureTerminalCheck
                                        
                                    } else {
                                        
                                        departureTerminal = "-"
                                    }
                                    
                                    if let departureGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureGate"] as? String {
                                        
                                        departureGate = departureGateCheck
                                        
                                    } else {
                                        
                                        departureGate = "-"
                                        
                                    }
                                    
                                    //departure timings
                                    var publishedDeparture:String! = ""
                                    var publishedDepartureWhole:String! = ""
                                    var convertedPublishedDeparture:String! = ""
                                    
                                    var actualGateDeparture:String! = ""
                                    var actualGateDepartureUtc:String! = ""
                                    var actualGateDepartureWhole:String! = ""
                                    var convertedActualGateDeparture:String! = ""
                                    
                                    var scheduledGateDeparture:String! = ""
                                    var scheduledGateDepartureDateTimeWhole:String! = ""
                                    var convertedScheduledGateDeparture:String! = ""
                                    
                                    var estimatedGateDeparture:String! = ""
                                    var estimatedGateDepartureWholeNumber:String! = ""
                                    var convertedEstimatedGateDeparture:String! = ""
                                    
                                    var actualRunwayDepartureWhole:String! = ""
                                    var convertedActualRunwayDeparture:String! = ""
                                    var actualRunwayDepartureUtc:String! = ""
                                    var actualRunwayDeparture:String! = ""
                                    
                                    var scheduledRunwayDepartureWhole:String! = ""
                                    var convertedScheduledRunwayDeparture:String! = ""
                                    var scheduledRunwayDepartureUtc:String! = ""
                                    var scheduledRunwayDeparture:String! = ""
                                    
                                    var estimatedRunwayDeparture:String! = ""
                                    var estimatedRunwayDepartureWholeNumber:String! = ""
                                    var convertedEstimatedRunwayDeparture:String! = ""
                                    
                                    if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayDeparture = estimatedRunwayDepartureCheck
                                        estimatedRunwayDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedRunwayDepartureCheck)
                                        convertedEstimatedRunwayDeparture = self.convertDateTime(date: estimatedRunwayDepartureCheck)
                                    }
                                    
                                    if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledRunwayDeparture = scheduledRunwayDepartureCheck
                                        convertedScheduledRunwayDeparture = self.convertDateTime(date: scheduledRunwayDeparture)
                                        scheduledRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: scheduledRunwayDeparture)
                                        scheduledRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayDeparture = actualRunwayDepartureCheck
                                        convertedActualRunwayDeparture = self.convertDateTime(date: actualRunwayDepartureCheck)
                                        actualRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: actualRunwayDepartureCheck)
                                        actualRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let publishedDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedDeparture = publishedDepartureCheck
                                        convertedPublishedDeparture = self.convertDateTime(date: publishedDepartureCheck)
                                        publishedDepartureWhole = self.formatDateTimetoWhole(dateTime: publishedDepartureCheck)
                                        
                                    }
                                    
                                    if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateDeparture = scheduledGateDepartureCheck
                                        scheduledGateDepartureDateTimeWhole = self.formatDateTimetoWhole(dateTime: scheduledGateDepartureCheck)
                                        convertedScheduledGateDeparture = self.convertDateTime(date: scheduledGateDepartureCheck)
                                        
                                    }
                                    
                                    if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateDeparture = estimatedGateDepartureCheck
                                        estimatedGateDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateDepartureCheck)
                                        convertedEstimatedGateDeparture = self.convertDateTime(date: estimatedGateDepartureCheck)
                                    }
                                    
                                    if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateDeparture = actualGateDepartureCheck
                                        convertedActualGateDeparture = self.convertDateTime(date: actualGateDepartureCheck)
                                        actualGateDepartureWhole = self.formatDateTimetoWhole(dateTime: actualGateDepartureCheck)
                                        actualGateDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    //arrival data
                                    var arrivalTerminal:String!
                                    var arrivalGate:String!
                                    
                                    //diverted airport data
                                    var divertedAirportArrivalCode:String!
                                    var divertedAirportArrivalCountryName:String!
                                    var divertedAirportArrivalLongitudeDouble:Double!
                                    var divertedAirportArrivalIata:String!
                                    var divertedAirportArrivalLatitudeDouble:Double!
                                    var divertedAirportArrivalCityCode:String!
                                    var divertedAirportArrivalName:String!
                                    var divertedAirportArrivalCity:String!
                                    var divertedAirportArrivalTimeZone:String!
                                    var divertedAirportArrivalUtcOffsetHours:Double!
                                    
                                    if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                        
                                        divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String!
                                        divertedAirportArrivalCountryName = divertedAirportCheck["countryName"] as! String!
                                        divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double!
                                        divertedAirportArrivalIata = divertedAirportCheck["iata"] as! String!
                                        divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double!
                                        divertedAirportArrivalCityCode = divertedAirportCheck["cityCode"] as! String!
                                        divertedAirportArrivalName = divertedAirportCheck["name"] as! String!
                                        divertedAirportArrivalCity = divertedAirportCheck["city"] as! String!
                                        divertedAirportArrivalTimeZone = divertedAirportCheck["timeZoneRegionName"] as! String!
                                        divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double!
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.flights[index]["Arrival Airport Code"] = "\(divertedAirportArrivalCode!)"
                                            self.flights[index]["Airport Arrival Longitude"] = "\(divertedAirportArrivalLongitudeDouble!)"
                                            self.flights[index]["Airport Arrival Latitude"] = "\(divertedAirportArrivalLatitudeDouble!)"
                                            self.flights[index]["Airport Arrival FS"] = "\(divertedAirportArrivalCode!)"
                                            self.flights[index]["Arrival Country"] = "\(divertedAirportArrivalCountryName!)"
                                            self.flights[index]["Airport Arrival IATA"] = "\(divertedAirportArrivalIata!)"
                                            self.flights[index]["Airport Arrival City Code"] = "\(divertedAirportArrivalCityCode!)"
                                            self.flights[index]["Airport Arrival Name"] = "\(divertedAirportArrivalName!)"
                                            self.flights[index]["Arrival City"] = "\(divertedAirportArrivalCity!)"
                                            self.flights[index]["Airport Arrival Time Zone"] = "\(divertedAirportArrivalTimeZone!)"
                                            self.flights[index]["Arrival Airport UTC Offset"] = "\(divertedAirportArrivalUtcOffsetHours!)"
                                        }
                                        
                                    }
                                    
                                    if let arrivalGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalGate"] as? String {
                                        
                                        arrivalGate = arrivalGateCheck
                                        
                                    } else {
                                        
                                        arrivalGate = "-"
                                        
                                    }
                                    
                                    if let arrivalTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalTerminal"] as? String {
                                        
                                        arrivalTerminal = arrivalTerminalCheck
                                        
                                    } else {
                                        
                                        arrivalTerminal = "-"
                                    }
                                    
                                    //arrival timings
                                    var publishedArrival:String! = ""
                                    var convertedPublishedArrival:String! = ""
                                    var publishedArrivalWhole:String! = ""
                                    
                                    var scheduledGateArrivalUtc:String! = ""
                                    var scheduledGateArrivalWholeNumber:String! = ""
                                    var scheduledGateArrival:String! = ""
                                    var convertedScheduledGateArrival:String! = ""
                                    
                                    var estimatedGateArrivalUtc:String! = ""
                                    var estimatedGateArrivalWholeNumber:String! = ""
                                    var convertedEstimatedGateArrival:String! = ""
                                    var estimatedGateArrival:String! = ""
                                    
                                    var convertedActualGateArrival:String! = ""
                                    var actualGateArrivalWhole:String! = ""
                                    var actualGateArrival:String! = ""
                                    
                                    var convertedEstimatedRunwayArrival:String! = ""
                                    var estimatedRunwayArrivalUtc:String! = ""
                                    var estimatedRunwayArrivalWhole:String! = ""
                                    var estimatedRunwayArrival:String! = ""
                                    
                                    var convertedActualRunwayArrival:String! = ""
                                    var actualRunwayArrivalUtc:String! = ""
                                    var actualRunwayArrivalWhole:String! = ""
                                    var actualRunwayArrival:String! = ""
                                    
                                    if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayArrival = actualRunwayArrivalCheck
                                        actualRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: actualRunwayArrivalCheck)
                                        convertedActualRunwayArrival = self.convertDateTime(date: actualRunwayArrivalCheck)
                                        actualRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let publishedArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedArrival = publishedArrivalCheck
                                        convertedPublishedArrival = self.convertDateTime(date: publishedArrival!)
                                        publishedArrivalWhole = self.formatDateTimetoWhole(dateTime: publishedArrival!)
                                        
                                    }
                                    
                                    if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayArrival = estimatedRunwayArrivalCheck
                                        estimatedRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: estimatedRunwayArrivalCheck)
                                        convertedEstimatedRunwayArrival = self.convertDateTime(date: estimatedRunwayArrivalCheck)
                                        estimatedRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateArrival = scheduledGateArrivalCheck
                                        scheduledGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: scheduledGateArrivalCheck)
                                        convertedScheduledGateArrival = self.convertDateTime(date: scheduledGateArrivalCheck)
                                        scheduledGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateArrival = estimatedGateArrivalCheck
                                        estimatedGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateArrivalCheck)
                                        convertedEstimatedGateArrival = self.convertDateTime(date: estimatedGateArrivalCheck)
                                        estimatedGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateArrival = actualGateArrivalCheck
                                        convertedActualGateArrival = self.convertDateTime(date: actualGateArrivalCheck)
                                        actualGateArrivalWhole = self.formatDateTimetoWhole(dateTime: actualGateArrivalCheck)
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        //unambiguos data
                                        self.flights[index]["Flight Status"] = "\(NSLocalizedString(self.flightStatusFormatted!, comment: ""))"
                                        self.flights[index]["Flight Duration Scheduled"] = "\(flightDurationScheduled!)"
                                        self.flights[index]["Baggage Claim"] = "\(baggageClaim)"
                                        self.flights[index]["Primary Carrier"] = "\(primaryCarrier)"
                                        self.flights[index]["Irregular Operation Message 1"] = "\(irregularOperationsMessage1)"
                                        self.flights[index]["Irregular Operation Message 2"] = "\(irregularOperationsMessage2)"
                                        self.flights[index]["Irregular Operation Type 1"] = "\(irregularOperationsType1)"
                                        self.flights[index]["Irregular Operation Type 2"] = "\(irregularOperationsType2)"
                                        self.flights[index]["Confirmed Incident Message"] = "\(confirmedIncidentMessage!)"
                                        self.flights[index]["Updated Flight Equipment"] = "\(updatedFlightEquipment!)"
                                        
                                        //departure data
                                        self.flights[index]["Airport Departure Terminal"] = "\(departureTerminal!)"
                                        self.flights[index]["Departure Gate"] = "\(departureGate!)"
                                        
                                        //departure timings
                                        self.flights[index]["Converted Actual Runway Departure"] = "\(convertedActualRunwayDeparture!)"
                                        self.flights[index]["Actual Runway Departure Whole"] = "\(actualRunwayDepartureWhole!)"
                                        self.flights[index]["Actual Runway Departure UTC"] = "\(actualRunwayDepartureUtc!)"
                                        self.flights[index]["Actual Runway Departure"] = "\(actualRunwayDeparture!)"
                                        
                                        self.flights[index]["Scheduled Runway Departure Whole Number"] = "\(scheduledRunwayDepartureWhole!)"
                                        self.flights[index]["Converted Scheduled Runway Departure"] = "\(convertedScheduledRunwayDeparture!)"
                                        self.flights[index]["Scheduled Runway Departure"] = "\(scheduledRunwayDeparture!)"
                                        self.flights[index]["Scheduled Runway Departure UTC"] = "\(scheduledRunwayDepartureUtc!)"
                                        
                                        self.flights[index]["Converted Estimated Runway Departure"] = "\(convertedEstimatedRunwayDeparture!)"
                                        self.flights[index]["Estimated Runway Departure Whole Number"] = "\(estimatedRunwayDepartureWholeNumber!)"
                                        self.flights[index]["Estimated Runway Departure"] = "\(estimatedRunwayDeparture!)"
                                        
                                        self.flights[index]["Scheduled Gate Departure Whole Number"] = "\(scheduledGateDepartureDateTimeWhole!)"
                                        self.flights[index]["Converted Scheduled Gate Departure"] = "\(convertedScheduledGateDeparture!)"
                                        self.flights[index]["Scheduled Gate Departure"] = "\(scheduledGateDeparture!)"
                                        
                                        self.flights[index]["Converted Published Departure"] = "\(convertedPublishedDeparture!)"
                                        self.flights[index]["Published Departure Whole"] = "\(publishedDepartureWhole!)"
                                        self.flights[index]["Published Departure"] = "\(publishedDeparture!)"
                                        
                                        self.flights[index]["Converted Estimated Gate Departure"] = "\(convertedEstimatedGateDeparture!)"
                                        self.flights[index]["Estimated Gate Departure Whole Number"] = "\(estimatedGateDepartureWholeNumber!)"
                                        self.flights[index]["Estimated Gate Departure"] = "\(estimatedGateDeparture!)"
                                        
                                        self.flights[index]["Converted Actual Gate Departure"] = "\(convertedActualGateDeparture!)"
                                        self.flights[index]["Actual Gate Departure Whole"] = "\(actualGateDepartureWhole!)"
                                        self.flights[index]["Actual Gate Departure UTC"] = "\(actualGateDepartureUtc!)"
                                        self.flights[index]["Actual Gate Departure"] = "\(actualGateDeparture!)"
                                        
                                        
                                        //arrival data
                                        self.flights[index]["Airport Arrival Terminal"] = "\(arrivalTerminal!)"
                                        self.flights[index]["Arrival Gate"] = "\(arrivalGate!)"
                                        
                                        //arrival timings
                                        self.flights[index]["Actual Runway Arrival Whole Number"] = "\(actualRunwayArrivalWhole!)"
                                        self.flights[index]["Converted Actual Runway Arrival"] = "\(convertedActualRunwayArrival!)"
                                        self.flights[index]["Actual Runway Arrival UTC"] = "\(actualRunwayArrivalUtc!)"
                                        self.flights[index]["Actual Runway Arrival"] = "\(actualRunwayArrival!)"
                                        
                                        self.flights[index]["Estimated Runway Arrival Whole Number"] = "\(estimatedRunwayArrivalWhole!)"
                                        self.flights[index]["Converted Estimated Runway Arrival"] = "\(convertedEstimatedRunwayArrival!)"
                                        self.flights[index]["Estimated Runway Arrival UTC"] = "\(estimatedRunwayArrivalUtc!)"
                                        self.flights[index]["Estimated Runway Arrival"] = "\(estimatedRunwayArrival!)"
                                        
                                        self.flights[index]["Scheduled Gate Arrival Whole Number"] = "\(scheduledGateArrivalWholeNumber!)"
                                        self.flights[index]["Converted Scheduled Gate Arrival"] = "\(convertedScheduledGateArrival!)"
                                        self.flights[index]["Scheduled Gate Arrival UTC"] = "\(scheduledGateArrivalUtc!)"
                                        self.flights[index]["Scheduled Gate Arrival"] = "\(scheduledGateArrival!)"
                                        
                                        self.flights[index]["Converted Published Arrival"] = "\(convertedPublishedArrival!)"
                                        self.flights[index]["Published Arrival Whole"] = "\(publishedArrivalWhole!)"
                                        self.flights[index]["Published Arrival"] = "\(publishedArrival!)"
                                        
                                        self.flights[index]["Estimated Gate Arrival Whole Number"] = "\(estimatedGateArrivalWholeNumber!)"
                                        self.flights[index]["Converted Estimated Gate Arrival"] = "\(convertedEstimatedGateArrival!)"
                                        self.flights[index]["Estimated Gate Arrival UTC"] = "\(estimatedGateArrivalUtc!)"
                                        self.flights[index]["Estimated Gate Arrival"] = "\(estimatedGateArrival!)"
                                        
                                        self.flights[index]["Converted Actual Gate Arrival"] = "\(convertedActualGateArrival!)"
                                        self.flights[index]["Actual Gate Arrival Whole"] = "\(actualGateArrivalWhole!)"
                                        self.flights[index]["Actual Gate Arrival"] = "\(actualGateArrival!)"
                                        
                                        print("flights = \(self.flights)")
                                        
                                        self.flightTable.reloadData()
                                        
                                        UserDefaults.standard.set(self.flights, forKey: "flights")
                                        
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.activityIndicator.stopAnimating()
                                            self.activityLabel.removeFromSuperview()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && self.flightId != 0 {
                                                
                                                let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n\(NSLocalizedString("Would you like to add the replacement flight automatically?", comment: ""))" , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.parseFlightID(dictionary: self.flights[index], index: index)
                                                    
                                                }))
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" {
                                                
                                                let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)" , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                                
                                            } else if irregularOperationsMessage1 != "" {
                                                
                                                let alert = UIAlertController(title: "\(irregularOperationsType1)", message: "\n\(irregularOperationsMessage1)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                                
                                            } else if irregularOperationsType1 != "" {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: "\(NSLocalizedString("This flight has an irregular operation of type:", comment: "")) \(irregularOperationsType1)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                        
                                        self.flightTable.reloadData()
                                        
                                    }
                                    
                                } else {
                                    
                                    if let errorMessage = ((jsonFlightStatusData)["error"] as? NSDictionary)?["errorMessage"] as? String {
                                        
                                        print("errorMessage = \(errorMessage)")
                                        
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.activityLabel.removeFromSuperview()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
                
            } catch {
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityLabel.removeFromSuperview()
                    self.blurEffectViewActivity.removeFromSuperview()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                print("Error parsing")
            }
            
        }
        
        task.resume()
    }
    
    func refresh() {
        
        if PFUser.current() != nil {
            
            let getSharedFlightQuery = PFQuery(className: "SharedFlight")
            
            getSharedFlightQuery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
            
            getSharedFlightQuery.findObjectsInBackground { (sharedFlights, error) in
                
                if error != nil {
                    self.refresher.endRefreshing()
                    print("error = \(error as Any)")
                    
                } else {
                    
                    print("sharedFlight = \(sharedFlights as Any)")
                    
                    for flight in sharedFlights! {
                        
                        print("flight = \(flight)")
                        
                        //parse flight
                        //self.addActivityIndicatorCenter()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                        let flightDictionary = flight["flightDictionary"]
                        let dictionary = flightDictionary as! NSDictionary
                        self.flights.append(dictionary as! Dictionary<String, String>)
                        self.sortFlightsbyDepartureDate()
                        UserDefaults.standard.set(self.flights, forKey: "flights")
                        self.flightTable.reloadData()
                        
                        DispatchQueue.main.async {
                            self.refresher.endRefreshing()
                        }
                        
                        
                        flight.deleteInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                print("error = \(error as Any)")
                                
                                
                            } else {
                                
                                print("place deleted")
                                
                            }
                            
                        })
                        
                        
                        
                    }
                    
                    
                    
                }
                
                DispatchQueue.main.async {
                    self.refresher.endRefreshing()
                }
                
            }
            flightTable.reloadData()
            
        } else {
            
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
            }
            
        }
    }
    
    func parseFlightID(dictionary: Dictionary<String,String>, index: Int) {
        
        self.activityLabel.text = NSLocalizedString("Updating Flight", comment: "")
        addActivityIndicatorCenter()
        
        let url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + "\(self.flightId!)" + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonFlightStatusData = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            //print("jsonFlightStatusData =\n\(jsonFlightStatusData)")
                            
                            //check status
                            
                            if let flightStatusesArray = jsonFlightStatusData["flightStatuses"] as? NSArray {
                                
                                if flightStatusesArray.count > 0 {
                                    
                                    self.flightStatusUnformatted = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["status"] as? String
                                    print("flightStatusUnformatted = \(self.flightStatusUnformatted!)")
                                    
                                    if self.flightStatusUnformatted! == "S" {
                                        
                                        self.flightStatusFormatted = "Scheduled"
                                        
                                    } else if self.flightStatusUnformatted! == "A" {
                                        
                                        self.flightStatusFormatted = "Departed"
                                        
                                    } else if self.flightStatusUnformatted! == "D" {
                                        
                                        self.flightStatusFormatted = "Diverted"
                                        
                                    } else if self.flightStatusUnformatted! == "DN" {
                                        
                                        self.flightStatusFormatted = "Data Source Needed"
                                        
                                    } else if self.flightStatusUnformatted! == "L" {
                                        
                                        self.flightStatusFormatted = "Landed"
                                        
                                    } else if self.flightStatusUnformatted! == "NO" {
                                        
                                        self.flightStatusFormatted = "Not Operational"
                                        
                                    } else if self.flightStatusUnformatted! == "R" {
                                        
                                        self.flightStatusFormatted = "Redirected"
                                        
                                    } else if self.flightStatusUnformatted! == "U" {
                                        
                                        self.flightStatusFormatted = "Unknown"
                                        
                                    } else if self.flightStatusUnformatted! == "C" {
                                        
                                        self.flightStatusFormatted = "Cancelled"
                                        
                                        DispatchQueue.main.async {
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Flight has been Cancelled!", comment: ""), message: NSLocalizedString("Contact your airline to get replacement flight number.", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                    } else {
                                        
                                        print("Error formatting flight status")
                                        
                                    }
                                    
                                    //unambiguos data
                                    var baggageClaim = "-"
                                    var irregularOperationsMessage1:String = ""
                                    var irregularOperationsMessage2:String = ""
                                    var irregularOperationsType1:String = ""
                                    var irregularOperationsType2:String = ""
                                    var updatedFlightEquipment:String! = ""
                                    var confirmedIncidentDate:String! = ""
                                    var confirmedIncidentTime:String! = ""
                                    var confirmedIncidentMessage:String! = ""
                                    var flightDurationScheduled:String! = ""
                                    var replacementFlightId:Double! = 0
                                    var primaryCarrier:String = ""
                                    
                                    if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                        
                                        baggageClaim = baggageCheck
                                    }
                                    
                                    if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                        
                                        primaryCarrier = primaryCarrierCheck
                                    }
                                    
                                    if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: scheduledFlightEquipment)
                                        
                                    }
                                    
                                    if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: actualFlightEquipment)
                                    }
                                    
                                    //must add in code to check if the count is greater then one or not and to handle one or two different items
                                    if let irregularOperations = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["irregularOperations"] as? NSArray {
                                        
                                        if irregularOperations.count > 1 {
                                            
                                            if let irregularOperationsMessage1Check = (irregularOperations[0] as? NSDictionary)?["message"] as? String {
                                                
                                                irregularOperationsMessage1 = irregularOperationsMessage1Check
                                            }
                                            
                                            if let irregularOperationsMessage2Check = (irregularOperations[1] as? NSDictionary)?["message"] as? String {
                                                
                                                irregularOperationsMessage2 = irregularOperationsMessage2Check
                                            }
                                            
                                            irregularOperationsType1 = ((irregularOperations[0] as? NSDictionary)?["type"] as? String)!
                                            irregularOperationsType2 = ((irregularOperations[1] as? NSDictionary)?["type"] as? String)!
                                            
                                            if irregularOperationsType2 == "REPLACED_BY" {
                                                
                                                replacementFlightId = ((irregularOperations[1] as? NSDictionary)?["relatedFlightId"] as? Double)!
                                                self.flightId = replacementFlightId
                                                
                                            }
                                            
                                        } else if irregularOperations.count == 1 {
                                            
                                            if let irregularOperationsMessage1Check = (irregularOperations[0] as? NSDictionary)?["message"] as? String {
                                                
                                                irregularOperationsMessage1 = irregularOperationsMessage1Check
                                            }
                                            
                                            irregularOperationsType1 = ((irregularOperations[0] as? NSDictionary)?["type"] as? String)!
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    if let confirmedIncidentMessageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["confirmedIncident"] as? NSDictionary)?["message"] as? String {
                                        
                                        var confirmedIncidentDate = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["confirmedIncident"] as? NSDictionary)?["publishedDate"] as? String
                                        
                                        confirmedIncidentMessage = confirmedIncidentMessageCheck
                                        
                                    }
                                    
                                    if let flightDurationScheduledCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightDurations"] as? NSDictionary)?["scheduledBlockMinutes"] as? Int {
                                        
                                        flightDurationScheduled = String(flightDurationScheduledCheck)
                                    }
                                    
                                    //departure data
                                    var departureTerminal:String!
                                    var departureGate:String!
                                    
                                    if let departureTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureTerminal"] as? String {
                                        
                                        departureTerminal = departureTerminalCheck
                                        
                                    } else {
                                        
                                        departureTerminal = "-"
                                    }
                                    
                                    if let departureGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureGate"] as? String {
                                        
                                        departureGate = departureGateCheck
                                        
                                    } else {
                                        
                                        departureGate = "-"
                                        
                                    }
                                    
                                    //departure timings
                                    var publishedDeparture:String! = ""
                                    var publishedDepartureWhole:String! = ""
                                    var convertedPublishedDeparture:String! = ""
                                    
                                    var actualGateDeparture:String! = ""
                                    var actualGateDepartureUtc:String! = ""
                                    var actualGateDepartureWhole:String! = ""
                                    var convertedActualGateDeparture:String! = ""
                                    
                                    var scheduledGateDeparture:String! = ""
                                    var scheduledGateDepartureDateTimeWhole:String! = ""
                                    var convertedScheduledGateDeparture:String! = ""
                                    
                                    var estimatedGateDeparture:String! = ""
                                    var estimatedGateDepartureWholeNumber:String! = ""
                                    var convertedEstimatedGateDeparture:String! = ""
                                    
                                    var actualRunwayDepartureWhole:String! = ""
                                    var convertedActualRunwayDeparture:String! = ""
                                    var actualRunwayDepartureUtc:String! = ""
                                    var actualRunwayDeparture:String! = ""
                                    
                                    var scheduledRunwayDepartureWhole:String! = ""
                                    var convertedScheduledRunwayDeparture:String! = ""
                                    var scheduledRunwayDepartureUtc:String! = ""
                                    var scheduledRunwayDeparture:String! = ""
                                    
                                    var estimatedRunwayDeparture:String! = ""
                                    var estimatedRunwayDepartureWholeNumber:String! = ""
                                    var convertedEstimatedRunwayDeparture:String! = ""
                                    
                                    if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayDeparture = estimatedRunwayDepartureCheck
                                        estimatedRunwayDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedRunwayDepartureCheck)
                                        convertedEstimatedRunwayDeparture = self.convertDateTime(date: estimatedRunwayDepartureCheck)
                                    }
                                    
                                    if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledRunwayDeparture = scheduledRunwayDepartureCheck
                                        convertedScheduledRunwayDeparture = self.convertDateTime(date: scheduledRunwayDeparture)
                                        scheduledRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: scheduledRunwayDeparture)
                                        scheduledRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayDeparture = actualRunwayDepartureCheck
                                        convertedActualRunwayDeparture = self.convertDateTime(date: actualRunwayDepartureCheck)
                                        actualRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: actualRunwayDepartureCheck)
                                        actualRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let publishedDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedDeparture = publishedDepartureCheck
                                        convertedPublishedDeparture = self.convertDateTime(date: publishedDepartureCheck)
                                        publishedDepartureWhole = self.formatDateTimetoWhole(dateTime: publishedDepartureCheck)
                                        
                                    }
                                    
                                    if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateDeparture = scheduledGateDepartureCheck
                                        scheduledGateDepartureDateTimeWhole = self.formatDateTimetoWhole(dateTime: scheduledGateDepartureCheck)
                                        convertedScheduledGateDeparture = self.convertDateTime(date: scheduledGateDepartureCheck)
                                        
                                    }
                                    
                                    if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateDeparture = estimatedGateDepartureCheck
                                        estimatedGateDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateDepartureCheck)
                                        convertedEstimatedGateDeparture = self.convertDateTime(date: estimatedGateDepartureCheck)
                                    }
                                    
                                    if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateDeparture = actualGateDepartureCheck
                                        convertedActualGateDeparture = self.convertDateTime(date: actualGateDepartureCheck)
                                        actualGateDepartureWhole = self.formatDateTimetoWhole(dateTime: actualGateDepartureCheck)
                                        actualGateDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    //arrival data
                                    var arrivalTerminal:String!
                                    var arrivalGate:String!
                                    
                                    //diverted airport data
                                    var divertedAirportArrivalCode:String!
                                    var divertedAirportArrivalCountryName:String!
                                    var divertedAirportArrivalLongitudeDouble:Double!
                                    var divertedAirportArrivalIata:String!
                                    var divertedAirportArrivalLatitudeDouble:Double!
                                    var divertedAirportArrivalCityCode:String!
                                    var divertedAirportArrivalName:String!
                                    var divertedAirportArrivalCity:String!
                                    var divertedAirportArrivalTimeZone:String!
                                    var divertedAirportArrivalUtcOffsetHours:Double!
                                    
                                    if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                        
                                        divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String!
                                        divertedAirportArrivalCountryName = divertedAirportCheck["countryName"] as! String!
                                        divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double!
                                        divertedAirportArrivalIata = divertedAirportCheck["iata"] as! String!
                                        divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double!
                                        divertedAirportArrivalCityCode = divertedAirportCheck["cityCode"] as! String!
                                        divertedAirportArrivalName = divertedAirportCheck["name"] as! String!
                                        divertedAirportArrivalCity = divertedAirportCheck["city"] as! String!
                                        divertedAirportArrivalTimeZone = divertedAirportCheck["timeZoneRegionName"] as! String!
                                        divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double!
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.flights[index]["Arrival Airport Code"] = "\(divertedAirportArrivalCode!)"
                                            self.flights[index]["Airport Arrival Longitude"] = "\(divertedAirportArrivalLongitudeDouble!)"
                                            self.flights[index]["Airport Arrival Latitude"] = "\(divertedAirportArrivalLatitudeDouble!)"
                                            self.flights[index]["Airport Arrival FS"] = "\(divertedAirportArrivalCode!)"
                                            self.flights[index]["Arrival Country"] = "\(divertedAirportArrivalCountryName!)"
                                            self.flights[index]["Airport Arrival IATA"] = "\(divertedAirportArrivalIata!)"
                                            self.flights[index]["Airport Arrival City Code"] = "\(divertedAirportArrivalCityCode!)"
                                            self.flights[index]["Airport Arrival Name"] = "\(divertedAirportArrivalName!)"
                                            self.flights[index]["Arrival City"] = "\(divertedAirportArrivalCity!)"
                                            self.flights[index]["Airport Arrival Time Zone"] = "\(divertedAirportArrivalTimeZone!)"
                                            self.flights[index]["Arrival Airport UTC Offset"] = "\(divertedAirportArrivalUtcOffsetHours!)"
                                        }
                                        
                                    }
                                    
                                    if let arrivalGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalGate"] as? String {
                                        
                                        arrivalGate = arrivalGateCheck
                                        
                                    } else {
                                        
                                        arrivalGate = "-"
                                        
                                    }
                                    
                                    if let arrivalTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalTerminal"] as? String {
                                        
                                        arrivalTerminal = arrivalTerminalCheck
                                        
                                    } else {
                                        
                                        arrivalTerminal = "-"
                                    }
                                    
                                    //arrival timings
                                    var publishedArrival:String! = ""
                                    var convertedPublishedArrival:String! = ""
                                    var publishedArrivalWhole:String! = ""
                                    
                                    var scheduledGateArrivalUtc:String! = ""
                                    var scheduledGateArrivalWholeNumber:String! = ""
                                    var scheduledGateArrival:String! = ""
                                    var convertedScheduledGateArrival:String! = ""
                                    
                                    var estimatedGateArrivalUtc:String! = ""
                                    var estimatedGateArrivalWholeNumber:String! = ""
                                    var convertedEstimatedGateArrival:String! = ""
                                    var estimatedGateArrival:String! = ""
                                    
                                    var convertedActualGateArrival:String! = ""
                                    var actualGateArrivalWhole:String! = ""
                                    var actualGateArrival:String! = ""
                                    
                                    var convertedEstimatedRunwayArrival:String! = ""
                                    var estimatedRunwayArrivalUtc:String! = ""
                                    var estimatedRunwayArrivalWhole:String! = ""
                                    var estimatedRunwayArrival:String! = ""
                                    
                                    var convertedActualRunwayArrival:String! = ""
                                    var actualRunwayArrivalUtc:String! = ""
                                    var actualRunwayArrivalWhole:String! = ""
                                    var actualRunwayArrival:String! = ""
                                    
                                    if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayArrival = actualRunwayArrivalCheck
                                        actualRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: actualRunwayArrivalCheck)
                                        convertedActualRunwayArrival = self.convertDateTime(date: actualRunwayArrivalCheck)
                                        actualRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let publishedArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedArrival = publishedArrivalCheck
                                        convertedPublishedArrival = self.convertDateTime(date: publishedArrival!)
                                        publishedArrivalWhole = self.formatDateTimetoWhole(dateTime: publishedArrival!)
                                        
                                    }
                                    
                                    if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayArrival = estimatedRunwayArrivalCheck
                                        estimatedRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: estimatedRunwayArrivalCheck)
                                        convertedEstimatedRunwayArrival = self.convertDateTime(date: estimatedRunwayArrivalCheck)
                                        estimatedRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateArrival = scheduledGateArrivalCheck
                                        scheduledGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: scheduledGateArrivalCheck)
                                        convertedScheduledGateArrival = self.convertDateTime(date: scheduledGateArrivalCheck)
                                        scheduledGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateArrival = estimatedGateArrivalCheck
                                        estimatedGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateArrivalCheck)
                                        convertedEstimatedGateArrival = self.convertDateTime(date: estimatedGateArrivalCheck)
                                        estimatedGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateArrival = actualGateArrivalCheck
                                        convertedActualGateArrival = self.convertDateTime(date: actualGateArrivalCheck)
                                        actualGateArrivalWhole = self.formatDateTimetoWhole(dateTime: actualGateArrivalCheck)
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        //unambiguos data
                                        self.flights[index]["Flight Status"] = "\(NSLocalizedString(self.flightStatusFormatted!, comment: ""))"
                                        self.flights[index]["Flight Duration Scheduled"] = "\(flightDurationScheduled!)"
                                        self.flights[index]["Baggage Claim"] = "\(baggageClaim)"
                                        self.flights[index]["Primary Carrier"] = "\(primaryCarrier)"
                                        self.flights[index]["Irregular Operation Message 1"] = "\(irregularOperationsMessage1)"
                                        self.flights[index]["Irregular Operation Message 2"] = "\(irregularOperationsMessage2)"
                                        self.flights[index]["Irregular Operation Type 1"] = "\(irregularOperationsType1)"
                                        self.flights[index]["Irregular Operation Type 2"] = "\(irregularOperationsType2)"
                                        self.flights[index]["Confirmed Incident Message"] = "\(confirmedIncidentMessage!)"
                                        self.flights[index]["Updated Flight Equipment"] = "\(updatedFlightEquipment!)"
                                        
                                        //departure data
                                        self.flights[index]["Airport Departure Terminal"] = "\(departureTerminal!)"
                                        self.flights[index]["Departure Gate"] = "\(departureGate!)"
                                        
                                        //departure timings
                                        self.flights[index]["Converted Actual Runway Departure"] = "\(convertedActualRunwayDeparture!)"
                                        self.flights[index]["Actual Runway Departure Whole"] = "\(actualRunwayDepartureWhole!)"
                                        self.flights[index]["Actual Runway Departure UTC"] = "\(actualRunwayDepartureUtc!)"
                                        self.flights[index]["Actual Runway Departure"] = "\(actualRunwayDeparture!)"
                                        
                                        self.flights[index]["Scheduled Runway Departure Whole Number"] = "\(scheduledRunwayDepartureWhole!)"
                                        self.flights[index]["Converted Scheduled Runway Departure"] = "\(convertedScheduledRunwayDeparture!)"
                                        self.flights[index]["Scheduled Runway Departure"] = "\(scheduledRunwayDeparture!)"
                                        self.flights[index]["Scheduled Runway Departure UTC"] = "\(scheduledRunwayDepartureUtc!)"
                                        
                                        self.flights[index]["Converted Estimated Runway Departure"] = "\(convertedEstimatedRunwayDeparture!)"
                                        self.flights[index]["Estimated Runway Departure Whole Number"] = "\(estimatedRunwayDepartureWholeNumber!)"
                                        self.flights[index]["Estimated Runway Departure"] = "\(estimatedRunwayDeparture!)"
                                        
                                        self.flights[index]["Scheduled Gate Departure Whole Number"] = "\(scheduledGateDepartureDateTimeWhole!)"
                                        self.flights[index]["Converted Scheduled Gate Departure"] = "\(convertedScheduledGateDeparture!)"
                                        self.flights[index]["Scheduled Gate Departure"] = "\(scheduledGateDeparture!)"
                                        
                                        self.flights[index]["Converted Published Departure"] = "\(convertedPublishedDeparture!)"
                                        self.flights[index]["Published Departure Whole"] = "\(publishedDepartureWhole!)"
                                        self.flights[index]["Published Departure"] = "\(publishedDeparture!)"
                                        
                                        self.flights[index]["Converted Estimated Gate Departure"] = "\(convertedEstimatedGateDeparture!)"
                                        self.flights[index]["Estimated Gate Departure Whole Number"] = "\(estimatedGateDepartureWholeNumber!)"
                                        self.flights[index]["Estimated Gate Departure"] = "\(estimatedGateDeparture!)"
                                        
                                        self.flights[index]["Converted Actual Gate Departure"] = "\(convertedActualGateDeparture!)"
                                        self.flights[index]["Actual Gate Departure Whole"] = "\(actualGateDepartureWhole!)"
                                        self.flights[index]["Actual Gate Departure UTC"] = "\(actualGateDepartureUtc!)"
                                        self.flights[index]["Actual Gate Departure"] = "\(actualGateDeparture!)"
                                        
                                        
                                        
                                        //arrival data
                                        self.flights[index]["Airport Arrival Terminal"] = "\(arrivalTerminal!)"
                                        self.flights[index]["Arrival Gate"] = "\(arrivalGate!)"
                                        
                                        //arrival timings
                                        self.flights[index]["Actual Runway Arrival Whole Number"] = "\(actualRunwayArrivalWhole!)"
                                        self.flights[index]["Converted Actual Runway Arrival"] = "\(convertedActualRunwayArrival!)"
                                        self.flights[index]["Actual Runway Arrival UTC"] = "\(actualRunwayArrivalUtc!)"
                                        self.flights[index]["Actual Runway Arrival"] = "\(actualRunwayArrival!)"
                                        
                                        self.flights[index]["Estimated Runway Arrival Whole Number"] = "\(estimatedRunwayArrivalWhole!)"
                                        self.flights[index]["Converted Estimated Runway Arrival"] = "\(convertedEstimatedRunwayArrival!)"
                                        self.flights[index]["Estimated Runway Arrival UTC"] = "\(estimatedRunwayArrivalUtc!)"
                                        self.flights[index]["Estimated Runway Arrival"] = "\(estimatedRunwayArrival!)"
                                        
                                        self.flights[index]["Scheduled Gate Arrival Whole Number"] = "\(scheduledGateArrivalWholeNumber!)"
                                        self.flights[index]["Converted Scheduled Gate Arrival"] = "\(convertedScheduledGateArrival!)"
                                        self.flights[index]["Scheduled Gate Arrival UTC"] = "\(scheduledGateArrivalUtc!)"
                                        self.flights[index]["Scheduled Gate Arrival"] = "\(scheduledGateArrival!)"
                                        
                                        self.flights[index]["Converted Published Arrival"] = "\(convertedPublishedArrival!)"
                                        self.flights[index]["Published Arrival Whole"] = "\(publishedArrivalWhole!)"
                                        self.flights[index]["Published Arrival"] = "\(publishedArrival!)"
                                        
                                        self.flights[index]["Estimated Gate Arrival Whole Number"] = "\(estimatedGateArrivalWholeNumber!)"
                                        self.flights[index]["Converted Estimated Gate Arrival"] = "\(convertedEstimatedGateArrival!)"
                                        self.flights[index]["Estimated Gate Arrival UTC"] = "\(estimatedGateArrivalUtc!)"
                                        self.flights[index]["Estimated Gate Arrival"] = "\(estimatedGateArrival!)"
                                        
                                        self.flights[index]["Converted Actual Gate Arrival"] = "\(convertedActualGateArrival!)"
                                        self.flights[index]["Actual Gate Arrival Whole"] = "\(actualGateArrivalWhole!)"
                                        self.flights[index]["Actual Gate Arrival"] = "\(actualGateArrival!)"
                                        
                                        //print("flights = \(self.flights)")
                                        
                                        self.flightTable.reloadData()
                                        
                                        UserDefaults.standard.set(self.flights, forKey: "flights")
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.activityIndicator.stopAnimating()
                                            self.activityLabel.removeFromSuperview()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            
                                            if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && self.flightId != 0 {
                                                
                                                let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n\(NSLocalizedString("Would you like to add the replacement flight automatically?", comment: ""))" , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.parseFlightID(dictionary: self.flights[index], index: index)
                                                    
                                                }))
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" {
                                                
                                                let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)" , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                                
                                            } else if irregularOperationsMessage1 != "" {
                                                
                                                let alert = UIAlertController(title: "\(irregularOperationsType1)", message: "\n\(irregularOperationsMessage1)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                                
                                            } else if irregularOperationsType1 != "" {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: "\(NSLocalizedString("This flight has an irregular operation of type:", comment: "")) \(irregularOperationsType1)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                        
                                        //need to change below
                                        
                                        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "FlightsTable") as UIViewController; self.present(viewController, animated: true, completion: nil)
                                        
                                    }
                                    
                                } else {
                                    
                                    if let errorMessage = ((jsonFlightStatusData)["error"] as? NSDictionary)?["errorMessage"] as? String {
                                        
                                        print("errorMessage = \(errorMessage)")
                                        
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.activityLabel.removeFromSuperview()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
                
            } catch {
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityLabel.removeFromSuperview()
                    self.blurEffectViewActivity.removeFromSuperview()
                    print("Error parsing")
                }
                
            }
            
        }
        
        task.resume()
    }
    
    
    func shareFlight(indexPath: Int) {
        
        let alert = UIAlertController(title: NSLocalizedString("Share With", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for user in self.userNames {
            
            alert.addAction(UIAlertAction(title: "\(user)", style: .default, handler: { (action) in
                
                let departureDate = self.flights[indexPath]["URL Departure Date"]
                let airlineCode = self.flights[indexPath]["Airline Code"]
                let flightNumber = self.flights[indexPath]["Flight Number"]
                
                let flight = self.flights[indexPath]
                
                let sharedFlight = PFObject(className: "SharedFlight")
                
                sharedFlight["shareToUsername"] = user
                sharedFlight["shareFromUsername"] = PFUser.current()?.username
                sharedFlight["departureDate"] = departureDate
                sharedFlight["airlineCode"] = airlineCode
                sharedFlight["flightNumber"] = flightNumber
                sharedFlight["flightDictionary"] = flight
                
                sharedFlight.saveInBackground(block: { (success, error) in
                    
                    if error != nil {
                        
                        let alert = UIAlertController(title: NSLocalizedString("Could not share flight", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "\(NSLocalizedString("Flight shared to", comment: "")) \(user)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        
                        
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                            
                            
                            
                            
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    }
                })
                
                
            }))
            
        }
        
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        print("shareflight")
        
    }
    
    func getFlightDuration(departureDate: String, arrivalDate: String, departureOffset: String, arrivalOffset: String) -> (String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        let departureDateTime = dateFormatter.date(from: departureDate)
        let arrivalDateTime = dateFormatter.date(from: arrivalDate)
        
        var utcDepartureInterval = (Double(departureOffset)! * 60 * 60)
        var utcArrivalInterval = (Double(arrivalOffset)! * 60 * 60)
        
        if utcDepartureInterval < 0 {
            
            utcDepartureInterval = abs(utcDepartureInterval)
            
        } else if utcDepartureInterval > 0 {
            
            utcDepartureInterval = utcDepartureInterval * -1
            
        } else if utcDepartureInterval == 0 {
            
            utcDepartureInterval = 0
        }
        
        if utcArrivalInterval < 0 {
            
            utcArrivalInterval = abs(utcArrivalInterval)
            
        } else if utcArrivalInterval > 0 {
            
            utcArrivalInterval = utcArrivalInterval * -1
            
        } else if utcArrivalInterval == 0 {
            
            utcArrivalInterval = 0
            
        }
        
        let departureDateUtc = departureDateTime!.addingTimeInterval(utcDepartureInterval)
        let arrivalDateUtc = arrivalDateTime!.addingTimeInterval(utcArrivalInterval)
        
        let interval = arrivalDateUtc.timeIntervalSince(departureDateUtc)
        
        let hours = abs((Int(interval) % 86400) / 3600)
        
        let minutes = abs((Int(interval) % 3600) / 60)
        
        if hours > 0 {
            
            return("\(hours)hr \(minutes)min")
            
        } else {
            
            return("\(minutes)min")
            
        }
        
    }
    
    func convertDuration(flightDurationScheduled: String) -> (String) {
        
        let flightDurationScheduledInt = (Int(flightDurationScheduled)! * 60)
        
        let hours1 = (Int(flightDurationScheduledInt) / 3600)
        
        let minutes1 = (Int(flightDurationScheduledInt) % 3600) / 60
        
        if hours1 > 0 {
            
            return("\(hours1)hr \(minutes1)min")
            
        } else {
            
            return("\(minutes1)min")
            
        }
        
    }
    
    func countDown(departureDate: String, departureUtcOffset: String) -> (months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        
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
        
        let currentDateUtc = date.addingTimeInterval(TimeInterval(utcInterval))
        let calendar = NSCalendar.current
        let nowDateComponents = NSDateComponents()
        nowDateComponents.day = calendar.component(.day, from: currentDateUtc as Date)
        nowDateComponents.month = calendar.component(.month, from: currentDateUtc as Date)
        nowDateComponents.year = calendar.component(.year, from: currentDateUtc as Date)
        nowDateComponents.hour = calendar.component(.hour, from: currentDateUtc as Date)
        nowDateComponents.minute = calendar.component(.minute, from: currentDateUtc as Date)
        nowDateComponents.second = calendar.component(.second, from: currentDateUtc as Date)
        let currentDate = NSCalendar.current.date(from: nowDateComponents as DateComponents)
        
        //here we change departure date to UTC time
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        let departureDateTime = departureDateFormatter.date(from: departureDate)
        
        var utcDepartureInterval = (Double(departureUtcOffset)! * 60 * 60)
        
        if utcDepartureInterval < 0 {
            
            utcDepartureInterval = abs(utcDepartureInterval)
            
        } else if utcDepartureInterval > 0 {
            
            utcDepartureInterval = utcDepartureInterval * -1
            
        } else if utcDepartureInterval == 0 {
            
            utcDepartureInterval = 0
        }
        
        let departureDateUtc = departureDateTime!.addingTimeInterval(utcDepartureInterval)
        let departureDateUtcString = departureDateFormatter.string(from: departureDateUtc)
        
        // here we set the due date. When the timer is supposed to finish
        var dateArray = departureDateUtcString.components(separatedBy: "T")
        let dateSegment = dateArray[0]
        let timeSegment = dateArray[1]
        var timeArray = timeSegment.components(separatedBy: ".000")
        let time1 = timeArray[0]
        var hoursAndMinutes = time1.components(separatedBy: ":")
        let departureHour = hoursAndMinutes[0]
        let departureMinutes = hoursAndMinutes[1]
        let departureSeconds = hoursAndMinutes[2]
        
        var dateSplitArray = dateSegment.components(separatedBy: "-")
        let departureYear = dateSplitArray[0]
        let departureMonth = dateSplitArray[1]
        let departureDay = dateSplitArray[2]
        
        let dateComponents1 = NSDateComponents()
        dateComponents1.day = Int(departureDay)!
        dateComponents1.month = Int(departureMonth)!
        dateComponents1.year = Int(departureYear)!
        dateComponents1.hour = Int(departureHour)!
        dateComponents1.minute = Int(departureMinutes)!
        dateComponents1.second = Int(departureSeconds)!
        
        let departureDateUtcCalendar = NSCalendar.current.date(from: dateComponents1 as DateComponents)
        
        var componentsDifference = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate!, to: departureDateUtcCalendar!)
        
        if componentsDifference.month! < 0 || componentsDifference.day! < 0 || componentsDifference.hour! < 0 || componentsDifference.minute! < 0 || componentsDifference.second! < 0 {
            
            return(((componentsDifference.month!) * 0), ((componentsDifference.day!) * 0), ((componentsDifference.hour!) * 0), ((componentsDifference.minute!) * 0), ((componentsDifference.second!) * 0))
            
        } else if componentsDifference.year! > 0 {
            
            return(((12 * componentsDifference.year!) + (componentsDifference.month!)), componentsDifference.day!, componentsDifference.hour!, componentsDifference.minute!, componentsDifference.second!)
            
        } else {
            
            return(componentsDifference.month!, componentsDifference.day!, componentsDifference.hour!, componentsDifference.minute!, componentsDifference.second!)
            
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
    
    
    func getUtcTimes(publishedDeparture: String, publishedArrival: String, departureOffset: String, arrivalOffset: String) -> (departureDateUtc: String, arrivalDateUtc: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        let departureDateTime = dateFormatter.date(from: publishedDeparture)
        let arrivalDateTime = dateFormatter.date(from: publishedArrival)
        
        var utcDepartureInterval = (Double(departureOffset)! * 60 * 60)
        var utcArrivalInterval = (Double(arrivalOffset)! * 60 * 60)
        
        if utcDepartureInterval < 0 {
            
            utcDepartureInterval = abs(utcDepartureInterval)
            
        } else if utcDepartureInterval > 0 {
            
            utcDepartureInterval = utcDepartureInterval * -1
            
        } else if utcDepartureInterval == 0 {
            
            utcDepartureInterval = 0
        }
        
        if utcArrivalInterval < 0 {
            
            utcArrivalInterval = abs(utcArrivalInterval)
            
        } else if utcArrivalInterval > 0 {
            
            utcArrivalInterval = utcArrivalInterval * -1
            
        } else if utcArrivalInterval == 0 {
            
            utcArrivalInterval = 0
            
        }
        
        let departureDateUtc = String(describing: departureDateTime!.addingTimeInterval(utcDepartureInterval))
        let arrivalDateUtc = String(describing: arrivalDateTime!.addingTimeInterval(utcArrivalInterval))
        
        return(departureDateUtc, arrivalDateUtc)
        
    }
    
    func didFlightAlreadyLand (arrivalDate: String, utcOffset: String) -> (Bool) {
        
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
        let arrivalDateUtc = self.getUtcTime(time: arrivalDate, utcOffset: utcOffset)
        
        let arrivalDateUtcDate = dateFormatter.date(from: arrivalDateUtc)
        
        if arrivalDateUtcDate! < currentDateUtc as Date {
            
            return true
            
        } else {
            
            return false
        }
        
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
    
    
    
    func checkFlightStatusOffline() {
        
        for (index, flight) in self.flights.enumerated() {
            
            let departureDate = flight["Published Departure"]!
            let departureUTC = flight["Departure Airport UTC Offset"]!
            self.flightTookOff = didFlightAlreadyTakeoff(departureDate: departureDate, utcOffset: departureUTC)
            
            let scheduledArrival = flight["Published Arrival"]!
            let arrivalUTC = flight["Arrival Airport UTC Offset"]!
            self.flightLanded = didFlightAlreadyLand(arrivalDate: scheduledArrival, utcOffset: arrivalUTC)
            
            self.flights[index]["Took off"] = "\(self.flightTookOff!)"
            self.flights[index]["Landed"] = "\(self.flightLanded!)"
            
        }
        
        
        
    }
    
    func sortFlightsbyDepartureDate() {
        
        sortedFlights = flights.sorted {
            
            (dictOne, dictTwo) -> Bool in
            
            let d1 = Int(dictOne["Published Departure UTC Number"]!)
            let d2 = Int(dictTwo["Published Departure UTC Number"]!)
            
            
            return d1! < d2!
            
        };
        flights = sortedFlights
    }
    
    func convertToURLDate (date: String) -> (String) {
        
        var dateArray = date.components(separatedBy: "T")
        let dateSegment = dateArray[0]
        
        var dateSplitArray = dateSegment.components(separatedBy: "-")
        let year = dateSplitArray[0]
        let month = dateSplitArray[1]
        let day = dateSplitArray[2]
        
        let urlDepartureDate = "\(year)/" + "\(month)/" + "\(day)"
        
        return urlDepartureDate
        
    }
    
    func getTimeDifference(publishedTime: String, actualTime: String) -> (String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let date1 = dateFormatter.date(from: publishedTime)
        let date2 = dateFormatter.date(from: actualTime)
        
        let interval = date1?.timeIntervalSince(date2!)
        
        let hours = abs((Int(interval!) % 86400) / 3600)
        
        let minutes = abs((Int(interval!) % 3600) / 60)
        
        if hours > 0 {
            
            return("\(hours)hr \(minutes)min")
            
        } else {
            
            return("\(minutes)min")
            
        }
        
    }
    
    func secondsTillLanding (arrivalDateUTC: String) -> (Int) {
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateToCheck = dateTimeFormatter.date(from: arrivalDateUTC)! as NSDate
        let secondsFromNow = dateToCheck.timeIntervalSinceNow
        
        return Int(secondsFromNow)
        
    }
    
    func secondsSinceTakeOff (departureDateUTC: String) -> (Int) {
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateToCheck = dateTimeFormatter.date(from: departureDateUTC)! as NSDate
        let secondsSinceTakeOff = dateToCheck.timeIntervalSinceNow
        
        return Int(abs(secondsSinceTakeOff))
        
    }
    
    func formatDateTimetoWhole(dateTime: String) -> String {
        
        let dateTimeAsNumberStep1 = dateTime.replacingOccurrences(of: "-", with: "")
        let dateTimeAsNumberStep2 = dateTimeAsNumberStep1.replacingOccurrences(of: "T", with: "")
        let dateTimeAsNumberStep3 = dateTimeAsNumberStep2.replacingOccurrences(of: ":", with: "")
        let dateTimeWhole = dateTimeAsNumberStep3.replacingOccurrences(of: ".", with: "")
        
        return dateTimeWhole
    }
    
    func convertDateTime (date: String) -> (String) {
        
        
        var dateArray = date.components(separatedBy: "T")
        let dateSegment = dateArray[0]
        let timeSegment = dateArray[1]
        var timeArray = timeSegment.components(separatedBy: ":00.000")
        let time1 = timeArray[0]
        var hoursAndMinutes = time1.components(separatedBy: ":")
        let hour = hoursAndMinutes[0]
        let minutes = hoursAndMinutes[1]
        
        var dateSplitArray = dateSegment.components(separatedBy: "-")
        let year = dateSplitArray[0]
        let month = dateSplitArray[1]
        let day1 = dateSplitArray[2]
        
        let dateComponents = NSDateComponents()
        dateComponents.day = Int(day1)!
        dateComponents.month = Int(month)!
        dateComponents.year = Int(year)!
        dateComponents.hour = Int(hour)!
        dateComponents.minute = Int(minutes)!
        
        let dateToBeFormatted = NSCalendar.current.date(from: dateComponents as DateComponents)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy, HH:mm"
        
        let dateString = formatter.string(from: dateToBeFormatted!)
        
        return dateString
        
    }
    
    func formatFlightEquipment(flightEquipment: String) -> String {
        
        var seperatedArray = flightEquipment.components(separatedBy: " (sharklets)")
        let aircraftString = seperatedArray[0]
        
        return aircraftString
        
    }
    
    func isDepartureDate72HoursAwayOrLess (date: String) -> (Bool) {
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let dateToCheck = dateTimeFormatter.date(from: date)! as NSDate
        let secondsFromNow = dateToCheck.timeIntervalSinceNow
        
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        var utcInterval = secondsFromGMT
        
        if utcInterval < 0 {
            
            utcInterval = abs(utcInterval)
            
        } else if utcInterval > 0 {
            
            utcInterval = utcInterval * -1
            
        } else if utcInterval == 0 {
            
            utcInterval = 0
        }
        
        
        
        
        if (secondsFromNow - Double(utcInterval)) >= 259199 {
            
            return false
            
        } else {
            
            return true
            
        }
        
    }

}
