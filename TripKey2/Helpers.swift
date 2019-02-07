//
//  Helpers.swift
//  
//
//  Created by Peter on 30/01/19.
//

import Foundation
import UIKit
import SystemConfiguration
import CoreData

public func displayAlert(viewController: UIViewController, title: String, message: String) {
    
    let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
    viewController.present(alertcontroller, animated: true, completion: nil)
    
}

public func isInternetAvailable() -> Bool {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
    
}

public func countDown(departureDate: String, departureUtcOffset: Double) -> (months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
    
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
    var utcDepartureInterval = (departureUtcOffset * 60 * 60)
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

public func formatDateTimetoWhole(dateTime: String) -> Double {
    
    let dateTimeAsNumberStep1 = dateTime.replacingOccurrences(of: "-", with: "")
    let dateTimeAsNumberStep2 = dateTimeAsNumberStep1.replacingOccurrences(of: "T", with: "")
    let dateTimeAsNumberStep3 = dateTimeAsNumberStep2.replacingOccurrences(of: ":", with: "")
    let dateTimeWhole = dateTimeAsNumberStep3.replacingOccurrences(of: ".", with: "")
    return Double(dateTimeWhole)!
}

public func getUtcTime(time: String, utcOffset: Double) -> (String) {
    print("func getUtcTime")
    //here we change departure date to UTC time
    let departureDateFormatter = DateFormatter()
    departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    let departureDateTime = departureDateFormatter.date(from: time)
    var utcInterval = utcOffset * 60 * 60
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

public func convertDuration(flightDurationScheduled: String) -> (String) {
    
    let flightDurationScheduledInt = (Int(flightDurationScheduled)! * 60)
    let hours1 = (Int(flightDurationScheduledInt) / 3600)
    let minutes1 = (Int(flightDurationScheduledInt) % 3600) / 60
    if hours1 > 0 {
        return("\(hours1)hr \(minutes1)min")
    } else {
        return("\(minutes1)min")
    }
}

public func getUtcTimes(publishedDeparture: String, publishedArrival: String, departureOffset: String, arrivalOffset: String) -> (departureDateUtc: String, arrivalDateUtc: String) {
    
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

public func getFlightDuration(departureDate: String, arrivalDate: String, departureOffset: Double, arrivalOffset: Double) -> (String) {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    let departureDateTime = dateFormatter.date(from: departureDate)
    let arrivalDateTime = dateFormatter.date(from: arrivalDate)
    var utcDepartureInterval = (departureOffset * 60 * 60)
    var utcArrivalInterval = (arrivalOffset * 60 * 60)
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
        return("\(hours)\(NSLocalizedString("hr", comment: "")) \(minutes)\(NSLocalizedString("min", comment: ""))")
    } else {
        return("\(minutes)\(NSLocalizedString("min", comment: ""))")
    }
}

public func getTimeDifference(publishedTime: String, actualTime: String) -> (String) {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    let date1 = dateFormatter.date(from: publishedTime)
    let date2 = dateFormatter.date(from: actualTime)
    let interval = date1?.timeIntervalSince(date2!)
    let hours = abs((Int(interval!) % 86400) / 3600)
    let minutes = abs((Int(interval!) % 3600) / 60)
    if hours > 0 {
        return("\(hours)\(NSLocalizedString("hr", comment: "")) \(minutes)\(NSLocalizedString("min", comment: ""))")
    } else {
        return("\(minutes)\(NSLocalizedString("min", comment: ""))")
    }
}

public func convertCurrentDateToWhole (date: NSDate) -> (String) {
    
    let currentDate = NSDate()
    let dateString = String(describing: currentDate)
    let date1 = dateString.replacingOccurrences(of: "-", with: "")
    let date2 = date1.replacingOccurrences(of: ":", with: "")
    let date3 = date2.replacingOccurrences(of: "+", with: "")
    let date4 = date3.replacingOccurrences(of: "-", with: "")
    let date5 = date4.replacingOccurrences(of: " ", with: "")
    return date5
    
}

public func convertDateTime (date: String) -> (String) {
    
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

public func didFlightAlreadyTakeoff (departureDate: String, utcOffset: Double) -> (Bool) {
    
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
    let departureDateUtc = getUtcTime(time: departureDate, utcOffset: utcOffset)
    let departureDateUtcDate = dateFormatter.date(from: departureDateUtc)
    if departureDateUtcDate! < currentDateUtc as Date {
        return true
    } else {
        return false
    }
}

public func convertToURLDate(date: String) -> (String) {
    
    var dateArray = date.components(separatedBy: "T")
    let dateSegment = dateArray[0]
    var dateSplitArray = dateSegment.components(separatedBy: "-")
    let year = dateSplitArray[0]
    let month = dateSplitArray[1]
    let day = dateSplitArray[2]
    let urlDepartureDate = "\(year)/" + "\(month)/" + "\(day)"
    return urlDepartureDate
    
}

public func isDepartureDate72HoursAwayOrLess (date: String) -> (Bool) {
    
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

public func formatFlightEquipment(flightEquipment: String) -> String {
    
    var seperatedArray = flightEquipment.components(separatedBy: " (sharklets)")
    let aircraftString = seperatedArray[0]
    return aircraftString
}

public func saveFollowedUserToCoreData(viewController: UIViewController, username: String) -> Bool {
    print("saveUserToCoreData")
    
    var appDelegate = AppDelegate()
    var success = Bool()
    
    if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
        print("appDelegateCheck")
        
        appDelegate = appDelegateCheck
        
    } else {
        
        displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
        success = false
        
    }
    
    let context = appDelegate.persistentContainer.viewContext
    print("context")
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FollowedUsers")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
        
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
        
        if results.count > 0 {
            print("results exist")
            
            print("results = \(results)")
            
            var userAlreadySaved = false
            
            for data in results {
                
                if data.value(forKey: "username") as! String == username {
                    
                    userAlreadySaved = true
            
                }
            }
            
            if !userAlreadySaved {
                
                let entity = NSEntityDescription.entity(forEntityName: "FollowedUsers", in: context)
                let followedUser = NSManagedObject(entity: entity!, insertInto: context)
                followedUser.setValue(username, forKey: "username")
                
                do {
                    
                    try context.save()
                    success = true
                    print("success saving \(username) to coredata")
                    
                } catch {
                    
                    print("Failed saving")
                    success = false
                    
                }
            }
            
        } else {
            
            print("no results so create one")
            
            let entity = NSEntityDescription.entity(forEntityName: "FollowedUsers", in: context)
            let followedUser = NSManagedObject(entity: entity!, insertInto: context)
            followedUser.setValue(username, forKey: "username")
            
            do {
                
                try context.save()
                success = true
                print("success saving to coredata")
                
            } catch {
                
                print("Failed saving")
                success = false
                
            }
            
        }
        
    } catch {
        
        print("Failed")
        
    }
    
    return success
}

public func deleteUserFromCoreData(viewController: UIViewController, username: String) {
    
    var appDelegate = AppDelegate()
    
    if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
        
        appDelegate = appDelegateCheck
        
    } else {
        
        displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
        
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FollowedUsers")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
        
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
        
        if results.count > 0 {
            
            for (index, data) in results.enumerated() {
                
                if username == data.value(forKey: "username") as? String {
                    
                    context.delete(results[index] as NSManagedObject)
                    print("deleted \(username) succesfully")
                    
                    do {
                        
                        try context.save()
                        
                    } catch {
                        
                        print("error deleting")
                    }
                    
                }
                
            }
            
        } else {
            
            print("no results")
            
        }
        
    } catch {
        
        print("Failed")
        
    }
}

public func getFollowedUsers() -> [String] {
    
    print("getFollowedUsers")
    
    var followedUsers = [String]()
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return followedUsers
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FollowedUsers")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
        
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
        
        if results.count > 0 {
            
            print("get followed users results = \(results) ")
            
            for data in results {
                
                if let user = data.value(forKey: "username") as? String {
                    
                    followedUsers.append(user)
                }
                
            }
            
        }
        
        
        
    } catch {
        
        print("Failed")
        
    }
    
    return followedUsers
    
}

public func saveFlight(viewController: UIViewController, departureAirport: String, departureLat: Double, departureLon: Double, arrivalLat: Double, arrivalLon: Double, airlineCode: String, arrivalAirportCode: String, arrivalCity: String, arrivalDate: String, arrivalGate: String, arrivalTerminal: String, arrivalUtcOffset: Double, baggageClaim: String, departureCity: String, departureGate: String, departureTerminal: String, departureTime: String, departureUtcOffset: Double, flightDuration: String, flightNumber: String, flightStatus: String, primaryCarrier: String, flightEquipment: String, identifier: String, phoneNumber: String, publishedDepartureUtc: String, urlArrivalDate: String, publishedDeparture: String, publishedArrival: String) -> Bool {
    
    print("saveFlight")
    
    var success = Bool()
    var alreadySaved = false
 
    let keys = ["departureAirport", "departureLat", "departureLon", "arrivalLat", "arrivalLon", "airlineCode", "arrivalAirportCode", "arrivalCity", "arrivalDate", "arrivalGate", "arrivalTerminal", "arrivalUtcOffset", "baggageClaim", "departureCity", "departureGate", "departureTerminal", "departureTime", "departureUtcOffset", "flightDuration", "flightNumber", "flightStatus", "primaryCarrier", "flightEquipment", "identifier", "phoneNumber", "publishedDepartureUtc", "urlArrivalDate", "publishedDeparture", "publishedArrival"]
 
    let values = [departureAirport, departureLat, departureLon, arrivalLat, arrivalLon, airlineCode, arrivalAirportCode, arrivalCity, arrivalDate, arrivalGate, arrivalTerminal, arrivalUtcOffset, baggageClaim, departureCity, departureGate, departureTerminal, departureTime, departureUtcOffset, flightDuration, flightNumber, flightStatus, primaryCarrier, flightEquipment, identifier, phoneNumber, publishedDepartureUtc, urlArrivalDate, publishedDeparture, publishedArrival] as [Any]
    
    var appDelegate = AppDelegate()
    
    if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
        
        appDelegate = appDelegateCheck
        
    } else {
        
        displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
        success = false
        
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
        
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
        
        if results.count > 0 {
            
            for data in results {
                
                for _ in keys {
                    
                    if (values[22] as! String) == data.value(forKey: "identifier") as? String {
                        
                        alreadySaved = true
                        
                        for (index, key) in keys.enumerated() {
                            
                            data.setValue(values[index], forKey: key)
                            
                            do {
                                
                                try context.save()
                                success = true
                                print("updated flight data")
                                
                            } catch {
                                
                                print("Failed updating flight data")
                                success = false
                                
                            }
                        }
                    }
                }
            }
            
            if alreadySaved != true {
                
                let entity = NSEntityDescription.entity(forEntityName: "Flight", in: context)
                let flight = NSManagedObject(entity: entity!, insertInto: context)
                
                for (index, key) in keys.enumerated() {
                    
                    flight.setValue(values[index], forKey: key)
                    
                    do {
                        
                        try context.save()
                        success = true
                        print("Flight saved for first time")
                        
                    } catch {
                        
                        print("Failed saving flight")
                        success = false
                    }
                }
            }
            
        } else {
            
            print("no results so create one")
            
            let entity = NSEntityDescription.entity(forEntityName: "Flight", in: context)
            let flight = NSManagedObject(entity: entity!, insertInto: context)
            
            
            for (index, key) in keys.enumerated() {
                
                flight.setValue(values[index], forKey: key)
                
                do {
                    
                    try context.save()
                    success = true
                    print("saved flight for first time")
                    
                } catch {
                    
                    print("Failed saving")
                    success = false
                    
                }
            }
            
        }
        
    } catch {
        
        print("Failed to save")
        
    }
    
    return success
    
}

public func checkCoreDataFlights(viewController: UIViewController) -> Bool {
    print("saveUserToCoreData")
    
    var appDelegate = AppDelegate()
    var success = Bool()
    
    DispatchQueue.main.async {
        if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            print("appDelegateCheck")
            
            appDelegate = appDelegateCheck
            
        } else {
            
            displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
            success = false
            
        }
    }
    
    let context = appDelegate.persistentContainer.viewContext
    print("context")
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
        
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
        
        if results.count > 0 {
            print("results exist")
            
            print("results = \(results)")
            
            
        } else {
            
            print("no flights")
            
            
        }
        
    } catch {
        
        print("Failed")
        
    }
    
    return success
}

public func getFlightArray() -> [[String:Any]] {
    
    print("getFlightArray")
    
    var flightArray = [[String:Any]]()
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return flightArray
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Flight")
    request.returnsObjectsAsFaults = false
    request.resultType = .dictionaryResultType
    
    do {
        
        if let results = try context.fetch(request) as? [[String:Any]] {
            
            for data in results {
                
                flightArray.append(data)
                
            }
            
        }
        
        
        
    } catch {
        
        print("Failed")
        
    }
    
    return flightArray
    
}

public func deleteFlight(viewController: UIViewController, flightIdentifier: String) {
    
    var appDelegate = AppDelegate()
    
    DispatchQueue.main.async {
        
        if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate = appDelegateCheck
            
        } else {
            
            displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
            
        }
        
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
        
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
        
        if results.count > 0 {
            
            for (index, data) in results.enumerated() {
                
                if flightIdentifier == data.value(forKey: "identifier") as? String {
                    
                    context.delete(results[index] as NSManagedObject)
                    print("deleted succesfully")
                    
                    do {
                        
                        try context.save()
                        
                    } catch {
                        
                        print("error deleting")
                    }
                    
                }
                
            }
            
        } else {
            
            print("no results")
            
        }
        
    } catch {
        
        print("Failed")
        
    }
}

public func updateFlight(viewController: UIViewController, id: String, newValue: Any, keyToEdit: String) {
    
    
    
    DispatchQueue.main.async {
        
        var appDelegate = AppDelegate()
        
        if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate = appDelegateCheck
            
        } else {
            
            displayAlert(viewController: viewController, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
            
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
            if results.count > 0 {
                
                for data in results {
                    
                    if id == data.value(forKey: "identifier") as? String {
                        
                        data.setValue(newValue, forKey: keyToEdit)
                        
                        do {
                            
                            try context.save()
                            print("updated \(keyToEdit) succesfully")
                            
                        } catch {
                            
                            print("error editing")
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                print("no results")
                
            }
            
        } catch {
            
            print("Failed")
            
        }
    }
    
}

public func parseLeg2Only(viewController: UIViewController, dictionary: [String:Any], index: Int) {
    
    print("parseLeg2Only")
    
    DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    let nearMeVC = NearMeViewController()
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
                        viewController.present(alert, animated: true, completion: nil)
                        
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
                                    let flightStatusFormatted = formatFlightStatus(flightStatusUnformatted: flightStatusUnformatted)
                                    updateFlight(viewController: viewController, id: id, newValue: flightStatusFormatted, keyToEdit: "flightStatus")
                                    
                                    //unambiguos data
                                    var irregularOperationsMessage1 = ""
                                    var irregularOperationsMessage2 = ""
                                    var irregularOperationsType1 = ""
                                    var irregularOperationsType2 = ""
                                    var confirmedIncidentMessage = ""
                                    var replacementFlightId:Double! = 0
                                    var flightId = String()
                                    
                                    if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: baggageCheck, keyToEdit: "baggageClaim")
                                    }
                                    
                                    if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: primaryCarrierCheck, keyToEdit: "primaryCarrier")
                                    }
                                    
                                    if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: formatFlightEquipment(flightEquipment: scheduledFlightEquipment), keyToEdit: "flightEquipment")
                                    }
                                    
                                    if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: formatFlightEquipment(flightEquipment: actualFlightEquipment), keyToEdit: "flightEquipment")
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
                                        displayAlert(viewController: viewController, title: "Incident Alert!", message: confirmedIncidentMessage)
                                    }
                                    
                                    if let flightDurationScheduledCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightDurations"] as? NSDictionary)?["scheduledBlockMinutes"] as? Int {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: String(flightDurationScheduledCheck), keyToEdit: "flightDuration")
                                    }
                                    
                                    //departure data
                                    if let departureTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureTerminal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: departureTerminalCheck, keyToEdit: "departureTerminal")
                                        
                                    } else {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: "-", keyToEdit: "departureTerminal")
                                    }
                                    
                                    if let departureGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureGate"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: departureGateCheck, keyToEdit: "departureGate")
                                        
                                    } else {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: "-", keyToEdit: "departureGate")
                                    }
                                    
                                    //departure timings
                                    
                                    
                                    if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: scheduledRunwayDepartureCheck, keyToEdit: "departureTime")
                                    }
                                    
                                    if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: estimatedRunwayDepartureCheck, keyToEdit: "departureTime")
                                    }
                                    
                                    if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: actualRunwayDepartureCheck, keyToEdit: "departureTime")
                                    }
                                    
                                    if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: scheduledGateDepartureCheck, keyToEdit: "departureTime")
                                        
                                    }
                                    
                                    if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: estimatedGateDepartureCheck, keyToEdit: "departureTime")
                                    }
                                    
                                    if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: actualGateDepartureCheck, keyToEdit: "departureTime")
                                        
                                    }
                                    
                                    //diverted airport data
                                    var divertedAirportArrivalCode = ""
                                    var divertedAirportArrivalLongitudeDouble = Double()
                                    var divertedAirportArrivalLatitudeDouble = Double()
                                    var divertedAirportArrivalCity = ""
                                    var divertedAirportArrivalUtcOffsetHours = Double()
                                    
                                    if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                        
                                        divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String
                                        updateFlight(viewController: viewController, id: id, newValue: divertedAirportArrivalCode, keyToEdit: "departureAirport")
                                        
                                        divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double
                                        updateFlight(viewController: viewController, id: id, newValue: divertedAirportArrivalLongitudeDouble, keyToEdit: "arrivalLon")
                                        
                                        divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double
                                        updateFlight(viewController: viewController, id: id, newValue: divertedAirportArrivalLatitudeDouble, keyToEdit: "arrivalLat")
                                        
                                        divertedAirportArrivalCity = divertedAirportCheck["city"] as! String
                                        updateFlight(viewController: viewController, id: id, newValue: divertedAirportArrivalCity, keyToEdit: "arrivalCity")
                                        
                                        divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double
                                        updateFlight(viewController: viewController, id: id, newValue: divertedAirportArrivalUtcOffsetHours, keyToEdit: "arrivalUtcOffset")
                                        
                                    }
                                    
                                    if let arrivalGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalGate"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: arrivalGateCheck, keyToEdit: "arrivalGate")
                                        
                                    } else {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: "-", keyToEdit: "arrivalGate")
                                        
                                    }
                                    
                                    if let arrivalTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalTerminal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: arrivalTerminalCheck, keyToEdit: "arrivalTerminal")
                                        
                                    } else {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: "-", keyToEdit: "arrivalTerminal")
                                    }
                                    
                                    //arrival timings
                                    if let scheduledRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: scheduledRunwayArrivalCheck, keyToEdit: "arrivalDate")
                                        
                                    }
                                    
                                    if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: estimatedRunwayArrivalCheck, keyToEdit: "arrivalDate")
                                        
                                    }
                                    
                                    if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: actualRunwayArrivalCheck, keyToEdit: "arrivalDate")
                                        
                                    }
                                    
                                    if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: scheduledGateArrivalCheck, keyToEdit: "arrivalDate")
                                        
                                    }
                                    
                                    if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: estimatedGateArrivalCheck, keyToEdit: "arrivalDate")
                                    }
                                    
                                    if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        updateFlight(viewController: viewController, id: id, newValue: actualGateArrivalCheck, keyToEdit: "arrivalDate")
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        nearMeVC.flightArray = getFlightArray()
                                        
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        DispatchQueue.main.async {
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && flightId != "" {
                                                
                                                let alert = UIAlertController(title: "\(String(describing: confirmedIncidentMessage))", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n" + NSLocalizedString("Would you like to add the replacement flight automatically?", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    nearMeVC.parseFlightID(dictionary: nearMeVC.flightArray[index], index: index)
                                                    
                                                }))
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in }))
                                                
                                                viewController.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" {
                                                
                                                
                                                let alert = UIAlertController(title: "\(String(describing: confirmedIncidentMessage))", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)" , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                viewController.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                viewController.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" {
                                                
                                                let alert = UIAlertController(title: "\(irregularOperationsType1)", message: "\n\(irregularOperationsMessage1)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                viewController.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsType1 != "" {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: NSLocalizedString("This flight has an irregular operation of type:", comment: "") +  " \(irregularOperationsType1)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                viewController.present(alert, animated: true, completion: nil)
                                                
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
                                        
                                        flightId = String(flightIdCheck)
                                        
                                        if flightStatusFormatted == "Departed" {
                                            nearMeVC.updateFlightFirstTime = true
                                            nearMeVC.parseFlightIDForTracking(index: index)
                                        }
                                    }
                                    
                                    if nearMeVC.didTapMarker {
                                        nearMeVC.showFlightInfoWindows(flightIndex: nearMeVC.flightIndex)
                                    }
                                    
                                } else {
                                    
                                    if (((jsonFlightStatusData)["error"] as? NSDictionary)?["errorMessage"] as? String) != nil {
                                        
                                        DispatchQueue.main.async {
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("It looks like the flight number was changed by the airline, please check with your airline to ensure you have the updated flight number.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                
                                            }))
                                            
                                            viewController.present(alert, animated: true, completion: nil)
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

public func formatFlightStatus(flightStatusUnformatted: String) -> String {
    var formattedText = String()
    switch flightStatusUnformatted {
    case "S": formattedText = "Scheduled"
    case "A": formattedText = "Departed"
    case "D": formattedText = "Diverted"
    case "DN": formattedText = "Data Source Needed"
    case "L": formattedText = "Landed"
    case "NO": formattedText = "Not Operational"
    case "R": formattedText = "Redirected"
    case "U": formattedText = "Unknown"
    case "C": formattedText = "Cancelled"
    /*DispatchQueue.main.async {
        let alert = UIAlertController(title: NSLocalizedString("Flight has been Cancelled!", comment: ""), message: NSLocalizedString("Contact your airline to get replacement flight number.", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
        }*/
    default:
        print("Error formatting flight status")
    }
    return formattedText
}
