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

public func saveFollowedUserToCoreData(viewController: UIViewController, username: String, userId: String) -> Bool {
    print("saveUserToCoreData")
    
    var appDelegate = AppDelegate()
    var success = Bool()
    
    let keys = ["username", "userid"]
    let values = [username, userId]
    
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
    var userAlreadySaved = false
    
    do {
        
        let results = try context.fetch(fetchRequest) as [NSManagedObject]
        
        if results.count > 0 {
            print("results exist")
            
            for data in results {
                
                for _ in keys {
                    
                    if values[1] == data.value(forKey: "userid") as? String {
                        
                        //already following
                        userAlreadySaved = true
                        displayAlert(viewController: viewController, title: "Error", message: "You are already following \(username)")
                        
                    } else {
                        
                        //user not saved yet
                    }
                }
                
            }
            
            if !userAlreadySaved {
                
                let entity = NSEntityDescription.entity(forEntityName: "FollowedUsers", in: context)
                let user = NSManagedObject(entity: entity!, insertInto: context)
                
                for (index, key) in keys.enumerated() {
                    
                    user.setValue(values[index], forKey: key)
                    
                    do {
                        
                        try context.save()
                        success = true
                        print("saved user \(values[index])")
                        
                    } catch {
                        
                        print("Failed saving user \(values[index])")
                        success = false
                        
                    }
                }
                
            }
            
        } else {
            
            print("no results so create one")
            
            let entity = NSEntityDescription.entity(forEntityName: "FollowedUsers", in: context)
            let user = NSManagedObject(entity: entity!, insertInto: context)
            
            for (index, key) in keys.enumerated() {
                
                user.setValue(values[index], forKey: key)
                
                do {
                    
                    try context.save()
                    success = true
                    print("saved user \(values[index])")
                    
                } catch {
                    
                    print("Failed saving user \(values[index])")
                    success = false
                    
                }
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

public func getFollowedUsers() -> [[String:String]] {
    
    print("getFollowedUsers")
    
    var followedUsers = [[String:String]]()
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return followedUsers
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FollowedUsers")
    fetchRequest.returnsObjectsAsFaults = false
    fetchRequest.resultType = .dictionaryResultType
    
    
    do {
        
        if let results = try context.fetch(fetchRequest) as? [[String:String]] {
            
            if results.count > 0 {
                
                for user in results {
                    
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
        
    var appDelegate = AppDelegate()
        
        DispatchQueue.main.async {
            
            if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
                
                appDelegate = appDelegateCheck
                
            }
            
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
                
                flightArray = flightArray.sorted{ ($0["publishedDepartureUtc"] as! String) < ($1["publishedDepartureUtc"] as! String) }
                
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
    default:
        print("Error formatting flight status")
    }
    return formattedText
}

public func updateUserNameInCoreData(viewController: UIViewController, username: String, userId: String) -> Bool {
    print("updateUserNameInCoreData")
    
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
            
            for data in results {
                
                if userId == data.value(forKey: "userid") as? String {
                    
                    //overwrite username
                    data.setValue(username, forKey: "username")
                    
                    do {
                        
                        try context.save()
                        print("updated \(username) succesfully")
                        
                    } catch {
                        
                        print("error editing")
                        
                    }
                    
                } else {
                    
                    
                }
                
            }
            
        } else {
            
            print("no results")
            
        }
            
        
    } catch {
        
        print("Failed")
        
    }
    
    return success
}


