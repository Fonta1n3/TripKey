//
//  FlightDetailsViewController.swift
//  TripKey2
//
//  Created by Peter on 9/15/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import StoreKit
import UserNotifications

class FlightDetailsViewController: UIViewController, UITextFieldDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, UITabBarControllerDelegate {
    
    let activityCenter = CenterActivityView()
    var flightArray = [[String:Any]]()
    let datePickerView = Bundle.main.loadNibNamed("Date Picker", owner: self, options: nil)?[0] as! DatePickerView
    var flightCount:[Int] = []
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    @IBOutlet var addFlightButton: UIButton!
    @IBOutlet var airlineCode: UITextField!
    var button = UIButton(type: UIButtonType.custom)
    let PREMIUM_PRODUCT_ID = "com.TripKeyLite.unlockPremium"
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    
    @objc func saveDate() {
        print("saveDate")
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.datePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            DispatchQueue.main.async {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY/MM/dd"
                let departureDate = dateFormatter.string(from: self.datePickerView.datePicker.date)
                let flightNumber = self.formattedFlightNumber(textInput: self.airlineCode.text!)
                self.parseFlightNumber(flightNumber: flightNumber, departureDate: departureDate)
                self.datePickerView.removeFromSuperview()
                self.blurEffectView.removeFromSuperview()
                
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        UserDefaults.standard.set(true, forKey: "nonConsumablePurchaseMade")
        
        self.activityCenter.remove()
        
        displayAlert(viewController: self, title: NSLocalizedString("TripKey", comment: ""), message: NSLocalizedString("You've successfully restored your purchase!", comment: ""))
        
    }
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts()  {
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: PREMIUM_PRODUCT_ID)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            
            iapProducts = response.products
            
            // 1st IAP Product (Consumable) ------------------------------------
            let firstProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            //let price1Str = numberFormatter.string(from: firstProduct.price)
            
            // Show its description
            //upgradePrice = firstProduct.localizedDescription + "\nfor just \(price1Str!)"
            // ------------------------------------------------
        }
    }
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(product: SKProduct) {
        
        if self.canMakePurchases() {
            
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
            
            
        } else {
            
            // IAP Purchases dsabled on the Device
            self.activityCenter.remove()
            displayAlert(viewController: self, title: NSLocalizedString("TripKey", comment: ""), message: NSLocalizedString("Purchases are disabled in your device!", comment: ""))
        }
    }
    
    
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction:AnyObject in transactions {
            
            if let trans = transaction as? SKPaymentTransaction {
                
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Non-Consumable product (Premium) has been purchased!
                    if productID == PREMIUM_PRODUCT_ID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        nonConsumablePurchaseMade = true
                        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
                        
                        self.activityCenter.remove()
                        
                        displayAlert(viewController: self, title: NSLocalizedString("TripKey", comment: ""), message: NSLocalizedString("You've successfully unlocked the Premium version!", comment: ""))
                    }
                    
                    break
                    
                case .failed:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    self.activityCenter.remove()
                    
                    displayAlert(viewController: self, title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Sorry we had a problem processing your payment", comment: ""))
                    
                    break
                    
                case .restored:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    self.activityCenter.remove()
                    
                    displayAlert(viewController: self, title: NSLocalizedString("TripKey", comment: ""), message: NSLocalizedString("You've successfully unlocked the Premium version!", comment: ""))
                    
                    break
                    
                default:
                    break
                    
                }
            }
        }
    }

    
    func purchasePremium() {
        
        let alert = UIAlertController(title: NSLocalizedString("Youv'e reached your limit of free flights.", comment: ""), message: NSLocalizedString("This will be a one time charge that is valid even if you switch phones or uninstall TripKey.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Unlock Premium for $2.99", comment: ""), style: .default, handler: { (action) in
                
                self.addActivityIndicatorCenter(description: "Purchasing")
                self.purchaseMyProduct(product: self.iapProducts[0])
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: ""), style: .default, handler: { (action) in }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Restore Purchases", comment: ""), style: .default, handler: { (action) in
                
                self.addActivityIndicatorCenter(description: "Restoring")
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
    }
    
    func pleaseEnterFlightNumber() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: NSLocalizedString("Please enter a Flight Number", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func addDateView() {
        
        airlineCode.resignFirstResponder()
        view.addSubview(blurEffectView)
        view.addSubview(datePickerView)
        
        UIView.animate(withDuration: 0.5) {
            
            self.blurEffectView.alpha = 1
            self.datePickerView.alpha = 1
            
        }
        
    }
   
    @IBAction func addFlight(_ sender: AnyObject) {
        
       if self.flightCount.count >= 10 && self.nonConsumablePurchaseMade == false {
         
            self.fetchAvailableProducts()
        
            DispatchQueue.main.async {
            
                let alert = UIAlertController(title: NSLocalizedString("You've reached your limit of flights!", comment: ""), message: "TripKey has taken an enourmous amount of work and it costs us money to provide you this service, please support the app and purchase the premium version, we greatly appreciate it. This is a one off charge and you will never be charged again", preferredStyle: UIAlertControllerStyle.alert)
            
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
                    self.purchasePremium()
                
                }))
            
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                
                }))
            
                self.present(alert, animated: true, completion: nil)
                
            }
        
    } else if self.flightCount.count >= 10 && self.nonConsumablePurchaseMade {
        
            if airlineCode.text == "" {
                
                pleaseEnterFlightNumber()
                
            } else {
                
                self.addDateView()
                
            }
            
       } else if self.flightCount.count < 10 {
        
            if airlineCode.text == "" {
                
                pleaseEnterFlightNumber()
                
            } else {
                
                self.addDateView()
                
            }
        
        }
        
    }
    
    @objc func closeDate() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.datePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            self.datePickerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
            
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is viewdidload FlightDetailsViewController")
        
        tabBarController!.delegate = self
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0
        datePickerView.save.setTitle("Next", for: .normal)
        datePickerView.save.addTarget(self, action: #selector(saveDate), for: .touchUpInside)
        datePickerView.exit.addTarget(self, action: #selector(closeDate), for: .touchUpInside)
        datePickerView.center = view.center
        datePickerView.alpha = 0
        datePickerView.title.text = "Please select Departure Date"
        let currentDate = NSDate()
        datePickerView.datePicker.date = currentDate as Date
        airlineCode.keyboardAppearance = UIKeyboardAppearance.light
        addFlightButton.titleLabel?.adjustsFontSizeToFitWidth = true
        addFlightButton.setTitle(NSLocalizedString("Add Flight", comment: ""), for: .normal)
        
        if UserDefaults.standard.object(forKey: "flightCount") != nil {
            
            self.flightCount = UserDefaults.standard.object(forKey: "flightCount") as! [Int]
            
        } else {
            
            self.flightCount = []
            
        }
        
        UserDefaults.standard.removeObject(forKey: "airlines")
        
        self.airlineCode.delegate = self
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        center.getNotificationSettings { (settings) in
            
            if settings.authorizationStatus != .authorized {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: NSLocalizedString("We would like to send you notifications about your flight", comment: ""), message: NSLocalizedString("We send you friendly reminders so that you do not forget about your flight and always make it to the airport on time, we keep them to a minimum", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                        
                        DispatchQueue.main.async {
                            
                            center.requestAuthorization(options: options) {
                                
                                (granted, error) in
                                
                                if !granted {
                                    
                                    print("Norifications denied")
                                    
                                }
                                
                            }
                            
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    func formattedFlightNumber(textInput: String) -> String {
        print("formattedFlightNumber = \(textInput)")
        
        var numbers = textInput.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        let letters = textInput.trimmingCharacters(in: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted)
        if numbers.first == "0" {
            numbers = String(numbers.dropFirst())
        }
        let formattedFlightNumber = letters + "/" + numbers
        
        return formattedFlightNumber
    }

    func parseFlightNumber(flightNumber: String, departureDate: String) {
        print("parseFlightNumber")
        
        addActivityIndicatorCenter(description: "Getting Flight")
        
        func getDict() {
            print("getDict")
            
            DispatchQueue.main.async {
                
                self.activityCenter.remove()
                
            }
            
            if let jsonFlightData = MakeHttpRequest.sharedInstance.dictToReturn as? NSDictionary {
                
                var airlineName = ""
                var phoneNumber = ""
                var aircraft = ""
                var airlineCode = ""
                var arrivalDate = ""
                var flightNumber = ""
                var departureDate = ""
                var departureTerminal = "-"
                var arrivalTerminal = "-"
                var departureGate = "-"
                var arrivalGate = "-"
                var departureLongitude:Double! = 0
                var departureLatitude:Double! = 0
                var departureCity = ""
                var departureUtcOffset:Double! = 0
                var arrivalLongitude:Double! = 0
                var arrivalLatitude:Double! = 0
                var arrivalCity = ""
                var arrivalUtcOffset:Double! = 0
                var airlineNameArray:[String]! = []
                var departureDateUtc = ""
                var urlArrivalDate = ""
                
                if let aircraftCheck = ((((jsonFlightData)["appendix"] as? NSDictionary)?["equipments"] as? NSArray)?[0] as? NSDictionary)?["name"] as? String {
                    
                    aircraft = aircraftCheck
                    
                }
                
                if let airlinesArray = ((jsonFlightData)["appendix"] as? NSDictionary)?["airlines"] as? NSArray {
                    
                    print("airlinesArray = \(airlinesArray)")
                    
                    for item in airlinesArray {
                        
                        let obj = item as! NSDictionary
                        let bookingAirlineName = obj["name"] as! String
                        let fs = obj["fs"] as! String
                        let iata = obj["iata"] as! String
                        let icao = obj["icao"] as! String
                        var airlineCode = ""
                        
                        DispatchQueue.main.async {
                            
                            airlineCode = self.airlineCode.text!.trimmingCharacters(in: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted)
                            
                            if airlineCode.uppercased() == fs || airlineCode.uppercased() == iata || airlineCode.uppercased() == icao {
                                print("step 1")
                                
                                airlineName = bookingAirlineName
                                
                                if let phoneNumberCheck = obj["phoneNumber"] as? String {
                                    print("step 2")
                                    
                                    phoneNumber = phoneNumberCheck
                                    
                                    
                                    switch airlineName {
                                    case "American Airlines": phoneNumber = "+1 800-433-7300"
                                    case "Virgin Australia": phoneNumber = "+61 7 3295 2296"
                                    case "British Airways": phoneNumber = "+1-800-247-9297"
                                    default:
                                        phoneNumber = phoneNumberCheck
                                    }
                                    print("phonenumber = \(phoneNumber)")
                                }
                                
                            }
                            
                            airlineNameArray.append(bookingAirlineName)
                        }
                        
                    }
                    
                }
                
                if let errorMessage = ((jsonFlightData)["error"] as? NSDictionary)?["errorMessage"] as? String {
                    
                    DispatchQueue.main.async {
                        
                        self.activityCenter.remove()
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else if let scheduledFlightsArray = jsonFlightData["scheduledFlights"] as? NSArray {
                    
                    if scheduledFlightsArray.count > 0 {
                        
                        var airportDictionaries = [[String:Any]]()
                        
                        if let airportDicts = (((jsonFlightData)["appendix"] as? NSDictionary)?["airports"] as? NSArray) {
                            
                            airportDictionaries = airportDicts as! [[String : Any]]
                            
                        }
                        
                        var flightStructArray = [FlightStruct]()
                        
                        for flight in scheduledFlightsArray {
                            
                            let flightDict = flight as! NSDictionary
                            
                            let departureAirportCode = flightDict["departureAirportFsCode"] as! String
                            let arrivalAirportCode = flightDict["arrivalAirportFsCode"]! as! String
                            
                            var departureAirportIndex = Int()
                            var arrivalAirportIndex = Int()
                            
                            for (index, airport) in airportDictionaries.enumerated() {
                                
                                if departureAirportCode == airport["fs"] as! String {
                                    
                                    departureAirportIndex = index
                                    
                                }
                                
                                if arrivalAirportCode == airport["fs"] as! String {
                                    
                                    arrivalAirportIndex = index
                                    
                                }
                            }
                            
                            //assigns correct airport variables to departure
                            departureLongitude = (airportDictionaries[departureAirportIndex]["longitude"] as! Double)
                            departureLatitude = (airportDictionaries[departureAirportIndex]["latitude"] as! Double)
                            departureCity = airportDictionaries[departureAirportIndex]["city"] as! String
                            departureUtcOffset = (airportDictionaries[departureAirportIndex]["utcOffsetHours"] as! Double)
                            
                            //assigns correct airport variables to arrival
                            arrivalLongitude = (airportDictionaries[arrivalAirportIndex]["longitude"] as! Double)
                            arrivalLatitude = (airportDictionaries[arrivalAirportIndex]["latitude"] as! Double)
                            arrivalCity = airportDictionaries[arrivalAirportIndex]["city"] as! String
                            arrivalUtcOffset = (airportDictionaries[arrivalAirportIndex]["utcOffsetHours"] as! Double)
                            
                            //checks for optional terminal and gate info
                            if let departureTerminalCheck = flightDict["departureTerminal"] as? String {
                                
                                departureTerminal = departureTerminalCheck
                            }
                            
                            if let arrivalTerminalCheck = flightDict["arrivalTerminal"] as? String {
                                
                                arrivalTerminal = arrivalTerminalCheck
                            }
                            
                            if let departureGateCheck = flightDict["departureGate"] as? String {
                                
                                departureGate = departureGateCheck
                            }
                            
                            if let arrivalGateCheck = flightDict["arrivalGate"] as? String {
                                
                                arrivalGate = arrivalGateCheck
                            }
                            
                            airlineCode = flightDict["carrierFsCode"] as! String
                            flightNumber = flightDict["flightNumber"] as! String
                            
                            departureDate = flightDict["departureTime"] as! String
                            departureDateUtc = getUtcTime(time: departureDate, utcOffset: departureUtcOffset)
                            
                            arrivalDate = flightDict["arrivalTime"] as! String
                            urlArrivalDate = convertToURLDate(date: arrivalDate)
                            
                            let leg:[String:Any]! = [
                                
                                //Info that applies to both origin and destination
                                "identifier":departureDate + airlineCode + flightNumber,
                                "airlineCode":airlineCode,
                                "flightNumber":airlineCode + flightNumber,
                                "primaryCarrier":airlineName,
                                "flightEquipment":aircraft,
                                "phoneNumber":phoneNumber,
                                "sharedFrom":UserDefaults.standard.string(forKey: "userId")!,
                                
                                //Departure airport info
                                "departureAirport":departureAirportCode,
                                "departureCity":departureCity,
                                "departureTerminal":departureTerminal,
                                "departureGate":departureGate,
                                "departureUtcOffset":departureUtcOffset!,
                                "departureLon":departureLongitude!,
                                "departureLat":departureLatitude!,
                                
                                //Departure times
                                "publishedDeparture":departureDate,
                                "departureTime":departureDate,
                                "publishedDepartureUtc":departureDateUtc,
                                
                                //Arrival Airport Info
                                "arrivalAirportCode":arrivalAirportCode,
                                "arrivalLon":arrivalLongitude!,
                                "arrivalLat":arrivalLatitude!,
                                "arrivalCity":arrivalCity,
                                "arrivalTerminal":arrivalTerminal,
                                "arrivalGate":arrivalGate,
                                "arrivalUtcOffset":arrivalUtcOffset!,
                                
                                //Arrival Times
                                "publishedArrival":arrivalDate,
                                "arrivalDate":arrivalDate,
                                "urlArrivalDate":urlArrivalDate,
                                
                                ]
                            
                            let flightStruct = FlightStruct(dictionary: leg)
                            flightStructArray.append(flightStruct)
                            
                        }
                        
                        DispatchQueue.main.async {
                            
                            func addFlight(flight: FlightStruct) {
                                
                                self.flightCount.append(1)
                                UserDefaults.standard.set(self.flightCount, forKey: "flightCount")
                                self.airlineCode.text = ""
                                
                                let success = saveFlight(viewController: self,
                                                         flight: flight)
                                
                                if success {
                                    
                                    print("saved new flight to coredata")
                                    self.flightArray = getFlightArray()
                                    self.scheduleNotifications(id: flight.identifier)
                                    
                                    let successView = SuccessAlertView()
                                    successView.labelText = "Flight Added"
                                    successView.addSuccessView(viewController: self)
                                    
                                } else {
                                    
                                    displayAlert(viewController: self, title: "Error", message: "We had a problem getting that flight, please ensure you are connected to the internet and input a valid flight number and departure date")
                                }
                                
                            }
                            
                            self.activityCenter.remove()
                            
                            let alert = UIAlertController(title: NSLocalizedString("Add flight", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                            
                            if flightStructArray.count > 1 {
                               
                                for flight in flightStructArray {
                                    
                                    let title = "\(flight.departureCity) \(NSLocalizedString("to", comment: "")) \(flight.arrivalCity)"
                                    
                                    alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
                                        
                                        addFlight(flight: flight)
                                        
                                    }))
                                    
                                    let cancelTitle = NSLocalizedString("Cancel", comment: "")
                                    
                                    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                                
                            } else if flightStructArray.count == 1 {
                                
                                addFlight(flight: flightStructArray[0])
                                
                            }
                            
                        }
                        
                    } else if let _ = (((jsonFlightData)["request"] as? NSDictionary)?["flightNumber"] as? NSDictionary)?["interpreted"] as? String {
                        
                        let departingDay = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["day"] as? String
                        let departingMonth = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["month"] as? String
                        let departingYear = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["year"] as? String
                        
                        let formattedDepartureDate = "\(departingDay!)/\(departingMonth!)/\(departingYear!)"
                        
                        DispatchQueue.main.async {
                            
                            self.activityCenter.remove()
                            
                            let alert = UIAlertController(title: "\(NSLocalizedString("There are no scheduled flights for flight number", comment: "")) \(self.airlineCode.text!), \(NSLocalizedString("departing on", comment: "")) \(formattedDepartureDate)", message: "\n\(NSLocalizedString("Please make sure you input the correct flight number and departure date.", comment: ""))", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                                self.airlineCode.text = ""
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    
                } else {
                    
                    displayAlert(viewController: self, title: "Error", message: "We had an issue getting that flight, please check your internet connection")
                    
                }
                
            }
            
        }
        
        let url = "schedules/rest/v1/json/flight/" + flightNumber + "/departing/" + departureDate
        MakeHttpRequest.sharedInstance.getRequest(api: url, completion: getDict)
        
    }
    
    func scheduleNotifications(id: String) {
        
        DispatchQueue.main.async {
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            for flight in self.flightArray {
                
                let identifier = flight["identifier"] as! String
                
                if identifier == id {
                    
                    let flightStruct = FlightStruct.init(dictionary: flight)
                    let departureDate = flightStruct.departureDate
                    let utcOffset = flightStruct.departureUtcOffset
                    let departureCity = flightStruct.departureCity
                    let arrivalCity = flightStruct.arrivalCity
                    let arrivalDate = flightStruct.arrivalDate
                    let arrivalOffset = flightStruct.arrivalUtcOffset
                    
                    let departingTerminal = flightStruct.departureTerminal
                    let departingGate = flightStruct.departureGate
                    let departingAirport = flightStruct.departureAirport
                    let arrivalAirport = flightStruct.arrivalAirportCode
                    let flightNumber = flightStruct.flightNumber
                    
                    delegate?.schedule48HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                    
                    delegate?.schedule4HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                    
                    delegate?.schedule2HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                    
                    delegate?.schedule1HourNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                    
                    delegate?.scheduleTakeOffNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                    
                    delegate?.scheduleLandingNotification(id: id, arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                    
                    print("scheduled notifications")
                    
                }
                
            }
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    func formatDate(date: String) -> String {
        
        var dateTimeArray = date.components(separatedBy: "T")
        let dateOnly = dateTimeArray[0]
        var dateArray = dateOnly.components(separatedBy: "-")
        let formattedDate = "\(dateArray[2])/" + "\(dateArray[1])/" + "\(dateArray[0])"
        return formattedDate
        
    }
    
    func addActivityIndicatorCenter(description: String) {
        print("addActivityIndicatorCenter")
        
        DispatchQueue.main.async {
            self.activityCenter.activityDescription = description
            self.activityCenter.add(viewController: self)
        }
        
    }
    
}

extension FlightDetailsViewController  {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}
