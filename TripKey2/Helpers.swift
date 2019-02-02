//
//  Helpers.swift
//  
//
//  Created by Peter on 30/01/19.
//

import Foundation
import UIKit
import SystemConfiguration


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

public func countDown(departureDate: String, departureUtcOffset: String) -> (months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
    
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

public func formatDateTimetoWhole(dateTime: String) -> String {
    
    let dateTimeAsNumberStep1 = dateTime.replacingOccurrences(of: "-", with: "")
    let dateTimeAsNumberStep2 = dateTimeAsNumberStep1.replacingOccurrences(of: "T", with: "")
    let dateTimeAsNumberStep3 = dateTimeAsNumberStep2.replacingOccurrences(of: ":", with: "")
    let dateTimeWhole = dateTimeAsNumberStep3.replacingOccurrences(of: ".", with: "")
    return dateTimeWhole
}

public func getUtcTime(time: String, utcOffset: String) -> (String) {
    print("func getUtcTime")
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

public func getFlightDuration(departureDate: String, arrivalDate: String, departureOffset: String, arrivalOffset: String) -> (String) {
    
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

public func didFlightAlreadyTakeoff (departureDate: String, utcOffset: String) -> (Bool) {
    
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
