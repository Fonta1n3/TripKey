//
//  FlightTableNewViewController.swift
//  TripKey
//
//  Created by Peter on 12/11/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import Parse

class FlightTableNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {
    
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    @IBOutlet var actionLabel: UILabel!
    @IBOutlet var callLabel: UILabel!
    let gradientLayer = CAGradientLayer()
    @IBOutlet weak var flightTable: UITableView!
    var flightArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flightTable.alpha = 0
        tabBarController!.delegate = self
        flightTable.delegate = self
        flightTable.dataSource = self
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    override func viewDidDisappear(_ animated: Bool) {
        flightTable.alpha = 0
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        flightArray = getFlightArray()
        flightTable.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.flightTable.alpha = 1
        }
        
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
        //cell.countdownView.isHidden = true
        
        cell.tapShareAction = {
            
            (cell) in self.shareFlight(indexPath: (tableView.indexPath(for: cell)!.row))
            
        }
        
        let flight = FlightStruct(dictionary: self.flightArray[indexPath.row])
        let publishedDeparture = flight.publishedDeparture
        let publishedDepartureNumber = formatDateTimetoWhole(dateTime: publishedDeparture)
        let publishedArrival = flight.publishedArrival
        let publishedArrivalNumber = formatDateTimetoWhole(dateTime: publishedArrival)
        let departureDate = flight.departureDate
        let departureDateNumber = formatDateTimetoWhole(dateTime: departureDate)
        let arrivalDate = flight.arrivalDate
        let arrivalDateNumber = formatDateTimetoWhole(dateTime: arrivalDate)
        let departureOffset = flight.departureUtcOffset
        let arrivalOffset = flight.arrivalUtcOffset
        let flightStatus = flight.flightStatus
        let flightEquipment = flight.airplaneType
        let primaryCarrier = flight.primaryCarrier
        let flightNumber = flight.flightNumber
        let depCity = flight.departureCity
        let depAirport = flight.departureAirport
        let arrCity = flight.arrivalCity
        let arrAirport = flight.arrivalAirportCode
        let depTerminal = flight.departureTerminal
        let depGate = flight.departureGate
        let arrTerminal = flight.arrivalTerminal
        let arrGate = flight.arrivalGate
        let baggage = flight.baggageClaim
        
        let flightDuration = getFlightDuration(departureDate: departureDate,
                                               arrivalDate: arrivalDate,
                                               departureOffset: departureOffset,
                                               arrivalOffset: arrivalOffset)
        
        let departureTimeDifference = getTimeDifference(publishedTime: publishedDeparture,
                                                        actualTime: departureDate)
        
        let arrivalTimeDifference = getTimeDifference(publishedTime: publishedArrival,
                                                      actualTime: arrivalDate)
            
        cell.status.text = NSLocalizedString(flightStatus, comment: "")
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
                
            var monthsLeft = Int()
            var daysLeft = Int()
            var hoursLeft = Int()
            var minutesLeft = Int()
            var secondsLeft = Int()
            
            let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                (_) in
                
                DispatchQueue.main.async {
                    
                    if flightStatus != "Departed" {
                        
                        cell.countDownLabel.text = NSLocalizedString("till departure", comment: "")
                        monthsLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).months
                        daysLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).days
                        hoursLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).hours
                        minutesLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).minutes
                        secondsLeft = countDown(departureDate: departureDate, departureUtcOffset: departureOffset).seconds
                        
                    } else if flightStatus == "Departed" {
                        
                        cell.countDownLabel.text = NSLocalizedString("till arrival", comment: "")
                        monthsLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).months
                        daysLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).days
                        hoursLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).hours
                        minutesLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).minutes
                        secondsLeft = countDown(departureDate: arrivalDate, departureUtcOffset: arrivalOffset).seconds
                    }
                    
                    cell.months.text = "\(monthsLeft)"
                    cell.days.text = "\(daysLeft)"
                    cell.hours.text = "\(hoursLeft)"
                    cell.mins.text = "\(minutesLeft)"
                    cell.secs.text = "\(secondsLeft)"
                    
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
                print("arrivalDateUtc = \(arrivalDateUtc)")
                let timeTillLanding = self.secondsTillLanding(arrivalDateUTC: arrivalDateUtc)
                print("timeTillLanding = \(timeTillLanding)")
                
                let departuerDateUtc = getUtcTime(time: departureDate, utcOffset: departureOffset)
                print("departuerDateUtc = \(departuerDateUtc)")
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
        print("setcountdown = \(type) \(date) \(offset) \(indexPath)")
        
        let cell = flightTable.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath) as! TableViewCell
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
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
                
                DispatchQueue.main.async {
                    cell.months.text = "\(monthsLeft)"
                    cell.days.text = "\(daysLeft)"
                    cell.hours.text = "\(hoursLeft)"
                    cell.mins.text = "\(minutesLeft)"
                    cell.secs.text = "\(secondsLeft)"
                }
                
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
    
    
    func shareFlight(indexPath: Int) {
        
        let followedUsers = getFollowedUsers()
        let flight = FlightStruct(dictionary: self.flightArray[indexPath])
        let departureCity = flight.departureCity
        let arrivalCity = flight.arrivalCity
        let departureDate = convertDateTime(date: flight.departureDate)
        let flightNumber = flight.flightNumber
        let airlineCode = flight.airlineCode
        
        let alert = UIAlertController(title: NSLocalizedString("Share Flight \(flightNumber) from \(departureCity) to \(arrivalCity), departing on \(departureDate) with:", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for user in followedUsers {
            
            alert.addAction(UIAlertAction(title: "\(String(describing: user["username"]!))", style: .default, handler: { (action) in
                
                let sharedFlight = PFObject(className: "SharedFlight")
                sharedFlight["shareToUsername"] = user["userid"]!
                sharedFlight["shareFromUsername"] = PFUser.current()?.username
                sharedFlight["departureDate"] = departureDate
                sharedFlight["airlineCode"] = airlineCode
                sharedFlight["flightNumber"] = flightNumber
                sharedFlight["flightDictionary"] = self.flightArray[indexPath]
                
                sharedFlight.saveInBackground(block: { (success, error) in
                    
                    if error != nil {
                        
                        let alert = UIAlertController(title: NSLocalizedString("Could not share flight", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "\(NSLocalizedString("Flight shared to", comment: "")) \(String(describing: user["username"]!))", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        
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
    
    func secondsTillLanding(arrivalDateUTC: String) -> Int {
        
        let currentTime = Date()
        print("currentTime = \(currentTime)")
        
        //get current utc time
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        //let date1 = dateFormatter.date(from: currentDateUtc)
        let date2 = dateFormatter.date(from: arrivalDateUTC)
        
        let interval = currentDateUtc.timeIntervalSince(date2!)
        
        let secondsTillLanding = abs(Int(interval))
        
        
        return secondsTillLanding
        
    }
    
    func secondsSinceTakeOff(departureDateUTC: String) -> Int {
        
        let currentTime = Date()
        print("currentTime = \(currentTime)")
        
        //get current utc time
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        //let date1 = dateFormatter.date(from: currentDateUtc)
        let date2 = dateFormatter.date(from: departureDateUTC)
        
        let interval = currentDateUtc.timeIntervalSince(date2!)
        
        let secondsSinceTakeoff = abs(Int(interval))
        
        return secondsSinceTakeoff
        
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

extension FlightTableNewViewController  {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}
