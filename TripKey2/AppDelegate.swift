//
//  AppDelegate.swift
//  TripKey2
//
//  Created by Peter on 8/21/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import UserNotifications
import Parse


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func switchControllers(viewControllerToBeDismissed:UIViewController,controllerToBePresented:UIViewController) {
        if (viewControllerToBeDismissed.isViewLoaded && (viewControllerToBeDismissed.view.window != nil)) {
            
            viewControllerToBeDismissed.dismiss(animated: false, completion: {
                self.window?.rootViewController?.present(controllerToBePresented, animated: true, completion: nil)
            })
        } else {
            
            print("else")
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        Parse.enableLocalDatastore()
        
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            
            ParseMutableClientConfiguration.applicationId = "da4b113f84f8d2467b2c237a63778aa49f29dcee"
            ParseMutableClientConfiguration.clientKey = "e1d6ba3797e8364252e3cfaa546520ae2c268ed0"
            ParseMutableClientConfiguration.server = "http://ec2-54-202-119-191.us-west-2.compute.amazonaws.com:80/parse"
            
        })
        
        Parse.initialize(with: parseConfiguration)
        GMSServices.provideAPIKey("AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw")
        
        let defaultACL = PFACL();
        defaultACL.hasPublicReadAccess = true
        defaultACL.hasPublicWriteAccess = true
        
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        self.saveContext()
        
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                
                print("Uh oh! We had an error: \(error)")
                
            } else {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                //fatalError("Unresolved error \(String(describing: error)), \(String(describing: error?._userInfo))")
                
            }
            
        })
        
        return container
        
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            
            do {
                
                try context.save()
                
            } catch {
                
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
        }
    }
    
    
    
    func schedule48HrNotification(id: String, departureDate: String, departureOffset: Double, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        var departureDateTime = Date()
        
        departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        var departureUtcInterval = (departureOffset * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        let currentDateUtc = Date()
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = departureDateUtc.addingTimeInterval(-172800)
        
        if departureDateUtc.timeIntervalSince(currentDateUtc) > 172800 {
            
            let triggerComponents = calendar.dateComponents(in: .current, from: triggerDate)
            let triggerDateComponents = DateComponents(calendar: calendar, timeZone: .current, month: triggerComponents.month,day: triggerComponents.day, hour: triggerComponents.hour, minute: triggerComponents.minute)
            
            let notification = UNMutableNotificationContent()
            notification.sound = UNNotificationSound.default()
            let notificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: triggerDateComponents, repeats: false)
            notification.title = "Flight Reminder for flight \(flightNumber)"
            
            if departingTerminal != "-" && departingGate != "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport))  \(NSLocalizedString("is departing in 48 hours! Make sure to check in online and choose your seats.", comment: ""))"
                
            } else if departingGate == "-" && departingTerminal != "-"{
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 48 hours! Make sure to check in online and choose your seats.", comment: ""))"
                
            } else if departingGate != "-" && departingTerminal == "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 48 hours! Make sure to check in online and choose your seats.", comment: ""))"
                
            } else {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport))  \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 48 hours! Make sure to check in online and choose your seats.", comment: ""))"
            }
            
            let identifier = "\(id)48HrNotification"
            
            let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("scheduled 48 hr notification = \(request.identifier)")
            
        }
        
    }
    
    
    
    func schedule4HrNotification(id: String, departureDate: String, departureOffset: Double, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        var departureUtcInterval = (departureOffset * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        let currentDateUtc = Date()
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = departureDateUtc.addingTimeInterval(-14400)
        
        if departureDateUtc.timeIntervalSince(currentDateUtc) > 14400 {
            
            let triggerComponents = calendar.dateComponents(in: .current, from: triggerDate)
            let triggerDateComponents = DateComponents(calendar: calendar, timeZone: .current, month: triggerComponents.month,day: triggerComponents.day, hour: triggerComponents.hour, minute: triggerComponents.minute)
            
            let notification = UNMutableNotificationContent()
            
            notification.sound = UNNotificationSound.default()
            let notificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: triggerDateComponents, repeats: false)
            notification.title = "Flight Reminder for flight \(flightNumber)"
            
            
            if departingTerminal != "-" && departingGate != "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport))  \(NSLocalizedString("is departing in 4 hours. Use TripKey to effortlessly get directions to the airport.", comment: ""))"
                
            } else if departingGate == "-" && departingTerminal != "-"{
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 4 hours. Use TripKey to effortlessly get directions to the airport.", comment: ""))"
                
            } else if departingGate != "-" && departingTerminal == "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 4 hours. Use TripKey to effortlessly get directions to the airport.", comment: ""))"
                
            } else {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport))  \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 4 hours. Use TripKey to effortlessly get directions to the airport.", comment: ""))"
            }
            
            let request = UNNotificationRequest(identifier: "\(id)4HrNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("scheduled 4 hr notification = \(request.identifier)")
        }
        
    }
    
    
    
    func schedule2HrNotification(id: String, departureDate: String, departureOffset: Double, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        var departureUtcInterval = (departureOffset * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        let currentDateUtc = Date()
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = departureDateUtc.addingTimeInterval(-7200)
        
        if departureDateUtc.timeIntervalSince(currentDateUtc) > 7200 {
            
            let triggerComponents = calendar.dateComponents(in: .current, from: triggerDate)
            let triggerDateComponents = DateComponents(calendar: calendar, timeZone: .current, month: triggerComponents.month,day: triggerComponents.day, hour: triggerComponents.hour, minute: triggerComponents.minute)
            
            let notification = UNMutableNotificationContent()
            notification.sound = UNNotificationSound.default()
            let notificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: triggerDateComponents, repeats: false)
            notification.title = "Flight Reminder for flight \(flightNumber)"
            
            if departingTerminal != "-" && departingGate != "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport))  \(NSLocalizedString("is departing in 2 hours. Use TripKey to update your flight info", comment: ""))"
                
            } else if departingGate == "-" && departingTerminal != "-"{
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 2 hours. Use TripKey to update your flight info", comment: ""))"
                
            } else if departingGate != "-" && departingTerminal == "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 2 hours. Use TripKey to update your flight info", comment: ""))"
                
            } else {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport))  \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 2 hours. Use TripKey to update your flight info", comment: ""))"
            }
            
            let request = UNNotificationRequest(identifier: "\(id)2HrNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("scheduled 2 hr notification = \(request.identifier)")
        }
        
    }
    
    func schedule1HourNotification(id: String, departureDate: String, departureOffset: Double, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        var departureUtcInterval = (departureOffset * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        
        let currentDateUtc = Date()
        
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = departureDateUtc.addingTimeInterval(-3600)
        
        if departureDateUtc.timeIntervalSince(currentDateUtc) > 3600 {
            
            let triggerComponents = calendar.dateComponents(in: .current, from: triggerDate)
            let triggerDateComponents = DateComponents(calendar: calendar, timeZone: .current, month: triggerComponents.month,day: triggerComponents.day, hour: triggerComponents.hour, minute: triggerComponents.minute)
            
            let notification = UNMutableNotificationContent()
            notification.sound = UNNotificationSound.default()
            let notificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: triggerDateComponents, repeats: false)
            notification.title = "Flight Reminder for flight \(flightNumber)"
            
            
            if departingTerminal != "-" && departingGate != "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport))  \(NSLocalizedString("is departing in 1 hour. The flight will board soon, check TripKey for updates.", comment: ""))"
                
            } else if departingGate == "-" && departingTerminal != "-"{
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 1 hour. The flight will board soon, check TripKey for updates.", comment: ""))"
                
            } else if departingGate != "-" && departingTerminal == "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 1 hour. The flight will board soon, check TripKey for updates.", comment: ""))"
                
            } else {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport))  \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is departing in 1 hour. The flight will board soon, check TripKey for updates.", comment: ""))"
            }
            
            let request = UNNotificationRequest(identifier: "\(id)1HrNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("scheduled 1 hr notification = \(request.identifier)")
        }
    }
    
    func scheduleTakeOffNotification(id: String, departureDate: String, departureOffset: Double, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        var departureUtcInterval = (departureOffset * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        
        let currentDateUtc = Date()
        
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = departureDateUtc
        
        if departureDateUtc.timeIntervalSince(currentDateUtc) > 0 {
            
            let triggerComponents = calendar.dateComponents(in: .current, from: triggerDate)
            let triggerDateComponents = DateComponents(calendar: calendar, timeZone: .current, month: triggerComponents.month,day: triggerComponents.day, hour: triggerComponents.hour, minute: triggerComponents.minute)
            
            let notification = UNMutableNotificationContent()
            notification.sound = UNNotificationSound.default()
            let notificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: triggerDateComponents, repeats: false)
            notification.title = "Flight Reminder for flight \(flightNumber)"
            
            
            if departingTerminal != "-" && departingGate != "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport))  \(NSLocalizedString("is scheduled to be departing now.", comment: ""))"
                
            } else if departingGate == "-" && departingTerminal != "-"{
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is scheduled to be departing now.", comment: ""))"
                
            } else if departingGate != "-" && departingTerminal == "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is scheduled to be departing now.", comment: ""))"
                
            } else {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport))  \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is scheduled to be departing now.", comment: ""))"
            }
            let request = UNNotificationRequest(identifier: "\(id)TakeOffNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
             print("scheduled takeoff notification = \(request.identifier)")
        }
    }
    
    func scheduleLandingNotification(id: String, arrivalDate: String, arrivalOffset: Double, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        departureDateTime = departureDateFormatter.date(from: arrivalDate)!
            
        var departureUtcInterval = arrivalOffset * 60 * 60
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        
        let currentDateUtc = Date()
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = departureDateUtc
        
        if departureDateUtc.timeIntervalSince(currentDateUtc) > 0 {
            
            let triggerComponents = calendar.dateComponents(in: .current, from: triggerDate)
            
            let triggerDateComponents = DateComponents(calendar: calendar, timeZone: .current, month: triggerComponents.month,day: triggerComponents.day, hour: triggerComponents.hour, minute: triggerComponents.minute)
            
            let notification = UNMutableNotificationContent()
            notification.sound = UNNotificationSound.default()
            let notificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: triggerDateComponents, repeats: false)
            notification.title = "Flight Reminder for flight \(flightNumber)"
            
            
            if departingTerminal != "-" && departingGate != "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport))  \(NSLocalizedString("is scheduled to be landing now.", comment: ""))"
                
            } else if departingGate == "-" && departingTerminal != "-"{
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Terminal", comment: "")) \(departingTerminal) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is scheduled to be landing now.", comment: ""))"
                
            } else if departingGate != "-" && departingTerminal == "-" {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport)) \(NSLocalizedString("Gate", comment: "")) \(departingGate) \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is scheduled to be landing now.", comment: ""))"
                
            } else {
                
                notification.body = "\(NSLocalizedString("Your flight from", comment: "")) \(departureCity) (\(departingAirport))  \(NSLocalizedString("to", comment: "")) \(arrivalCity) (\(arrivingAirport)) \(NSLocalizedString("is scheduled to be landing now.", comment: ""))"
            }
            let request = UNNotificationRequest(identifier: "\(id)LandingNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
             print("scheduled landing notification = \(request.identifier)")
        }
    }
}


