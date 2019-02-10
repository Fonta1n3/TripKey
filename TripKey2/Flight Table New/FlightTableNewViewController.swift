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
    var flightArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flightTable.delegate = self
        flightTable.dataSource = self
        addBackButton()
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
        cell.flightDuration.text = flightDuration
            
        if self.flightArray.count <= 3 {
                
            if flightStatus != "Departed" {
                    
                DispatchQueue.main.async {
                    self.setCountDown(type: "departure", date: departureDate, offset: departureOffset, indexPath: indexPath)
                }
                
            } else if flightStatus == "Departed" {
                
                DispatchQueue.main.async {
                    self.setCountDown(type: "arrival", date: arrivalDate, offset: arrivalOffset, indexPath: indexPath)
                }
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
                
                let arrivalDateUtc = getUtcTime(time: arrivalDate, utcOffset: arrivalOffset)
                let timeTillLanding = self.secondsTillLanding(arrivalDateUTC: arrivalDateUtc)
                print("timeTillLanding = \(timeTillLanding)")
                
                let departuerDateUtc = getUtcTime(time: departureDate, utcOffset: departureOffset)
                let timeSinceTakeOff = self.secondsSinceTakeOff(departureDateUTC: departuerDateUtc)
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
        
        //parseLeg2Only(viewController: self, dictionary: flightArray[indexPath.row], index: indexPath.row)
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
    
    func secondsTillLanding(arrivalDateUTC: String) -> Int {
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let dateToCheck = dateTimeFormatter.date(from: arrivalDateUTC)! as NSDate
        let secondsFromNow = dateToCheck.timeIntervalSinceNow
        return Int(abs(secondsFromNow))
        
    }
    
    func secondsSinceTakeOff(departureDateUTC: String) -> Int {
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
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
    
    
    func parseLeg2Only(dictionary: [String:Any], index: Int) {
        
        print("parseLeg2Only")
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let departureDateTime = dictionary["publishedDepartureUtc"] as! String
        
        if isDepartureDate72HoursAwayOrLess(date: departureDateTime) == true {
            
            var url:URL!
            let id = dictionary["identifier"] as! String
            let arrivalDateURL = dictionary["urlArrivalDate"] as! String
            let arrivalAirport = dictionary["arrivalAirportCode"] as! String
            let airlineCodeURL = (dictionary["airlineCode"] as! String)
            let flightNumberURL = (dictionary["flightNumber"] as! String).replacingOccurrences(of: airlineCodeURL, with: "")
            
            url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + airlineCodeURL + "/" + flightNumberURL + "/arr/" + arrivalDateURL + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87&utc=false&airport=" + arrivalAirport + "&extendedOptions=useinlinedreferences")
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        print(error as Any)
                        DispatchQueue.main.async {
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonFlightStatusData = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                //check status
                                if let flightStatusesArray = jsonFlightStatusData["flightStatuses"] as? NSArray {
                                    
                                    if flightStatusesArray.count == 0 {
                                        DispatchQueue.main.async {
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        }
                                        
                                    } else if flightStatusesArray.count > 0 {
                                        
                                        let flightStatusUnformatted = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["status"] as! String
                                        let flightStatusFormatted = self.formatFlightStatus(flightStatusUnformatted: flightStatusUnformatted)
                                        updateFlight(viewController: self, id: id, newValue: flightStatusFormatted, keyToEdit: "flightStatus")
                                        
                                        //unambiguos data
                                        var irregularOperationsMessage1 = ""
                                        var irregularOperationsMessage2 = ""
                                        var irregularOperationsType1 = ""
                                        var irregularOperationsType2 = ""
                                        var confirmedIncidentMessage = ""
                                        var replacementFlightId:Double! = 0
                                        var flightId = String()
                                        
                                        if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: baggageCheck, keyToEdit: "baggageClaim")
                                        }
                                        
                                        if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: primaryCarrierCheck, keyToEdit: "primaryCarrier")
                                        }
                                        
                                        if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: formatFlightEquipment(flightEquipment: scheduledFlightEquipment), keyToEdit: "flightEquipment")
                                        }
                                        
                                        if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: formatFlightEquipment(flightEquipment: actualFlightEquipment), keyToEdit: "flightEquipment")
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
                                                    flightId = String(replacementFlightId)
                                                }
                                                
                                            } else if irregularOperations.count == 1 {
                                                
                                                if let irregularOperationsMessage1Check = (irregularOperations[0] as? NSDictionary)?["message"] as? String {
                                                    irregularOperationsMessage1 = irregularOperationsMessage1Check
                                                }
                                                irregularOperationsType1 = ((irregularOperations[0] as? NSDictionary)?["type"] as? String)!
                                            }
                                        }
                                        
                                        if let confirmedIncidentMessageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["confirmedIncident"] as? NSDictionary)?["message"] as? String {
                                            
                                            confirmedIncidentMessage = confirmedIncidentMessageCheck
                                            displayAlert(viewController: self, title: "Incident Alert!", message: confirmedIncidentMessage)
                                        }
                                        
                                        if let flightDurationScheduledCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightDurations"] as? NSDictionary)?["scheduledBlockMinutes"] as? Int {
                                            
                                            updateFlight(viewController: self, id: id, newValue: String(flightDurationScheduledCheck), keyToEdit: "flightDuration")
                                        }
                                        
                                        //departure data
                                        if let departureTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureTerminal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: departureTerminalCheck, keyToEdit: "departureTerminal")
                                            
                                        } else {
                                            
                                            updateFlight(viewController: self, id: id, newValue: "-", keyToEdit: "departureTerminal")
                                        }
                                        
                                        if let departureGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureGate"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: departureGateCheck, keyToEdit: "departureGate")
                                            
                                        } else {
                                            
                                            updateFlight(viewController: self, id: id, newValue: "-", keyToEdit: "departureGate")
                                        }
                                        
                                        //departure timings
                                        
                                        
                                        if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: scheduledRunwayDepartureCheck, keyToEdit: "departureTime")
                                        }
                                        
                                        if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: estimatedRunwayDepartureCheck, keyToEdit: "departureTime")
                                        }
                                        
                                        if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: actualRunwayDepartureCheck, keyToEdit: "departureTime")
                                        }
                                        
                                        if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: scheduledGateDepartureCheck, keyToEdit: "departureTime")
                                            
                                        }
                                        
                                        if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: estimatedGateDepartureCheck, keyToEdit: "departureTime")
                                        }
                                        
                                        if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: actualGateDepartureCheck, keyToEdit: "departureTime")
                                            
                                        }
                                        
                                        //diverted airport data
                                        var divertedAirportArrivalCode = ""
                                        var divertedAirportArrivalLongitudeDouble = Double()
                                        var divertedAirportArrivalLatitudeDouble = Double()
                                        var divertedAirportArrivalCity = ""
                                        var divertedAirportArrivalUtcOffsetHours = Double()
                                        
                                        if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                            
                                            divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String
                                            updateFlight(viewController: self, id: id, newValue: divertedAirportArrivalCode, keyToEdit: "departureAirport")
                                            
                                            divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double
                                            updateFlight(viewController: self, id: id, newValue: divertedAirportArrivalLongitudeDouble, keyToEdit: "arrivalLon")
                                            
                                            divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double
                                            updateFlight(viewController: self, id: id, newValue: divertedAirportArrivalLatitudeDouble, keyToEdit: "arrivalLat")
                                            
                                            divertedAirportArrivalCity = divertedAirportCheck["city"] as! String
                                            updateFlight(viewController: self, id: id, newValue: divertedAirportArrivalCity, keyToEdit: "arrivalCity")
                                            
                                            divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double
                                            updateFlight(viewController: self, id: id, newValue: divertedAirportArrivalUtcOffsetHours, keyToEdit: "arrivalUtcOffset")
                                            
                                        }
                                        
                                        if let arrivalGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalGate"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: arrivalGateCheck, keyToEdit: "arrivalGate")
                                            
                                        } else {
                                            
                                            updateFlight(viewController: self, id: id, newValue: "-", keyToEdit: "arrivalGate")
                                            
                                        }
                                        
                                        if let arrivalTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalTerminal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: arrivalTerminalCheck, keyToEdit: "arrivalTerminal")
                                            
                                        } else {
                                            
                                            updateFlight(viewController: self, id: id, newValue: "-", keyToEdit: "arrivalTerminal")
                                        }
                                        
                                        //arrival timings
                                        if let scheduledRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: scheduledRunwayArrivalCheck, keyToEdit: "arrivalDate")
                                            
                                        }
                                        
                                        if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: estimatedRunwayArrivalCheck, keyToEdit: "arrivalDate")
                                            
                                        }
                                        
                                        if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: actualRunwayArrivalCheck, keyToEdit: "arrivalDate")
                                            
                                        }
                                        
                                        if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: scheduledGateArrivalCheck, keyToEdit: "arrivalDate")
                                            
                                        }
                                        
                                        if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: estimatedGateArrivalCheck, keyToEdit: "arrivalDate")
                                        }
                                        
                                        if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            updateFlight(viewController: self, id: id, newValue: actualGateArrivalCheck, keyToEdit: "arrivalDate")
                                            
                                        }
                                        
                                        DispatchQueue.main.async {
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            DispatchQueue.main.async {
                                                
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                                if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && flightId != "" {
                                                    
                                                    let alert = UIAlertController(title: "\(String(describing: confirmedIncidentMessage))", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n" + NSLocalizedString("Would you like to add the replacement flight automatically?", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                        
                                                        //self.parseFlightID(dictionary: self.flightArray[index], index: index)
                                                        
                                                    }))
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" {
                                                    
                                                    
                                                    let alert = UIAlertController(title: "\(String(describing: confirmedIncidentMessage))", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)" , preferredStyle: UIAlertControllerStyle.alert)
                                                    
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
                                                    
                                                    let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: NSLocalizedString("This flight has an irregular operation of type:", comment: "") +  " \(irregularOperationsType1)", preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                }
                                                
                                                //set notifications
                                                let delegate = UIApplication.shared.delegate as? AppDelegate
                                                
                                                let departureDate = dictionary["departureTime"] as! String
                                                let utcOffset = dictionary["departureUtcOffset"] as! Double
                                                let departureCity = dictionary["departureCity"] as! String
                                                let arrivalCity = dictionary["arrivalCity"] as! String
                                                let arrivalDate = dictionary["arrivalDate"] as! String
                                                let arrivalOffset = dictionary["arrivalUtcOffset"] as! Double
                                                
                                                let departingTerminal = dictionary["departureTerminal"] as! String
                                                let departingGate = dictionary["departureGate"] as! String
                                                let departingAirport = dictionary["departureAirport"] as! String
                                                let arrivalAirport = dictionary["arrivalAirportCode"] as! String
                                                
                                                let flightNumber = dictionary["flightNumber"] as! String
                                                
                                                delegate?.schedule48HrNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.schedule4HrNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.schedule2HrNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.schedule1HourNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.scheduleTakeOffNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.scheduleLandingNotification(arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                print("scheduled notifications")
                                                
                                            }
                                        }
                                        
                                        if let flightIdCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightId"] as? Double {
                                            
                                            flightId = String(flightIdCheck).replacingOccurrences(of: ".0", with: "")
                                            updateFlight(viewController: self, id: id, newValue: flightId, keyToEdit: "flightId")
                                        }
                                        
                                        self.flightArray = getFlightArray()
                                        
                                    } else {
                                        
                                        if (((jsonFlightStatusData)["error"] as? NSDictionary)?["errorMessage"] as? String) != nil {
                                            
                                            DispatchQueue.main.async {
                                                
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("It looks like the flight number was changed by the airline, please check with your airline to ensure you have the updated flight number.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    }
                                }
                            }
                        }
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    print("Error parsing")
                    
                }
                
            }
            
            task.resume()
            
            
        } else {
            
            print("more then 3 days")
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
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
