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
    var formattedFlightNumber = ""
    var formattedDepartureDate = ""
    var users = [String: String]()
    var userNames = [String]()
    var activityIndicator:UIActivityIndicatorView!
    var flights = [Dictionary<String,String>]()
    var airlineCodeURL = ""
    var flightNumberURL = ""
    var departureDateURL = ""
    var departureAirportCodeURL = ""
    var flightStatusFormatted = ""
    var flightStatusUnformatted = ""
    var selectedRow:Int!
    var cellArray:[String] = []
    var downlineFlightId = ""
    var currentDateWhole = ""
    var refresher:UIRefreshControl!
    var publishedDeparture = ""
    var actualDeparture = ""
    var publishedArrival = ""
    var actualArrival = ""
    var timer:Timer!
    var flightId:Double! = 0
    let gradientLayer = CAGradientLayer()
    var sortedFlights = [Dictionary<String,String>]()
    var departureDatesStringArray: [String] = []
    var departureDateString = ""
    var flightTookOff:Bool!
    var flightLanded:Bool!
    var flightEstimatedArrivalString = ""
    var flightActualDepartureString = ""
    @IBOutlet weak var flightTable: UITableView!
    let button = UIButton()
    let addButton = UIButton()
    var flightArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //checkFlightStatusOffline(flight: <#[String : Any]#>)
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
        
        cell.terminalLabel.text = NSLocalizedString("Terminal", comment: "")
        cell.gateLabel.text = NSLocalizedString("Gate", comment: "")
        cell.arrivalGateLabel.text = NSLocalizedString("Gate", comment: "")
        cell.arrivalBaggageLabel.text = NSLocalizedString("Baggage", comment: "")
        cell.arrivalTerminalLabel.text = NSLocalizedString("Terminal", comment: "")
        
        let thumbImage = UIImage(named: "airplaneSliderImage.png")?.resizeImage(targetSize: CGSize(width: 60, height: 60))
        cell.slider.setThumbImage(thumbImage, for: .normal)
        cell.slider.maximumValue = 1.0
        cell.slider.minimumValue = 0.0
        cell.slider.value = cell.slider.minimumValue
        cell.countdownView.isHidden = true
        
        cell.tapShareAction = {
            
            (cell) in self.shareFlight(indexPath: (tableView.indexPath(for: cell)!.row))
            
        }
        
        let publishedDeparture = self.flightArray[indexPath.row]["publishedDeparture"] as! String
        let publishedDepartureNumber = formatDateTimetoWhole(dateTime: publishedDeparture)
        let publishedArrival = self.flightArray[indexPath.row]["publishedArrival"] as! String
        let publishedArrivalNumber = formatDateTimetoWhole(dateTime: publishedArrival)
        let departureDate = self.flightArray[indexPath.row]["departureTime"] as! String
        let departureDateNumber = formatDateTimetoWhole(dateTime: departureDate)
        let arrivalDate = self.flightArray[indexPath.row]["arrivalDate"] as! String
        let arrivalDateNumber = formatDateTimetoWhole(dateTime: arrivalDate)
        let departureOffset = self.flightArray[indexPath.row]["departureUtcOffset"] as! Double
        let arrivalOffset = self.flightArray[indexPath.row]["arrivalUtcOffset"] as! Double
        let flightStatus = self.flightArray[indexPath.row]["flightStatus"] as! String
        let flightEquipment = self.flightArray[indexPath.row]["flightEquipment"] as! String
        let primaryCarrier = self.flightArray[indexPath.row]["primaryCarrier"] as! String
        let flightNumber = self.flightArray[indexPath.row]["flightNumber"] as! String
        let depCity = self.flightArray[indexPath.row]["departureCity"] as! String
        let depAirport = self.flightArray[indexPath.row]["departureAirport"] as! String
        let arrCity = self.flightArray[indexPath.row]["arrivalCity"] as! String
        let arrAirport = self.flightArray[indexPath.row]["arrivalAirportCode"] as! String
        let depTerminal = self.flightArray[indexPath.row]["departureTerminal"] as! String
        let depGate = self.flightArray[indexPath.row]["departureGate"] as! String
        let arrTerminal = self.flightArray[indexPath.row]["arrivalTerminal"] as! String
        let arrGate = self.flightArray[indexPath.row]["arrivalGate"] as! String
        let baggage = self.flightArray[indexPath.row]["baggageClaim"] as! String
        let flightDurationScheduled = self.flightArray[indexPath.row]["flightDuration"] as! String
        /*var convertedDuration = String()
        if flightDurationScheduled != "" {
            convertedDuration = convertDuration(flightDurationScheduled: flightDurationScheduled)
        }*/
        let flightDuration = getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
         let departureTimeDifference = getTimeDifference(publishedTime: publishedDeparture, actualTime: departureDate)
        let arrivalTimeDifference = getTimeDifference(publishedTime: publishedArrival, actualTime: arrivalDate)
            
        if flightStatus == "" {
                
            cell.status.text = NSLocalizedString("Tap to update", comment: "")
                
        } else {
                
            cell.status.text = NSLocalizedString(flightStatus, comment: "")
        }
            
        cell.flightDuration.text = flightDuration
        cell.aircraftType.text = flightEquipment
        cell.airlineName.text = "\(primaryCarrier) \(flightNumber)"
        cell.departureCity.text = depCity + " (\(depAirport))"
        cell.arrivalCity.text = arrCity + " (\(arrAirport))"
        cell.departureTerminal.text = depTerminal
        cell.departureGate.text = depGate
        cell.arrivalTerminal.text = arrTerminal
        cell.arrivalGate.text = arrGate
        cell.baggageClaim.text = baggage
        cell.departureDate.text = convertDateTime(date: departureDate)
        cell.arrivalDate.text = convertDateTime(date: arrivalDate)
        cell.flightDuration.text = flightDuration//convertedDuration
            
        if self.flights.count <= 3 {
                
            if flightStatus != "Departed" {
                    
                DispatchQueue.main.async {
                    self.setCountDown(type: "departure", date: departureDate, offset: departureOffset, indexPath: indexPath)
                }
                /*self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                        (_) in
                        
                    DispatchQueue.main.async {
                            
                        cell.countDownLabel.text = NSLocalizedString("till departure", comment: "")
                            
                        let monthsLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).months
                        let daysLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).days
                        let hoursLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).hours
                        let minutesLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).minutes
                        let secondsLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).seconds
                            
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
                }*/
                    
            } else if flightStatus == "Departed" {
                
                DispatchQueue.main.async {
                    self.setCountDown(type: "arrival", date: arrivalDate, offset: arrivalOffset, indexPath: indexPath)
                }
                
                
                    
                /*self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                        (_) in
                        
                    DispatchQueue.main.async {
                            
                        cell.countDownLabel.text = NSLocalizedString("till arrival", comment: "")
                            
                        let monthsLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).months
                        let daysLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).days
                        let hoursLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).hours
                        let minutesLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).minutes
                        let secondsLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).seconds
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
                }*/
            }
        }
        
        if flightStatus == "Scheduled" {
            
            DispatchQueue.main.async {
                
               if departureTimeDifference == "0min" {
                    
                    cell.landingOnTimeDelayed.text = NSLocalizedString("Departing on time", comment: "")
                    
                } else if publishedDepartureNumber < departureDateNumber {
                    
                    cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Departure delayed by", comment: "")) \(departureTimeDifference)"
                    
                } else if publishedDepartureNumber > departureDateNumber {
                    
                    cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                }
                    
            }
            
        } else if flightStatus == "Departed" || flightStatus == "Redirected" || flightStatus == "Diverted" {
            
            DispatchQueue.main.async {
                
                if arrivalTimeDifference == "0min" {
                    
                    cell.landingOnTimeDelayed.text = NSLocalizedString("Arriving on time", comment: "")
                    
                } else if publishedArrivalNumber < arrivalDateNumber {
                    
                    cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Arrival delayed by", comment: "")) \(arrivalTimeDifference)"
                    
                } else if publishedArrivalNumber > arrivalDateNumber {
                    
                    cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Arriving", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                }
                
                let timeTillLanding = self.secondsTillLanding(arrivalDateUTC: getUtcTime(time: arrivalDate, utcOffset: arrivalOffset))
                print("timeTillLanding = \(timeTillLanding)")
                let timeSinceTakeOff = self.secondsSinceTakeOff(departureDateUTC: getUtcTime(time: departureDate, utcOffset: departureOffset))
                print("timeSinceTakeOff = \(timeSinceTakeOff)")
                cell.slider.maximumValue = Float(timeSinceTakeOff + timeTillLanding)
                cell.slider.minimumValue = Float(0)
                cell.slider.value = Float(timeSinceTakeOff)
                
            }
            
        } else if flightStatus == "Landed" {
            
            DispatchQueue.main.async {
                
                if arrivalTimeDifference == "0min" {
                    
                    cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("late", comment: ""))"
                    
                } else if publishedArrivalNumber < arrivalDateNumber {
                    
                    cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Arrival delayed by", comment: "")) \(arrivalTimeDifference)"
                    
                } else if publishedArrivalNumber > arrivalDateNumber {
                    
                    cell.landingOnTimeDelayed.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                }
                
                cell.slider.maximumValue = 1.0
                cell.slider.minimumValue = 0.0
                cell.slider.value = cell.slider.maximumValue
                
            }
            
        } else if flightStatus == "Cancelled" {
            
            cell.status.text = NSLocalizedString("Cancelled", comment: "")
            cell.slider.maximumValue = 1.0
            cell.slider.minimumValue = 0.0
            cell.slider.value = cell.slider.minimumValue
            
        }
        
        return cell
    }
    
    func setCountDown(type: String, date: String, offset: Double, indexPath: IndexPath) {
        
        let cell = flightTable.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath) as! TableViewCell
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            (_) in
            
            DispatchQueue.main.async {
                
                if type == "arrival" {
                   cell.countDownLabel.text = NSLocalizedString("till arrival", comment: "")
                } else if type == "departure" {
                   cell.countDownLabel.text = NSLocalizedString("till departure", comment: "")
                }
                
                
                let monthsLeft = countDown(departureDate: date, departureUtcOffset: offset).months
                let daysLeft = countDown(departureDate: date, departureUtcOffset: offset).days
                let hoursLeft = countDown(departureDate: date, departureUtcOffset: offset).hours
                let minutesLeft = countDown(departureDate: date, departureUtcOffset: offset).minutes
                let secondsLeft = countDown(departureDate: date, departureUtcOffset: offset).seconds
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flightArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        parseLeg2Only(viewController: self, dictionary: flightArray[indexPath.row], index: indexPath.row)
        flightArray = getFlightArray()
        flightTable.reloadData()
        
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
    
    func refresh() {
        
        if PFUser.current() != nil {
            
            let getSharedFlightQuery = PFQuery(className: "SharedFlight")
            
            getSharedFlightQuery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
            
            getSharedFlightQuery.findObjectsInBackground { (sharedFlights, error) in
                
                if error != nil {
                    self.refresher.endRefreshing()
                    print("error = \(error as Any)")
                    
                } else {
                    
                    for flight in sharedFlights! {
                        
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
                                
                                print("flight deleted")
                                
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
    
    
    
    func shareFlight(indexPath: Int) {
        
        let followedUsers = getFollowedUsers()
        let departureDate = convertToURLDate(date: (self.flightArray[indexPath]["publishedDeparture"] as! String))
        let airlineCode = self.flightArray[indexPath]["airlineCode"] as! String
        let flightNumber = self.flightArray[indexPath]["flightNumber"] as! String
        let flight = self.flightArray[indexPath]
        let depCity = self.flightArray[indexPath]["departureCity"] as! String
        let arrCity = self.flightArray[indexPath]["arrivalCity"] as! String
        let date = convertDateTime(date: self.flightArray[indexPath]["departureTime"] as! String)
        
        let alert = UIAlertController(title: NSLocalizedString("Share Flight \(flightNumber) from \(depCity) to \(arrCity), departing on \(date) with:", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for user in followedUsers {
            
            alert.addAction(UIAlertAction(title: "\(user)", style: .default, handler: { (action) in
                
                print("shared flight dict = \(flight)")
                
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
                        
                        
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }))
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func didFlightAlreadyLand (arrivalDate: String, utcOffset: Double) -> (Bool) {
        
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
        let arrivalDateUtc = getUtcTime(time: arrivalDate, utcOffset: utcOffset)
        
        let arrivalDateUtcDate = dateFormatter.date(from: arrivalDateUtc)
        
        if arrivalDateUtcDate! < currentDateUtc as Date {
            
            return true
            
        } else {
            
            return false
        }
        
    }
    
    
    
    
    
    func checkFlightStatusOffline(flight: [String:Any]) -> String {
        
        var offlineStatus = String()
        
        let departureDate = flight["publishedDeparture"] as! String
        let departureUTC = flight["departureUtcOffset"] as! Double
        let flightTookOff = didFlightAlreadyTakeoff(departureDate: departureDate, utcOffset: departureUTC)
            
        let scheduledArrival = flight["publishedArrival"] as! String
        let arrivalUTC = flight["arrivalUtcOffset"] as! Double
        let flightLanded = didFlightAlreadyLand(arrivalDate: scheduledArrival, utcOffset: arrivalUTC)
            
        if flightTookOff && !flightLanded {
            offlineStatus =  "Departed"
        } else if flightLanded && flightTookOff {
            offlineStatus = "Landed"
        } else if !flightLanded && !flightTookOff {
            offlineStatus = "Scheduled"
        }
        
        return offlineStatus
        
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
    
    
    func formatFlightStatus(flightStatusUnformatted: String) -> String {
        var formattedText = String()
        switch self.flightStatusUnformatted {
        case "S": formattedText = "Scheduled"
        case "A": formattedText = "Departed"
        case "D": formattedText = "Diverted"
        case "DN": formattedText = "Data Source Needed"
        case "L": formattedText = "Landed"
        case "NO": formattedText = "Not Operational"
        case "R": formattedText = "Redirected"
        case "U": formattedText = "Unknown"
        case "C": formattedText = "Cancelled"
        DispatchQueue.main.async {
            let alert = UIAlertController(title: NSLocalizedString("Flight has been Cancelled!", comment: ""), message: NSLocalizedString("Contact your airline to get replacement flight number.", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion: nil)
            }
        default:
            print("Error formatting flight status")
        }
        return formattedText
    }
    
    
    

}

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
