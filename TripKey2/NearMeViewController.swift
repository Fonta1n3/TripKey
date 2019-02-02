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
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    var isConnected = Bool()
    let liveFlightMarker = GMSMarker()
    let nextFlightButton = UIButton()
    var didTapMarker = Bool()
    var usersLocationMode:Bool!
    var showArrivalWindow = false
    var session: WCSession?
    var userMarkerArray:[GMSMarker] = []
    var followedUsers = [Dictionary<String,Any>]()
    var howManyTimesUsed:[Int]! = []
    var infoWindowIsVisible = false
    @IBOutlet var bottomToolbar: UIToolbar!
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
    var address:String!
    var category:String!
    var types:[String]!
    var imageFiles = [PFFile]()
    @IBOutlet var communityButton: UIView!
    @IBOutlet var flightsButton: UIView!
    var imageArray:[UIImage]! = []
    let recognizer = UITapGestureRecognizer()
    let recognizerTopView = UITapGestureRecognizer()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var name:String!
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
    var flights = [Dictionary<String,String>]()
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
    var userAddedPlaceDictionaryArray = [Dictionary<String,String>]()
    var userTappedCoordinates:CLLocationCoordinate2D! = CLLocationCoordinate2D()
    var selectedPlaceLongitude:Double!
    var selectedPlaceLatitude:Double!
    var selectedPlaceCoordinates:CLLocationCoordinate2D!
    var userSwipedBack:Bool!
    var latitude:Double!
    var longitude:Double!
    var locationManager = CLLocationManager()
    var buttonPanoView = UIButton()
    var button = UIButton()
    var tappedCoordinates:CLLocationCoordinate2D!
    var placeMarkerArray:[GMSMarker] = []
    var biasmarker:GMSMarker!
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
            let index = Int((overlay.accessibilityLabel?.components(separatedBy: ", ")[1])!)
            self.parseLeg2Only(dictionary: flights[index!], index: index!)
            self.trackAirplaneTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {
                (_) in
                self.parseFlightIDForTracking(index: index!)
            }
        case "routePolyline":
            self.userTappedRoute = true
            let index = Int((overlay.accessibilityLabel?.components(separatedBy: ", ")[1])!)
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(departureMarkerArray[index!].position)
            bounds = bounds.includingCoordinate(arrivalMarkerArray[index!].position)
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds))
            self.parseLeg2Only(dictionary: flights[index!], index: index!)
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
                    //self.addButtons()
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
                var latitude:Double!
                var longitude:Double!
                var newLocation:GMSCameraPosition!
                
                if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                    print("from departure to arrival for same flight")
                    self.tappedMarker = self.arrivalMarkerArray[0]
                    self.showFlightInfoWindows(flightIndex: self.flightIndex)
                        latitude = Double(self.flights[self.flightIndex]["Airport Arrival Latitude"]!)!
                        longitude = Double(self.flights[self.flightIndex]["Airport Arrival Longitude"]!)!
                        newLocation = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.googleMapsView.camera.zoom)
                        DispatchQueue.main.async {
                            CATransaction.begin()
                            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                            self.googleMapsView.animate(to: newLocation)
                            CATransaction.commit()
                        }
                        self.addFlightViewFromRightToLeft()
                        
                    } else if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                        //from arrival to departure for same flight
                        self.tappedMarker = self.departureMarkerArray[0]
                        self.showDepartureWindow(index: self.flightIndex)
                        latitude = Double(self.flights[self.flightIndex]["Airport Departure Latitude"]!)!
                        longitude = Double(self.flights[self.flightIndex]["Airport Departure Longitude"]!)!
                        newLocation = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.googleMapsView.camera.zoom)
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
                var latitude:Double!
                var longitude:Double!
                var newLocation:GMSCameraPosition!
                
                
                    
                    if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                        //from arrival to departure for same flight
                        self.tappedMarker = self.departureMarkerArray[0]
                        self.showDepartureWindow(index: self.flightIndex)
                        latitude = Double(self.flights[self.flightIndex]["Airport Departure Latitude"]!)!
                        longitude = Double(self.flights[self.flightIndex]["Airport Departure Longitude"]!)!
                        newLocation = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.googleMapsView.camera.zoom)
                        DispatchQueue.main.async {
                            CATransaction.begin()
                            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                            self.googleMapsView.animate(to: newLocation)
                            CATransaction.commit()
                        }
                        self.addFlightViewFromLeftToRight()
                    } else {
                        
                        if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                            print("from departure to arrival for same flight")
                            self.tappedMarker = self.arrivalMarkerArray[0]
                            self.showFlightInfoWindows(flightIndex: self.flightIndex)
                            latitude = Double(self.flights[self.flightIndex]["Airport Arrival Latitude"]!)!
                            longitude = Double(self.flights[self.flightIndex]["Airport Arrival Longitude"]!)!
                            newLocation = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.googleMapsView.camera.zoom)
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
                print("percentageLeft = \(percentage)")
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
                flightView.center.x = self.view.center.x
                print("sliding down")
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
        arrivalInfoWindow.deleteFlight.addTarget(self, action: #selector(deleteFlight), for: .touchUpInside)
        let flightDragged = UIPanGestureRecognizer(target: self, action: #selector(flightWasDragged(gestureRecognizer:)))
        arrivalInfoWindow.addGestureRecognizer(flightDragged)
        
        
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        locationManager.delegate = self
        if UserDefaults.standard.object(forKey: "flights") != nil {
            flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
        }
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = true
        
            DispatchQueue.main.async {
                
                self.googleMapsView.delegate = self
                self.locationManager.startUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                self.googleMapsView.settings.rotateGestures = false
                self.googleMapsView.settings.tiltGestures = false
                self.googleMapsView.isMyLocationEnabled = true
                self.googleMapsView.isBuildingsEnabled = true
                self.googleMapsView.settings.compassButton = false
                self.googleMapsView.accessibilityElementsHidden = false
                self.googleMapsView.mapType = GMSMapViewType.hybrid
                self.view.addSubview(self.googleMapsView)
                self.addButtons()
                if self.flights.count > 0 {
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
           
            if (PFUser.current() != nil) {
                self.userNames.removeAll()
                print("User already logged in with Parse")
            } else {
                print("user is nil")
            }
        
        print("how many times used = \(howManyTimesUsed.count)")
        if howManyTimesUsed.count % 10 == 0 {
            self.askForReview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.liveFlightMarker.map = nil
        self.userNames.removeAll()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("viewdidappear")
        
        if flights.count > 1 {
            self.nextFlightButton.removeFromSuperview()
            
            if self.flightIndex + 1 == self.flights.count {
                DispatchQueue.main.async {
                    self.nextFlightButton.setTitle("Show First Flight", for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.nextFlightButton.setTitle("Show Next Flight", for: .normal)
                }
            }
            self.googleMapsView.addSubview(self.nextFlightButton)
        }
        
        getSharedFlights()
        
        if UserDefaults.standard.object(forKey: "flights") != nil {
            flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
            if flights.count > 0 {
                
                for (index, flight) in flights.enumerated() {
                    self.parseLeg2Only(dictionary: flight, index: index)
                }
                if let swipedBack = UserDefaults.standard.object(forKey: "userSwipedBack") as? Bool {
                    if swipedBack {
                        self.resetFlightZeroViewdidappear()
                    }
                }
            }
        }
        
        if UserDefaults.standard.object(forKey: "userSwipedBack") == nil {
            UserDefaults.standard.set(false, forKey: "userSwipedBack")
        }
        if UserDefaults.standard.object(forKey: "userSwipedBack") as! Bool == true {
            UserDefaults.standard.set(false, forKey: "userSwipedBack")
        }
        self.userNames.removeAll()
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            if let followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as? [Dictionary<String,Any>] {
                self.followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
                for user in followedUsers {
                    self.userNames.append(user["Username"] as! String)
                }
                
            } else {
                
                self.userNames = UserDefaults.standard.object(forKey: "followedUsernames") as! [String]
                
                for user in self.userNames {
                    
                    let dictionary = [
                        "Username":"\(user)",
                        "Profile Image":"",
                        "Latitude":"",
                        "Longitude":""
                    ]
                    
                    var followedUsers = [Dictionary<String,Any>]()
                    followedUsers.append(dictionary)
                    UserDefaults.standard.set(followedUsers, forKey: "followedUsernames")
                }
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
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appId)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
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
        
        if segue.identifier == "goToTable" {
            
            if let vc = segue.destination as? FlightTableNewViewController {
                
                vc.flights = self.flights
                vc.userNames = self.userNames
                
            }
            
        }
        
        if segue.identifier == "seatGuru" {
            
            if let vc = segue.destination as? SeatGuruViewController {
                
                vc.selectedFlight = self.flights[self.flightIndex]
                
            }
            
        }
        
    }
    
    @objc func nextFlight() {
        
        self.liveFlightMarker.map = nil
        
        func updateLabelText() {
            if self.flightIndex + 1 == self.flights.count {
                DispatchQueue.main.async {
                    self.nextFlightButton.setTitle("Show First Flight", for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.nextFlightButton.setTitle("Show Next Flight", for: .normal)
                }
            }
        }
        
        if self.flights.count > self.flightIndex + 1 {
            
            parseLeg2Only(dictionary: self.flights[self.flightIndex + 1], index: self.flightIndex + 1)
            self.getAirportCoordinates(flight: self.flights[self.flightIndex + 1], index: self.flightIndex + 1)
            self.flightIndex = self.flightIndex + 1
            updateLabelText()
            
        } else if self.flights.count == self.flightIndex + 1 {
            
            self.flightIndex = 0
            parseLeg2Only(dictionary: self.flights[self.flightIndex], index: self.flightIndex)
            self.getAirportCoordinates(flight: self.flights[self.flightIndex], index: self.flightIndex)
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
        
            let circleBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
            circleBlurView.removeFromSuperview()
            circleBlurView.frame = CGRect(x: (googleMapsView.bounds.maxX / 2) - 70, y: googleMapsView.bounds.maxY - 45, width: 140, height: 35)
            circleBlurView.clipsToBounds = true
            circleBlurView.layer.cornerRadius = 18
            nextFlightButton.frame = CGRect(x: (googleMapsView.bounds.maxX / 2) - 70, y: googleMapsView.bounds.maxY - 45, width: 140, height: 35)
            nextFlightButton.setTitle("Show Next Flight", for: .normal)
            nextFlightButton.setTitleColor(UIColor.white, for: .normal)
            nextFlightButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Thin", size: 15)
            nextFlightButton.backgroundColor = UIColor.clear
            nextFlightButton.showsTouchWhenHighlighted = true
            nextFlightButton.addTarget(self, action: #selector(nextFlight), for: .touchUpInside)
            circleBlurView.contentView.addSubview(nextFlightButton)
            googleMapsView.addSubview(circleBlurView)
            circleBlurView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: {
                circleBlurView.transform = .identity
            })
     }
    
    @objc func showTable() {
        if flights.count > 0 {
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToTable", sender: self)
            }
        } else {
            
            displayAlert(viewController: self, title: "No Flights", message: "You havent added a flight yet, tap the plane button to get started.")
        }
        
    }
    
    func showUsers() {
        
        if self.isUserLoggedIn() == true {
            if let followedUsersCheck = UserDefaults.standard.object(forKey: "followedUsernames") as? [Dictionary<String,Any>] {
                    self.followedUsers = followedUsersCheck
                    if self.followedUsers.count > 0 {
                        for user in self.followedUsers {
                            self.userNames.append(user["Username"] as! String)
                        }
                    }
                }
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
        
        var user = PFUser()
        
        if PFUser.current() != nil {
            
            user = PFUser.current()!
            user["userlocation"] = PFGeoPoint(latitude: latitude!, longitude: longitude!)
            user.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    self.locationManager.stopUpdatingLocation()
                    
                } else {
                    
                    self.locationManager.stopUpdatingLocation()
                }
                
                
            })
            
        } else {
            
            self.locationManager.stopUpdatingLocation()
        }
        }
        
        self.locationManager.stopUpdatingLocation()
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
        
        let tappedMarkerLatitude = marker.position.latitude
        let tappedMarkerLongitude = marker.position.longitude
        UserDefaults.standard.set(tappedMarkerLatitude, forKey: "tappedMarkerLatitude")
        UserDefaults.standard.set(tappedMarkerLongitude, forKey: "tappedMarkerLongitude")
        
        if (marker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" || (marker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
            self.didTapMarker = true
            self.userTappedRoute = false
            let index:Int = Int((marker.accessibilityLabel?.components(separatedBy: " - ")[1])!)!
            self.flightIndex = index
            self.parseLeg2Only(dictionary: self.flights[self.flightIndex], index: self.flightIndex)
            self.tappedMarker = marker
            let tappedMarkerLatitude = marker.position.latitude
            let tappedMarkerLongitude = marker.position.longitude
            self.tappedCoordinates = CLLocationCoordinate2D(latitude: tappedMarkerLatitude, longitude: tappedMarkerLongitude)
            let newPosition = GMSCameraPosition(target: self.tappedCoordinates, zoom: 6, bearing: self.googleMapsView.camera.bearing, viewingAngle: self.googleMapsView.camera.viewingAngle)
            //self.removeButtons()
            CATransaction.begin()
            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
            self.googleMapsView.animate(to: newPosition)
            CATransaction.commit()
            self.showFlightInfoWindows(flightIndex: self.flightIndex)
            self.addFlightViewFromRightToLeft()
           return false
           
        } else if (marker.accessibilityLabel?.components(separatedBy: ", ")[0])! == "Airplane Location" {
            
            let index = Int((marker.accessibilityLabel?.components(separatedBy: ", ")[1])!)!
            self.parseFlightIDForTracking(index: index)
            return false
            
        }
        
        return false
    }
    
    func callAirline() {
        
        self.phoneNumberString = self.flights[self.flightIndex]["Phone Number"]!
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
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        userTappedRoute = false
        if self.trackAirplaneTimer != nil {
            if (self.trackAirplaneTimer?.isValid)! {
                DispatchQueue.main.async {
                    self.trackAirplaneTimer?.invalidate()
                    self.trackAirplaneTimer = nil
                }
            }
        }
    }
    
    
    
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
    
    func formatFlightStatus(flightStatusUnformatted: String) -> String {
        var formattedText = String()
        switch self.flightStatusUnformatted {
        case "S": formattedText = "Scheduled"
        case "A": formattedText = "Departed"
        case "D": formattedText = "Diverted"
        case "DN": formattedText = "Data Source Needed"
        case "L": formattedText = "Landed"
        case "NO": formattedText = "Not Operational"
        case "R": formattedText = "Redirected"
        case "U": formattedText = "Unknown"
        case "C": formattedText = "Cancelled"
        DispatchQueue.main.async {
            let alert = UIAlertController(title: NSLocalizedString("Flight has been Cancelled!", comment: ""), message: NSLocalizedString("Contact your airline to get replacement flight number.", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion: nil)
            }
        default:
            print("Error formatting flight status")
        }
        return formattedText
    }
    
    func parseFlightID(dictionary: Dictionary<String,String>, index: Int) {
        
        print("parseFlightID")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + "\(self.flightId!)" + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87")
        
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
                                
                                if flightStatusesArray.count > 0 {
                                    
                                    self.flightStatusUnformatted = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["status"] as? String
                                    self.flightStatusFormatted = self.formatFlightStatus(flightStatusUnformatted: self.flightStatusUnformatted)
                                    
                                    //unambiguos data
                                    var baggageClaim = "-"
                                    var irregularOperationsMessage1 = ""
                                    var irregularOperationsMessage2 = ""
                                    var irregularOperationsType1 = ""
                                    var irregularOperationsType2 = ""
                                    var updatedFlightEquipment = ""
                                    var confirmedIncidentMessage = ""
                                    var flightDurationScheduled = ""
                                    var replacementFlightId:Double! = 0
                                    var primaryCarrier = ""
                                    
                                    if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                        
                                        baggageClaim = baggageCheck
                                    }
                                    
                                    if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                        
                                        primaryCarrier = primaryCarrierCheck
                                    }
                                    
                                    if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = formatFlightEquipment(flightEquipment: scheduledFlightEquipment)
                                        
                                    }
                                    
                                    if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = formatFlightEquipment(flightEquipment: actualFlightEquipment)
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
                                                self.flightId = replacementFlightId
                                                
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
                                        
                                    }
                                    
                                    if let flightDurationScheduledCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightDurations"] as? NSDictionary)?["scheduledBlockMinutes"] as? Int {
                                        
                                        flightDurationScheduled = String(flightDurationScheduledCheck)
                                    }
                                    
                                    //departure data
                                    var departureTerminal:String!
                                    var departureGate:String!
                                    
                                    if let departureTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureTerminal"] as? String {
                                        
                                        departureTerminal = departureTerminalCheck
                                        
                                    } else {
                                        
                                        departureTerminal = "-"
                                    }
                                    
                                    if let departureGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureGate"] as? String {
                                        
                                        departureGate = departureGateCheck
                                        
                                    } else {
                                        
                                        departureGate = "-"
                                        
                                    }
                                    
                                    //departure timings
                                    var publishedDeparture = ""
                                    var publishedDepartureWhole = ""
                                    var convertedPublishedDeparture = ""
                                    var actualGateDeparture = ""
                                    var actualGateDepartureUtc = ""
                                    var actualGateDepartureWhole = ""
                                    var convertedActualGateDeparture = ""
                                    var scheduledGateDeparture = ""
                                    var scheduledGateDepartureDateTimeWhole = ""
                                    var convertedScheduledGateDeparture = ""
                                    var estimatedGateDeparture = ""
                                    var estimatedGateDepartureWholeNumber = ""
                                    var convertedEstimatedGateDeparture = ""
                                    var actualRunwayDepartureWhole = ""
                                    var convertedActualRunwayDeparture = ""
                                    var actualRunwayDepartureUtc = ""
                                    var actualRunwayDeparture = ""
                                    var scheduledRunwayDepartureWhole = ""
                                    var convertedScheduledRunwayDeparture = ""
                                    var scheduledRunwayDepartureUtc = ""
                                    var scheduledRunwayDeparture = ""
                                    var estimatedRunwayDeparture = ""
                                    var estimatedRunwayDepartureWholeNumber = ""
                                    var convertedEstimatedRunwayDeparture = ""
                                    
                                    if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayDeparture = estimatedRunwayDepartureCheck
                                        estimatedRunwayDepartureWholeNumber = formatDateTimetoWhole(dateTime: estimatedRunwayDepartureCheck)
                                        convertedEstimatedRunwayDeparture = convertDateTime(date: estimatedRunwayDepartureCheck)
                                    }
                                    
                                    if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledRunwayDeparture = scheduledRunwayDepartureCheck
                                        convertedScheduledRunwayDeparture = convertDateTime(date: scheduledRunwayDeparture)
                                        scheduledRunwayDepartureWhole = formatDateTimetoWhole(dateTime: scheduledRunwayDeparture)
                                        if let scheduledRunwayDepartureUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                            scheduledRunwayDepartureUtc = scheduledRunwayDepartureUtcCheck
                                        }
                                    }
                                    
                                    if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayDeparture = actualRunwayDepartureCheck
                                        convertedActualRunwayDeparture = convertDateTime(date: actualRunwayDepartureCheck)
                                        actualRunwayDepartureWhole = formatDateTimetoWhole(dateTime: actualRunwayDepartureCheck)
                                        if let actualRunwayDepartureUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                            actualRunwayDepartureUtc = actualRunwayDepartureUtcCheck
                                        }
                                    }
                                    
                                    if let publishedDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedDeparture = publishedDepartureCheck
                                        convertedPublishedDeparture = convertDateTime(date: publishedDepartureCheck)
                                        publishedDepartureWhole = formatDateTimetoWhole(dateTime: publishedDepartureCheck)
                                        
                                    }
                                    
                                    if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateDeparture = scheduledGateDepartureCheck
                                        scheduledGateDepartureDateTimeWhole = formatDateTimetoWhole(dateTime: scheduledGateDepartureCheck)
                                        convertedScheduledGateDeparture = convertDateTime(date: scheduledGateDepartureCheck)
                                        
                                    }
                                    
                                    if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateDeparture = estimatedGateDepartureCheck
                                        estimatedGateDepartureWholeNumber = formatDateTimetoWhole(dateTime: estimatedGateDepartureCheck)
                                        convertedEstimatedGateDeparture = convertDateTime(date: estimatedGateDepartureCheck)
                                    }
                                    
                                    if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateDeparture = actualGateDepartureCheck
                                        convertedActualGateDeparture = convertDateTime(date: actualGateDepartureCheck)
                                        actualGateDepartureWhole = formatDateTimetoWhole(dateTime: actualGateDepartureCheck)
                                        if let actualGateDepartureUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                            actualGateDepartureUtc = actualGateDepartureUtcCheck
                                        }
                                        
                                    }
                                    
                                    //arrival data
                                    var arrivalTerminal:String!
                                    var arrivalGate:String!
                                    
                                    //diverted airport data
                                    var divertedAirportArrivalCode = ""
                                    var divertedAirportArrivalCountryName = ""
                                    var divertedAirportArrivalLongitudeDouble = Double()
                                    var divertedAirportArrivalIata = ""
                                    var divertedAirportArrivalLatitudeDouble = Double()
                                    var divertedAirportArrivalCityCode = ""
                                    var divertedAirportArrivalName = ""
                                    var divertedAirportArrivalCity = ""
                                    var divertedAirportArrivalTimeZone = ""
                                    var divertedAirportArrivalUtcOffsetHours = Double()
                                    
                                    if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                        
                                        divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String
                                        divertedAirportArrivalCountryName = divertedAirportCheck["countryName"] as! String
                                        divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double
                                        divertedAirportArrivalIata = divertedAirportCheck["iata"] as! String
                                        divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double
                                        divertedAirportArrivalCityCode = divertedAirportCheck["cityCode"] as! String
                                        divertedAirportArrivalName = divertedAirportCheck["name"] as! String
                                        divertedAirportArrivalCity = divertedAirportCheck["city"] as! String
                                        divertedAirportArrivalTimeZone = divertedAirportCheck["timeZoneRegionName"] as! String
                                        divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.flights[index]["Arrival Airport Code"] = "\(divertedAirportArrivalCode)"
                                            self.flights[index]["Airport Arrival Longitude"] = "\(divertedAirportArrivalLongitudeDouble)"
                                            self.flights[index]["Airport Arrival Latitude"] = "\(divertedAirportArrivalLatitudeDouble)"
                                            self.flights[index]["Airport Arrival FS"] = "\(divertedAirportArrivalCode)"
                                            self.flights[index]["Arrival Country"] = "\(divertedAirportArrivalCountryName)"
                                            self.flights[index]["Airport Arrival IATA"] = "\(divertedAirportArrivalIata)"
                                            self.flights[index]["Airport Arrival City Code"] = "\(divertedAirportArrivalCityCode)"
                                            self.flights[index]["Airport Arrival Name"] = "\(divertedAirportArrivalName)"
                                            self.flights[index]["Arrival City"] = "\(divertedAirportArrivalCity)"
                                            self.flights[index]["Airport Arrival Time Zone"] = "\(divertedAirportArrivalTimeZone)"
                                            self.flights[index]["Arrival Airport UTC Offset"] = "\(divertedAirportArrivalUtcOffsetHours)"
                                        }
                                        
                                    }
                                    
                                    if let arrivalGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalGate"] as? String {
                                        
                                        arrivalGate = arrivalGateCheck
                                        
                                    } else {
                                        
                                        arrivalGate = "-"
                                        
                                    }
                                    
                                    if let arrivalTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalTerminal"] as? String {
                                        
                                        arrivalTerminal = arrivalTerminalCheck
                                        
                                    } else {
                                        
                                        arrivalTerminal = "-"
                                    }
                                    
                                    //arrival timings
                                    var publishedArrival = ""
                                    var convertedPublishedArrival = ""
                                    var publishedArrivalWhole = ""
                                    var scheduledGateArrivalUtc = ""
                                    var scheduledGateArrivalWholeNumber = ""
                                    var scheduledGateArrival = ""
                                    var convertedScheduledGateArrival = ""
                                    var scheduledRunwayArrivalWholeNumber = ""
                                    var scheduledRunwayArrivalUtc = ""
                                    var scheduledRunwayArrival = ""
                                    var convertedScheduledRunwayArrival = ""
                                    var estimatedGateArrivalUtc = ""
                                    var estimatedGateArrivalWholeNumber = ""
                                    var convertedEstimatedGateArrival = ""
                                    var estimatedGateArrival = ""
                                    var convertedActualGateArrival = ""
                                    var actualGateArrivalWhole = ""
                                    var actualGateArrival = ""
                                    var convertedEstimatedRunwayArrival = ""
                                    var estimatedRunwayArrivalUtc = ""
                                    var estimatedRunwayArrivalWhole = ""
                                    var estimatedRunwayArrival = ""
                                    var convertedActualRunwayArrival = ""
                                    var actualRunwayArrivalUtc = ""
                                    var actualRunwayArrivalWhole = ""
                                    var actualRunwayArrival = ""
                                    
                                    if let scheduledRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledRunwayArrival = scheduledRunwayArrivalCheck
                                        scheduledRunwayArrivalWholeNumber = formatDateTimetoWhole(dateTime: scheduledRunwayArrivalCheck)
                                        convertedScheduledRunwayArrival = convertDateTime(date: scheduledRunwayArrivalCheck)
                                        if let scheduledRunwayArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                            scheduledRunwayArrivalUtc = scheduledRunwayArrivalUtcCheck
                                        }
                                        
                                    }
                                    
                                    if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayArrival = actualRunwayArrivalCheck
                                        actualRunwayArrivalWhole = formatDateTimetoWhole(dateTime: actualRunwayArrivalCheck)
                                        convertedActualRunwayArrival = convertDateTime(date: actualRunwayArrivalCheck)
                                        if let actualRunwayArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                            actualRunwayArrivalUtc = actualRunwayArrivalUtcCheck
                                        }
                                        
                                    }
                                    
                                    if let publishedArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedArrival = publishedArrivalCheck
                                        convertedPublishedArrival = convertDateTime(date: publishedArrival)
                                        publishedArrivalWhole = formatDateTimetoWhole(dateTime: publishedArrival)
                                        
                                    }
                                    
                                    if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayArrival = estimatedRunwayArrivalCheck
                                        estimatedRunwayArrivalWhole = formatDateTimetoWhole(dateTime: estimatedRunwayArrivalCheck)
                                        convertedEstimatedRunwayArrival = convertDateTime(date: estimatedRunwayArrivalCheck)
                                        if let estimatedRunwayArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                            estimatedRunwayArrivalUtc = estimatedRunwayArrivalUtcCheck
                                        }
                                        
                                    }
                                    
                                    if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateArrival = scheduledGateArrivalCheck
                                        scheduledGateArrivalWholeNumber = formatDateTimetoWhole(dateTime: scheduledGateArrivalCheck)
                                        convertedScheduledGateArrival = convertDateTime(date: scheduledGateArrivalCheck)
                                        if let scheduledGateArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                            scheduledGateArrivalUtc = scheduledGateArrivalUtcCheck
                                        }
                                        
                                    }
                                    
                                    if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateArrival = estimatedGateArrivalCheck
                                        estimatedGateArrivalWholeNumber = formatDateTimetoWhole(dateTime: estimatedGateArrivalCheck)
                                        convertedEstimatedGateArrival = convertDateTime(date: estimatedGateArrivalCheck)
                                        if let estimatedGateArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                            estimatedGateArrivalUtc = estimatedGateArrivalUtcCheck
                                        }
                                    }
                                    
                                    if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateArrival = actualGateArrivalCheck
                                        convertedActualGateArrival = convertDateTime(date: actualGateArrivalCheck)
                                        actualGateArrivalWhole = formatDateTimetoWhole(dateTime: actualGateArrivalCheck)
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        //unambiguos data
                                        self.flights[index]["Flight Status"] = "\(NSLocalizedString(self.flightStatusFormatted!, comment: ""))"
                                        self.flights[index]["Flight Duration Scheduled"] = "\(flightDurationScheduled)"
                                        self.flights[index]["Baggage Claim"] = "\(baggageClaim)"
                                        self.flights[index]["Primary Carrier"] = "\(primaryCarrier)"
                                        self.flights[index]["Irregular Operation Message 1"] = "\(irregularOperationsMessage1)"
                                        self.flights[index]["Irregular Operation Message 2"] = "\(irregularOperationsMessage2)"
                                        self.flights[index]["Irregular Operation Type 1"] = "\(irregularOperationsType1)"
                                        self.flights[index]["Irregular Operation Type 2"] = "\(irregularOperationsType2)"
                                        self.flights[index]["Confirmed Incident Message"] = "\(confirmedIncidentMessage)"
                                        self.flights[index]["Updated Flight Equipment"] = "\(updatedFlightEquipment)"
                                        
                                        //departure data
                                        self.flights[index]["Airport Departure Terminal"] = "\(departureTerminal!)"
                                        self.flights[index]["Departure Gate"] = "\(departureGate!)"
                                        
                                        //departure timings
                                        self.flights[index]["Converted Actual Runway Departure"] = "\(convertedActualRunwayDeparture)"
                                        self.flights[index]["Actual Runway Departure Whole"] = "\(actualRunwayDepartureWhole)"
                                        self.flights[index]["Actual Runway Departure UTC"] = "\(actualRunwayDepartureUtc)"
                                        self.flights[index]["Actual Runway Departure"] = "\(actualRunwayDeparture)"
                                        
                                        self.flights[index]["Scheduled Runway Departure Whole Number"] = "\(scheduledRunwayDepartureWhole)"
                                        self.flights[index]["Converted Scheduled Runway Departure"] = "\(convertedScheduledRunwayDeparture)"
                                        self.flights[index]["Scheduled Runway Departure"] = "\(scheduledRunwayDeparture)"
                                        self.flights[index]["Scheduled Runway Departure UTC"] = "\(scheduledRunwayDepartureUtc)"
                                        
                                        self.flights[index]["Converted Estimated Runway Departure"] = "\(convertedEstimatedRunwayDeparture)"
                                        self.flights[index]["Estimated Runway Departure Whole Number"] = "\(estimatedRunwayDepartureWholeNumber)"
                                        self.flights[index]["Estimated Runway Departure"] = "\(estimatedRunwayDeparture)"
                                        
                                        self.flights[index]["Scheduled Gate Departure Whole Number"] = "\(scheduledGateDepartureDateTimeWhole)"
                                        self.flights[index]["Converted Scheduled Gate Departure"] = "\(convertedScheduledGateDeparture)"
                                        self.flights[index]["Scheduled Gate Departure"] = "\(scheduledGateDeparture)"
                                        
                                        self.flights[index]["Converted Published Departure"] = "\(convertedPublishedDeparture)"
                                        self.flights[index]["Published Departure Whole"] = "\(publishedDepartureWhole)"
                                        self.flights[index]["Published Departure"] = "\(publishedDeparture)"
                                        
                                        self.flights[index]["Converted Estimated Gate Departure"] = "\(convertedEstimatedGateDeparture)"
                                        self.flights[index]["Estimated Gate Departure Whole Number"] = "\(estimatedGateDepartureWholeNumber)"
                                        self.flights[index]["Estimated Gate Departure"] = "\(estimatedGateDeparture)"
                                        
                                        self.flights[index]["Converted Actual Gate Departure"] = "\(convertedActualGateDeparture)"
                                        self.flights[index]["Actual Gate Departure Whole"] = "\(actualGateDepartureWhole)"
                                        self.flights[index]["Actual Gate Departure UTC"] = "\(actualGateDepartureUtc)"
                                        self.flights[index]["Actual Gate Departure"] = "\(actualGateDeparture)"
                                        
                                        
                                        
                                        //arrival data
                                        self.flights[index]["Airport Arrival Terminal"] = "\(arrivalTerminal!)"
                                        self.flights[index]["Arrival Gate"] = "\(arrivalGate!)"
                                        
                                        //arrival timings
                                        self.flights[index]["Actual Runway Arrival Whole Number"] = "\(actualRunwayArrivalWhole)"
                                        self.flights[index]["Converted Actual Runway Arrival"] = "\(convertedActualRunwayArrival)"
                                        self.flights[index]["Actual Runway Arrival UTC"] = "\(actualRunwayArrivalUtc)"
                                        self.flights[index]["Actual Runway Arrival"] = "\(actualRunwayArrival)"
                                        
                                        self.flights[index]["Scheduled Runway Arrival Whole Number"] = "\(scheduledRunwayArrivalWholeNumber)"
                                        self.flights[index]["Converted Scheduled Runway Arrival"] = "\(convertedScheduledRunwayArrival)"
                                        self.flights[index]["Scheduled Runway Arrival UTC"] = "\(scheduledRunwayArrivalUtc)"
                                        self.flights[index]["Scheduled Runway Arrival"] = "\(scheduledRunwayArrival)"
                                        
                                        self.flights[index]["Estimated Runway Arrival Whole Number"] = "\(estimatedRunwayArrivalWhole)"
                                        self.flights[index]["Converted Estimated Runway Arrival"] = "\(convertedEstimatedRunwayArrival)"
                                        self.flights[index]["Estimated Runway Arrival UTC"] = "\(estimatedRunwayArrivalUtc)"
                                        self.flights[index]["Estimated Runway Arrival"] = "\(estimatedRunwayArrival)"
                                        
                                        self.flights[index]["Scheduled Gate Arrival Whole Number"] = "\(scheduledGateArrivalWholeNumber)"
                                        self.flights[index]["Converted Scheduled Gate Arrival"] = "\(convertedScheduledGateArrival)"
                                        self.flights[index]["Scheduled Gate Arrival UTC"] = "\(scheduledGateArrivalUtc)"
                                        self.flights[index]["Scheduled Gate Arrival"] = "\(scheduledGateArrival)"
                                        
                                        self.flights[index]["Converted Published Arrival"] = "\(convertedPublishedArrival)"
                                        self.flights[index]["Published Arrival Whole"] = "\(publishedArrivalWhole)"
                                        self.flights[index]["Published Arrival"] = "\(publishedArrival)"
                                        
                                        self.flights[index]["Estimated Gate Arrival Whole Number"] = "\(estimatedGateArrivalWholeNumber)"
                                        self.flights[index]["Converted Estimated Gate Arrival"] = "\(convertedEstimatedGateArrival)"
                                        self.flights[index]["Estimated Gate Arrival UTC"] = "\(estimatedGateArrivalUtc)"
                                        self.flights[index]["Estimated Gate Arrival"] = "\(estimatedGateArrival)"
                                        
                                        self.flights[index]["Converted Actual Gate Arrival"] = "\(convertedActualGateArrival)"
                                        self.flights[index]["Actual Gate Arrival Whole"] = "\(actualGateArrivalWhole)"
                                        self.flights[index]["Actual Gate Arrival"] = "\(actualGateArrival)"
                                        
                                        UserDefaults.standard.set(self.flights, forKey: "flights")
                                        
                                       if self.tappedCoordinates.latitude != 0 && self.tappedCoordinates.longitude != 0 {
                                            
                                            for departureMarker in self.departureMarkerArray {
                                                
                                                if self.tappedMarker.position.latitude == departureMarker.position.latitude && self.tappedMarker.position.longitude == departureMarker.position.longitude {
                                                    
                                                    self.googleMapsView.selectedMarker = nil
                                                    self.googleMapsView.selectedMarker = departureMarker
                                                    
                                                } else {
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                            for arrivalMarker in self.arrivalMarkerArray {
                                                
                                                if self.tappedMarker.position.latitude == arrivalMarker.position.latitude && self.tappedMarker.position.longitude == self.arrivalMarker.position.longitude {
                                                    
                                                    self.googleMapsView.selectedMarker = nil
                                                    self.googleMapsView.selectedMarker = arrivalMarker
                                                    
                                                } else {
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        DispatchQueue.main.async {
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            self.activityIndicator.stopAnimating()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            self.activityLabel.removeFromSuperview()
                                            
                                            if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && self.flightId != 0 {
                                                
                                                let alert = UIAlertController(title: "\(String(describing: confirmedIncidentMessage))", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n" + NSLocalizedString("Would you like to add the replacement flight automatically?", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.parseFlightID(dictionary: self.flights[index], index: index)
                                                    
                                                }))
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
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
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: NSLocalizedString("This flight has an irregular operation of type:", comment: "") + " \(irregularOperationsType1)", preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                   }
                                    
                                } else {
                                    
                                    if let errorMessage = ((jsonFlightStatusData)["error"] as? NSDictionary)?["errorMessage"] as? String {
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        print("errorMessage = \(errorMessage)")
                                        
                                        DispatchQueue.main.async {
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            self.activityIndicator.stopAnimating()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            self.activityLabel.removeFromSuperview()
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                                            
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
    
    func parseLeg2Only(dictionary: Dictionary<String,String>, index: Int) {
        
        print("parseLeg2Only")
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let departureDateTime = flights[index]["Published Departure UTC"]!
        
        if isDepartureDate72HoursAwayOrLess(date: departureDateTime) == true {
            
            var url:URL!
            let arrivalDateURL = flights[index]["URL Arrival Date"]!
            let arrivalAirport = flights[index]["Arrival Airport Code"]!
            self.airlineCodeURL = flights[index]["Airline Code"]!
            self.flightNumberURL = flights[index]["Flight Number"]!
            
            url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + (self.airlineCodeURL!) + "/" + (self.flightNumberURL!) + "/arr/" + (arrivalDateURL) + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87&utc=false&airport=" + (arrivalAirport) + "&extendedOptions=useinlinedreferences")
            
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
                                        
                                        self.flightStatusUnformatted = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["status"] as? String
                                        self.flightStatusFormatted = self.formatFlightStatus(flightStatusUnformatted: self.flightStatusUnformatted)
                                        
                                        //unambiguos data
                                        var baggageClaim = "-"
                                        var irregularOperationsMessage1 = ""
                                        var irregularOperationsMessage2 = ""
                                        var irregularOperationsType1 = ""
                                        var irregularOperationsType2 = ""
                                        var updatedFlightEquipment = ""
                                        var confirmedIncidentMessage = ""
                                        var flightDurationScheduled = ""
                                        var replacementFlightId:Double! = 0
                                        var primaryCarrier = ""
                                        var flightId:Int!
                                        
                                        if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                            baggageClaim = baggageCheck
                                        }
                                        
                                        if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                            primaryCarrier = primaryCarrierCheck
                                        }
                                        
                                        if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                            updatedFlightEquipment = formatFlightEquipment(flightEquipment: scheduledFlightEquipment)
                                        }
                                        
                                        if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                            updatedFlightEquipment = formatFlightEquipment(flightEquipment: actualFlightEquipment)
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
                                                    self.flightId = replacementFlightId
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
                                        }
                                        
                                        if let flightDurationScheduledCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightDurations"] as? NSDictionary)?["scheduledBlockMinutes"] as? Int {
                                            flightDurationScheduled = String(flightDurationScheduledCheck)
                                        }
                                        
                                        //departure data
                                        var departureTerminal:String!
                                        var departureGate:String!
                                        
                                        if let departureTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureTerminal"] as? String {
                                            departureTerminal = departureTerminalCheck
                                        } else {
                                            departureTerminal = "-"
                                        }
                                        
                                        if let departureGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["departureGate"] as? String {
                                            departureGate = departureGateCheck
                                        } else {
                                            departureGate = "-"
                                        }
                                        
                                        //departure timings
                                        var publishedDeparture = ""
                                        var publishedDepartureWhole = ""
                                        var convertedPublishedDeparture = ""
                                        
                                        var actualGateDeparture = ""
                                        var actualGateDepartureUtc = ""
                                        var actualGateDepartureWhole = ""
                                        var convertedActualGateDeparture = ""
                                        
                                        var scheduledGateDeparture = ""
                                        var scheduledGateDepartureDateTimeWhole = ""
                                        var convertedScheduledGateDeparture = ""
                                        var scheduledGateDepartureUTC = ""
                                        
                                        var estimatedGateDeparture = ""
                                        var estimatedGateDepartureWholeNumber = ""
                                        var convertedEstimatedGateDeparture = ""
                                        var estimatedGateDepartureUTC = ""
                                        
                                        var actualRunwayDepartureWhole = ""
                                        var convertedActualRunwayDeparture = ""
                                        var actualRunwayDepartureUtc = ""
                                        var actualRunwayDeparture = ""
                                        
                                        var scheduledRunwayDepartureWhole = ""
                                        var convertedScheduledRunwayDeparture = ""
                                        var scheduledRunwayDepartureUtc = ""
                                        var scheduledRunwayDeparture = ""
                                        
                                        var estimatedRunwayDeparture = ""
                                        var estimatedRunwayDepartureWholeNumber = ""
                                        var convertedEstimatedRunwayDeparture = ""
                                        
                                        if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedRunwayDeparture = estimatedRunwayDepartureCheck
                                            estimatedRunwayDepartureWholeNumber = formatDateTimetoWhole(dateTime: estimatedRunwayDepartureCheck)
                                            convertedEstimatedRunwayDeparture = convertDateTime(date: estimatedRunwayDepartureCheck)
                                        }
                                        
                                        if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledRunwayDeparture = scheduledRunwayDepartureCheck
                                            convertedScheduledRunwayDeparture = convertDateTime(date: scheduledRunwayDeparture)
                                            scheduledRunwayDepartureWhole = formatDateTimetoWhole(dateTime: scheduledRunwayDeparture)
                                            if let scheduledRunwayDepartureUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                                scheduledRunwayDepartureUtc = scheduledRunwayDepartureUtcCheck
                                            }
                                        }
                                        
                                        if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualRunwayDeparture = actualRunwayDepartureCheck
                                            convertedActualRunwayDeparture = convertDateTime(date: actualRunwayDepartureCheck)
                                            actualRunwayDepartureWhole = formatDateTimetoWhole(dateTime: actualRunwayDepartureCheck)
                                            if let actualRunwayDepartureUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                                actualRunwayDepartureUtc = actualRunwayDepartureUtcCheck
                                            }
                                        }
                                        
                                        if let publishedDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            publishedDeparture = publishedDepartureCheck
                                            convertedPublishedDeparture = convertDateTime(date: publishedDepartureCheck)
                                            publishedDepartureWhole = formatDateTimetoWhole(dateTime: publishedDepartureCheck)
                                            
                                        }
                                        
                                        if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledGateDeparture = scheduledGateDepartureCheck
                                            scheduledGateDepartureDateTimeWhole = formatDateTimetoWhole(dateTime: scheduledGateDepartureCheck)
                                            convertedScheduledGateDeparture = convertDateTime(date: scheduledGateDepartureCheck)
                                            if let scheduledGateDepartureUTCCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                                scheduledGateDepartureUTC = scheduledGateDepartureUTCCheck
                                            }
                                            
                                        }
                                        
                                        if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedGateDeparture = estimatedGateDepartureCheck
                                            estimatedGateDepartureWholeNumber = formatDateTimetoWhole(dateTime: estimatedGateDepartureCheck)
                                            convertedEstimatedGateDeparture = convertDateTime(date: estimatedGateDepartureCheck)
                                            if let estimatedGateDepartureUTCCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                                estimatedGateDepartureUTC = estimatedGateDepartureUTCCheck
                                            }
                                        }
                                        
                                        if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualGateDeparture = actualGateDepartureCheck
                                            convertedActualGateDeparture = convertDateTime(date: actualGateDepartureCheck)
                                            actualGateDepartureWhole = formatDateTimetoWhole(dateTime: actualGateDepartureCheck)
                                            if let actualGateDepartureUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateUtc"] as? String {
                                                actualGateDepartureUtc = actualGateDepartureUtcCheck
                                            }
                                            
                                        }
                                        
                                        //arrival data
                                        var arrivalTerminal:String!
                                        var arrivalGate:String!
                                        
                                        //diverted airport data
                                        var divertedAirportArrivalCode = ""
                                        var divertedAirportArrivalCountryName = ""
                                        var divertedAirportArrivalLongitudeDouble = Double()
                                        var divertedAirportArrivalIata = ""
                                        var divertedAirportArrivalLatitudeDouble = Double()
                                        var divertedAirportArrivalCityCode = ""
                                        var divertedAirportArrivalName = ""
                                        var divertedAirportArrivalCity = ""
                                        var divertedAirportArrivalTimeZone = ""
                                        var divertedAirportArrivalUtcOffsetHours = Double()
                                        
                                        if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                            
                                            divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String
                                            divertedAirportArrivalCountryName = divertedAirportCheck["countryName"] as! String
                                            divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double
                                            divertedAirportArrivalIata = divertedAirportCheck["iata"] as! String
                                            divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double
                                            divertedAirportArrivalCityCode = divertedAirportCheck["cityCode"] as! String
                                            divertedAirportArrivalName = divertedAirportCheck["name"] as! String
                                            divertedAirportArrivalCity = divertedAirportCheck["city"] as! String
                                            divertedAirportArrivalTimeZone = divertedAirportCheck["timeZoneRegionName"] as! String
                                            divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.flights[index]["Arrival Airport Code"] = "\(divertedAirportArrivalCode)"
                                                self.flights[index]["Airport Arrival Longitude"] = "\(divertedAirportArrivalLongitudeDouble)"
                                                self.flights[index]["Airport Arrival Latitude"] = "\(divertedAirportArrivalLatitudeDouble)"
                                                self.flights[index]["Airport Arrival FS"] = "\(divertedAirportArrivalCode)"
                                                self.flights[index]["Arrival Country"] = "\(divertedAirportArrivalCountryName)"
                                                self.flights[index]["Airport Arrival IATA"] = "\(divertedAirportArrivalIata)"
                                                self.flights[index]["Airport Arrival City Code"] = "\(divertedAirportArrivalCityCode)"
                                                self.flights[index]["Airport Arrival Name"] = "\(divertedAirportArrivalName)"
                                                self.flights[index]["Arrival City"] = "\(divertedAirportArrivalCity)"
                                                self.flights[index]["Airport Arrival Time Zone"] = "\(divertedAirportArrivalTimeZone)"
                                                self.flights[index]["Arrival Airport UTC Offset"] = "\(divertedAirportArrivalUtcOffsetHours)"
                                            }
                                            
                                        }
                                        
                                        if let arrivalGateCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalGate"] as? String {
                                            
                                            arrivalGate = arrivalGateCheck
                                            
                                        } else {
                                            
                                            arrivalGate = "-"
                                            
                                        }
                                        
                                        if let arrivalTerminalCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["arrivalTerminal"] as? String {
                                            
                                            arrivalTerminal = arrivalTerminalCheck
                                            
                                        } else {
                                            
                                            arrivalTerminal = "-"
                                        }
                                        
                                        //arrival timings
                                        var publishedArrival = ""
                                        var convertedPublishedArrival = ""
                                        var publishedArrivalWhole = ""
                                        var scheduledGateArrivalUtc = ""
                                        var scheduledGateArrivalWholeNumber = ""
                                        var scheduledGateArrival = ""
                                        var convertedScheduledGateArrival = ""
                                        var scheduledRunwayArrivalWholeNumber = ""
                                        var scheduledRunwayArrivalUtc = ""
                                        var scheduledRunwayArrival = ""
                                        var convertedScheduledRunwayArrival = ""
                                        var estimatedGateArrivalUtc = ""
                                        var estimatedGateArrivalWholeNumber = ""
                                        var convertedEstimatedGateArrival = ""
                                        var estimatedGateArrival = ""
                                        var convertedActualGateArrival = ""
                                        var actualGateArrivalWhole = ""
                                        var actualGateArrival = ""
                                        var convertedEstimatedRunwayArrival = ""
                                        var estimatedRunwayArrivalUtc = ""
                                        var estimatedRunwayArrivalWhole = ""
                                        var estimatedRunwayArrival = ""
                                        var convertedActualRunwayArrival = ""
                                        var actualRunwayArrivalUtc = ""
                                        var actualRunwayArrivalWhole = ""
                                        var actualRunwayArrival = ""
                                        
                                        if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualRunwayArrival = actualRunwayArrivalCheck
                                            actualRunwayArrivalWhole = formatDateTimetoWhole(dateTime: actualRunwayArrivalCheck)
                                            convertedActualRunwayArrival = convertDateTime(date: actualRunwayArrivalCheck)
                                            if let actualRunwayArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                                actualRunwayArrivalUtc = actualRunwayArrivalUtcCheck
                                            }
                                            
                                        }
                                        
                                        if let publishedArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            publishedArrival = publishedArrivalCheck
                                            convertedPublishedArrival = convertDateTime(date: publishedArrival)
                                            publishedArrivalWhole = formatDateTimetoWhole(dateTime: publishedArrival)
                                            
                                        }
                                        
                                        if let scheduledRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledRunwayArrival = scheduledRunwayArrivalCheck
                                            scheduledRunwayArrivalWholeNumber = formatDateTimetoWhole(dateTime: scheduledRunwayArrivalCheck)
                                            convertedScheduledRunwayArrival = convertDateTime(date: scheduledRunwayArrivalCheck)
                                            if let scheduledRunwayArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                                scheduledRunwayArrivalUtc = scheduledRunwayArrivalUtcCheck
                                            }
                                            
                                        }
                                        
                                        if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedRunwayArrival = estimatedRunwayArrivalCheck
                                            estimatedRunwayArrivalWhole = formatDateTimetoWhole(dateTime: estimatedRunwayArrivalCheck)
                                            convertedEstimatedRunwayArrival = convertDateTime(date: estimatedRunwayArrivalCheck)
                                            if let estimatedRunwayArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                                estimatedRunwayArrivalUtc = estimatedRunwayArrivalUtcCheck
                                            }
                                            
                                        }
                                        
                                        if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledGateArrival = scheduledGateArrivalCheck
                                            scheduledGateArrivalWholeNumber = formatDateTimetoWhole(dateTime: scheduledGateArrivalCheck)
                                            convertedScheduledGateArrival = convertDateTime(date: scheduledGateArrivalCheck)
                                            if let scheduledGateArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                                scheduledGateArrivalUtc = scheduledGateArrivalUtcCheck
                                            }
                                            
                                        }
                                        
                                        if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedGateArrival = estimatedGateArrivalCheck
                                            estimatedGateArrivalWholeNumber = formatDateTimetoWhole(dateTime: estimatedGateArrivalCheck)
                                            convertedEstimatedGateArrival = convertDateTime(date: estimatedGateArrivalCheck)
                                            if let estimatedGateArrivalUtcCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateUtc"] as? String {
                                                
                                                estimatedGateArrivalUtc = estimatedGateArrivalUtcCheck
                                            }
                                        }
                                        
                                        if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualGateArrival = actualGateArrivalCheck
                                            convertedActualGateArrival = convertDateTime(date: actualGateArrivalCheck)
                                            actualGateArrivalWhole = formatDateTimetoWhole(dateTime: actualGateArrivalCheck)
                                            
                                        }
                                        
                                        DispatchQueue.main.async {
                                            
                                            //unambiguos data
                                            self.flights[index]["Flight Status"] = "\((NSLocalizedString(self.flightStatusFormatted!, comment: "")))"
                                            self.flights[index]["Flight Duration Scheduled"] = "\(flightDurationScheduled)"
                                            self.flights[index]["Baggage Claim"] = "\(baggageClaim)"
                                            self.flights[index]["Primary Carrier"] = "\(primaryCarrier)"
                                            self.flights[index]["Irregular Operation Message 1"] = "\(irregularOperationsMessage1)"
                                            self.flights[index]["Irregular Operation Message 2"] = "\(irregularOperationsMessage2)"
                                            self.flights[index]["Irregular Operation Type 1"] = "\(irregularOperationsType1)"
                                            self.flights[index]["Irregular Operation Type 2"] = "\(irregularOperationsType2)"
                                            self.flights[index]["Confirmed Incident Message"] = "\(confirmedIncidentMessage)"
                                            self.flights[index]["Updated Flight Equipment"] = "\(updatedFlightEquipment)"
                                            
                                            //departure data
                                            self.flights[index]["Airport Departure Terminal"] = "\(departureTerminal!)"
                                            self.flights[index]["Departure Gate"] = "\(departureGate!)"
                                            
                                            //departure timings
                                            self.flights[index]["Converted Actual Runway Departure"] = "\(convertedActualRunwayDeparture)"
                                            self.flights[index]["Actual Runway Departure Whole"] = "\(actualRunwayDepartureWhole)"
                                            self.flights[index]["Actual Runway Departure UTC"] = "\(actualRunwayDepartureUtc)"
                                            self.flights[index]["Actual Runway Departure"] = "\(actualRunwayDeparture)"
                                            self.flights[index]["Scheduled Runway Departure Whole Number"] = "\(scheduledRunwayDepartureWhole)"
                                            self.flights[index]["Converted Scheduled Runway Departure"] = "\(convertedScheduledRunwayDeparture)"
                                            self.flights[index]["Scheduled Runway Departure"] = "\(scheduledRunwayDeparture)"
                                            self.flights[index]["Scheduled Runway Departure UTC"] = "\(scheduledRunwayDepartureUtc)"
                                            self.flights[index]["Converted Estimated Runway Departure"] = "\(convertedEstimatedRunwayDeparture)"
                                            self.flights[index]["Estimated Runway Departure Whole Number"] = "\(estimatedRunwayDepartureWholeNumber)"
                                            self.flights[index]["Estimated Runway Departure"] = "\(estimatedRunwayDeparture)"
                                            self.flights[index]["Scheduled Gate Departure Whole Number"] = "\(scheduledGateDepartureDateTimeWhole)"
                                            self.flights[index]["Converted Scheduled Gate Departure"] = "\(convertedScheduledGateDeparture)"
                                            self.flights[index]["Scheduled Gate Departure"] = "\(scheduledGateDeparture)"
                                            self.flights[index]["Scheduled Gate Departure UTC"] = "\(scheduledGateDepartureUTC)"
                                            self.flights[index]["Converted Published Departure"] = "\(convertedPublishedDeparture)"
                                            self.flights[index]["Published Departure Whole"] = "\(publishedDepartureWhole)"
                                            self.flights[index]["Published Departure"] = "\(publishedDeparture)"
                                            self.flights[index]["Converted Estimated Gate Departure"] = "\(convertedEstimatedGateDeparture)"
                                            self.flights[index]["Estimated Gate Departure Whole Number"] = "\(estimatedGateDepartureWholeNumber)"
                                            self.flights[index]["Estimated Gate Departure"] = "\(estimatedGateDeparture)"
                                            self.flights[index]["Estimated Gate Departure UTC"] = "\(estimatedGateDepartureUTC)"
                                            self.flights[index]["Converted Actual Gate Departure"] = "\(convertedActualGateDeparture)"
                                            self.flights[index]["Actual Gate Departure Whole"] = "\(actualGateDepartureWhole)"
                                            self.flights[index]["Actual Gate Departure UTC"] = "\(actualGateDepartureUtc)"
                                            self.flights[index]["Actual Gate Departure"] = "\(actualGateDeparture)"
                                            
                                            
                                            //arrival data
                                            self.flights[index]["Airport Arrival Terminal"] = "\(arrivalTerminal!)"
                                            self.flights[index]["Arrival Gate"] = "\(arrivalGate!)"
                                            
                                            //arrival timings
                                            self.flights[index]["Scheduled Runway Arrival Whole Number"] = "\(scheduledRunwayArrivalWholeNumber)"
                                            self.flights[index]["Converted Scheduled Runway Arrival"] = "\(convertedScheduledRunwayArrival)"
                                            self.flights[index]["Scheduled Runway Arrival UTC"] = "\(scheduledRunwayArrivalUtc)"
                                            self.flights[index]["Scheduled Runway Arrival"] = "\(scheduledRunwayArrival)"
                                            self.flights[index]["Actual Runway Arrival Whole Number"] = "\(actualRunwayArrivalWhole)"
                                            self.flights[index]["Converted Actual Runway Arrival"] = "\(convertedActualRunwayArrival)"
                                            self.flights[index]["Actual Runway Arrival UTC"] = "\(actualRunwayArrivalUtc)"
                                            self.flights[index]["Actual Runway Arrival"] = "\(actualRunwayArrival)"
                                            self.flights[index]["Estimated Runway Arrival Whole Number"] = "\(estimatedRunwayArrivalWhole)"
                                            self.flights[index]["Converted Estimated Runway Arrival"] = "\(convertedEstimatedRunwayArrival)"
                                            self.flights[index]["Estimated Runway Arrival UTC"] = "\(estimatedRunwayArrivalUtc)"
                                            self.flights[index]["Estimated Runway Arrival"] = "\(estimatedRunwayArrival)"
                                            self.flights[index]["Scheduled Gate Arrival Whole Number"] = "\(scheduledGateArrivalWholeNumber)"
                                            self.flights[index]["Converted Scheduled Gate Arrival"] = "\(convertedScheduledGateArrival)"
                                            self.flights[index]["Scheduled Gate Arrival UTC"] = "\(scheduledGateArrivalUtc)"
                                            self.flights[index]["Scheduled Gate Arrival"] = "\(scheduledGateArrival)"
                                            self.flights[index]["Converted Published Arrival"] = "\(convertedPublishedArrival)"
                                            self.flights[index]["Published Arrival Whole"] = "\(publishedArrivalWhole)"
                                            self.flights[index]["Published Arrival"] = "\(publishedArrival)"
                                            self.flights[index]["Estimated Gate Arrival Whole Number"] = "\(estimatedGateArrivalWholeNumber)"
                                            self.flights[index]["Converted Estimated Gate Arrival"] = "\(convertedEstimatedGateArrival)"
                                            self.flights[index]["Estimated Gate Arrival UTC"] = "\(estimatedGateArrivalUtc)"
                                            self.flights[index]["Estimated Gate Arrival"] = "\(estimatedGateArrival)"
                                            self.flights[index]["Converted Actual Gate Arrival"] = "\(convertedActualGateArrival)"
                                            self.flights[index]["Actual Gate Arrival Whole"] = "\(actualGateArrivalWhole)"
                                            self.flights[index]["Actual Gate Arrival"] = "\(actualGateArrival)"
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            UserDefaults.standard.set(self.flights, forKey: "flights")
                                            DispatchQueue.main.async {
                                                
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                                if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && self.flightId != 0 {
                                                    
                                                    let alert = UIAlertController(title: "\(String(describing: confirmedIncidentMessage))", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n" + NSLocalizedString("Would you like to add the replacement flight automatically?", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                        
                                                        self.parseFlightID(dictionary: self.flights[index], index: index)
                                                        
                                                    }))
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
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
                                                
                                                let departureDate = dictionary["Published Departure"]!
                                                let utcOffset = dictionary["Departure Airport UTC Offset"]!
                                                let departureCity = dictionary["Departure City"]!
                                                let arrivalCity = dictionary["Arrival City"]!
                                                let arrivalDate = dictionary["Published Arrival"]!
                                                let arrivalOffset = dictionary["Arrival Airport UTC Offset"]!
                                                
                                                let departingTerminal = "\(dictionary["Airport Departure Terminal"]!)"
                                                let departingGate = "\(dictionary["Departure Gate"]!)"
                                                let departingAirport = "\(dictionary["Departure Airport Code"]!)"
                                                let arrivalAirport = "\(dictionary["Arrival Airport Code"]!)"
                                                
                                                let flightNumber = self.airlineCodeURL! + self.flightNumberURL!
                                                
                                                if dictionary["48 Hour Notification"] == "true" {
                                                    
                                                    delegate?.schedule48HrNotification(estimatedDeparture: estimatedGateDeparture, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["4 Hour Notification"] == "true" {
                                                
                                                delegate?.schedule4HrNotification(estimatedDeparture: estimatedGateDeparture, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["2 Hour Notification"] == "true" {
                                                
                                                delegate?.schedule2HrNotification(estimatedDeparture: estimatedGateDeparture, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["1 Hour Notification"] == "true" {
                                                
                                                 delegate?.schedule1HourNotification(estimatedDeparture: estimatedGateDeparture, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["Taking Off Notification"] == "true" {
                                                
                                                delegate?.scheduleTakeOffNotification(estimatedDeparture: estimatedGateDeparture, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                }
                                                
                                                if dictionary["Landing Notification"] == "true" {
                                                
                                                delegate?.scheduleLandingNotification(estimatedArrival: estimatedGateArrival, arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                print("scheduled notifications")
                                                
                                            }
                                           self.getWeather(dictionary: self.flights[index], index: index)
                                                
                                            
                                        }
                                        
                                        if let flightIdCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightId"] as? Double {
                                            
                                            flightId = Int(flightIdCheck)
                                            self.flightIDString = String(flightId)
                                            
                                            if self.flightStatusFormatted == "Departed" {
                                                self.updateFlightFirstTime = true
                                                self.parseFlightIDForTracking(index: index)
                                            }
                                        }
                                        
                                        if self.didTapMarker {
                                            self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                        }
                                        
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
                
            var longitude:String!
            var latitude:String!
            var name:String!
            
            switch (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! {
            case "Departure Airport":
                longitude = self.flights[self.flightIndex]["Airport Departure Longitude"]!
                latitude = self.flights[self.flightIndex]["Airport Departure Latitude"]!
                name = self.flights[self.flightIndex]["Departure Airport Code"]!
            case "Arrival Airport":
                longitude = self.flights[self.flightIndex]["Airport Arrival Longitude"]!
                latitude = self.flights[self.flightIndex]["Airport Arrival Latitude"]!
                name = self.flights[self.flightIndex]["Arrival Airport Code"]!
            default:
                break
            }
            
            if longitude != nil && latitude != nil {
                
                let coordinate = CLLocationCoordinate2DMake(Double(latitude)!,Double(longitude)!)
                
                
                if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Which map would you like to use?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Apple Maps", comment: ""), style: .default, handler: { (action) in
                        
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                        mapItem.name = name
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Google Maps", comment: ""), style: .default, handler: { (action) in
                        
                        
                        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude!),\(longitude!)&directionsmode=driving")
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
        
            let departureDate = self.flights[self.flightIndex]["Published Departure"]!
            let utcOffset = self.flights[self.flightIndex]["Departure Airport UTC Offset"]!
            let didFlightTakeOff = didFlightAlreadyTakeoff(departureDate: departureDate, utcOffset: utcOffset)
                    
            if didFlightTakeOff == true {
                        
                let alert = UIAlertController(title: NSLocalizedString("Flight was scheduled to have already taken off.", comment: ""), message: NSLocalizedString("Please add a future flight to check for amenities", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
                        
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                }))
                        
                self.present(alert, animated: true, completion: nil)
                        
            } else {
                        
                let selectedFlight = self.flights[self.flightIndex]
                        
                UserDefaults.standard.set(selectedFlight, forKey: "selectedFlight")
                        
                self.performSegue(withIdentifier: "seatGuru", sender: self)
                        
            }
                    
    }
    
    func deleteFlight() {
        print("deleteFlight")
        
        let airlineCode = self.flights[self.flightIndex]["Airline Code"]!
        let flightNumber = self.flights[self.flightIndex]["Flight Number"]!
        let publishedDeparture = self.flights[self.flightIndex]["Published Departure"]!
        let estimatedDeparture = self.flights[self.flightIndex]["Estimated Gate Departure"]!
        let publishedArrival = self.flights[self.flightIndex]["Published Arrival"]!
        let estimatedArrival = self.flights[self.flightIndex]["Estimated Gate Arrival"]!
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete flight \(self.flights[self.flightIndex]["Airline Code"]!)\(self.flights[self.flightIndex]["Flight Number"]!)", comment: ""), style: .destructive, handler: { (action) in
                
                let center = UNUserNotificationCenter.current()
                
                center.delegate = self as? UNUserNotificationCenterDelegate
                
                center.getPendingNotificationRequests(completionHandler: { (notifications) in
                    
                    
                    for notification in notifications {
                        
                        if self.flights.count > 0 {
                            
                            if notification.identifier == "\(airlineCode)\(flightNumber)\(publishedDeparture)1HrNotification" || notification.identifier == "\(airlineCode)\(flightNumber)\(estimatedDeparture)1HrNotification" {
                                
                                center.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                                print("deleted notification \n\(notification.identifier)")
                                
                            } else if notification.identifier == "\(airlineCode)\(flightNumber)\(publishedDeparture)2HrNotification" || notification.identifier == "\(airlineCode)\(flightNumber)\(estimatedDeparture)2HrNotification" {
                                
                                center.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                                print("deleted notification \n\(notification.identifier)")
                                
                            } else if notification.identifier == "\(airlineCode)\(flightNumber)\(publishedDeparture)4HrNotification" || notification.identifier == "\(airlineCode)\(flightNumber)\(estimatedDeparture)4HrNotification" {
                                
                                center.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                                print("deleted notification \n\(notification.identifier)")
                                
                            } else if notification.identifier == "\(airlineCode)\(flightNumber)\(publishedDeparture)48HrNotification" || notification.identifier == "\(self.flights[self.flightIndex]["Airline Code"]!)\(airlineCode)\(flightNumber)\(estimatedDeparture)48HrNotification" {
                                
                                center.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                                print("deleted notification \n\(notification.identifier)")
                                
                            } else if notification.identifier == "\(airlineCode)\(flightNumber)\(publishedDeparture)TakeOffNotification" || notification.identifier == "\(airlineCode)\(flightNumber)\(estimatedDeparture)TakeOffNotification" {
                                
                                center.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                                print("deleted notification \n\(notification.identifier)")
                                
                            } else if notification.identifier == "\(airlineCode)\(flightNumber)\(publishedArrival)LandingNotification" || notification.identifier == "\(self.flights[self.flightIndex]["Airline Code"]!)\(airlineCode)\(flightNumber)\(estimatedArrival)LandingNotification" {
                                
                                center.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                                print("deleted notification \n\(notification.identifier)")
                            }
                        }
                    }
                    
                    self.flights.remove(at: self.flightIndex)
                    UserDefaults.standard.set(self.flights, forKey: "flights")
                    
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
                            //self.addButtons()
                        }
                    }
                    
                    if self.flights.count > 0 {
                        
                        self.resetFlightZeroViewdidappear()
                        
                    } else {
                        
                        DispatchQueue.main.async {
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
                            
                            self.nextFlightButton.removeFromSuperview()
                        }
                        
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func shareFlight() {
        
        print("shareflight")
        
        if self.isUserLoggedIn() == true {
            
                let alert = UIAlertController(title: NSLocalizedString("Share flight with", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                for user in self.userNames {
                    
                    alert.addAction(UIAlertAction(title: " \(user)", style: .default, handler: { (action) in
                        
                        
                        let flight = self.flights[self.flightIndex]
                        self.activityLabel.text = "Sharing"
                        
                        
                        let sharedFlight = PFObject(className: "SharedFlight")
                        
                        sharedFlight["shareToUsername"] = user
                        sharedFlight["shareFromUsername"] = PFUser.current()?.username
                        sharedFlight["flightDictionary"] = flight
                        
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
                                                
                                                print("fcmToken = \(fcmToken)")
                                                
                                                let username = (PFUser.current()?.username)!
                                                
                                                if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
                                                    
                                                    var request = URLRequest(url: url)
                                                    request.allHTTPHeaderFields = ["Content-Type":"application/json", "Authorization":"key=AAAASkgYWy4:APA91bFMTuMvXfwcVJbsKJqyBitkb9EUpvaHOkciT5wvtVHsaWmhxfLpqysRIdjgRaEDWKcb9tD5WCvqz67EvDyeSGswL-IEacN54UpVT8bhK1iAvKDvicOge6I6qaZDu8tAHOvzyjHs"]
                                                    request.httpMethod = "POST"
                                                    request.httpBody = "{\"to\":\"\(fcmToken)\",\"priority\":\"high\",\"notification\":{\"body\":\"\(username) shared a flight with you.\"}}".data(using: .utf8)
                                                    
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
            
            if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.topView.alpha = 1
                    self.arrivalInfoWindow.bottomView.alpha = 1
                    self.arrivalInfoWindow.flightIcon.alpha = 0.25
                    self.arrivalInfoWindow.flightIcon.image = UIImage(named: "airplane-landing-icon-256.png")
                }
                
                var departureTimeDuration = ""
                let departureOffset = self.flights[index]["Departure Airport UTC Offset"]!
                //var departureTime = ""
                let departureDate = self.flights[index]["Published Departure"]!
                let arrivalDate = self.flights[index]["Published Arrival"]!
                let arrivalOffset = self.flights[index]["Arrival Airport UTC Offset"]!
                var flightDuration = getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                var arrivalTimeDuration = ""
                var arrivalCountdown = ""
                var arrivalTime = ""
                
                //Departure heirarchy
                if self.flights[index]["Converted Published Departure"]! != "" {
                    
                    //departureTime = self.flights[index]["Converted Published Departure"]!
                    departureTimeDuration = self.flights[index]["Published Departure"]!
                    flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    publishedDeparture = departureTimeDuration
                }
                
                if self.flights[index]["Converted Scheduled Gate Departure"]! != "" {
                    
                    //departureTime = self.flights[index]["Converted Scheduled Gate Departure"]!
                    departureTimeDuration = self.flights[index]["Scheduled Gate Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                }
                
                if self.flights[index]["Converted Estimated Gate Departure"]! != "" {
                    
                    //departureTime = self.flights[index]["Converted Estimated Gate Departure"]!
                    departureTimeDuration = self.flights[index]["Estimated Gate Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                }
                
                if self.flights[index]["Converted Actual Gate Departure"]! != "" {
                    
                    //departureTime = self.flights[index]["Converted Actual Gate Departure"]!
                    departureTimeDuration = self.flights[index]["Actual Gate Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                }
                
                if self.flights[index]["Converted Actual Runway Departure"]! != "" {
                    
                    //departureTime = self.flights[index]["Converted Actual Runway Departure"]!
                    departureTimeDuration = self.flights[index]["Actual Runway Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                }
                
                //arrival heirarchy
                if self.flights[index]["Converted Published Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Published Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Published Arrival"]!
                    flightDuration = getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Scheduled Gate Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Scheduled Gate Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Scheduled Gate Arrival"]!
                    flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                }
                
                if self.flights[index]["Converted Estimated Runway Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Estimated Runway Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Estimated Runway Arrival"]!
                    flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Estimated Gate Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Estimated Gate Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Estimated Gate Arrival"]!
                    flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Actual Runway Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Actual Runway Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Actual Runway Arrival"]!
                    flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Actual Gate Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Actual Gate Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Actual Gate Arrival"]!
                    flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalFlightNumber.text = self.flights[index]["Airline Code"]! + self.flights[index]["Flight Number"]!
                self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                }
                if self.flights[index]["Flight Status"] == "" {
                    DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalStatus.text = ""
                    }
                } else {
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalStatus.text = self.flights[index]["Flight Status"]!
                    }
                }
                if self.flights[index]["Arrival Temperature"] != nil && self.flights[index]["Arrival Temperature"]! != "" {
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalTemperature.text = self.flights[index]["Arrival Temperature"]!
                    }
                }
                if self.flights[index]["Arrival Weather"] != nil && self.flights[index]["Arrival Weather"]! != "" {
                    
                    let weather = self.flights[index]["Arrival Weather"]!
                    let imageName = self.weatherImageName(weather: weather)
                    DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: imageName)
                    }
                }
                
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalAirportCode.text = "\(self.flights[index]["Arrival City"]!) " + "(\(self.flights[index]["Arrival Airport Code"]!))"
                self.arrivalInfoWindow.arrivalTerminal.text = self.flights[index]["Airport Arrival Terminal"]!
                self.arrivalInfoWindow.arrivalGate.text = self.flights[index]["Arrival Gate"]!
                self.arrivalInfoWindow.arrivalBaggageClaim.text = self.flights[index]["Baggage Claim"]!
                }
                publishedArrival = self.flights[index]["Published Arrival"]!
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalTime.text = arrivalTime
                }
                //work out whether it landed on time or late and by how much
                let arrivalTimeDifference = getTimeDifference(publishedTime: publishedArrival, actualTime: arrivalTimeDuration)
                if arrivalTimeDifference == "0min" {
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = NSLocalizedString("Arriving on time", comment: "") + ""
                    }
                }
                
                if self.flights[index]["Scheduled Gate Arrival Whole Number"]! != "" && self.flights[index]["Estimated Gate Arrival Whole Number"]! != ""  {
                    
                    if Double(self.flights[index]["Scheduled Gate Arrival Whole Number"]!)! < Double(self.flights[index]["Estimated Gate Arrival Whole Number"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Arriving", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("late", comment: ""))"
                        }
                        
                    } else if Double(self.flights[index]["Scheduled Gate Arrival Whole Number"]!)! > Double(self.flights[index]["Estimated Gate Arrival Whole Number"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Arriving", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        }
                    } else if Double(self.flights[index]["Scheduled Gate Arrival Whole Number"]!)! == Double(self.flights[index]["Estimated Gate Arrival Whole Number"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Arriving on time", comment: ""))"
                        }
                    }
                    
                }
                
                if self.flights[index]["Scheduled Runway Arrival Whole Number"]! != "" && self.flights[index]["Estimated Runway Arrival Whole Number"]! != "" {
                    
                    if Double(self.flights[index]["Scheduled Runway Arrival Whole Number"]!)! < Double(self.flights[index]["Estimated Runway Arrival Whole Number"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Arriving", comment: ""))\(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        }
                        
                    } else if Double(self.flights[index]["Scheduled Runway Arrival Whole Number"]!)! > Double(self.flights[index]["Estimated Runway Arrival Whole Number"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Arriving", comment: ""))\(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        }
                    }
                    
                    //checks delay time once flight has landed
                }
                
                if self.flights[index]["Scheduled Gate Arrival Whole Number"]! != "" && self.flights[index]["Actual Gate Arrival Whole"]! != "" {
                    
                    if Double(self.flights[index]["Scheduled Gate Arrival Whole Number"]!)! < Double(self.flights[index]["Actual Gate Arrival Whole"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("late", comment: ""))"
                        }
                    } else if Double(self.flights[index]["Scheduled Gate Arrival Whole Number"]!)! > Double(self.flights[index]["Actual Gate Arrival Whole"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Landed", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        }
                    }
                    
                }
                
                if self.flights[index]["Actual Runway Arrival Whole Number"]! != "" {
                    
                    if Double(self.flights[index]["Arrival Date Number"]!)! < Double(self.flights[index]["Actual Runway Arrival Whole Number"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Arrived at gate", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("late", comment: ""))"
                        }
                    } else if Double(self.flights[index]["Arrival Date Number"]!)! > Double(self.flights[index]["Actual Runway Arrival Whole Number"]!)! {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Arrived at gate", comment: "")) \(arrivalTimeDifference) \(NSLocalizedString("early", comment: ""))"
                        }
                    }
                    
                }
                
                arrivalCountdown = arrivalTimeDuration
                
                DispatchQueue.main.async {
                    
                    self.arrivalInfoWindow.arrivalMins.isHidden = false
                    self.arrivalInfoWindow.arrivalHours.isHidden = false
                    self.arrivalInfoWindow.arrivaldays.isHidden = false
                    self.arrivalInfoWindow.arrivalMonths.isHidden = false
                    self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalMinsLabel.isHidden = false
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                    self.arrivalInfoWindowTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                        (_) in
                        
                        let monthsLeft = countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).months
                        let daysLeft = countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).days
                        let hoursLeft = countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).hours
                        let minutesLeft = countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).minutes
                        let secondsLeft = countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).seconds
                        
                        DispatchQueue.main.async {
                            self.arrivalInfoWindow.arrivalMonths.text = "\(monthsLeft)"
                            self.arrivalInfoWindow.arrivaldays.text = "\(daysLeft)"
                            self.arrivalInfoWindow.arrivalHours.text = "\(hoursLeft)"
                            self.arrivalInfoWindow.arrivalMins.text = "\(minutesLeft)"
                            self.arrivalInfoWindow.arrivalSeconds.text = "\(secondsLeft)"
                        }
                        
                        if monthsLeft == 0 {
                            
                            self.arrivalInfoWindow.arrivalMonths.isHidden = true
                            self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                         
                        }
                        
                        if daysLeft == 0 && monthsLeft == 0 {
                            
                            self.arrivalInfoWindow.arrivaldays.isHidden = true
                            self.arrivalInfoWindow.arrivalMonths.isHidden = true
                            self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                            
                        }
                        
                        if hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                            
                            self.arrivalInfoWindow.arrivalHours.isHidden = true
                            self.arrivalInfoWindow.arrivaldays.isHidden = true
                            self.arrivalInfoWindow.arrivalMonths.isHidden = true
                            self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalHoursLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                        }
                        
                        if minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                            
                            self.arrivalInfoWindow.arrivalMins.isHidden = true
                            self.arrivalInfoWindow.arrivalHours.isHidden = true
                            self.arrivalInfoWindow.arrivaldays.isHidden = true
                            self.arrivalInfoWindow.arrivalMonths.isHidden = true
                            self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                            self.arrivalInfoWindow.arrivalHoursLabel.isHidden = true
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
                
            } else if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                
                self.showDepartureWindow(index: index)
                
            }
        }
    }

    func getAirportCoordinates(flight: [String : String], index: Int) {
        
        print("getAirportCoordinates")
        
        if self.flights.count > 0 {
            
            DispatchQueue.main.async {
                
                if self.flights.count > 1 {
                    self.nextFlightButton.removeFromSuperview()
                    
                    if self.flightIndex + 1 == self.flights.count {
                        DispatchQueue.main.async {
                            self.nextFlightButton.setTitle("Show First Flight", for: .normal)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.nextFlightButton.setTitle("Show Next Flight", for: .normal)
                        }
                    }
                    self.googleMapsView.addSubview(self.nextFlightButton)
                } else {
                    DispatchQueue.main.async {
                        self.nextFlightButton.setTitle("Show First Flight", for: .normal)
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
                        
                        let departureLongitude = Double(flight["Airport Departure Longitude"]!)
                        let departureLatitude = Double(flight["Airport Departure Latitude"]!)
                        let arrivalLongitude = Double(flight["Airport Arrival Longitude"]!)
                        let arrivalLatitude = Double(flight["Airport Arrival Latitude"]!)
                        
                        
                        departureAirportCoordinates = CLLocationCoordinate2D(latitude: departureLatitude!, longitude: departureLongitude!)
                        arrivalAirportCoordinates = CLLocationCoordinate2D(latitude: arrivalLatitude!, longitude: arrivalLongitude!)
                        
                        let departurePosition = departureAirportCoordinates
                        let arrivalPosition = arrivalAirportCoordinates
                        path.add(departurePosition)
                        path.add(arrivalPosition)
                        
                        var eastToWest = Bool()
                        if departureLongitude! > arrivalLongitude! {
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
    
    func getWeather(dictionary: [String:String], index: Int) {
        
        print("get weather for all flights")
        var departureWeatherDescription = ""
        var departureTemperature = ""
        var arrivalWeatherDescription = ""
        var arrivalTemperature = ""
        let departureLatitude = self.flights[index]["Airport Departure Latitude"]!
        let departureLongitude = self.flights[index]["Airport Departure Longitude"]!
        let departureUrl = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=" + departureLatitude + "&lon=" + departureLongitude + "&units=imperial&appid=08e64df2d3f3bc0822de1f0fc22fcb2d")!
        
        let departureTask = URLSession.shared.dataTask(with: departureUrl) { (data, response, error) in
            
            if error != nil {
                
                print("error")
                print(error as Any)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let departureJsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if let departureWeatherDescriptionCheck = ((departureJsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String {
                            departureWeatherDescription = departureWeatherDescriptionCheck
                        }
                        
                        if let departureTempCheck = (departureJsonResult["main"] as? NSDictionary)?["temp"] as? Double {
                            let departureTemp = Int(departureTempCheck)
                            let departureTempCelsius = Int((departureTemp - 32) * 5/9)
                            departureTemperature = "\(departureTemp)°F\n\(departureTempCelsius)°C"
                        }
                        
                        DispatchQueue.main.async {
                            self.flights[index]["Departure Weather"] = "\(departureWeatherDescription)"
                            self.flights[index]["Departure Temperature"] = "\(departureTemperature)"
                            UserDefaults.standard.set(self.flights, forKey: "flights")
                        }
                        
                    } catch {
                        print("JSON Processing Failed")
                    }
                }
            }
        }
        
        departureTask.resume()
        
        let arrivalLatitude = flights[index]["Airport Arrival Latitude"]!
        let arrivalLongitude = flights[index]["Airport Arrival Longitude"]!
        let arrivalUrl = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=" + arrivalLatitude + "&lon=" + arrivalLongitude + "&units=imperial&appid=08e64df2d3f3bc0822de1f0fc22fcb2d")!
        
        let arrivalTask = URLSession.shared.dataTask(with: arrivalUrl) { (data, response, error) in
            
            if error != nil {
                
                print("error")
                print(error as Any)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let arrivalJsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if let arrivalDescription = ((arrivalJsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String {
                            arrivalWeatherDescription = arrivalDescription
                        }
                        
                        if let arrivalTempCheck = (arrivalJsonResult["main"] as? NSDictionary)?["temp"] as? Double {
                            let arrivalTemp = Int(arrivalTempCheck)
                            let arrivalTempCelsius = Int((arrivalTemp - 32) * 5/9)
                            arrivalTemperature = "\(arrivalTemp)°F\n\(arrivalTempCelsius)°C"
                        }
                        
                        DispatchQueue.main.async {
                            self.flights[index]["Arrival Weather"] = "\(arrivalWeatherDescription)"
                            self.flights[index]["Arrival Temperature"] = "\(arrivalTemperature)"
                            UserDefaults.standard.set(self.flights, forKey: "flights")
                        }
                        
                    } catch {
                        print("JSON Processing Failed")
                    }
                }
            }
        }
        arrivalTask.resume()
    }
    
    func resetFlightZeroViewdidappear() {
        
        print("resetFlightZeroViewdidappear")
        
        for (index, flight) in self.flights.enumerated() {
            getWeather(dictionary: flight, index: index)
        }
        DispatchQueue.main.async {
            self.liveFlightMarker.map = nil
            self.getAirportCoordinates(flight: self.flights[0], index: 0)
        }
        
    }
    
    
    func parseFlightIDForTracking(index: Int) {
        
        print("parseFlightIDForTracking")
        
        let url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/track/\(self.flightIDString!)?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87&includeFlightPlan=false&maxPositions=1&sourceType=derived")
        
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
                                    
                                    DispatchQueue.main.async {
                                        self.activityIndicator.stopAnimating()
                                        self.blurEffectViewActivity.removeFromSuperview()
                                        self.activityLabel.removeFromSuperview()
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    @IBAction func backToNearMe(segue:UIStoryboardSegue) {}
    
    func showDepartureWindow(index: Int) {
        
        resetTimers()
        var departureTimeDuration = ""
        var departureCountDown = ""
        let departureOffset = self.flights[index]["Departure Airport UTC Offset"]!
        var departureTime = ""
        let departureDate = self.flights[index]["Published Departure"]!
        let arrivalDate = self.flights[index]["Published Arrival"]!
        let arrivalOffset = self.flights[index]["Arrival Airport UTC Offset"]!
        var flightDuration = getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        var arrivalTimeDuration = ""
        //var arrivalTime = ""
        
        //Departure heirarchy
        if self.flights[index]["Converted Published Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Published Departure"]!
            departureTimeDuration = self.flights[index]["Published Departure"]!
            flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                self.arrivalInfoWindow.flightIcon.alpha = 0.25
                self.arrivalInfoWindow.flightIcon.image = UIImage(named: "26_Airplane_take_off-512.png")
            }
            publishedDeparture = departureTimeDuration
        }
        
        if self.flights[index]["Converted Scheduled Gate Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Scheduled Gate Departure"]!
            departureTimeDuration = self.flights[index]["Scheduled Gate Departure"]!
            self.actualTakeOff = departureTimeDuration
            flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Estimated Gate Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Estimated Gate Departure"]!
            departureTimeDuration = self.flights[index]["Estimated Gate Departure"]!
            self.actualTakeOff = departureTimeDuration
            flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Actual Gate Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Actual Gate Departure"]!
            departureTimeDuration = self.flights[index]["Actual Gate Departure"]!
            self.actualTakeOff = departureTimeDuration
            flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Actual Runway Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Actual Runway Departure"]!
            departureTimeDuration = self.flights[index]["Actual Runway Departure"]!
            self.actualTakeOff = departureTimeDuration
            flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        //arrival heirarchy
        if self.flights[index]["Converted Published Arrival"]! != "" {
            
            //arrivalTime = self.flights[index]["Converted Published Arrival"]!
            arrivalTimeDuration = self.flights[index]["Published Arrival"]!
            flightDuration = getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Scheduled Gate Arrival"]! != "" {
            
            //arrivalTime = self.flights[index]["Converted Scheduled Gate Arrival"]!
            arrivalTimeDuration = self.flights[index]["Scheduled Gate Arrival"]!
            flightDuration = getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Estimated Runway Arrival"]! != "" {
            
            //arrivalTime = self.flights[index]["Converted Estimated Runway Arrival"]!
            arrivalTimeDuration = self.flights[index]["Estimated Runway Arrival"]!
            flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Estimated Gate Arrival"]! != "" {
            
            //arrivalTime = self.flights[index]["Converted Estimated Gate Arrival"]!
            arrivalTimeDuration = self.flights[index]["Estimated Gate Arrival"]!
            flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Actual Runway Arrival"]! != "" {
            
            //arrivalTime = self.flights[index]["Converted Actual Runway Arrival"]!
            arrivalTimeDuration = self.flights[index]["Actual Runway Arrival"]!
            flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        if self.flights[index]["Converted Actual Gate Arrival"]! != "" {
            
            //arrivalTime = self.flights[index]["Converted Actual Gate Arrival"]!
            arrivalTimeDuration = self.flights[index]["Actual Gate Arrival"]!
            flightDuration = getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        }
        
        DispatchQueue.main.async {
            self.arrivalInfoWindow.arrivalFlightNumber.text = self.flights[index]["Airline Code"]! + self.flights[index]["Flight Number"]!
            self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
        }
        
        if self.flights[index]["Flight Status"] == "" {
            DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalStatus.text = ""
            }
        } else {
            DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalStatus.text = self.flights[index]["Flight Status"]!
            }
        }
        
        if self.flights[index]["Departure Temperature"] != nil && self.flights[index]["Departure Temperature"]! != "" {
            DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalTemperature.text = self.flights[index]["Departure Temperature"]!
            }
        }
        
        if self.flights[index]["Departure Weather"] != nil && self.flights[index]["Departure Weather"]! != "" {
            
            let weather = self.flights[index]["Departure Weather"]!
            let imageName = self.weatherImageName(weather: weather)
            DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: imageName)
            }
        }
        
        DispatchQueue.main.async {
            self.arrivalInfoWindow.arrivalAirportCode.text = "\(self.flights[index]["Departure City"]!) " + "(\(self.flights[index]["Departure Airport Code"]!))"
            self.arrivalInfoWindow.arrivalTerminal.text = self.flights[index]["Airport Departure Terminal"]!
            self.arrivalInfoWindow.arrivalGate.text = self.flights[index]["Departure Gate"]!
            self.arrivalInfoWindow.arrivalBaggageClaim.text = "-"
        }
        
        //work out whether it took off on time or late and by how much
        let departureTimeDifference = getTimeDifference(publishedTime: publishedDeparture, actualTime: departureTimeDuration)
        
        if self.flights[index]["Departure Date Number"]! != "" && self.flights[index]["Estimated Gate Departure Whole Number"]! != "" {
            
            if Double(self.flights[index]["Departure Date Number"]!)! < Double(self.flights[index]["Estimated Gate Departure Whole Number"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("late", comment: ""))"
                }
                
            } else if Double(self.flights[index]["Departure Date Number"]!)! > Double(self.flights[index]["Estimated Gate Departure Whole Number"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                }
            }
        }
        
        if departureTimeDifference == "0min" {
            DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalDelayTime.text = NSLocalizedString("Departing on time", comment: "")
            }
        }
        
        if self.flights[index]["Departure Date Number"]! != "" && self.flights[index]["Estimated Runway Departure Whole Number"]! != "" {
            
            if Double(self.flights[index]["Departure Date Number"]!)! < Double(self.flights[index]["Estimated Runway Departure Whole Number"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("late", comment: ""))"
                }
                
            } else if Double(self.flights[index]["Departure Date Number"]!)! > Double(self.flights[index]["Estimated Runway Departure Whole Number"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departing", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                }
            }
            //checks delay time once flight has taken off
        }
        
        if self.flights[index]["Scheduled Gate Departure Whole Number"]! != "" && self.flights[index]["Actual Gate Departure Whole"]! != "" {
            
            if Double(self.flights[index]["Scheduled Gate Departure Whole Number"]!)! < Double(self.flights[index]["Actual Gate Departure Whole"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departed", comment: "")) \(departureTimeDifference) \(NSLocalizedString("late", comment: ""))"
                }
            } else if Double(self.flights[index]["Departure Date Number"]!)! > Double(self.flights[index]["Actual Gate Departure Whole"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "\(NSLocalizedString("Departed", comment: "")) \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                }
            } else {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "Departed on time"
                }
            }
        }
        
        if self.flights[index]["Actual Runway Departure Whole Number"]! != "" {
            
            if Double(self.flights[index]["Departure Date Number"]!)! < Double(self.flights[index]["Actual Runway Departure Whole Number"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "Took off \(departureTimeDifference) \(NSLocalizedString("late", comment: ""))"
                }
            } else if Double(self.flights[index]["Departure Date Number"]!)! > Double(self.flights[index]["Actual Runway Departure Whole Number"]!)! {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "Took off \(departureTimeDifference) \(NSLocalizedString("early", comment: ""))"
                }
            } else {
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = "Departed on time"
                }
            }
        }
        
        DispatchQueue.main.async {
            self.arrivalInfoWindow.arrivalTime.text = departureTime
        }
        
        departureCountDown = departureTimeDuration
        
        DispatchQueue.main.async {
            self.arrivalInfoWindow.arrivalMins.isHidden = false
            self.arrivalInfoWindow.arrivalHours.isHidden = false
            self.arrivalInfoWindow.arrivaldays.isHidden = false
            self.arrivalInfoWindow.arrivalMonths.isHidden = false
            self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = false
            self.arrivalInfoWindow.arrivalDaysLabel.isHidden = false
            self.arrivalInfoWindow.arrivalHoursLabel.isHidden = false
            self.arrivalInfoWindow.arrivalMinsLabel.isHidden = false
            self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
            self.departureInfoWindowTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                (_) in
                
                let monthsLeft = countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).months
                let daysLeft = countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).days
                let hoursLeft = countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).hours
                let minutesLeft = countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).minutes
                let secondsLeft = countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).seconds
                
                DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalMonths.text = "\(monthsLeft)"
                    self.arrivalInfoWindow.arrivaldays.text = "\(daysLeft)"
                    self.arrivalInfoWindow.arrivalHours.text = "\(hoursLeft)"
                    self.arrivalInfoWindow.arrivalMins.text = "\(minutesLeft)"
                    self.arrivalInfoWindow.arrivalSeconds.text = "\(secondsLeft)"
                }
                
                if monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivalMonths.isHidden = true
                    self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
                
                if daysLeft == 0 && monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivaldays.isHidden = true
                    self.arrivalInfoWindow.arrivalMonths.isHidden = true
                    self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
                
                if hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivalHours.isHidden = true
                    self.arrivalInfoWindow.arrivaldays.isHidden = true
                    self.arrivalInfoWindow.arrivalMonths.isHidden = true
                    self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                }
                
                if minutesLeft == 0 && hoursLeft == 0 && daysLeft == 0 && monthsLeft == 0 {
                    self.arrivalInfoWindow.arrivalMins.isHidden = true
                    self.arrivalInfoWindow.arrivalHours.isHidden = true
                    self.arrivalInfoWindow.arrivaldays.isHidden = true
                    self.arrivalInfoWindow.arrivalMonths.isHidden = true
                    self.arrivalInfoWindow.arrivalMonthsLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalDaysLabel.isHidden = true
                    self.arrivalInfoWindow.arrivalHoursLabel.isHidden = true
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
                        
                        let currentflightcount = self.flights.count
                        
                        if sharedFlights!.count > 0 {
                            
                            var sharedFromArray = [String]()
                            
                            for flight in sharedFlights! {
                                
                                //parse flight
                                let flightDictionary = flight["flightDictionary"]
                                let dictionary = flightDictionary as! NSDictionary
                                print("shared flight = \(flight)")
                                sharedFromArray.append(flight["shareFromUsername"] as! String)
                                self.flights.append(dictionary as! [String:String])
                                self.parseLeg2Only(dictionary: dictionary as! [String:String], index: self.flights.count - 1)
                                UserDefaults.standard.set(self.flights, forKey: "flights")
                                self.getWeather(dictionary: dictionary as! [String:String], index: self.flights.count - 1)
                                
                                flight.deleteInBackground(block: { (success, error) in
                                    
                                    if error != nil {
                                        print("error = \(error as Any)")
                                    } else {
                                        print("flight deleted from parse database")
                                    }
                                })
                            }
                            
                            DispatchQueue.main.async {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                if currentflightcount == 0 {
                                    self.getAirportCoordinates(flight: self.flights[0], index: 0)
                                }
                                let unique = Array(Set(sharedFromArray))
                                var string = (unique.description).replacingOccurrences(of: "[", with: "")
                                string = string.replacingOccurrences(of: "]", with: "")
                                
                                displayAlert(viewController: self, title: "Receieved flights", message: "\(string) has shared flights with you, tap the next flight button to toggle between the flights or tap the table icon to see them all.")
                            }
                            
                        }
                    }
               }
            }
                
                /*if let pfObjects = sharedFlights as? [PFObject] {
                    
                    if pfObjects.count > 0 {
                        
                        DispatchQueue.main.async {
                            
                            var senderUsername = "unknown"
                            
                            if let username = pfObjects[0]["shareFromUsername"] as? String {
                                
                                senderUsername = username
                                
                            }
                            
                            let alertController = UIAlertController(title: "\(senderUsername) " + NSLocalizedString("shared a flight with you", comment: ""), message: "", preferredStyle: .alert)
                            
                            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        }
                        
                        for flight in pfObjects {
                            
                            let getSharedFlightQuery = PFQuery(className: "SharedFlight")
                            
                            getSharedFlightQuery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
                            
                            getSharedFlightQuery.findObjectsInBackground { (sharedFlights, error) in
                                
                                if error != nil {
                                    
                                    print("error = \(error as Any)")
                                    
                                } else {
                                    
                                    //parse flight
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                                    let flightDictionary = flight["flightDictionary"]
                                    let dictionary = flightDictionary as! NSDictionary
                                    self.flights.append(dictionary as! [String:String])
                                    self.parseLeg2Only(dictionary: dictionary as! [String:String], index: self.flights.count - 1)
                                    UserDefaults.standard.set(self.flights, forKey: "flights")
                                    self.getWeather(dictionary: dictionary as! [String:String], index: self.flights.count - 1)
                                    
                                    flight.deleteInBackground(block: { (success, error) in
                                        
                                        if error != nil {
                                            print("error = \(error as Any)")
                                        } else {
                                            print("flight deleted")
                                        }
                                    })
                                }
                            }
                        }
                    }
                }*/
            
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
}




