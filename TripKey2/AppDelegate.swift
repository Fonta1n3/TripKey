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
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var token:String!
    var window: UIWindow?
    
    func switchControllers(viewControllerToBeDismissed:UIViewController,controllerToBePresented:UIViewController) {
        if (viewControllerToBeDismissed.isViewLoaded && (viewControllerToBeDismissed.view.window != nil)) {
            // viewControllerToBeDismissed is visible
            //First dismiss and then load your new presented controller
            viewControllerToBeDismissed.dismiss(animated: false, completion: {
                self.window?.rootViewController?.present(controllerToBePresented, animated: true, completion: nil)
            })
        } else {
            
            print("else")
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            
            ParseMutableClientConfiguration.applicationId = "da4b113f84f8d2467b2c237a63778aa49f29dcee"
            ParseMutableClientConfiguration.clientKey = "e1d6ba3797e8364252e3cfaa546520ae2c268ed0"
            ParseMutableClientConfiguration.server = "http://ec2-54-202-119-191.us-west-2.compute.amazonaws.com:80/parse"
            
            
        })
        
        Parse.initialize(with: parseConfiguration)
        GMSServices.provideAPIKey("AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw")
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        let action = UNNotificationAction(identifier: "updateStatuses", title: "Get Directions to Airport", options: [])
        let category = UNNotificationCategory(identifier: "statusUpdates", actions: [action], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        
        
        // ****************************************************************************
        // Uncomment and fill in with your Parse credentials:
        // Parse.setApplicationId("your_application_id", clientKey: "your_client_key")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
        //PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.hasPublicReadAccess = true
        //defaultACL.setPublicWriteAccess = true
        defaultACL.hasPublicWriteAccess = true
        
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            /*
             let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
             let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
             var noPushPayload = false;
             if let options = launchOptions {
             noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
             }
             if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
             PFAnalytics.trackAppOpened(launchOptions: launchOptions)
             }
             */
        }
        
        
        
        return true
    }
    
    @objc(messaging:didReceiveRegistrationToken:) func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        //this is where u will get the fcm token and now u can save it to your database for sending notifications to the user in future
        
        //saving the fcm token it to the database
        if PFUser.current() != nil {
            
            let user = PFUser.current()
            
            user?["firebaseToken"] = fcmToken
            
            user?.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    print("save users firebaseToken to parse")
                    
                } else {
                    
                    print("could not save users device token to parse")
                }
            })
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcmMessageIDKey"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        
        print("applicationReceivedRemoteMessage ")
        
        print("remoteMessage.appData = \(remoteMessage.appData)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register:", error)
        
    }
    
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        //exit(0)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TripKey2")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error {
                
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
                fatalError("Unresolved error \(String(describing: error)), \(String(describing: error?._userInfo))")
                
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
    
    
    
    func schedule48HrNotification(estimatedDeparture: String, departureDate: String, departureOffset: String, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        var departureDateTime = Date()
        
        if estimatedDeparture != "" {
            
            departureDateTime = departureDateFormatter.date(from: estimatedDeparture)!
            
        } else {
            
            departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        }
        
        var departureUtcInterval = (Double(departureOffset)! * 60 * 60)
        
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
            
            let identifier = "\(flightNumber + departureDate)48HrNotification"
            
            let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: notificationTrigger)
            
            //UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                
                if error != nil {
                    
                    print("error = \(String(describing: error))")
                    
                } else {
                    
                   print("scheduled 48 hr notification = \(request.identifier)")
                }
            })
            
            
            
        }
        
    }
    
    
    
    func schedule4HrNotification(estimatedDeparture: String, departureDate: String, departureOffset: String, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        if estimatedDeparture != "" {
            
            departureDateTime = departureDateFormatter.date(from: estimatedDeparture)!
            
        } else {
            
            departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        }
        
        var departureUtcInterval = (Double(departureOffset)! * 60 * 60)
        
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
            
            let request = UNNotificationRequest(identifier: "\(flightNumber + departureDate)4HrNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("scheduled 4 hr notification = \(request.identifier)")
        }
        
    }
    
    
    
    func schedule2HrNotification(estimatedDeparture: String, departureDate: String, departureOffset: String, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        if estimatedDeparture != "" {
            
            departureDateTime = departureDateFormatter.date(from: estimatedDeparture)!
            
        } else {
            
            departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        }
        
        var departureUtcInterval = (Double(departureOffset)! * 60 * 60)
        
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
            
            let request = UNNotificationRequest(identifier: "\(flightNumber + departureDate)2HrNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("scheduled 2 hr notification = \(request.identifier)")
        }
        
    }
    
    func schedule1HourNotification(estimatedDeparture: String, departureDate: String, departureOffset: String, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        if estimatedDeparture != "" {
            
            departureDateTime = departureDateFormatter.date(from: estimatedDeparture)!
            
        } else {
            
            departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        }
        
        var departureUtcInterval = (Double(departureOffset)! * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        
        // let currentDateFormatter = DateFormatter()
        let currentDateUtc = Date()
        
        print("currentDateUtc = \(currentDateUtc)")
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
            let request = UNNotificationRequest(identifier: "\(flightNumber + departureDate)1HrNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("scheduled 1 hr notification = \(request.identifier)")
        }
    }
    
    func scheduleTakeOffNotification(estimatedDeparture: String, departureDate: String, departureOffset: String, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        if estimatedDeparture != "" {
            
            departureDateTime = departureDateFormatter.date(from: estimatedDeparture)!
            
        } else {
            
            departureDateTime = departureDateFormatter.date(from: departureDate)!
            
        }
        
        var departureUtcInterval = (Double(departureOffset)! * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        
        // let currentDateFormatter = DateFormatter()
        let currentDateUtc = Date()
        
        print("currentDateUtc = \(currentDateUtc)")
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
            let request = UNNotificationRequest(identifier: "\(flightNumber + departureDate)TakeOffNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
             print("scheduled takeoff notification = \(request.identifier)")
        }
    }
    
    func scheduleLandingNotification(estimatedArrival: String, arrivalDate: String, arrivalOffset: String, departureCity: String, arrivalCity: String, flightNumber: String, departingTerminal: String, departingGate: String, departingAirport: String, arrivingAirport: String) {
        
        let departureDateFormatter = DateFormatter()
        departureDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var departureDateTime = Date()
        
        if estimatedArrival != "" {
            
            departureDateTime = departureDateFormatter.date(from: estimatedArrival)!
            
        } else {
            
            departureDateTime = departureDateFormatter.date(from: arrivalDate)!
            
        }
        
        var departureUtcInterval = (Double(arrivalOffset)! * 60 * 60)
        
        if departureUtcInterval < 0 {
            
            departureUtcInterval = abs(departureUtcInterval)
            
        } else if departureUtcInterval > 0 {
            
            departureUtcInterval = departureUtcInterval * -1
            
        } else if departureUtcInterval == 0 {
            
            departureUtcInterval = 0
        }
        
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let departureDateUtc = departureDateTime.addingTimeInterval((departureUtcInterval + Double(secondsFromGMT)))
        
        // let currentDateFormatter = DateFormatter()
        let currentDateUtc = Date()
        
        print("currentDateUtc = \(currentDateUtc)")
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
            let request = UNNotificationRequest(identifier: "\(flightNumber + arrivalDate)LandingNotification", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
             print("scheduled landing notification = \(request.identifier)")
        }
    }
    
    func schedulePassportExpiryNotification(expiryDate: Date) {
        
        let expiryDateFormatter = DateFormatter()
        expiryDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var secondsFromGMT: Int { return NSTimeZone.local.secondsFromGMT() }
        let expiryDateUtc = expiryDate.addingTimeInterval((Double(secondsFromGMT)))
        print("expiryDateUtc = \(expiryDateUtc)")
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = expiryDateUtc.addingTimeInterval(-15778476)
        let triggerComponents = calendar.dateComponents(in: .current, from: triggerDate)
        let triggerDateComponents = DateComponents(calendar: calendar, timeZone: .current, month: triggerComponents.month,day: triggerComponents.day, hour: triggerComponents.hour, minute: triggerComponents.minute)
        
        let notification = UNMutableNotificationContent()
        notification.sound = UNNotificationSound.default()
        let notificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: triggerDateComponents, repeats: false)
        notification.title = "Your passport is expiring in 6 months"
        notification.body = "Many countries will not allow you entry with less then 6 months to go on your passport, try and renew it as soon as possible."
        let request = UNNotificationRequest(identifier: "passport6monthNotification", content: notification, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //this is where the APNS token has to be sent to the FCM
        Messaging.messaging().apnsToken = deviceToken//
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        
        if PFUser.current() != nil {
            
            installation?["username"] = PFUser.current()?.username
            
        }
        
        installation?.addUniqueObject("channelName", forKey: "channels")
        
        installation?.saveInBackground()
        
        self.token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("token = \(String(describing: token))")
        
        if PFUser.current() != nil {
            
            let user = PFUser.current()
            
            user?["deviceToken"] = self.token
            
            user?.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    print("save users device token to parse")
                    
                } else {
                    
                    print("could not save users device token to parse")
                }
                
            })
            
            
        }
        
        PFPush.subscribeToChannel(inBackground: "") { (succeeded, error) in
            
            if succeeded {
                
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n");
                
            } else {
                
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error as Any)
                
            }
            
        }
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                
                if PFUser.current() != nil {
                    
                    if let user = PFUser.current() {
                       
                        user["firebaseToken"] = result.token
                        
                        user.saveInBackground(block: { (success, error) in
                            
                            if success {
                                
                                print("save users firebaseToken to parse")
                                
                            } else {
                                
                                print("could not save users device token to parse")
                            }
                        })
                    }
                }
            }
        }
        
        /*if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            
            if PFUser.current() != nil {
                
                var user = PFUser.current()
                
                user?["firebaseToken"] = refreshedToken
                
                user?.saveInBackground(block: { (success, error) in
                    
                    if success {
                        
                        print("save users firebaseToken to parse")
                        
                    } else {
                        
                        print("could not save users device token to parse")
                    }
                })
            }
        }*/
        
        
        
        
        
    }
    
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        
        if response.actionIdentifier == "updateStatuses" {
            
            //do something...
            
         }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        PFPush.handle(notification.request.content.userInfo)
        completionHandler(.alert)
        
    }
    
}



