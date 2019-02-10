//
//  NearMeViewController.swift
//  TripKey2
//
//  Created by Peter on 2/1/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import MapKit
import Parse
import StoreKit
import Foundation
import WatchConnectivity
import UserNotifications

class NearMeViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate, UISearchBarDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    var flightArray = [[String:Any]]()
    let liveFlightMarker = GMSMarker()
    let nextFlightButton = UIButton()
    var didTapMarker = Bool()
    var usersLocationMode:Bool!
    var showArrivalWindow = false
    var session: WCSession?
    var userMarkerArray:[GMSMarker] = []
    var howManyTimesUsed:[Int]! = []
    var infoWindowIsVisible = false
    var usersHeading:Double!
    var showUsersButton = UIButton(type: .custom)
    var fitFlightsButton = UIButton(type: .custom)
    var flightIndex:Int! = 0
    var bearing:Double!
    var iconZoom:Float!
    var position:CLLocationCoordinate2D!
    var icon:UIImage!
    var overlay:GMSGroundOverlay!
    var flightIDString:String!
    let arrivalInfoWindow = Bundle.main.loadNibNamed("Arrival Info Window", owner: self, options: nil)?[0] as! ArrivalInfoWindow
    let blurEffectViewFlightInfoWindow = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewFlightInfoWindowBottom = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewFlightInfoWindowTop = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    var ascending = true
    var descending = false
    var attributedTextArray:[NSAttributedString]! = []
    var swiping = false
    var swipingPic = false
    let PREMIUM_PRODUCT_ID = "com.TripKeyLite.unlockPremium"
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    let recognizer = UITapGestureRecognizer()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    //var name:String!
    var users = [String: String]()
    var userNames = [String]()
    var website:String!
    var phoneNumberString:String!
    var tappedMarkerIndex:Int!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var topView: UIView!
    var resultsArray = [String]()
    var searchBar = UISearchBar()
    var searchButton = UIButton(type: .custom)
    var actualTakeOff:String!
    var departureMarkerArray:[GMSMarker] = []
    var arrivalMarkerArray:[GMSMarker] = []
    var routePolyline:GMSPolyline!
    var routePolylineArray:[GMSPolyline] = []
    var flightCode:String!
    var flightNumber:String!
    var flight:String!
    var departureMarker:GMSMarker!
    var arrivalMarker:GMSMarker!
    var tappedMarker:GMSMarker!
    var googleMapsView:GMSMapView!
    var bounds = GMSCoordinateBounds()
    var airportBounds = GMSCoordinateBounds()
    var activityIndicator:UIActivityIndicatorView!
    var airlineCodeURL:String!
    var flightNumberURL:String!
    var departureDateURL:String!
    var departureAirportCodeURL:String!
    var flightStatusFormatted:String!
    var flightStatusUnformatted:String!
    var timer:Timer!
    weak var arrivalInfoWindowTimer:Timer?
    weak var departureInfoWindowTimer:Timer?
    var currentDateWhole:String!
    var publishedDeparture:String!
    var actualDeparture:String!
    var publishedArrival:String!
    var actualArrival:String!
    var flightId:Double! = 0
    var flightEstimatedArrivalString:String!
    var flightActualDepartureString:String!
    var flightLanded:Bool!
    var flightTookOff:Bool!
    var userSwipedBack:Bool!
    var latitude:Double!
    var longitude:Double!
    var locationManager = CLLocationManager()
    @IBOutlet var mapView: UIView!
    var int:Int!
    var userTappedRoute:Bool!
    var trackAirplaneTimer:Timer!
    var updateFlightFirstTime:Bool!
    var tableButton = UIButton()
    
    func addCircleBlurBackground(frame: CGRect, button: UIButton) {
        
        let circleBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
        circleBlurView.removeFromSuperview()
        circleBlurView.frame = frame
        circleBlurView.clipsToBounds = true
        circleBlurView.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 5
        circleBlurView.contentView.addSubview(button)
        googleMapsView.addSubview(circleBlurView)
        circleBlurView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: {
            circleBlurView.transform = .identity
        })
    }
    
    func isUserLoggedIn() -> Bool {
        if (PFUser.current() != nil) {
            return true
        } else {
            return false
        }
    }
    
    func promptUserToLogIn() {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: NSLocalizedString("You are not logged in.", comment: ""), message: NSLocalizedString("Please log in to share flights.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: ""), style: .default, handler: { (action) in }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Log In", comment: ""), style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "logIn", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
        switch overlay.accessibilityLabel?.components(separatedBy: ", ")[0] {
        case "Airplane Location":
            self.updateFlightFirstTime = true
            let index = Int((overlay.accessibilityLabel?.components(separatedBy: ", ")[1])!)!
            let flightId = self.flightArray[index]["flightId"] as! String
            self.parseFlightIDForTracking(flightId: flightId, index: index)
        
        default:
            break
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
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
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                    }
                    break
                    
                default: break
                    
                }}}
        
    }
    
    
    
    
    func flightWasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        print("flightWasDragged")
        
        let translation = gestureRecognizer.translation(in: self.arrivalInfoWindow)
        let flightView = gestureRecognizer.view!
        flightView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        let xFromCenter = flightView.center.x - self.view.bounds.width / 2
        let yFromCenter = flightView.center.y - self.view.bounds.width / 2
        let markerLabel = (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])!
        let flight = FlightStruct(dictionary: self.flightArray[self.flightIndex])
        let arrivalLat = flight.arrivalLat
        let arrivalLon = flight.arrivalLon
        let departureLat = flight.departureLat
        let departureLon = flight.departureLon
        var newLocation:GMSCameraPosition!
        
        switch gestureRecognizer.state {
            
        case UIGestureRecognizerState.ended:
            
            if yFromCenter >= 300 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.arrivalInfoWindow.alpha = 0
                    self.blurEffectViewFlightInfoWindowBottom.alpha = 0
                    self.blurEffectViewFlightInfoWindowTop.alpha = 0
                    
                }) { _ in
                    
                    self.arrivalInfoWindow.removeFromSuperview()
                    self.blurEffectViewFlightInfoWindowTop.removeFromSuperview()
                    self.blurEffectViewFlightInfoWindowBottom.removeFromSuperview()
                    print("swiped down")
                    
                }
                
            } else if yFromCenter <= 80 {
                
                print("swiped up")
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    flightView.center = self.view.center
                    self.arrivalInfoWindow.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowTop.alpha = 1.0
                    
                })
                
            }
            
            if xFromCenter <= -50 {
                
                print("swiped left")
                
                if markerLabel == "Departure Airport" {
                    
                    print("from departure to arrival for same flight")
                    
                    self.tappedMarker = self.arrivalMarkerArray[0]
                    self.showFlightInfoWindows(flightIndex: self.flightIndex)
                    newLocation = GMSCameraPosition.camera(withLatitude: arrivalLat, longitude: arrivalLon, zoom: self.googleMapsView.camera.zoom)
                    
                    DispatchQueue.main.async {
                        CATransaction.begin()
                        CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                        self.googleMapsView.animate(to: newLocation)
                        CATransaction.commit()
                    }
                    
                    self.addFlightViewFromRightToLeft()
                        
                    } else if markerLabel == "Arrival Airport" {
                    
                        //from arrival to departure for same flight
                    
                        self.tappedMarker = self.departureMarkerArray[0]
                        self.showFlightInfoWindow(index: self.flightIndex, type: "Departure")
                        newLocation = GMSCameraPosition.camera(withLatitude: departureLat, longitude: departureLon, zoom: self.googleMapsView.camera.zoom)
                    
                        DispatchQueue.main.async {
                            CATransaction.begin()
                            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                            self.googleMapsView.animate(to: newLocation)
                            CATransaction.commit()
                        }
                    
                        self.addFlightViewFromLeftToRight()
                }
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    flightView.center = self.view.center
                    self.arrivalInfoWindow.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowTop.alpha = 1.0
                    
                })
            }
            
            if xFromCenter >= 50 {
                
                print("swiped right")
                
                if markerLabel == "Arrival Airport" {
                    
                        //from arrival to departure for same flight
                    
                        self.tappedMarker = self.departureMarkerArray[0]
                        self.showFlightInfoWindow(index: self.flightIndex, type: "Arrival")
                        newLocation = GMSCameraPosition.camera(withLatitude: departureLat, longitude: departureLon, zoom: self.googleMapsView.camera.zoom)
                    
                        DispatchQueue.main.async {
                            CATransaction.begin()
                            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                            self.googleMapsView.animate(to: newLocation)
                            CATransaction.commit()
                        }
                    
                        self.addFlightViewFromLeftToRight()
                    
                    } else {
                        
                        if markerLabel == "Departure Airport" {
                            
                            print("from departure to arrival for same flight")
                            self.tappedMarker = self.arrivalMarkerArray[0]
                            self.showFlightInfoWindows(flightIndex: self.flightIndex)
                            newLocation = GMSCameraPosition.camera(withLatitude: arrivalLat, longitude: arrivalLon, zoom: self.googleMapsView.camera.zoom)
                            
                            DispatchQueue.main.async {
                                CATransaction.begin()
                                CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                                self.googleMapsView.animate(to: newLocation)
                                CATransaction.commit()
                            }
                            
                            self.addFlightViewFromRightToLeft()
                            
                        }
                }
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    flightView.center = self.view.center
                    self.arrivalInfoWindow.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowTop.alpha = 1.0
                })
                
            }
            
        default:
            
            break
            
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            
            if flightView.center.x < (self.view.center.x - 50) {
                
                //for sliding left
                flightView.center.x =  (flightView.center.x + xFromCenter) + (self.view.frame.width / 2)
                flightView.center.y = self.view.center.y
                let percentage = translation.x/(self.view.frame.size.width / 3)
                self.arrivalInfoWindow.alpha = 1.0 - abs(percentage)
                self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0 - abs(percentage)
                self.blurEffectViewFlightInfoWindowTop.alpha = 1.0 - abs(percentage)
                
            } else if flightView.center.x > (self.view.center.x + 50) {
                
                //for sliding right
                flightView.center.x =  (flightView.center.x + xFromCenter) - (self.view.frame.width / 2)
                flightView.center.y = self.view.center.y
                let percentage = translation.x/(self.view.frame.size.width / 3)
                self.arrivalInfoWindow.alpha = 1.0 - percentage
                self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0 - percentage
                self.blurEffectViewFlightInfoWindowTop.alpha = 1.0 - percentage
                
            } else if flightView.center.y < (self.view.center.y - 50) {
                print("sliding up")
                
           } else if flightView.center.y > (self.view.center.y - 50) {
                print("sliding down")
                
                flightView.center.x = self.view.center.x
                let percentage = translation.y/(self.view.frame.size.height / 3)
                self.arrivalInfoWindow.alpha = 1.0 - percentage
                self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0 - percentage
                self.blurEffectViewFlightInfoWindowTop.alpha = 1.0 - percentage
                
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    flightView.center = self.view.center
                })
            }
        }
    }
    
    func addFlightViewFromRightToLeft() {
        
        self.view.addSubview(self.blurEffectViewFlightInfoWindowBottom)
        self.view.addSubview(self.blurEffectViewFlightInfoWindowTop)
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffectViewFlightInfoWindowTop.alpha = 1
            self.blurEffectViewFlightInfoWindowBottom.alpha = 1
        })
        UIView.animate(withDuration: 0.5, animations: {
            let transition = CATransition()
            transition.duration = 0.35
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.arrivalInfoWindow.layer.add(transition, forKey: kCATransition)
            self.view.addSubview(self.arrivalInfoWindow)
            self.arrivalInfoWindow.alpha = 1
        })
    }
    
    func addFlightViewFromLeftToRight() {
        
        self.view.addSubview(self.blurEffectViewFlightInfoWindowBottom)
        self.view.addSubview(self.blurEffectViewFlightInfoWindowTop)
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffectViewFlightInfoWindowTop.alpha = 1
            self.blurEffectViewFlightInfoWindowBottom.alpha = 1
        })
        UIView.animate(withDuration: 0.5, animations: {
            let transition = CATransition()
            transition.duration = 0.35
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.arrivalInfoWindow.layer.add(transition, forKey: kCATransition)
            self.view.addSubview(self.arrivalInfoWindow)
            self.arrivalInfoWindow.alpha = 1
        })
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func isUserInChina() -> Bool {
        let locale = Locale.current.identifier
        switch locale {
        case "zh_Hans": return true
        case "zh_Hans_CN": return true
        case "zh_Hans_MO": return true
        case "zh_Hant": return true
        case "zh_Hant_MO": return true
        case "zh": return true
        default:
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload nearMe")
        
        didTapMarker = false
        mapView.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height - 20)
        googleMapsView = GMSMapView(frame: mapView.frame)
        arrivalInfoWindow.terminalLabel.text = NSLocalizedString("Terminal", comment: "")
        arrivalInfoWindow.gateLabel.text = NSLocalizedString("Gate", comment: "")
        arrivalInfoWindow.baggageLabel.text = NSLocalizedString("Baggage", comment: "")
        blurEffectViewFlightInfoWindowBottom.alpha = 0
        blurEffectViewFlightInfoWindowTop.alpha = 0
        arrivalInfoWindow.alpha = 0
        arrivalInfoWindow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arrivalInfoWindow.topView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arrivalInfoWindow.bottomView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arrivalInfoWindow.frame = view.frame
        blurEffectViewFlightInfoWindowBottom.frame = CGRect(x: 0, y: view.frame.maxY - 140, width: view.frame.width, height: 140)
        blurEffectViewFlightInfoWindowTop.frame = CGRect(x: 0, y: view.frame.minY, width: view.frame.width, height: 180)
        arrivalInfoWindow.directions.addTarget(self, action: #selector(directionsToArrivalAirport), for: .touchUpInside)
        arrivalInfoWindow.flightAmenities.addTarget(self, action: #selector(flightAmenities), for: .touchUpInside)
        arrivalInfoWindow.share.addTarget(self, action: #selector(shareFlight), for: .touchUpInside)
        arrivalInfoWindow.call.addTarget(self, action: #selector(callAirline), for: .touchUpInside)
        arrivalInfoWindow.deleteFlight.addTarget(self, action: #selector(removeFlight), for: .touchUpInside)
        let flightDragged = UIPanGestureRecognizer(target: self, action: #selector(flightWasDragged(gestureRecognizer:)))
        arrivalInfoWindow.addGestureRecognizer(flightDragged)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        locationManager.delegate = self
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = true
        googleMapsView.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        googleMapsView.settings.rotateGestures = false
        googleMapsView.settings.tiltGestures = false
        googleMapsView.isMyLocationEnabled = true
        googleMapsView.isBuildingsEnabled = true
        googleMapsView.settings.compassButton = false
        googleMapsView.accessibilityElementsHidden = false
        googleMapsView.mapType = GMSMapViewType.hybrid
        view.addSubview(self.googleMapsView)
        addButtons()
        convertUserDefaultsToCoreData()
        isUsersFirstTime()
           
        if (PFUser.current() != nil) {
            self.userNames = getFollowedUsers()
        }
        
        if howManyTimesUsed.count % 10 == 0 {
            self.askForReview()
        }
        
    }
    
    func isUsersFirstTime() {
        
        if UserDefaults.standard.object(forKey: "howManyTimesUsed") != nil {
            howManyTimesUsed = UserDefaults.standard.object(forKey: "howManyTimesUsed") as? [Int]
            howManyTimesUsed.append(1)
            UserDefaults.standard.set(howManyTimesUsed, forKey: "howManyTimesUsed")
        } else {
            howManyTimesUsed.append(1)
            UserDefaults.standard.set(howManyTimesUsed, forKey: "howManyTimesUsed")
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Add flights?" , message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "goToAddFlights", sender: self)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func convertUserDefaultsToCoreData() {
        print("convertUserDefaultsToCoreData")
        
        if UserDefaults.standard.object(forKey: "flights") != nil {
            
            let flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
            
            var convertedSuccessfully = true
            
            for flight in flights {
                
                let id = flight["Published Departure"]! + flight["Airline Code"]! + flight["Flight Number"]!
                
                let success = saveFlight(viewController: self,
                                         departureAirport: flight["Departure Airport Code"]!,
                                         departureLat: Double(flight["Airport Departure Latitude"]!)!,
                                         departureLon: Double(flight["Airport Departure Longitude"]!)!,
                                         arrivalLat: Double(flight["Airport Arrival Latitude"]!)!,
                                         arrivalLon: Double(flight["Airport Arrival Longitude"]!)!,
                                         airlineCode: flight["Airline Code"]!,
                                         arrivalAirportCode: flight["Arrival Airport Code"]!,
                                         arrivalCity: flight["Arrival City"]!,
                                         arrivalDate: flight["Published Arrival"]!,
                                         arrivalGate: flight["Arrival Gate"]!,
                                         arrivalTerminal: flight["Airport Arrival Terminal"]!,
                                         arrivalUtcOffset: Double(flight["Arrival Airport UTC Offset"]!)!,
                                         baggageClaim: flight["Baggage Claim"]!,
                                         departureCity: flight["Departure City"]!,
                                         departureGate: flight["Departure Gate"]!,
                                         departureTerminal: flight["Airport Departure Terminal"]!,
                                         departureTime: flight["Published Departure"]!,
                                         departureUtcOffset: Double(flight["Departure Airport UTC Offset"]!)!,
                                         flightDuration: flight["Flight Duration Scheduled"]!,
                                         flightNumber: flight["Flight Number"]!,
                                         flightStatus: flight["Flight Status"]!,
                                         primaryCarrier: flight["Primary Carrier"]!,
                                         flightEquipment: flight["Updated Flight Equipment"]!,
                                         identifier: id,
                                         phoneNumber: flight["Phone Number"]!,
                                         publishedDepartureUtc: flight["Published Departure UTC"]!,
                                         urlArrivalDate: flight["URL Arrival Date"]!,
                                         publishedDeparture: flight["Published Departure"]!,
                                         publishedArrival: flight["Published Arrival"]!)
                
                if success {
                    print("succesfully converted flight dict to coredata")
                } else {
                    print("fail")
                    convertedSuccessfully = false
                }
            }
            
            if convertedSuccessfully {
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: "flights")
                    self.flightArray = getFlightArray()
                    //self.sortFlightsbyDepartureDate()
                    self.resetFlightZeroViewdidappear()
                }
            }
            
            showFlightOrUserLocation()
            
        } else {
            
            self.flightArray = getFlightArray()
            //self.sortFlightsbyDepartureDate()
            showFlightOrUserLocation()
        }
    }
    
    func showFlightOrUserLocation() {
        if flightArray.count > 0 {
            self.flightIndex = 0
            self.resetFlightZeroViewdidappear()
        } else {
            if let longitude = UserDefaults.standard.object(forKey: "usersLongitude") {
                let latitude = UserDefaults.standard.object(forKey: "usersLatitude")
                let userLocation = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
                CATransaction.begin()
                CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                self.googleMapsView.animate(toLocation: userLocation)
                CATransaction.commit()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.liveFlightMarker.map = nil
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("viewdidappear")
        
        flightArray = getFlightArray()
        getSharedFlights()
        userNames = getFollowedUsers()
        
        if flightArray.count > 0 {
                
            for (index, flight) in flightArray.enumerated() {
                parseLeg2Only(dictionary: flight, index: index)
            }
            if let swipedBack = UserDefaults.standard.object(forKey: "userSwipedBack") as? Bool {
                if swipedBack {
                    self.resetFlightZeroViewdidappear()
                }
            }
        }
        
        if UserDefaults.standard.object(forKey: "userSwipedBack") == nil {
            UserDefaults.standard.set(false, forKey: "userSwipedBack")
        }
        if UserDefaults.standard.object(forKey: "userSwipedBack") as! Bool == true {
            UserDefaults.standard.set(false, forKey: "userSwipedBack")
        }
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            if let followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as? [Dictionary<String,Any>] {
                
                for user in followedUsers {
                    
                    let success = saveFollowedUserToCoreData(viewController: self, username: user["Username"] as! String)
                    
                    if success {
                        UserDefaults.standard.removeObject(forKey: "followedUsernames")
                        self.userNames = getFollowedUsers()
                    }
                    
                }
                
            } else {
                
                self.userNames = getFollowedUsers()
                
            }
        }
    }
    
   func askForReview() {
    
        DispatchQueue.main.async {
            if #available( iOS 10.3,*){
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    func removeButtons() {
        
       UIView.animate(withDuration: 0.5, animations: {
            self.fitFlightsButton.alpha = 0
            self.showUsersButton.alpha = 0
            self.tableButton.alpha = 0
        }) { _ in
            self.fitFlightsButton.removeFromSuperview()
            self.showUsersButton.removeFromSuperview()
            self.tableButton.removeFromSuperview()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.liveFlightMarker.map = nil
        
        switch segue.identifier {
        case "goToTable":
            if let vc = segue.destination as? FlightTableNewViewController {
                vc.userNames = self.userNames
                vc.flightArray = getFlightArray()
            }
        case "seatGuru":
            if let vc = segue.destination as? SeatGuruViewController {
                vc.selectedFlight = self.flightArray[self.flightIndex]
            }
        case "Show User Feed":
            if let vc = segue.destination as? CommunityFeedViewController {
                vc.flightArray = self.flightArray
                vc.userNames = self.userNames
            }
        case "goToAddFlights":
            if let vc = segue.destination as? FlightDetailsViewController {
                vc.flightArray = self.flightArray
            }
        default:
            break
        }
        
    }
    
    func updateLabelText() {
        
        if self.flightIndex + 1 == self.flightArray.count {
            DispatchQueue.main.async {
                self.nextFlightButton.setTitle("Show First Flight", for: .normal)
            }
        } else {
            DispatchQueue.main.async {
                self.nextFlightButton.setTitle("Show Next Flight", for: .normal)
            }
        }
        if self.flightArray.count == 1 {
            DispatchQueue.main.async {
                self.nextFlightButton.setTitle("Update Flight", for: .normal)
            }
        } else if flightArray.count == 0 {
            DispatchQueue.main.async {
                self.nextFlightButton.setTitle("Add a Flight", for: .normal)
            }
        }
    }
    
    @objc func nextFlight() {
        
        self.liveFlightMarker.map = nil
        
        if self.flightArray.count == 0 {
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToAddFlights", sender: self)
            }
            
        } else if self.flightArray.count > self.flightIndex + 1 {
            
            parseLeg2Only(dictionary: self.flightArray[self.flightIndex + 1], index: self.flightIndex + 1)
            self.getAirportCoordinates(flight: self.flightArray[self.flightIndex + 1], index: self.flightIndex + 1)
            self.flightIndex = self.flightIndex + 1
            updateLabelText()
            
        } else if self.flightArray.count == self.flightIndex + 1 {
            
            self.flightIndex = 0
            parseLeg2Only(dictionary: self.flightArray[self.flightIndex], index: self.flightIndex)
            self.getAirportCoordinates(flight: self.flightArray[self.flightIndex], index: self.flightIndex)
            updateLabelText()
            
        }
    }
    
    func addButtons() {
        
        tableButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        let tableButtonImage = UIImage(named: "whiteList.png")
        tableButton.setImage(tableButtonImage, for: .normal)
        tableButton.backgroundColor = UIColor.clear
        tableButton.layer.cornerRadius = 28
        tableButton.addTarget(self, action: #selector(showTable), for: .touchUpInside)
        let tableButtonFrame = CGRect(x: 10, y: 10, width: 50, height: 50)
        addCircleBlurBackground(frame: tableButtonFrame, button: tableButton)
        
        showUsersButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        let showUsersButtonImage = UIImage(named: "whiteCommunity.png")
        showUsersButton.setImage(showUsersButtonImage, for: .normal)
        showUsersButton.backgroundColor = UIColor.clear
        showUsersButton.layer.cornerRadius = 28
        showUsersButton.addTarget(self, action: #selector(showUsers), for: .touchUpInside)
        let usersButtonFrame = CGRect(x: googleMapsView.bounds.maxX - 60, y: 10, width: 50, height: 50)
        addCircleBlurBackground(frame: usersButtonFrame, button: showUsersButton)
        
        fitFlightsButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        let image = UIImage(named: "white-plus.png")
        fitFlightsButton.setImage(image, for: .normal)
        fitFlightsButton.backgroundColor = UIColor.clear
        fitFlightsButton.layer.cornerRadius = 28
        fitFlightsButton.addTarget(self, action: #selector(fitAirports), for: .touchUpInside)
        let fitFlightsFrame = CGRect(x: googleMapsView.frame.maxX - 60, y: googleMapsView.frame.maxY - 80, width: 50, height: 50)
        addCircleBlurBackground(frame: fitFlightsFrame, button: fitFlightsButton)
        
        let circleView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
        circleView.frame = CGRect(x: (googleMapsView.bounds.maxX / 2) - 70, y: googleMapsView.bounds.maxY - 55, width: 140, height: 35)
        circleView.clipsToBounds = true
        circleView.layer.cornerRadius = 18
        nextFlightButton.frame = CGRect(x: 0, y: 0, width: 140, height: 35)
        if flightArray.count == 0 {
            nextFlightButton.setTitle("Add Flight", for: .normal)
        } else if flightArray.count == 1 {
            nextFlightButton.setTitle("Update Flight", for: .normal)
        } else {
            nextFlightButton.setTitle("Next Flight", for: .normal)
        }
        nextFlightButton.addTarget(self, action: #selector(nextFlight), for: .touchUpInside)
        nextFlightButton.setTitleColor(UIColor.white, for: .normal)
        nextFlightButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Thin", size: 15)
        nextFlightButton.backgroundColor = UIColor.clear
        nextFlightButton.showsTouchWhenHighlighted = true
        googleMapsView.addSubview(circleView)
        circleView.contentView.addSubview(nextFlightButton)
        circleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: {
            circleView.transform = .identity
        })
     }
    
    @objc func showTable() {
        if flightArray.count > 0 {
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToTable", sender: self)
            }
        } else {
            
            displayAlert(viewController: self, title: "No Flights", message: "You havent added a flight yet, tap the plus button to get started.")
        }
        
    }
    
    func showUsers() {
        
        if self.isUserLoggedIn() {
            self.goToUserFeed()
        } else {
            self.promptUserToLogIn()
        }
    }
    
    func goToUserFeed() {
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Show User Feed", sender: self)
        }
    }
    
    func fitAirports() {
        
        print("fitAirports()")
        
        self.performSegue(withIdentifier: "goToAddFlights", sender: self)
        
        DispatchQueue.main.async {
            var bounds = GMSCoordinateBounds()
            
            for marker in self.departureMarkerArray {
                bounds = bounds.includingCoordinate(marker.position)
            }
            
            for marker in self.arrivalMarkerArray {
                bounds = bounds.includingCoordinate(marker.position)
            }
            
            CATransaction.begin()
            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
            CATransaction.commit()
        }
        
        
    }
    
    func goNearMe() {
        
        //check for permissions
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        
                        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
               }
                
                self.locationManager.startUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                
            case .authorizedAlways:
                
                self.locationManager.startUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                
                if self.latitude != nil {
                    
                    let userPosition = CLLocationCoordinate2DMake(self.latitude, self.longitude)
                    var cameraPosition:GMSCameraPosition!
                    
                    if self.usersHeading != nil {
                        
                        cameraPosition = GMSCameraPosition(target: userPosition, zoom: 18, bearing: self.usersHeading, viewingAngle: 45)
                        
                    } else {
                        
                        cameraPosition = GMSCameraPosition(target: userPosition, zoom: 18, bearing: 0, viewingAngle: 45)
                    }
                    
                    CATransaction.begin()
                    CATransaction.setValue(Int(1.5), forKey: kCATransactionAnimationDuration)
                    googleMapsView.animate(to: cameraPosition)
                    CATransaction.commit()
                }
                
            case .authorizedWhenInUse:
                
                self.locationManager.startUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                
                if self.latitude != nil {
                    
                    let userPosition = CLLocationCoordinate2DMake(self.latitude, self.longitude)
                    var cameraPosition:GMSCameraPosition!
                    
                    if self.usersHeading != nil {
                        
                        cameraPosition = GMSCameraPosition(target: userPosition, zoom: 18, bearing: self.usersHeading, viewingAngle: 45)
                        
                    } else {
                        
                        cameraPosition = GMSCameraPosition(target: userPosition, zoom: 18, bearing: 0, viewingAngle: 45)
                    }
                    
                    CATransaction.begin()
                    CATransaction.setValue(Int(1.5), forKey: kCATransactionAnimationDuration)
                    googleMapsView.animate(to: cameraPosition)
                    CATransaction.commit()
                    
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.usersHeading = newHeading.trueHeading
        locationManager.stopUpdatingHeading()
    }
    
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
       if locations.count > 0 {
            let location = locations.last
            let longitude = location?.coordinate.longitude
            let latitude = location?.coordinate.latitude
            self.longitude = longitude
            self.latitude = latitude
            UserDefaults.standard.set(latitude, forKey: "usersLatitude")
            UserDefaults.standard.set(longitude, forKey: "usersLongitude")
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        let zoom = Float(mapView.camera.zoom)
        self.iconZoom = zoom
        if zoom <= 8 {
           DispatchQueue.main.async {
                self.updateLines()
            }
        } else if zoom > 8 {
            DispatchQueue.main.async {
                for polyline in self.routePolylineArray {
                    polyline.map = nil
                }
            }
        }
     }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let markerLabel = (marker.accessibilityLabel?.components(separatedBy: " - ")[0])!
        let flightTrackMarker = (marker.accessibilityLabel?.components(separatedBy: ", ")[0])!
        
        if  markerLabel == "Departure Airport" || markerLabel == "Arrival Airport" {
            
            let index = Int((marker.accessibilityLabel?.components(separatedBy: " - ")[1])!)!
            self.didTapMarker = true
            self.userTappedRoute = false
            self.flightIndex = index
            parseLeg2Only(dictionary: self.flightArray[self.flightIndex], index: self.flightIndex)
            self.tappedMarker = marker
            let tappedMarkerLatitude = marker.position.latitude
            let tappedMarkerLongitude = marker.position.longitude
            let tappedCoordinates = CLLocationCoordinate2D(latitude: tappedMarkerLatitude, longitude: tappedMarkerLongitude)
            let newPosition = GMSCameraPosition(target: tappedCoordinates, zoom: 6, bearing: self.googleMapsView.camera.bearing, viewingAngle: self.googleMapsView.camera.viewingAngle)
            CATransaction.begin()
            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
            self.googleMapsView.animate(to: newPosition)
            CATransaction.commit()
            self.showFlightInfoWindows(flightIndex: self.flightIndex)
            self.addFlightViewFromRightToLeft()
            
           return false
           
        } else if flightTrackMarker == "Airplane Location" {
            
            let index = Int((marker.accessibilityLabel?.components(separatedBy: ", ")[1])!)!
            let flightId = self.flightArray[index]["flightId"] as! String
            self.parseFlightIDForTracking(flightId: flightId, index: index)
            
            return false
            
        }
        
        return false
    }
    
    func callAirline() {
        let flight = FlightStruct(dictionary: self.flightArray[self.flightIndex])
        let phoneNumber = flight.phoneNumber
        self.phoneNumberString = phoneNumber
        self.callPlace()
    }
    
    func callPlace() {
        
        print("callPlace()")
        if self.phoneNumberString != "" {
            
            let formattedPhoneNumber = self.phoneNumberString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            let url = URL(string: "tel://+\(formattedPhoneNumber)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        } else {
            
            DispatchQueue.main.async {
                displayAlert(viewController: self, title: NSLocalizedString("No phone number given", comment: ""), message: "")
            }
        }
    }
    
    /*func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        userTappedRoute = false
        if self.trackAirplaneTimer != nil {
            if (self.trackAirplaneTimer?.isValid)! {
                DispatchQueue.main.async {
                    self.trackAirplaneTimer?.invalidate()
                    self.trackAirplaneTimer = nil
                }
            }
        }
    }*/
    
    func resetTimers() {
        
        DispatchQueue.main.async {
            if self.departureInfoWindowTimer != nil {
                if (self.departureInfoWindowTimer?.isValid)! {
                    self.departureInfoWindowTimer?.invalidate()
                    self.departureInfoWindowTimer = nil
                }
            }
            if self.arrivalInfoWindowTimer != nil {
                if (self.arrivalInfoWindowTimer?.isValid)! {
                    self.arrivalInfoWindowTimer?.invalidate()
                    self.arrivalInfoWindowTimer = nil
                }
            }
        }
    }
    
    func addActivityIndicatorCenter() {
        
        activityLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        activityLabel.center = CGPoint(x: self.view.frame.width/2 , y: self.view.frame.height/1.815)
        activityLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        activityLabel.textColor = UIColor.white
        activityLabel.textAlignment = .center
        activityLabel.alpha = 0
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.isUserInteractionEnabled = true
        activityIndicator.startAnimating()
        activityIndicator.alpha = 0
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
    
    func parseFlightID(dictionary: [String:Any], index: Int) {
        
        print("parseFlightID")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let flight = FlightStruct(dictionary: dictionary)
        let flightId = flight.flightId
        let id = flight.identifier
        
        let url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + flightId + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
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
                                    let flightStatusFormatted = formatFlightStatus(flightStatusUnformatted: flightStatusUnformatted)
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
                                                    
                                                    self.parseFlightID(dictionary: self.flightArray[index], index: index)
                                                    
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
                                            
                                            let departureDate = flight.departureDate
                                            let utcOffset = flight.departureUtcOffset
                                            let departureCity = flight.departureCity
                                            let arrivalCity = flight.arrivalCity
                                            let arrivalDate = flight.arrivalDate
                                            let arrivalOffset = flight.arrivalUtcOffset
                                            
                                            let departingTerminal = flight.departureTerminal
                                            let departingGate = flight.departureGate
                                            let departingAirport = flight.departureAirport
                                            let arrivalAirport = flight.arrivalAirportCode
                                            let flightNumber = flight.flightNumber
                                            
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
                                        
                                        if flightStatusFormatted == "Departed" {
                                            self.updateFlightFirstTime = true
                                            DispatchQueue.main.async {
                                                self.parseFlightIDForTracking(flightId: flightId, index: index)
                                            }
                                        }
                                    }
                                    
                                    if self.didTapMarker {
                                        self.showFlightInfoWindows(flightIndex: self.flightIndex)
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
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } catch {
                
                self.activityIndicator.stopAnimating()
                self.blurEffectViewActivity.removeFromSuperview()
                self.activityLabel.removeFromSuperview()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("Error parsing")
            }
            
        }
        
        task.resume()
    }
    
    
    
    func directionsToArrivalAirport() {
        print("directionsToArrivalAirport")
        
        //check location permission
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case.notDetermined:
                
                self.locationManager.requestWhenInUseAuthorization()
                
            case .restricted, .denied:
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "In order for the places feature to work TripKey needs to know your current location. Please tap settings and update the location permission for TripKey.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        
                        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            case .authorizedAlways, .authorizedWhenInUse:
                
            let flight = FlightStruct(dictionary: self.flightArray[self.flightIndex])
            var name = String()
            var lat = Double()
            var lon = Double()
            
            switch (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! {
            case "Departure Airport":
                lon = flight.departureLon
                lat = flight.departureLat
                name = flight.departureAirport
            case "Arrival Airport":
                lon = flight.arrivalLon
                lat = flight.arrivalLat
                name = flight.arrivalAirportCode
            default:
                break
            }
            
            if longitude != 0 && latitude != 0 {
                
                let coordinate = CLLocationCoordinate2DMake(latitude,longitude)
                
                
                if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Which map would you like to use?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Apple Maps", comment: ""), style: .default, handler: { (action) in
                        
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                        mapItem.name = name
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Google Maps", comment: ""), style: .default, handler: { (action) in
                        
                        
                        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(lat),\(lon)&directionsmode=driving")
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    NSLog("Can't use comgooglemaps://")
                    
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                    mapItem.name = name
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                }
                
                break
                
                }
            }
        }
   }
    
    func flightAmenities() {
        
        let flight = FlightStruct(dictionary: self.flightArray[self.flightIndex])
        let departureDate = flight.publishedDeparture
        let utcOffset = flight.departureUtcOffset
        let didFlightTakeOff = didFlightAlreadyTakeoff(departureDate: departureDate, utcOffset: utcOffset)
                    
        if didFlightTakeOff == true {
                        
            let alert = UIAlertController(title: NSLocalizedString("Flight was scheduled to have already taken off.", comment: ""), message: NSLocalizedString("Please add a future flight to check for amenities", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
                        
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                        
                self.present(alert, animated: true, completion: nil)
                        
        } else {
                        
            self.performSegue(withIdentifier: "seatGuru", sender: self)
                        
        }
                    
    }
    
    @objc func removeFlight() {
        print("removeFlight")
        
        let flight = FlightStruct(dictionary: self.flightArray[self.flightIndex])
        let publishedDeparture = flight.publishedDeparture
        let publishedArrival = flight.publishedArrival
        let flightnumber = flight.flightNumber
        let identifier  = flight.identifier
        let center = UNUserNotificationCenter.current()
        let prefix = flightnumber + publishedDeparture
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete flight \(flightnumber)", comment: ""), style: .destructive, handler: { (action) in
                
                center.delegate = self as? UNUserNotificationCenterDelegate
                center.getPendingNotificationRequests(completionHandler: { (notifications) in
                    
                    for notification in notifications {
                        
                        let id = notification.identifier
                        
                        if self.flightArray.count > 0 {
                            
                            switch id {
                            case "\(prefix)1HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(prefix)2HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(prefix)4HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(prefix)48HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(prefix)TakeOffNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(flightnumber)\(publishedArrival)LandingNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            default:
                                break
                            }
                        }
                    }
                    
                    deleteFlight(viewController: self, flightIdentifier: identifier)
                    self.flightArray = getFlightArray()
                    
                    DispatchQueue.main.async {
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            self.blurEffectViewFlightInfoWindow.alpha = 0
                            self.arrivalInfoWindow.alpha = 0
                            self.blurEffectViewFlightInfoWindowBottom.alpha = 0
                            self.blurEffectViewFlightInfoWindowTop.alpha = 0
                        }) { _ in
                            self.blurEffectViewFlightInfoWindow.removeFromSuperview()
                            self.arrivalInfoWindow.removeFromSuperview()
                            self.blurEffectViewFlightInfoWindowTop.removeFromSuperview()
                            self.blurEffectViewFlightInfoWindowBottom.removeFromSuperview()
                            self.infoWindowIsVisible = false
                        }
                    }
                    
                    if self.flightArray.count > 0 {
                        
                        self.resetFlightZeroViewdidappear()
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            self.nextFlightButton.setTitle("Add a Flight", for: .normal)
                            
                            for marker in self.departureMarkerArray {
                                marker.map = nil
                            }
                            
                            for marker in self.arrivalMarkerArray {
                                marker.map = nil
                            }
                            
                            for route in self.routePolylineArray {
                                route.map = nil
                            }
                            self.routePolylineArray.removeAll()
                            
                        }
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func shareFlight() {
        
        print("shareflight")
        
        if self.isUserLoggedIn() {
            
                let alert = UIAlertController(title: NSLocalizedString("Share flight with", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                for user in self.userNames {
                    
                    alert.addAction(UIAlertAction(title: " \(user)", style: .default, handler: { (action) in
                        
                        
                        //let flight = self.flightArray[self.flightIndex]
                        let flight = FlightStruct(dictionary: self.flightArray[self.flightIndex])
                        let departureAirport = flight.departureAirport
                        let departureCity = flight.departureCity
                        let arrivalAirport = flight.arrivalAirportCode
                        let arrivalCity = flight.arrivalCity
                        let departureDate = convertDateTime(date: flight.departureDate)
                        let flightNumber = flight.flightNumber
                        let arrivalDate = convertDateTime(date: flight.arrivalDate)
                        self.activityLabel.text = "Sharing"
                        
                        
                        let sharedFlight = PFObject(className: "SharedFlight")
                        
                        sharedFlight["shareToUsername"] = user
                        sharedFlight["shareFromUsername"] = PFUser.current()?.username
                        sharedFlight["flightDictionary"] = self.flightArray[self.flightIndex]
                        
                        sharedFlight.saveInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    self.activityLabel.removeFromSuperview()
                                }
                                
                                
                                let alert = UIAlertController(title: NSLocalizedString("Could not share flight", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    self.activityLabel.removeFromSuperview()
                                }
                                
                                let alert = UIAlertController(title: "\(NSLocalizedString("Flight shared to " , comment: ""))\(user)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                
                                let getUserFCM = PFUser.query()
                                
                                getUserFCM?.whereKey("username", equalTo: user)
                                
                                getUserFCM?.findObjectsInBackground { (tokens, error) in
                                    
                                    if error != nil {
                                        
                                        print("error = \(String(describing: error))")
                                        
                                    } else {
                                        
                                        for token in tokens! {
                                            
                                            if let fcmToken = token["firebaseToken"] as? String {
                                                
                                                let username = (PFUser.current()?.username)!
                                                
                                                if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
                                                    
                                                    var request = URLRequest(url: url)
                                                    request.allHTTPHeaderFields = ["Content-Type":"application/json", "Authorization":"key=AAAASkgYWy4:APA91bFMTuMvXfwcVJbsKJqyBitkb9EUpvaHOkciT5wvtVHsaWmhxfLpqysRIdjgRaEDWKcb9tD5WCvqz67EvDyeSGswL-IEacN54UpVT8bhK1iAvKDvicOge6I6qaZDu8tAHOvzyjHs"]
                                                    request.httpMethod = "POST"
                                                    request.httpBody = "{\"to\":\"\(fcmToken)\",\"priority\":\"high\",\"notification\":{\"body\":\"\(username) shared flight \(flightNumber) with you, departing on \(departureDate) from \(departureCity) (\(departureAirport)) to \(arrivalCity) \((arrivalAirport)), arriving on \(arrivalDate). Open TripKey to see more details.\"}}".data(using: .utf8)
                                                    
                                                    URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                                                        
                                                        if error != nil {
                                                            
                                                            print(error!)
                                                        } else {
                                                            print("sent notification")
                                                        }
                                                        
                                                    }).resume()
                                                    
                                                }
                                                
                                            } else {
                                                
                                                print("//user not enabled push notifications")
                                                
                                            }
                                        }
                                    }
                                }
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                        })
                        
                        
                    }))
                    
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.promptUserToLogIn()
        }
    }
    
    func showFlightInfoWindows(flightIndex: Int) {
        
        resetTimers()
        
        let index:Int = flightIndex
        if self.tappedMarker != nil && self.userTappedRoute != true {
            
            let label = (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])!
            
            if label == "Arrival Airport" {
                
                self.showFlightInfoWindow(index: index, type: "Arrival")
                
            } else if label == "Departure Airport" {
                
                self.showFlightInfoWindow(index: index, type: "Departure")
                
            }
        }
    }

    func getAirportCoordinates(flight: [String : Any], index: Int) {
        
        print("getAirportCoordinates")
        
        let currentFlight = FlightStruct(dictionary: flight)
        
            DispatchQueue.main.async {
                
                if self.flightArray.count > 1 {
                    
                    if self.flightIndex + 1 == self.flightArray.count {
                        
                        DispatchQueue.main.async {
                            self.nextFlightButton.setTitle("Show First Flight", for: .normal)
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            self.nextFlightButton.setTitle("Show Next Flight", for: .normal)
                        }
                        
                    }
                    
                } else if self.flightArray.count == 1 {
                    
                    DispatchQueue.main.async {
                        self.nextFlightButton.setTitle("Update Flight", for: .normal)
                    }
                    
                }
                
                for marker in self.departureMarkerArray {
                    marker.map = nil
                }
                
                for marker in self.arrivalMarkerArray {
                    marker.map = nil
                }
                
                self.departureMarkerArray.removeAll()
                self.arrivalMarkerArray.removeAll()
                let path = GMSMutablePath()
                let polylinePath = GMSMutablePath()
                
                if self.routePolylineArray.count > 0 {
                    for polyLine in self.routePolylineArray {
                        polyLine.map = nil
                    }
                    self.routePolylineArray.removeAll()
                }
                
                    DispatchQueue.main.async {
                        
                        var departureAirportCoordinates = CLLocationCoordinate2D()
                        var arrivalAirportCoordinates = CLLocationCoordinate2D()
                        polylinePath.removeAllCoordinates()
                        
                        let departureLongitude = currentFlight.departureLon
                        let departureLatitude = currentFlight.departureLat
                        let arrivalLongitude = currentFlight.arrivalLon
                        let arrivalLatitude = currentFlight.arrivalLat
                        departureAirportCoordinates = CLLocationCoordinate2D(latitude: departureLatitude, longitude: departureLongitude)
                        arrivalAirportCoordinates = CLLocationCoordinate2D(latitude: arrivalLatitude, longitude: arrivalLongitude)
                        
                        let flightDistanceMeters = GMSGeometryDistance(departureAirportCoordinates, arrivalAirportCoordinates)
                        let flightDistanceKilometers = Int(flightDistanceMeters / 1000)
                        let flightDistanceMiles = Int(flightDistanceMeters * 0.000621371)
                        self.arrivalInfoWindow.arrivalDistance.text = "\(flightDistanceMiles)mi (\(flightDistanceKilometers)km)"
                        
                        let departurePosition = departureAirportCoordinates
                        let arrivalPosition = arrivalAirportCoordinates
                        path.add(departurePosition)
                        path.add(arrivalPosition)
                        
                        var eastToWest = Bool()
                        if departureLongitude > arrivalLongitude {
                            eastToWest = false
                        } else {
                            eastToWest = true
                        }
                        
                        self.departureMarker = GMSMarker(position: departurePosition)
                        self.departureMarker.tracksInfoWindowChanges = true
                        self.departureMarker.appearAnimation = GMSMarkerAnimation.pop
                        
                        if eastToWest {
                            
                            self.departureMarker.groundAnchor = CGPoint(x: 1, y: 1)
                            let takeOffEastToWestImageView = UIImageView()
                            takeOffEastToWestImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
                            takeOffEastToWestImageView.image = UIImage(named: "takeOffEastToWestImage.png")
                            self.departureMarker.iconView = takeOffEastToWestImageView
                            
                        } else {
                            
                            self.departureMarker.groundAnchor = CGPoint(x: -0.1, y: 1)
                            let takeOffWestToEastImageView = UIImageView()
                            takeOffWestToEastImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
                            takeOffWestToEastImageView.image = UIImage(named: "takeOffWestToEastImage.png")
                            self.departureMarker.iconView = takeOffWestToEastImageView
                            
                        }
                        
                        self.departureMarker.isTappable = true
                        self.departureMarker.map = self.googleMapsView
                        self.departureMarker.accessibilityLabel = "Departure Airport - \(index)"
                        
                        self.arrivalMarker = GMSMarker(position: arrivalPosition)
                        self.arrivalMarker.tracksInfoWindowChanges = true
                        self.arrivalMarker.appearAnimation = GMSMarkerAnimation.pop
                        
                        if eastToWest {
                            
                            self.arrivalMarker.groundAnchor = CGPoint(x: -0.1, y: 1)
                            let landingEastToWestImageView = UIImageView()
                            landingEastToWestImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
                            landingEastToWestImageView.image = UIImage(named: "landingWestToEast.png")
                            self.arrivalMarker.iconView = landingEastToWestImageView
                            
                        } else {
                            
                            self.arrivalMarker.groundAnchor = CGPoint(x: 1, y: 1)
                            let landingWestToEastImageView = UIImageView()
                            landingWestToEastImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
                            landingWestToEastImageView.image = UIImage(named: "landingEastToWest.png")
                            self.arrivalMarker.iconView = landingWestToEastImageView
                            
                        }
                        
                        self.arrivalMarker.isTappable = true
                        self.arrivalMarker.map = self.googleMapsView
                        self.arrivalMarker.accessibilityLabel = "Arrival Airport - \(index)"
                        
                        polylinePath.add(departurePosition)
                        polylinePath.add(arrivalPosition)
                        self.routePolyline = GMSPolyline(path: polylinePath)
                        self.routePolyline.accessibilityLabel = "routePolyline, \(index)"
                        self.routePolyline.strokeWidth = 5.0
                        self.routePolyline.isTappable = true
                        self.routePolyline.geodesic = true
                        self.routePolylineArray.append(self.routePolyline)
                        
                        self.departureMarkerArray.append(self.departureMarker)
                        self.arrivalMarkerArray.append(self.arrivalMarker)
                        
                        self.routePolyline.map = self.googleMapsView
                        let styles = [GMSStrokeStyle.solidColor(.clear), GMSStrokeStyle.solidColor(.white)]
                        let scale = 1.0 / self.googleMapsView.projection.points(forMeters: 1, at: self.googleMapsView.camera.target)
                        let lengths: [Double] = [(Double(8.0 * scale)), (Double(5.0 * scale))]
                        self.routePolyline.spans = GMSStyleSpans(self.routePolyline.path!, styles, lengths as [NSNumber], GMSLengthKind.rhumb)
                    }
                
                DispatchQueue.main.async {
                    var bounds = GMSCoordinateBounds()
                    for marker in self.departureMarkerArray {
                        bounds = bounds.includingCoordinate(marker.position)
                    }
                    for marker in self.arrivalMarkerArray {
                        bounds = bounds.includingCoordinate(marker.position)
                    }
                    CATransaction.begin()
                    CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                    self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
                    CATransaction.commit()
                }
            }
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
    
    func updateLines() {
        
        if routePolylineArray.count > 0 {
            for polyLine in routePolylineArray {
                DispatchQueue.main.async {
                    polyLine.map = self.googleMapsView
                    let styles = [GMSStrokeStyle.solidColor(.clear), GMSStrokeStyle.solidColor(.white)]
                    let scale = 1.0 / self.googleMapsView.projection.points(forMeters: 1, at: self.googleMapsView.camera.target)
                    let lengths: [Double] = [(Double(8.0 * scale)), (Double(5 * scale))]
                    polyLine.spans = GMSStyleSpans(polyLine.path!, styles, lengths as [NSNumber], GMSLengthKind.rhumb)
                }
            }
        }
    }
    
    func getWeather(dictionary: [String:Any], index: Int, type: String) {
        
        print("get weather for all flights")
        let flight = FlightStruct(dictionary: dictionary)
        var lat = Double()
        var lon = Double()
        
        if type == "Departure" {
            
            lat = flight.departureLat
            lon = flight.departureLon
            
        } else if type == "Arrival" {
            
            lat = flight.arrivalLat
            lon = flight.arrivalLon
            
        }
        
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=" + "\(lat)" + "&lon=" + "\(lon)" + "&units=imperial&appid=08e64df2d3f3bc0822de1f0fc22fcb2d")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                print("error")
                print(error as Any)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if let weatherDescriptionCheck = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String {
                            
                            if let tempCheck = (jsonResult["main"] as? NSDictionary)?["temp"] as? Double {
                                let departureTemp = Int(tempCheck)
                                let departureTempCelsius = Int((tempCheck - 32) * 5/9)
                                let temperature = "\(departureTemp)°F (\(departureTempCelsius)°C)"
                                DispatchQueue.main.async {
                                    self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: self.weatherImageName(weather: weatherDescriptionCheck))
                                    self.arrivalInfoWindow.arrivalTemperature.text = temperature
                                }
                            }
                        }
                        
                    } catch {
                        print("JSON Processing Failed")
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func resetFlightZeroViewdidappear() {
        
        print("resetFlightZeroViewdidappear")
        
        DispatchQueue.main.async {
            self.liveFlightMarker.map = nil
            if self.flightArray.count > 0 {
               self.getAirportCoordinates(flight: self.flightArray[0], index: 0)
            }
        }
    }
    
    
    func parseFlightIDForTracking(flightId: String, index: Int) {
        
        print("parseFlightIDForTracking")
        
        let url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/track/\(flightId)?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87&includeFlightPlan=false&maxPositions=1&sourceType=derived")
        
       let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.blurEffectViewActivity.removeFromSuperview()
                        self.activityLabel.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonFlightTrackData = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let flightTrackDictionary = jsonFlightTrackData["flightTrack"] as? NSDictionary {
                                
                                if let bearingCheck = flightTrackDictionary["bearing"] as? Double {
                                    self.bearing = bearingCheck
                                }
                                
                                if let positionsCheck = flightTrackDictionary["positions"] as? NSArray {
                                    if positionsCheck.count > 0 {
                                        var altitude:Double!
                                        var latitude:Double!
                                        var longitude:Double!
                                        var speed:Double!
                                        
                                        if let altitudeCheck = (positionsCheck[0] as? NSDictionary)?["altitudeFt"] as? Double {
                                            altitude = altitudeCheck
                                        }
                                        
                                        if let latitudeCheck = (positionsCheck[0] as? NSDictionary)?["lat"] as? Double {
                                            latitude = latitudeCheck
                                        }
                                        
                                        if let longitudeCheck = (positionsCheck[0] as? NSDictionary)?["lon"] as? Double {
                                            longitude = longitudeCheck
                                        }
                                        
                                        if let speedCheck = (positionsCheck[0] as? NSDictionary)?["speedMph"] as? Double {
                                            speed = speedCheck
                                        }
                                        
                                        if altitude != nil && latitude != nil && longitude != nil && speed != nil {
                                            
                                            DispatchQueue.main.async {
                                                self.liveFlightMarker.map = nil
                                                self.position = CLLocationCoordinate2DMake(latitude!, longitude!)
                                                self.liveFlightMarker.position = self.position
                                                self.liveFlightMarker.appearAnimation = GMSMarkerAnimation.pop
                                                let liveFlightMarkerImageView = UIImageView()
                                                liveFlightMarkerImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
                                                liveFlightMarkerImageView.image = UIImage(named: "airplaneTrackerImage.png")
                                                self.liveFlightMarker.iconView = liveFlightMarkerImageView
                                                self.liveFlightMarker.rotation = self.bearing
                                                self.liveFlightMarker.isTappable = true
                                                self.liveFlightMarker.accessibilityLabel = "Airplane Location, \(index)"
                                                self.liveFlightMarker.map = self.googleMapsView
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
            } catch {
                print("Error parsing")
            }
        }
        task.resume()
    }
    
    @IBAction func backToNearMe(segue:UIStoryboardSegue) {}
    
    func showFlightInfoWindow(index: Int, type: String) {
        
        resetTimers()
        let flight = FlightStruct(dictionary: self.flightArray[index])
        self.getWeather(dictionary: self.flightArray[index], index: index, type: type)
        var countDownString = String()
        var offset = Double()
        let publishedDeparture = flight.publishedDeparture
        let departureOffset = flight.departureUtcOffset
        let departureDate = flight.departureDate
        let arrivalDate = flight.arrivalDate
        let arrivalOffset = flight.arrivalUtcOffset
        let flightStatus = flight.flightStatus
        let flightNumber = flight.flightNumber
        let departureCity = flight.departureCity
        let departureAirport = flight.departureAirport
        let departureTerminal = flight.departureTerminal
        let departureGate = flight.departureGate
        let arrivalCity = flight.arrivalCity
        let arrivalAirportCode = flight.arrivalAirportCode
        let arrivalTerminal = flight.arrivalTerminal
        let arrivalGate = flight.arrivalGate
        let baggageClaim = flight.baggageClaim
        let flightDuration = getFlightDuration(departureDate: departureDate,
                                               arrivalDate: arrivalDate,
                                               departureOffset: departureOffset,
                                               arrivalOffset: arrivalOffset)
        
        DispatchQueue.main.async {
            
            self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
            self.arrivalInfoWindow.flightIcon.alpha = 0.25
            
            if type == "Departure" {
                
                offset = departureOffset
                countDownString = departureDate
                self.arrivalInfoWindow.flightIcon.image = UIImage(named: "26_Airplane_take_off-512.png")
                self.arrivalInfoWindow.arrivalAirportCode.text = "\(departureCity) " + "(\(departureAirport))"
                self.arrivalInfoWindow.arrivalTerminal.text = departureTerminal
                self.arrivalInfoWindow.arrivalGate.text = departureGate
                self.arrivalInfoWindow.arrivalBaggageClaim.text = "-"
                self.arrivalInfoWindow.arrivalTime.text = convertDateTime(date: departureDate)
                
            } else {
                
                offset = arrivalOffset
                countDownString = arrivalDate
                self.arrivalInfoWindow.flightIcon.image = UIImage(named: "airplane-landing-icon-256.png")
                self.arrivalInfoWindow.arrivalAirportCode.text = "\(arrivalCity) " + "(\(arrivalAirportCode))"
                self.arrivalInfoWindow.arrivalTerminal.text = arrivalTerminal
                self.arrivalInfoWindow.arrivalGate.text = arrivalGate
                self.arrivalInfoWindow.arrivalBaggageClaim.text = baggageClaim
                self.arrivalInfoWindow.arrivalTime.text = convertDateTime(date: arrivalDate)
                
            }
            
            self.arrivalInfoWindow.arrivalFlightNumber.text = flightNumber
            self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
            self.arrivalInfoWindow.arrivalStatus.text = flightStatus
            
        }
        
        //work out whether it took off on time or late and by how much
        let departureTimeDifference = getTimeDifference(publishedTime: publishedDeparture, actualTime: departureDate)
        let departureDateNumber = formatDateTimetoWhole(dateTime: departureDate)
        let publishedDepartureDateNumber = formatDateTimetoWhole(dateTime: departureDate)
        
        if publishedDepartureDateNumber > departureDateNumber {
            
            if flightStatus != "Departed" {
                
                DispatchQueue.main.async {
                    
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departed", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                    
                }
            }
            
        } else if publishedDepartureDateNumber == departureDateNumber {
            
            if flightStatus != "Departed" {
                
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = NSLocalizedString("Departing on time", comment: "")
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = NSLocalizedString("Departed on time", comment: "")
                }
            }
            
        } else if publishedDepartureDateNumber < departureDateNumber {
            
            if flightStatus != "Departed" {
                
                DispatchQueue.main.async {
                    
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("late", comment: ""))"
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departed", comment: "")) \(departureTimeDifference) \(NSLocalizedString("late", comment: ""))"
                    
                }
            }
        }
        
        DispatchQueue.main.async {
            
            self.arrivalInfoWindow.arrivalMins.isHidden = true
            self.arrivalInfoWindow.arrivalHours.isHidden = true
            self.arrivalInfoWindow.arrivaldays.isHidden = true
            self.arrivalInfoWindow.arrivalMonths.isHidden = true
            self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
            self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
            self.arrivalInfoWindow.arrivalHoursLabel.isHidden = true
            self.arrivalInfoWindow.arrivalMinsLabel.isHidden = true
            self.arrivalInfoWindow.arrivalCoutdownView.isHidden = true
            
            self.departureInfoWindowTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                (_) in
                
                let monthsLeft = countDown(departureDate: countDownString, departureUtcOffset: offset).months
                let daysLeft = countDown(departureDate: countDownString, departureUtcOffset: offset).days
                let hoursLeft = countDown(departureDate: countDownString, departureUtcOffset: offset).hours
                let minutesLeft = countDown(departureDate: countDownString, departureUtcOffset: offset).minutes
                let secondsLeft = countDown(departureDate: countDownString, departureUtcOffset: offset).seconds
                
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalMonths.text = "\(monthsLeft)"
                    self.arrivalInfoWindow.arrivaldays.text = "\(daysLeft)"
                    self.arrivalInfoWindow.arrivalHours.text = "\(hoursLeft)"
                    self.arrivalInfoWindow.arrivalMins.text = "\(minutesLeft)"
                    self.arrivalInfoWindow.arrivalSeconds.text = "\(secondsLeft)"
                }
                
                if monthsLeft != 0 {
                   
                    self.arrivalInfoWindow.arrivalMins.isHidden = false
                    self.arrivalInfoWindow.arrivalHours.isHidden = false
                    self.arrivalInfoWindow.arrivaldays.isHidden = false
                    self.arrivalInfoWindow.arrivalMonths.isHidden = false
                    self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalMinsLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                    
                }
                
                if monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivalMins.isHidden = false
                    self.arrivalInfoWindow.arrivalHours.isHidden = false
                    self.arrivalInfoWindow.arrivaldays.isHidden = false
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalMinsLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
                
                if daysLeft == 0 && monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivaldays.isHidden = true
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                    
                    self.arrivalInfoWindow.arrivalMins.isHidden = false
                    self.arrivalInfoWindow.arrivalHours.isHidden = false
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalMinsLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
                
                if hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivalHours.isHidden = true
                    self.arrivalInfoWindow.arrivaldays.isHidden = true
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = true
                    
                    self.arrivalInfoWindow.arrivalMins.isHidden = false
                    self.arrivalInfoWindow.arrivalMinsLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
                
                if minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivalHours.isHidden = true
                    self.arrivalInfoWindow.arrivaldays.isHidden = true
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalMins.isHidden = true
                    self.arrivalInfoWindow.arrivalMinsLabel.isHidden = true
                    
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
                
                if secondsLeft == 0 && minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0  {
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = true
                } else {
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
            }
        }
    }
    
    func getSharedFlights() {
        
        if PFUser.current() != nil {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            let sharedFlightquery = PFQuery(className: "SharedFlight")
            sharedFlightquery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
            sharedFlightquery.findObjectsInBackground { (sharedFlights, error) in
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    displayAlert(viewController: self, title: "Error", message: "We had an error trying to fetch shared flights in the background, please try again later.")
                    
                } else {
                    
                    if sharedFlights != nil {
                        
                        if sharedFlights!.count > 0 {
                            
                            var sharedFromArray = [String]()
                            var sharedFlightArray = [[String:Any]]()
                            
                            for flight in sharedFlights! {
                                
                                let flightDictionary = flight["flightDictionary"]
                                let dictionary = flightDictionary as! NSDictionary
                                sharedFromArray.append(flight["shareFromUsername"] as! String)
                                sharedFlightArray.append(dictionary as! [String:Any])
                                
                                flight.deleteInBackground(block: { (success, error) in
                                    
                                    if error != nil {
                                        print("error = \(error as Any)")
                                    } else {
                                        print("flight deleted from parse database")
                                    }
                                })
                            }
                            
                            DispatchQueue.main.async {
                                
                                let unique = Array(Set(sharedFromArray))
                                var string = (unique.description).replacingOccurrences(of: "[", with: "")
                                string = string.replacingOccurrences(of: "]", with: "")
                                
                                let alert = UIAlertController(title: "\(string) has shared \(sharedFlightArray.count) flights with you." , message: "Would you like to add them to TripKey?", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                    
                                    for sharedFlight in sharedFlightArray {
                                        
                                        let flight = FlightStruct(dictionary: sharedFlight)
                                        let depLat = flight.departureLat
                                        let depLon = flight.departureLon
                                        let arrLat = flight.arrivalLat
                                        let arrLon = flight.arrivalLon
                                        let arrOffset = flight.arrivalUtcOffset
                                        let depOffset = flight.departureUtcOffset
                                        let id = flight.publishedDeparture + flight.flightNumber
                                        let depAirport = flight.departureAirport
                                        let airlineCode = flight.airlineCode
                                        let arrivalAirportCode = flight.arrivalAirportCode
                                        let arrivalCity = flight.arrivalCity
                                        let publishedArrival = flight.publishedArrival
                                        let arrivalGate = flight.arrivalGate
                                        let arrivalTerminal = flight.arrivalTerminal
                                        let baggageClaim = flight.baggageClaim
                                        let departureCity = flight.departureCity
                                        let departureGate = flight.departureGate
                                        let departureTerminal = flight.departureTerminal
                                        let publishedDeparture = flight.publishedDeparture
                                        let flightDuration = flight.flightDuration
                                        let flightNumber = flight.flightNumber
                                        let flightStatus = flight.flightStatus
                                        let primaryCarrier = flight.primaryCarrier
                                        let flightEquipment = flight.airplaneType
                                        let phoneNumber = flight.phoneNumber
                                        let publishedDepartureUtc = flight.publishedDepartureUtc
                                        let urlArrivalDate = flight.urlArrivalDate
                                        
                                        let success = saveFlight(viewController: self,
                                                                 departureAirport: depAirport,
                                                                 departureLat: depLat,
                                                                 departureLon: depLon,
                                                                 arrivalLat: arrLat,
                                                                 arrivalLon: arrLon,
                                                                 airlineCode: airlineCode,
                                                                 arrivalAirportCode: arrivalAirportCode,
                                                                 arrivalCity: arrivalCity,
                                                                 arrivalDate: publishedArrival,
                                                                 arrivalGate: arrivalGate,
                                                                 arrivalTerminal: arrivalTerminal,
                                                                 arrivalUtcOffset: arrOffset,
                                                                 baggageClaim: baggageClaim,
                                                                 departureCity: departureCity,
                                                                 departureGate: departureGate,
                                                                 departureTerminal: departureTerminal,
                                                                 departureTime: publishedDeparture,
                                                                 departureUtcOffset: depOffset,
                                                                 flightDuration: flightDuration,
                                                                 flightNumber: flightNumber,
                                                                 flightStatus: flightStatus,
                                                                 primaryCarrier: primaryCarrier,
                                                                 flightEquipment: flightEquipment,
                                                                 identifier: id,
                                                                 phoneNumber: phoneNumber,
                                                                 publishedDepartureUtc: publishedDepartureUtc,
                                                                 urlArrivalDate: urlArrivalDate,
                                                                 publishedDeparture: publishedDeparture,
                                                                 publishedArrival: publishedArrival)
                                        
                                        if success {
                                            print("succesfully converted flight dict to coredata")
                                            
                                        } else {
                                            print("fail")
                                        }
                                        
                                    }
                                    
                                    self.flightArray = getFlightArray()
                                    self.getAirportCoordinates(flight: self.flightArray[0], index: 0)
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
               }
            }
        }
    }
    
    func weatherImageName(weather: String) -> String {
        var stringToReturn = String()
        switch weather {
        case "smoke": stringToReturn = "haze_25.png"
        case "clear sky": stringToReturn = "sunny_25.png"
        case "light snow": stringToReturn = "snow_25.png"
        case "few clouds": stringToReturn = "prtly_cloudy_sun_25.png"
        case "mist": stringToReturn = "fog_mist_25.png"
        case "scattered clouds": stringToReturn = "prtly_cloudy_sun_25.png"
        case "broken clouds": stringToReturn = "prtly_cloudy_sun_25.png"
        case "light rain": stringToReturn = "light_rain_25.png"
        case "fog": stringToReturn = "fog_mist_25.png"
        case "haze": stringToReturn = "haze_25.png"
        case "snow": stringToReturn = "snow_25.png"
        case "shower rain": stringToReturn = "light_rain_25.png"
        case "heavy intensity rain": stringToReturn = "heavy_rain_25.png"
        case "light intensity shower rain": stringToReturn = "light_rain_25.png"
        case "moderate rain": stringToReturn = "heavy_rain_25.png"
        case "light intensity drizzle": stringToReturn = "light_rain_25.png"
        case "thunderstorm": stringToReturn = "thunderstorm_25.png"
        case "dust": stringToReturn = "haze_25.png"
        default:
            break
        }
        return stringToReturn
    }
    
    func parseLeg2Only(dictionary: [String:Any], index: Int) {
        
        print("parseLeg2Only")
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let flight = FlightStruct(dictionary: dictionary)
        let departureDateTime = flight.publishedDepartureUtc
        
        if isDepartureDate72HoursAwayOrLess(date: departureDateTime) == true {
            
            var url:URL!
            let id = flight.identifier
            let arrivalDateURL = flight.urlArrivalDate
            let arrivalAirport = flight.arrivalAirportCode
            let airlineCodeURL = flight.airlineCode
            let flightNumberURL = (flight.flightNumber).replacingOccurrences(of: airlineCodeURL, with: "")
            
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
                                        let flightStatusFormatted = formatFlightStatus(flightStatusUnformatted: flightStatusUnformatted)
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
                                                        
                                                        self.parseFlightID(dictionary: self.flightArray[index], index: index)
                                                        
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
                                                
                                                let departureDate = flight.departureDate
                                                let utcOffset = flight.departureUtcOffset
                                                let departureCity = flight.departureCity
                                                let arrivalCity = flight.arrivalCity
                                                let arrivalDate = flight.arrivalDate
                                                let arrivalOffset = flight.arrivalUtcOffset
                                                
                                                let departingTerminal = flight.departureTerminal
                                                let departingGate = flight.departureGate
                                                let departingAirport = flight.departureAirport
                                                let arrivalAirport = flight.arrivalAirportCode
                                                let flightNumber = flight.flightNumber
                                                
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
                                            
                                            if flightStatusFormatted == "Departed" {
                                                self.updateFlightFirstTime = true
                                                DispatchQueue.main.async {
                                                    self.parseFlightIDForTracking(flightId: flightId, index: index)
                                                }
                                            }
                                        }
                                        
                                        if self.didTapMarker {
                                            self.showFlightInfoWindows(flightIndex: self.flightIndex)
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




