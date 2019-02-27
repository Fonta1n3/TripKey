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
    
    let checkmarkview = UIImageView()
    let datePickerView = Bundle.main.loadNibNamed("Date Picker", owner: self, options: nil)?[0] as! DatePickerView
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    var flightCount:[Int] = []
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    @IBOutlet var addFlightButton: UIButton!
    var activityIndicator:UIActivityIndicatorView!
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
        
        nonConsumablePurchaseMade = true
        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.activityLabel.removeFromSuperview()
            self.blurEffectViewActivity.removeFromSuperview()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
        
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
        
        DispatchQueue.main.async {
            self.activityLabel.text = "Purchasing"
            self.addActivityIndicatorCenter()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        if self.canMakePurchases() {
            
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
            // IAP Purchases dsabled on the Device
        } else {
            
            DispatchQueue.main.async {
                
                self.activityIndicator.stopAnimating()
                self.activityLabel.removeFromSuperview()
                self.blurEffectViewActivity.removeFromSuperview()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
            
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
                        
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            self.activityLabel.removeFromSuperview()
                            self.blurEffectViewActivity.removeFromSuperview()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            
                        }
                        
                        displayAlert(viewController: self, title: NSLocalizedString("TripKey", comment: ""), message: NSLocalizedString("You've successfully unlocked the Premium version!", comment: ""))
                    }
                    
                    break
                    
                case .failed:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                    }
                    
                    displayAlert(viewController: self, title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Sorry we had a problem processing your payment", comment: ""))
                    
                    break
                    
                case .restored:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    displayAlert(viewController: self, title: NSLocalizedString("TripKey", comment: ""), message: NSLocalizedString("You've successfully unlocked the Premium version!", comment: ""))
                    
                    break
                    
                default:
                    break
                    
                }
            }
        }
    }

    
    func purchasePremium() {
        
        self.fetchAvailableProducts()
            
            let alert = UIAlertController(title: NSLocalizedString("Youv'e reached your limit of free flights.", comment: ""), message: NSLocalizedString("This will be a one time charge that is valid even if you switch phones or uninstall TripKey.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Unlock Premium for $2.99", comment: ""), style: .default, handler: { (action) in
                
                self.purchaseMyProduct(product: self.iapProducts[0])
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: ""), style: .default, handler: { (action) in }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Restore Purchases", comment: ""), style: .default, handler: { (action) in
                
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
        
       /*if self.flightCount.count >= 25 && self.nonConsumablePurchaseMade == false {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: NSLocalizedString("You've reached your limit of flights!", comment: ""), message: "TripKey has taken an enourmous amount of work and it costs us money to provide you this service, please support the app and purchase the premium version, we GREATLY appreciate it :)", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Sure", comment: ""), style: .default, handler: { (action) in
                
                self.purchasePremium()
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
       } else if self.flightCount.count >= 25 && self.nonConsumablePurchaseMade {
        
            if airlineCode.text == "" {
                pleaseEnterFlightNumber()
            } else {
                self.addDateView()
            }
            
       } else if self.flightCount.count < 25 {*/
        
            if airlineCode.text == "" {
                pleaseEnterFlightNumber()
            } else {
                self.addDateView()
            }
        
        //}
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
        
        self.activityLabel.text = "Getting Flight"
        addActivityIndicatorCenter()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if let url = URL(string: "https://api.flightstats.com/flex/schedules/rest/v1/json/flight/" + flightNumber + "/departing/" + departureDate + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87") {
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        print(error as Any)
                        
                        DispatchQueue.main.async {
                                
                            self.removeActivity()
                                
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }

                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonFlightData = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
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
                                    
                                    for item in airlinesArray {
                                        
                                        let obj = item as! NSDictionary
                                        let bookingAirlineName = obj["name"] as! String
                                        let fs = obj["fs"] as! String
                                        let iata = obj["iata"] as! String
                                        let icao = obj["icao"] as! String
                                        var airlineCode = ""
                                        
                                        DispatchQueue.main.async {
                                            
                                            airlineCode = "\(self.airlineCode.text!)"
                                            
                                            if airlineCode.uppercased() == fs || airlineCode.uppercased() == iata || airlineCode.uppercased() == icao {
                                                
                                                airlineName = bookingAirlineName
                                                
                                                if let phoneNumberCheck = obj["phoneNumber"] as? String {
                                                    
                                                    phoneNumber = phoneNumberCheck
                                                    
                                                    switch airlineName {
                                                    case "American Airlines": phoneNumber = "+1 800-433-7300"
                                                    case "Virgin Australia": phoneNumber = "+61 7 3295 2296"
                                                    case "British Airways": phoneNumber = "+1-800-247-9297"
                                                    default:
                                                        break
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                            airlineNameArray.append(bookingAirlineName)
                                        }
                                        
                                    }
                                    
                                }
                                
                                if let errorMessage = ((jsonFlightData)["error"] as? NSDictionary)?["errorMessage"] as? String {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.removeActivity()
                                        
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
                                            
                                            self.removeActivity()
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Add flight", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                                            
                                            for flight in flightStructArray {
                                                
                                                alert.addAction(UIAlertAction(title: "\(flight.departureCity) \(NSLocalizedString("to", comment: "")) \(flight.arrivalCity)", style: .default, handler: { (action) in
                                                    
                                                    self.flightCount.append(1)
                                                    UserDefaults.standard.set(self.flightCount, forKey: "flightCount")
                                                    self.airlineCode.text = ""
                                                    
                                                   let success = saveFlight(viewController: self,
                                                                             departureAirport: flight.departureAirport,
                                                                             departureLat: flight.departureLat,
                                                                             departureLon: flight.departureLon,
                                                                             arrivalLat: flight.arrivalLat,
                                                                             arrivalLon: flight.arrivalLon,
                                                                             airlineCode: flight.airlineCode,
                                                                             arrivalAirportCode: flight.arrivalAirportCode,
                                                                             arrivalCity: flight.arrivalCity,
                                                                             arrivalDate: flight.arrivalDate,
                                                                             arrivalGate: flight.arrivalGate,
                                                                             arrivalTerminal: flight.arrivalTerminal,
                                                                             arrivalUtcOffset: flight.arrivalUtcOffset,
                                                                             baggageClaim: "",
                                                                             departureCity: flight.departureCity,
                                                                             departureGate: flight.departureGate,
                                                                             departureTerminal: flight.departureTerminal,
                                                                             departureTime: flight.publishedDeparture,
                                                                             departureUtcOffset: flight.departureUtcOffset,
                                                                             flightDuration: "",
                                                                             flightNumber: flight.flightNumber,
                                                                             flightStatus: "",
                                                                             primaryCarrier: flight.primaryCarrier,
                                                                             flightEquipment: flight.airplaneType,
                                                                             identifier: flight.identifier,
                                                                             phoneNumber: flight.phoneNumber,
                                                                             publishedDepartureUtc: flight.publishedDepartureUtc,
                                                                             urlArrivalDate: flight.urlArrivalDate,
                                                                             publishedDeparture: flight.publishedDeparture,
                                                                             publishedArrival: flight.publishedArrival)
                                                    
                                                    if success {
                                                        print("saved new flight to coredata")
                                                    }
                                                    
                                                    //insert check mark animation instead
                                                    //add blur background
                                                    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
                                                    blurView.frame = self.view.frame
                                                    blurView.alpha = 0
                                                    self.view.addSubview(blurView)
                                                    
                                                    UIView.animate(withDuration: 0.3, animations: {
                                                        
                                                        blurView.alpha = 1
                                                        
                                                    }, completion: { _ in
                                                        
                                                        self.successAnimation()
                                                        
                                                        let alert = UIAlertController(title: NSLocalizedString("Flight Added", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                                                        
                                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Add another", comment: ""), style: .default, handler: { (action) in
                                                            
                                                            UIView.animate(withDuration: 0.3, animations: {
                                                                
                                                                blurView.alpha = 0
                                                                self.checkmarkview.alpha = 0
                                                                
                                                            }, completion: { _ in
                                                                
                                                                blurView.removeFromSuperview()
                                                                self.checkmarkview.removeFromSuperview()
                                                                
                                                            })
                                                            
                                                        }))
                                                        
                                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: { (action) in
                                                            
                                                            UIView.animate(withDuration: 0.3, animations: {
                                                                
                                                                blurView.alpha = 0
                                                                self.checkmarkview.alpha = 0
                                                                
                                                            }, completion: { _ in
                                                                
                                                                blurView.removeFromSuperview()
                                                                self.checkmarkview.removeFromSuperview()
                                                                
                                                            })
                                                            
                                                            self.tabBarController!.selectedIndex = 0
                                                            
                                                        }))
                                                        
                                                        self.present(alert, animated: true, completion: nil)
                                                        
                                                    })
                                                    
                                                }))
                                                
                                            }
                                            
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                        
                                    } else if let _ = (((jsonFlightData)["request"] as? NSDictionary)?["flightNumber"] as? NSDictionary)?["interpreted"] as? String {
                                      
                                        let departingDay = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["day"] as? String
                                        let departingMonth = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["month"] as? String
                                        let departingYear = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["year"] as? String
                                    
                                        let formattedDepartureDate = "\(departingDay!)/\(departingMonth!)/\(departingYear!)"
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.removeActivity()
                                                
                                            let alert = UIAlertController(title: "\(NSLocalizedString("There are no scheduled flights for flight number", comment: "")) \(self.airlineCode.text!), \(NSLocalizedString("departing on", comment: "")) \(formattedDepartureDate)", message: "\n\(NSLocalizedString("Please make sure you input the correct flight number and departure date.", comment: ""))", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.airlineCode.text = ""
                                                
                                                }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }

                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                } catch {
                        
                    
                    print("Error parsing")
                    
                    DispatchQueue.main.async {
                        
                        self.removeActivity()
                            
                        let alert = UIAlertController(title: NSLocalizedString(NSLocalizedString("There was an unknown error!", comment: ""), comment: ""), message: NSLocalizedString("Please contact customer support at TripKeyApp@gmail.com", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }

                    
                }
                
            }
            
            task.resume()
            
        }
        
    }
    
    func successAnimation() {
        
        checkmarkview.frame = CGRect(x: self.view.center.x - 95, y: (self.view.center.y - 95) - (self.view.frame.height / 5), width: 190, height: 190)
        checkmarkview.image = UIImage(named: "whiteCheck.png")
        checkmarkview.alpha = 0
        self.view.addSubview(checkmarkview)
        
        checkmarkview.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIViewAnimationOptions.allowUserInteraction, animations: {
            
            self.checkmarkview.alpha = 1
            self.checkmarkview.transform = CGAffineTransform.identity
            
        })
    }
    
    func removeActivity() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.activityLabel.removeFromSuperview()
            self.blurEffectViewActivity.removeFromSuperview()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
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
        activityIndicator.alpha = 0
        activityIndicator.isUserInteractionEnabled = true
        activityIndicator.startAnimating()
        
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
    
}

extension FlightDetailsViewController  {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}
