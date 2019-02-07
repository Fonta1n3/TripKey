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

class FlightDetailsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var flightArray = [[String:Any]]()
    let datePickerView = Bundle.main.loadNibNamed("Date Picker", owner: self, options: nil)?[0] as! DatePickerView
    let backButton = UIButton()
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    var flightCount:[Int] = []
    let closeButton = UIButton()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    @IBOutlet var addFlightButton: UIButton!
    var importantChanges:Bool!
    var dictionaryIataArray:[Dictionary<String,String>]! = []
    var dictionaryIcaoArray:[Dictionary<String,String>]! = []
    var fsCode = ""
    var autoCompletePossibilitiesArray:[String]! = []
    var autoCompletePossibilitiesDictionary:[Dictionary<String,String>]! = []
    var fsCodes:[String]! = []
    var iataCodes:[String]! = []
    var icaoCodes:[String]! = []
    var airlineNames:[String]! = []
    var autoComplete = [String]()
    @IBOutlet var autoSuggestTable: UITableView!
    var legs = [Dictionary<String,String>]()
    var sortedLegs = [Dictionary<String,String>]()
    var currentDateWhole = ""
    var activityIndicator:UIActivityIndicatorView!
    var number = ""
    var refNumber = " "
    var airlineNameArrayString = ""
    var sortedFlights = [[String:Any]]()
    var formattedFlightNumber = ""
    var formattedDepartureDate = ""
    @IBOutlet var airlineCode: UITextField!
    @IBOutlet var flightNumber: UITextField!
    var flightNumberTextField = ""
    var formattedTextFieldFlightNumber = ""
    var departureDate = ""
    @IBOutlet var departingDateTextField: UITextField!
    var button = UIButton(type: UIButtonType.custom)
    @IBOutlet var departureLabel: UILabel!
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
                
                if self.flightNumber.text!.first == "0" {
                    self.formattedTextFieldFlightNumber = String(self.flightNumber.text!.dropFirst())
                } else {
                    self.formattedTextFieldFlightNumber = self.flightNumber.text!
                }
                self.flightNumberTextField = "\(self.airlineCode.text!)" + "\(self.flightNumber.text!)"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY/MM/dd"
                self.departureDate = dateFormatter.string(from: self.datePickerView.datePicker.date)
                self.parseFlightNumber()
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
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func pleaseEnterFlightNumber() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: NSLocalizedString("Please enter a Flight Number", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func addDateView() {
        
        self.airlineCode.resignFirstResponder()
        self.flightNumber.resignFirstResponder()
        self.view.addSubview(self.blurEffectView)
        self.view.addSubview(self.datePickerView)
        UIView.animate(withDuration: 0.5) {
            self.blurEffectView.alpha = 1
            self.datePickerView.alpha = 1
        }
        
        
        
    }
   
    @IBAction func addFlight(_ sender: AnyObject) {
        
       if self.flightCount.count >= 25 && self.nonConsumablePurchaseMade == false {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: NSLocalizedString("You've reached your limit of flights!", comment: ""), message: "TripKey has taken an enourmous amount of work and it costs us money to provide you this service, please support the app and purchase the premium version, we GREATLY appreciate it :)", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Sure! :)", comment: ""), style: .default, handler: { (action) in
                
                self.purchasePremium()
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("No :(", comment: ""), style: .default, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
       } else if self.flightCount.count >= 25 && self.nonConsumablePurchaseMade {
        
        if flightNumber.text == "" || airlineCode.text == "" {
            pleaseEnterFlightNumber()
        } else {
            self.addDateView()
        }
            
       } else if self.flightCount.count < 25 {
        
            if flightNumber.text == "" || airlineCode.text == "" {
                pleaseEnterFlightNumber()
            } else {
                self.addDateView()
            }
        }
    }
    
    func addButtons() {
        DispatchQueue.main.async {
            self.backButton.removeFromSuperview()
            self.backButton.frame = CGRect(x: 5, y: 40, width: 25, height: 25)
            self.backButton.showsTouchWhenHighlighted = true
            let image = UIImage(imageLiteralResourceName: "backButton.png")
            self.backButton.setImage(image, for: .normal)
            self.backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
            self.view.addSubview(self.backButton)
        }
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
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
        flightNumber.keyboardType = .numberPad
        flightNumber.keyboardAppearance = UIKeyboardAppearance.light
        airlineCode.keyboardAppearance = UIKeyboardAppearance.light
        
        
        addFlightButton.titleLabel?.adjustsFontSizeToFitWidth = true
        addFlightButton.setTitle(NSLocalizedString("Add Flight", comment: ""), for: .normal)
        
        if UserDefaults.standard.object(forKey: "flightCount") != nil {
            
            self.flightCount = UserDefaults.standard.object(forKey: "flightCount") as! [Int]
            
        } else {
            
            self.flightCount = []
            
        }
        
        if UserDefaults.standard.object(forKey: "airlines") != nil {
            
            self.autoCompletePossibilitiesArray = (UserDefaults.standard.object(forKey: "airlines") as! [String])
            
        } else {
            
            getAirlineCodes()
            
        }
        
        addButtons()
        
        autoSuggestTable.isHidden = true
        
        self.airlineCode.delegate = self
        self.flightNumber.delegate = self
        self.autoSuggestTable.delegate = self
        
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
                
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "You have not allowed notifications yet", message: "You will NOT get any notifications for this flight, please update notification settings for TripKey to get notifications.", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "No Thanks", style: .default, handler: { (action) in
                        
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "Update Settings", style: .default, handler: { (action) in
                        
                        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                            //UIApplication.shared.openURL(url as URL)
                            UIApplication.shared.open(url as URL, options: [:], completionHandler: { _ in })
                        }
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    print("notifications denied")
                    
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        autoSuggestTable.tableFooterView = UIView()
        autoSuggestTable.reloadData()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            let isPointInTable = self.autoSuggestTable.frame.contains(currentPoint)
            
            if isPointInTable == false {
                self.autoSuggestTable.isHidden = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == airlineCode {
            self.autoSuggestTable.isHidden = true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        flightNumber.resignFirstResponder()
        airlineCode.resignFirstResponder()
        departingDateTextField.resignFirstResponder()
        return true
    }

    func parseFlightNumber() {
        
        self.activityLabel.text = "Getting Flight"
        addActivityIndicatorCenter()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
 
        if let url = URL(string: "https://api.flightstats.com/flex/schedules/rest/v1/json/flight/" + (self.airlineCode.text!) + "/" + (self.formattedTextFieldFlightNumber) + "/departing/" + (departureDate) + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87") {
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
                
                do {
                    
                    if error != nil {
                        
                        print(error as Any)
                        
                        DispatchQueue.main.async {
                                
                                self.activityIndicator.stopAnimating()
                                self.activityLabel.removeFromSuperview()
                                self.blurEffectViewActivity.removeFromSuperview()
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                
                            
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }

                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonFlightData = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                var airport1:NSDictionary = [:]
                                var airport2:NSDictionary = [:]
                                var airport1FsCode = ""
                                var airport2FsCode = ""
                                var departureAirport:NSDictionary! = [:]
                                var arrivalAirport:NSDictionary! = [:]
                                var airlineName = ""
                                var phoneNumber = ""
                                var aircraft = ""
                                var departureAirportCode = ""
                                var arrivalAirportCode = ""
                                var airlineCode = ""
                                var arrivalDate = ""
                                var flightNumber = ""
                                var departureDate = ""
                                var departureTerminal = "-"
                                var arrivalTerminal = "-"
                                var departureGate = "-"
                                var arrivalGate = "-"
                                var departureCountry = ""
                                var departureLongitude:Double! = 0
                                var departureLatitude:Double! = 0
                                var departureCity = ""
                                var departureUtcOffset:Double! = 0
                                var arrivalCountry = ""
                                var arrivalLongitude:Double! = 0
                                var arrivalLatitude:Double! = 0
                                var arrivalCity = ""
                                var arrivalUtcOffset:Double! = 0
                                var airlineNameArrayString = ""
                                var airlineNameArray:[String]! = []
                                var leg1:Dictionary<String,String>! = [:]
                                var convertedDepartureDate = ""
                                var departureDateNumber = ""
                                var departureDateUtc = ""
                                var convertedArrivalDate = ""
                                var arrivalDateNumber = ""
                                var arrivalDateUtc = ""
                                var departureDateUtcNumber = ""
                                var urlDepartureDate = ""
                                var urlArrivalDate = ""
                                var arrivalDateUtcNumber = ""
                                
                                
                                if let aircraftCheck = ((((jsonFlightData)["appendix"] as? NSDictionary)?["equipments"] as? NSArray)?[0] as? NSDictionary)?["name"] as? String {
                                    
                                    aircraft = aircraftCheck
                                }
                                
                                if let airlinesArray = ((jsonFlightData)["appendix"] as? NSDictionary)?["airlines"] as? NSArray {
                                    
                                    for item in airlinesArray {
                                        
                                        print("airlinesArray = \(airlinesArray)")
                                        
                                        let obj = item as! NSDictionary
                                        let bookingAirlineName = obj["name"] as! String
                                        let fs = obj["fs"] as! String
                                        let iata = obj["iata"] as! String
                                        let icao = obj["icao"] as! String
                                        var airlineCode = ""
                                        DispatchQueue.main.async {
                                           airlineCode = "\(self.airlineCode.text!)"
                                            print("self.airlineCode.text! = \(self.airlineCode.text!)")
                                            
                                            if airlineCode.uppercased() == fs || airlineCode.uppercased() == iata || airlineCode.uppercased() == icao {
                                                
                                                airlineName = bookingAirlineName
                                                print("airlineName = \(airlineName)")
                                                
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
                                    
                                    airlineNameArrayString = airlineNameArray.joined(separator: ", ")
                                    
                                }
                                
                                if let errorMessage = ((jsonFlightData)["error"] as? NSDictionary)?["errorMessage"] as? String {
                                    
                                    DispatchQueue.main.async {
                                        
                                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                        
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                            
                                            }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                    
                                } else if let scheduledFlightsArray = jsonFlightData["scheduledFlights"] as? NSArray {
                                    
                                    if scheduledFlightsArray.count > 1 {
                                        
                                        var scheduledFlights:[Dictionary<String,String>]! = []
                                        DispatchQueue.main.async{
                                            
                                        for flight in scheduledFlightsArray {
                                            
                                            let arrivalAirport = (flight as! NSDictionary)["arrivalAirportFsCode"] as! String
                                            let departureAirport = (flight as! NSDictionary)["departureAirportFsCode"] as! String
                                            airlineCode = (flight as! NSDictionary)["carrierFsCode"] as! String
                                            flightNumber = (flight as! NSDictionary)["flightNumber"] as! String
                                            departureDate = (flight as! NSDictionary)["departureTime"] as! String
                                            convertedDepartureDate = convertDateTime(date: departureDate)
                                            departureDateUtc = getUtcTime(time: departureDate, utcOffset: departureUtcOffset)
                                            //departureDateNumber = formatDateTimetoWhole(dateTime: departureDate)
                                            //departureDateUtcNumber = formatDateTimetoWhole(dateTime: departureDateUtc)
                                            urlDepartureDate = convertToURLDate(date: departureDate)
                                            
                                            arrivalDate = (flight as! NSDictionary)["arrivalTime"] as! String
                                            convertedArrivalDate = convertDateTime(date: arrivalDate)
                                            arrivalDateUtc = getUtcTime(time: arrivalDate, utcOffset: arrivalUtcOffset)
                                            //arrivalDateNumber = formatDateTimetoWhole(dateTime: arrivalDate)
                                            urlArrivalDate = convertToURLDate(date: arrivalDate)
                                            //arrivalDateUtcNumber = formatDateTimetoWhole(dateTime: arrivalDateUtc)
                                            
                                            if let departureTerminalCheck = (flight as! NSDictionary)["departureTerminal"] as? String {
                                                
                                                departureTerminal = departureTerminalCheck
                                                
                                            }
                                            
                                            if let arrivalTerminalCheck = (flight as! NSDictionary)["arrivalTerminal"] as? String {
                                                
                                                arrivalTerminal = arrivalTerminalCheck
                                                
                                            }
                                            
                                            if let departureGateCheck = (flight as! NSDictionary)["departureGate"] as? String {
                                                
                                                departureGate = departureGateCheck
                                                
                                            }
                                            
                                            if let arrivalGateCheck = (flight as! NSDictionary)["arrivalGate"] as? String {
                                                
                                                arrivalGate = arrivalGateCheck
                                                
                                            }
                                            
                                            let airportArray = ((jsonFlightData)["appendix"] as? NSDictionary)?["airports"] as? NSArray
                                            
                                            for (_, departureAirportDic) in (airportArray?.enumerated())! {
                                                
                                                let airportCode = (departureAirportDic as! NSDictionary)["fs"] as! String
                                                
                                                if airportCode == departureAirport {
                                                    
                                                    for (_, airport) in (airportArray?.enumerated())! {
                                                        
                                                        if (airport as! NSDictionary)["fs"] as! String == arrivalAirport {
                                                            
                                                            arrivalAirportCode = (airport as! NSDictionary)["fs"] as! String
                                                            arrivalCountry = (airport as! NSDictionary)["countryName"] as! String
                                                            arrivalLongitude = ((airport as! NSDictionary)["longitude"] as! Double)
                                                            arrivalLatitude = ((airport as! NSDictionary)["latitude"] as! Double)
                                                            arrivalCity = (airport as! NSDictionary)["city"] as! String
                                                            arrivalUtcOffset = ((airport as! NSDictionary)["utcOffsetHours"] as! Double)
                                                            
                                                            departureAirportCode = (departureAirportDic as! NSDictionary)["fs"] as! String
                                                            departureCountry = (departureAirportDic as! NSDictionary)["countryName"] as! String
                                                            departureLongitude = ((departureAirportDic as! NSDictionary)["longitude"] as! Double)
                                                            departureLatitude = ((departureAirportDic as! NSDictionary)["latitude"] as! Double)
                                                            departureCity = (departureAirportDic as! NSDictionary)["city"] as! String
                                                            departureUtcOffset = ((departureAirportDic as! NSDictionary)["utcOffsetHours"] as! Double)
                                                            
                                                            leg1 = [
                                                                    
                                                                    "Leg 0":"false",
                                                                    "Reference Number":"\(self.refNumber)",
                                                                    
                                                                    //Info that applies to both origin and destination
                                                                    "Airline Code":"\(airlineCode)",
                                                                    "Flight Number":"\(flightNumber)",
                                                                    "Airline Name":"\(airlineName)",
                                                                    "Partner Airlines":"\(airlineNameArrayString)",
                                                                    "Aircraft Type Name":"\(aircraft)",
                                                                    "Phone Number":"\(phoneNumber)",
                                                                    
                                                                    //Departure airport info
                                                                    "Departure Airport Code":"\(departureAirportCode)",
                                                                    "Departure Country":"\(departureCountry)",
                                                                    "Departure City":"\(departureCity)",
                                                                    "Airport Departure Terminal":"\(departureTerminal)",
                                                                    "Departure Gate":"\(departureGate)",
                                                                    "Departure Airport UTC Offset":"\(departureUtcOffset!)",
                                                                    "Airport Departure Longitude":"\(departureLongitude!)",
                                                                    "Airport Departure Latitude":"\(departureLatitude!)",
                                                                    
                                                                    //Departure times
                                                                    "Published Departure":"\(departureDate)",
                                                                    "Departure Date Number":"\(departureDateNumber)",
                                                                    "Published Departure UTC":"\(departureDateUtc)",
                                                                    "Published Departure UTC Number":"\(departureDateUtcNumber)",
                                                                    "URL Departure Date":"\(urlDepartureDate)",
                                                                    "Converted Published Departure":"\(convertedDepartureDate)",
                                                                    
                                                                    //Arrival Airport Info
                                                                    "Arrival Airport Code":"\(arrivalAirportCode)",
                                                                    "Airport Arrival Longitude":"\(arrivalLongitude!)",
                                                                    "Airport Arrival Latitude":"\(arrivalLatitude!)",
                                                                    "Arrival Country":"\(arrivalCountry)",
                                                                    "Arrival City":"\(arrivalCity)",
                                                                    "Airport Arrival Terminal":"\(arrivalTerminal)",
                                                                    "Arrival Gate":"\(arrivalGate)",
                                                                    "Arrival Airport UTC Offset":"\(arrivalUtcOffset!)",
                                                                    
                                                                    //Given in schedules json
                                                                    "Converted Published Arrival":"\(convertedArrivalDate)",
                                                                    "Published Arrival":"\(arrivalDate)",
                                                                    "Arrival Date Number":"\(arrivalDateNumber)",
                                                                    "Published Arrival UTC":"\(arrivalDateUtc)",
                                                                    "Published Arrival UTC Number":"\(arrivalDateUtcNumber)",
                                                                    "URL Arrival Date":"\(urlArrivalDate)",
                                                                    
                                                               ]
                                                            
                                                            scheduledFlights.append(leg1)
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                               }
                                                
                                            }
                                            
                                        }
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.activityIndicator.stopAnimating()
                                                self.activityLabel.removeFromSuperview()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                            }
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Choose your route", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            for (index, leg) in scheduledFlights.enumerated() {
                                                
                                                alert.addAction(UIAlertAction(title: "\(leg["Departure City"]!) \(NSLocalizedString("to", comment: "")) \(leg["Arrival City"]!)", style: .default, handler: { (action) in
                                                    
                                                    // for tripkeylite
                                                    self.flightCount.append(1)
                                                    UserDefaults.standard.set(self.flightCount, forKey: "flightCount")
                                                    
                                                    //self.sortFlightsbyDepartureDate()
                                                    
                                                    let departureDate = scheduledFlights[index]["Published Departure"]!
                                                    let utcOffset = Double(scheduledFlights[index]["Departure Airport UTC Offset"]!)!
                                                    let departureCity = scheduledFlights[index]["Departure City"]!
                                                    let arrivalCity = scheduledFlights[index]["Arrival City"]!
                                                    
                                                    let departingTerminal = "\(scheduledFlights[index]["Airport Departure Terminal"]!)"
                                                    let departingGate = "\(scheduledFlights[index]["Departure Gate"]!)"
                                                    let departingAirport = "\(scheduledFlights[index]["Departure Airport Code"]!)"
                                                    let arrivalAirport = "\(scheduledFlights[index]["Arrival Airport Code"]!)"
                                                    
                                                    let arrivalDate = "\(scheduledFlights[index]["Published Arrival"]!)"
                                                    let arrivalOffset = Double(scheduledFlights[index]["Arrival Airport UTC Offset"]!)!
                                                    
                                                    let delegate = UIApplication.shared.delegate as? AppDelegate
                                                    
                                                    delegate?.schedule4HrNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                        
                                                    delegate?.schedule1HourNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                        
                                                    
                                                    delegate?.schedule2HrNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                        
                                                    
                                                    delegate?.schedule48HrNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                        
                                                    
                                                    delegate?.scheduleTakeOffNotification(departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                    
                                                    delegate?.scheduleLandingNotification(arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                        
                                                        
                                                    
                                                    self.airlineCode.text = ""
                                                    self.flightNumber.text = ""
                                                    //self.sortFlightsbyDepartureDate()
                                                    
                                                    let id = departureDate + flightNumber
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        let success = saveFlight(viewController: self, departureAirport: departureAirportCode, departureLat: departureLatitude, departureLon: departureLongitude, arrivalLat: arrivalLatitude, arrivalLon: arrivalLongitude, airlineCode: airlineCode, arrivalAirportCode: arrivalAirportCode, arrivalCity: arrivalCity, arrivalDate: arrivalDate, arrivalGate: arrivalGate, arrivalTerminal: arrivalTerminal, arrivalUtcOffset: arrivalUtcOffset, baggageClaim: "", departureCity: departureCity, departureGate: departureGate, departureTerminal: departureTerminal, departureTime: departureDate, departureUtcOffset: departureUtcOffset, flightDuration: "", flightNumber: flightNumber, flightStatus: "", primaryCarrier: airlineName, flightEquipment: aircraft, identifier: id, phoneNumber: phoneNumber, publishedDepartureUtc: departureDateUtc, urlArrivalDate: urlArrivalDate, publishedDeparture: departureDate, publishedArrival: arrivalDate)
                                                        
                                                        if success {
                                                            print("saved new flight to coredata")
                                                        }
                                                        
                                                    }
                                                    
                                                    let alert = UIAlertController(title: NSLocalizedString("Flight Added", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Finished Adding Flights", comment: ""), style: .default, handler: { (action) in
                                                        
                                                        self.performSegue(withIdentifier: "goToNearMe", sender: self)
                                                        
                                                    }))
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Add Another Flight", comment: ""), style: .default, handler: { (action) in }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                    
                                                }))
                                                
                                                
                                                
                                            }
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                                
                                            }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                     
                                    } else if scheduledFlightsArray.count == 1 {
                                        
                                        if let airportDic1Check = (((jsonFlightData)["appendix"] as? NSDictionary)?["airports"] as? NSArray)?[0] as? NSDictionary {
                                            
                                            airport1 = airportDic1Check
                                            airport1FsCode = airport1["fs"] as! String
                                            
                                        }
                                        
                                        if let airportDic2Check = (((jsonFlightData)["appendix"] as? NSDictionary)?["airports"] as? NSArray)?[1] as? NSDictionary {
                                            
                                            airport2 = airportDic2Check
                                            airport2FsCode = airport2["fs"] as! String
                                            
                                        }
                                        
                                        if let leg0Check = (((jsonFlightData)["scheduledFlights"]) as? NSArray)?[0] as? NSDictionary {
                                            
                                            departureAirportCode = leg0Check["departureAirportFsCode"] as! String
                                            arrivalAirportCode = leg0Check["arrivalAirportFsCode"]! as! String
                                            
                                            //checks for optional terminal and gate info
                                            if let departureTerminalCheck = leg0Check["departureTerminal"] as? String {
                                                
                                                departureTerminal = departureTerminalCheck
                                            }
                                            
                                            if let arrivalTerminalCheck = leg0Check["arrivalTerminal"] as? String {
                                                
                                                arrivalTerminal = arrivalTerminalCheck
                                            }
                                            
                                            if let departureGateCheck = leg0Check["departureGate"] as? String {
                                                
                                                departureGate = departureGateCheck
                                            }
                                            
                                            if let arrivalGateCheck = leg0Check["arrivalGate"] as? String {
                                                
                                                arrivalGate = arrivalGateCheck
                                            }
                                            
                                            //assigns correct airports to flight
                                            if departureAirportCode == airport1FsCode {
                                                
                                                departureAirport = airport1
                                                
                                            } else if departureAirportCode == airport2FsCode {
                                                
                                                departureAirport = airport2
                                                
                                            }
                                            
                                            if arrivalAirportCode == airport1FsCode {
                                                
                                                arrivalAirport = airport1
                                                
                                            } else if arrivalAirportCode == airport2FsCode {
                                                
                                                arrivalAirport = airport2
                                                
                                            }
                                            
                                            //assigns correct airport variables to departure
                                            departureCountry = departureAirport["countryName"] as! String
                                            departureLongitude = (departureAirport["longitude"] as! Double)
                                            departureLatitude = (departureAirport["latitude"] as! Double)
                                            departureCity = departureAirport["city"] as! String
                                            departureUtcOffset = (departureAirport["utcOffsetHours"] as! Double)
                                            
                                            //assigns correct airport variables to arrival
                                            arrivalCountry = arrivalAirport["countryName"] as! String
                                            arrivalLongitude = (arrivalAirport["longitude"] as! Double)
                                            arrivalLatitude = (arrivalAirport["latitude"] as! Double)
                                            arrivalCity = arrivalAirport["city"] as! String
                                            arrivalUtcOffset = (arrivalAirport["utcOffsetHours"] as! Double)
                                            
                                            airlineCode = leg0Check["carrierFsCode"] as! String
                                            flightNumber = leg0Check["flightNumber"] as! String
                                            
                                            departureDate = leg0Check["departureTime"] as! String
                                            convertedDepartureDate = convertDateTime(date: departureDate)
                                            departureDateUtc = getUtcTime(time: departureDate, utcOffset: departureUtcOffset)
                                            urlDepartureDate = convertToURLDate(date: departureDate)
                                            
                                            arrivalDate = leg0Check["arrivalTime"] as! String
                                            convertedArrivalDate = convertDateTime(date: arrivalDate)
                                            arrivalDateUtc = getUtcTime(time: arrivalDate, utcOffset: arrivalUtcOffset)
                                            urlArrivalDate = convertToURLDate(date: arrivalDate)
                                            
                                            DispatchQueue.main.async {
                                                
                                                
                                                self.activityIndicator.stopAnimating()
                                                self.activityLabel.removeFromSuperview()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                    
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Non-stop flight", comment: ""), message: "\(NSLocalizedString("Flight", comment: "")) \(airlineCode + flightNumber) \(NSLocalizedString("with", comment: "")) \(airlineName) \(NSLocalizedString("departs", comment: "")) \(departureCity) \(NSLocalizedString("on", comment: "")) \(convertedDepartureDate) \(NSLocalizedString("and arrives in", comment: "")) \(arrivalCity) \(NSLocalizedString("on", comment: "")) \(convertedArrivalDate)\n\(NSLocalizedString("Please tap to add.", comment: ""))", preferredStyle: UIAlertControllerStyle.actionSheet)
                                                
                                                alert.addAction(UIAlertAction(title: "\(departureCity) \(NSLocalizedString("to", comment: "")) \(arrivalCity)", style: .default, handler: { (action) in
                                                    
                                                    // for tripkeylite
                                                    self.flightCount.append(1)
                                                    UserDefaults.standard.set(self.flightCount, forKey: "flightCount")
                                                    
                                                    let delegate = UIApplication.shared.delegate as? AppDelegate
                                                    
                                                    delegate?.schedule4HrNotification(departureDate: departureDate, departureOffset: departureUtcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departureTerminal, departingGate: departureGate, departingAirport: departureAirportCode, arrivingAirport: arrivalAirportCode)
                                                        
                                                    delegate?.schedule1HourNotification(departureDate: departureDate, departureOffset: departureUtcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departureTerminal, departingGate: departureGate, departingAirport: departureAirportCode, arrivingAirport: arrivalAirportCode)
                                                        
                                                    delegate?.schedule2HrNotification(departureDate: departureDate, departureOffset: departureUtcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departureTerminal, departingGate: departureGate, departingAirport: departureAirportCode, arrivingAirport: arrivalAirportCode)
                                                        
                                                    
                                                    delegate?.schedule48HrNotification(departureDate: departureDate, departureOffset: departureUtcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departureTerminal, departingGate: departureGate, departingAirport: departureAirportCode, arrivingAirport: arrivalAirportCode)
                                                        
                                                    delegate?.scheduleTakeOffNotification(departureDate: departureDate, departureOffset: departureUtcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departureTerminal, departingGate: departureGate, departingAirport: departureAirportCode, arrivingAirport: arrivalAirportCode)
                                                        
                                                        
                                                    delegate?.scheduleLandingNotification(arrivalDate: arrivalDate, arrivalOffset: arrivalUtcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departureTerminal, departingGate: departureGate, departingAirport: departureAirportCode, arrivingAirport: arrivalAirportCode)
                                                        
                                                        
                                                    self.airlineCode.text = ""
                                                    self.flightNumber.text = ""
                                                    
                                                    let id = departureDate + airlineCode + flightNumber
                                                    
                                                    let success = saveFlight(viewController: self, departureAirport: departureAirportCode, departureLat: departureLatitude, departureLon: departureLongitude, arrivalLat: arrivalLatitude, arrivalLon: arrivalLongitude, airlineCode: airlineCode, arrivalAirportCode: arrivalAirportCode, arrivalCity: arrivalCity, arrivalDate: arrivalDate, arrivalGate: arrivalGate, arrivalTerminal: arrivalTerminal, arrivalUtcOffset: arrivalUtcOffset, baggageClaim: "", departureCity: departureCity, departureGate: departureGate, departureTerminal: departureTerminal, departureTime: departureDate, departureUtcOffset: departureUtcOffset, flightDuration: "", flightNumber: airlineCode + flightNumber, flightStatus: "", primaryCarrier: airlineName, flightEquipment: aircraft, identifier: id, phoneNumber: phoneNumber, publishedDepartureUtc: departureDateUtc, urlArrivalDate: urlArrivalDate, publishedDeparture: departureDate, publishedArrival: arrivalDate)
                                                    
                                                    if success {
                                                        print("saved new flight to coredata")
                                                    }
                                                    
                                                    let alert = UIAlertController(title: NSLocalizedString("Flight Added", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Finished Adding Flights", comment: ""), style: .default, handler: { (action) in
                                                        
                                                        self.performSegue(withIdentifier: "goToNearMe", sender: self)
                                                        
                                                    }))
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Add Another Flight", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                }))
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                       
                                    } else if let numberCheck = (((jsonFlightData)["request"] as? NSDictionary)?["flightNumber"] as? NSDictionary)?["interpreted"] as? String {
                                      
                                        let number = numberCheck
                                        
                                        let departingDay = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["day"] as? String
                                        let departingMonth = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["month"] as? String
                                        let departingYear = (((jsonFlightData)["request"] as? NSDictionary)?["date"] as? NSDictionary)?["year"] as? String
                                    
                                        self.formattedDepartureDate = "\(departingDay!)/\(departingMonth!)/\(departingYear!)"
                                        DispatchQueue.main.async {
                                            self.formattedFlightNumber = "\(self.airlineCode.text!)" + "\(number)"
                                        }
                                        
                                         
                                        DispatchQueue.main.async {
                                            
                                            
                                            self.activityIndicator.stopAnimating()
                                            self.activityLabel.removeFromSuperview()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                

                                            let alert = UIAlertController(title: "\(NSLocalizedString("There are no scheduled flights for flight number", comment: "")) \(self.formattedFlightNumber), \(NSLocalizedString("departing on", comment: "")) \(self.formattedDepartureDate)", message: "\n\(NSLocalizedString("Please make sure you input the correct flight number and departure date.", comment: ""))", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.airlineCode.text = ""
                                                    self.flightNumber.text = ""
                                                
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
                        
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            
                        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
 
    
    func sortLegsByDepartureDate() {
        
        sortedLegs = legs.sorted {
            
            (dictOne, dictTwo) -> Bool in
            
            let d1 = Double(dictOne["Published Departure UTC Number"]!)
            let d2 = Double(dictTwo["Published Departure UTC Number"]!)
            
            
            return d1! < d2!
            
        }
        
        legs = sortedLegs
    }
    
    func sortFlightsbyDepartureDate() {
        
        sortedFlights = flightArray.sorted {
            
            (dictOne, dictTwo) -> Bool in
            
            let depDatUtcDict1 = dictOne["publishedDepartureUtc"] as! String
            let d1 = formatDateTimetoWhole(dateTime: depDatUtcDict1)
            
            let depDatUtcDict2 = dictTwo["publishedDepartureUtc"] as! String
            let d2 = formatDateTimetoWhole(dateTime: depDatUtcDict2)
            

            return d1 < d2
            
        };
        flightArray = sortedFlights
    }
    
    
    func formatDate(date: String) -> String {
        
        var dateTimeArray = date.components(separatedBy: "T")
        let dateOnly = dateTimeArray[0]
        var dateArray = dateOnly.components(separatedBy: "-")
        let formattedDate = "\(dateArray[2])/" + "\(dateArray[1])/" + "\(dateArray[0])"
        return formattedDate
    }
    
    func checkLeg2Date(downlinesArrivalDate: String, downlinesDepartureDate: String, destinationArrivalDate: String) ->(String, String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let downlinesArrivalDateFormatted = dateFormatter.date(from: downlinesArrivalDate)
        let downlinesDepartureDateFormatted = dateFormatter.date(from: downlinesDepartureDate)
        let destinationArrivalDateFormatted = dateFormatter.date(from: destinationArrivalDate)
        
        //Turns downlines arrival date into an actual date using date components
        var downlinesArrivalDateArray = downlinesArrivalDate.components(separatedBy: "T")
        let downlinesArrivalDateSegment = downlinesArrivalDateArray[0]
        var downlinesArrivalDateSplitArray = downlinesArrivalDateSegment.components(separatedBy: "-")
        let downlinesArrivalYear = Int(downlinesArrivalDateSplitArray[0])
        let downlinesArrivalMonth = Int(downlinesArrivalDateSplitArray[1])
        let downlinesArrivalDay = Int(downlinesArrivalDateSplitArray[2])
        
        let downlinesArrivalTimeSegment = downlinesArrivalDateArray[1]
        var downlinesArrivalTimeArray = downlinesArrivalTimeSegment.components(separatedBy: ":00.000")
        let downlinesArrivalTime1 = downlinesArrivalTimeArray[0]
        var downlinesArrivalHoursAndMinutes = downlinesArrivalTime1.components(separatedBy: ":")
        let downlinesArrivalHour = Int(downlinesArrivalHoursAndMinutes[0])
        let downlinesArrivalMinutes = Int(downlinesArrivalHoursAndMinutes[1])
        
        let downlinesArrivalDateComponents = NSDateComponents()
        downlinesArrivalDateComponents.day = downlinesArrivalDay!
        downlinesArrivalDateComponents.month = downlinesArrivalMonth!
        downlinesArrivalDateComponents.year = downlinesArrivalYear!
        downlinesArrivalDateComponents.hour = downlinesArrivalHour!
        downlinesArrivalDateComponents.minute = downlinesArrivalMinutes!
        
        //Turns downlines departure date into an actual date using date components
        var downlinesDepartureDateArray = downlinesDepartureDate.components(separatedBy: "T")
        let downlinesDepartureDateSegment = downlinesDepartureDateArray[0]
        var downlinesDepartureDateSplitArray = downlinesDepartureDateSegment.components(separatedBy: "-")
        let downlinesDepartureYear = Int(downlinesDepartureDateSplitArray[0])
        let downlinesDepartureMonth = Int(downlinesDepartureDateSplitArray[1])
        let downlinesDepartureDay = Int(downlinesDepartureDateSplitArray[2])
        
        let downlinesDepartureTimeSegment = downlinesDepartureDateArray[1]
        var downlinesDepartureTimeArray = downlinesDepartureTimeSegment.components(separatedBy: ":00.000")
        let downlinesDepartureTime1 = downlinesDepartureTimeArray[0]
        var downlinesDepartureHoursAndMinutes = downlinesDepartureTime1.components(separatedBy: ":")
        let downlinesDepartureHour = Int(downlinesDepartureHoursAndMinutes[0])
        let downlinesDepartureMinutes = Int(downlinesDepartureHoursAndMinutes[1])
        
        let downlinesDepartureDateComponents = NSDateComponents()
        downlinesDepartureDateComponents.day = downlinesDepartureDay!
        downlinesDepartureDateComponents.month = downlinesDepartureMonth!
        downlinesDepartureDateComponents.year = downlinesDepartureYear!
        downlinesDepartureDateComponents.hour = downlinesDepartureHour!
        downlinesDepartureDateComponents.minute = downlinesDepartureMinutes!
        
        if downlinesArrivalHour! >= 13 && downlinesDepartureHour! <= 12 {
            
            let correctedDownlineDepartureDate = downlinesDepartureDateFormatted?.addingTimeInterval(86400)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            let correctedDownlineDepartureDateString = dateFormatter.string(from: correctedDownlineDepartureDate!)
            
            let correctedDestinationArrivalDate = destinationArrivalDateFormatted?.addingTimeInterval(86400)
            let correctedDestinationArrivalDateString = dateFormatter.string(from: correctedDestinationArrivalDate!)
            
            return(correctedDownlineDepartureDateString, correctedDestinationArrivalDateString)
            
        } else if downlinesDepartureDateFormatted! < downlinesArrivalDateFormatted! {
            
            let correctedDownlineDepartureDate = downlinesDepartureDateFormatted?.addingTimeInterval(86400)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            let correctedDownlineDepartureDateString = dateFormatter.string(from: correctedDownlineDepartureDate!)
            
            let correctedDestinationArrivalDate = destinationArrivalDateFormatted?.addingTimeInterval(86400)
            let correctedDestinationArrivalDateString = dateFormatter.string(from: correctedDestinationArrivalDate!)
            
            return(correctedDownlineDepartureDateString, correctedDestinationArrivalDateString)
            
        } else {
            
            return(downlinesDepartureDate, destinationArrivalDate)
        }
        
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let autoCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        autoCell.textLabel?.text = autoComplete[indexPath.row]
        return autoCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.autoComplete.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell:UITableViewCell! = tableView.cellForRow(at: indexPath)!
        let selectedCellString = String("\(selectedCell.textLabel!.text!)")
        let cellArray = selectedCellString?.components(separatedBy: "- ")
        let airlineCodeString = cellArray?[1]
        self.airlineCode.text = airlineCodeString
        self.flightNumber.becomeFirstResponder()
        autoSuggestTable.isHidden = true
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.flightNumber {
            
           autoSuggestTable.isHidden = true
            
        } else if textField == self.airlineCode {
            
            let substring = (airlineCode.text! as NSString).replacingCharacters(in: range, with: string)
            autoSuggestTable.isHidden = false
            searchAutoCompleteEntriesWithSubstrings(substring: substring)
            
            
        }
        
        return true
        
    }
    
    func searchAutoCompleteEntriesWithSubstrings(substring: String) {
        
        autoComplete.removeAll(keepingCapacity: false)
        
        for key in self.autoCompletePossibilitiesArray {
            
            let myString:NSString = key as NSString
            let substringRange:NSRange! = myString.range(of: substring)
            
            if (substringRange.location == 0) {
                
                autoComplete.append(key)
                
            }
        }
        
        if autoComplete.count == 0 {
            
            self.autoSuggestTable.isHidden = true
        }
        
        self.autoSuggestTable.reloadData()
    }
    
    func getAirlineCodes() {
        
        self.activityLabel.text = "Loading"
        addActivityIndicatorCenter()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = URL(string: "https://api.flightstats.com/flex/airlines/rest/v1/json/active?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87")!
        
        let airlineTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                print(error as Any)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let airlineJsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        var airlineName = ""
                        var airlineIcao = ""
                        var airlineIata = ""
                        
                        if let airlines = airlineJsonResult["airlines"] as? NSArray {
                            
                            if airlines.count > 1 {
                                
                                for airline in airlines {
                                    
                                    let airlineDictionary = airline as! NSDictionary
                                    
                                    airlineName = airlineDictionary["name"] as! String
                                    
                                    if let icaoCheck = airlineDictionary["icao"] as? String {
                                        
                                        airlineIcao = icaoCheck
                                        
                                    }
                                    
                                    if let iataCheck = airlineDictionary["iata"] as? String {
                                        
                                        airlineIata = iataCheck
                                        
                                    }
                                    
                                    if airlineIcao != "" {
                                        
                                       self.autoCompletePossibilitiesArray.append("\(airlineName.lowercased()) - \(airlineIcao)")
                                    }
                                    
                                    if airlineIata != "" {
                                        
                                    self.autoCompletePossibilitiesArray.append("\(airlineName.lowercased()) - \(airlineIata)")
                                        
                                    }
                                    
                                    
                                }
                                
                                self.autoCompletePossibilitiesArray = self.autoCompletePossibilitiesArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                                
                                UserDefaults.standard.set(self.autoCompletePossibilitiesArray, forKey: "airlines")
                                
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.activityLabel.removeFromSuperview()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                     } catch {
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            self.activityLabel.removeFromSuperview()
                            self.blurEffectViewActivity.removeFromSuperview()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            
                        }
                        print("JSON Processing Failed")
                        
                    }
                    
                }
                
            }
            
        }
        
        airlineTask.resume()
        
    }
    
    @IBAction func backToAddFlight(segue:UIStoryboardSegue) {
    }
    


}
