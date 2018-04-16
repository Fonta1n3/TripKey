//
//  NearMeViewController.swift
//  TripKey2
//
//  Created by Peter on 2/1/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import MapKit
import Parse
import SystemConfiguration
import StoreKit
import Foundation
import WatchConnectivity
import UserNotifications

class NearMeViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate, UISearchBarDelegate, LocateOnTheMap, SKProductsRequestDelegate, SKPaymentTransactionObserver, WCSessionDelegate {
    
    var usersLocationMode:Bool!
    var buttonsVisible = true
    var showArrivalWindow = false
    var session: WCSession?
    var userMarkerArray:[GMSMarker] = []
    var followedUsers = [Dictionary<String,Any>]()
    var howManyTimesUsed:[Int]! = []
    var infoWindowIsVisible = false
    //var bottomToolBarVisible:Bool!
    @IBOutlet var bottomToolbar: UIToolbar!
    var usersHeading:Double!
    //var buttonsVisible:Bool!
    var showUsersButton = UIButton(type: .custom)
    var fitFlightsButton = UIButton(type: .custom)
    var nearMeButtonNew = UIButton(type: .custom)
    var findPlacesButtonNew = UIButton(type: .custom)
    var streetViewButtonNew = UIButton(type: .custom)
    var addPlaceButtonNew = UIButton(type: .custom)
    var flightIndex:Int!
    var bearing:Double!
    var iconZoom:Float!
    var position:CLLocationCoordinate2D!
    var icon:UIImage!
    var overlay:GMSGroundOverlay!
    @IBOutlet var findPlacesLabel: UIButton!
    var flightIDString:String!
    let arrivalInfoWindow = Bundle.main.loadNibNamed("Arrival Info Window", owner: self, options: nil)?[0] as! ArrivalInfoWindow
    let blurEffectViewFlightInfoWindow = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewFlightInfoWindowBottom = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewFlightInfoWindowTop = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    var ascending = true
    var descending = false
    let hoursOfOperation = Bundle.main.loadNibNamed("OpeningHours", owner: self, options: nil)?[0] as! HoursOfOperation
    let editplaceInfoViewNearMe = Bundle.main.loadNibNamed("editPlaceInfoView", owner: self, options: nil)?[0] as! editPlaceInfoView
    let blurEffectView3 = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectView4 = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectView5 = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    var photoIndex:Int = 0
    var imageArrayStrings:[String]! = []
    var photoArray:[GMSPlacePhotoMetadata]! = []
    var attributedTextArray:[NSAttributedString]! = []
    var swiping = false
    var swipingPic = false
    let PREMIUM_PRODUCT_ID = "com.TripKeyLite.unlockPremium"
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    var connected:Bool!
    var city = ""
    var state = ""
    var country = ""
    var address:String!
    var category:String!
    var types:[String]!
    var imageFiles = [PFFile]()
    @IBOutlet var communityButton: UIView!
    @IBOutlet var flightsButton: UIView!
    @IBOutlet var myPlacesButton: UIView!
    var imageArray:[UIImage]! = []
    let recognizer = UITapGestureRecognizer()
    let recognizerTopView = UITapGestureRecognizer()
    let longPressRecognizer = UILongPressGestureRecognizer()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectView2 = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewTopView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let blurEffectViewBottomView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var name:String!
    var users = [String: String]()
    var placeId:String!
    var userNames = [String]()
    var website:String!
    var phoneNumberString:String!
    var sortedPlaces = [Dictionary<String,String>]()
    var tappedMarkerIndex:Int!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var topView: UIView!
    var resultsArray = [String]()
    var searchBar = UISearchBar()
    var searchResultController:SearchResultsController!
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
    var placeDictionary:Dictionary<String,String>!
    var placeDictionaries = [Dictionary<String,String>]()
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
    let placeInfoWindow  = Bundle.main.loadNibNamed("placeInfoWindow", owner: self, options: nil)?[0] as! placeInfoWindow
    let placeAddInput = Bundle.main.loadNibNamed("placeAddInput", owner: self, options: nil)?[0] as! addPlaceDetails
    var latitude:Double!
    var longitude:Double!
    var locationManager = CLLocationManager()
    var buttonPanoView = UIButton()
    var button = UIButton()
    var userLongpressedCoordinates:CLLocationCoordinate2D!
    var tappedCoordinates:CLLocationCoordinate2D!
    var panoView:GMSPanoramaView!
    var placeMarkerArray:[GMSMarker] = []
    var biasmarker:GMSMarker!
    var placesSubCategories:[[String]]!
    var placeSubCategories:[[String]]!
    @IBOutlet var mapView: UIView!
    var int:Int!
    var userTappedRoute:Bool!
    var trackAirplaneTimer:Timer!
    var updateFlightFirstTime:Bool!
    var photosMode:Bool!
    var reviewsMode:Bool!
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
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
            
            let alert = UIAlertController(title: NSLocalizedString("You are not logged in.", comment: ""), message: NSLocalizedString("Please log in to share and access \"Community\" features.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: ""), style: .default, handler: { (action) in
                
                
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Log In", comment: ""), style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "logIn", sender: self)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
        if overlay.accessibilityLabel?.components(separatedBy: ", ")[0] == "Airplane Location" {
            
            self.updateFlightFirstTime = true
            let index = Int((overlay.accessibilityLabel?.components(separatedBy: ", ")[1])!)
            self.parseLeg2Only(dictionary: flights[index!], index: index!)
            
            let newPosition = GMSCameraPosition.camera(withLatitude: self.position.latitude, longitude: self.position.longitude, zoom: 14, bearing: self.bearing, viewingAngle: 25)
            
            CATransaction.begin()
            CATransaction.setValue(Int(5), forKey: kCATransactionAnimationDuration)
            self.googleMapsView.animate(to: newPosition)
            CATransaction.commit()
            
            
            
            self.trackAirplaneTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {
                (_) in
                
                self.parseFlightIDForTracking(index: index!)
                
            }
            
        } else if overlay.accessibilityLabel?.components(separatedBy: ", ")[0] == "routePolyline" {
            
            self.userTappedRoute = true
            let index = Int((overlay.accessibilityLabel?.components(separatedBy: ", ")[1])!)
            self.flightIndex = index
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(departureMarkerArray[index!].position)
            bounds = bounds.includingCoordinate(arrivalMarkerArray[index!].position)
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds))
            self.parseLeg2Only(dictionary: flights[index!], index: index!)
            
        }
        
    }
    
    func isInternetAvailable() -> Bool {
        
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
        self.connected = isReachable
        return (isReachable && !needsConnection)
    }
    
    func cancelPlaceInfo() {
        
        print("cancelPlaceInfo")
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.editplaceInfoViewNearMe.alpha = 0
            self.blurEffectView3.alpha = 0
            
        }) { _ in
            
            self.blurEffectView3.removeFromSuperview()
            self.editplaceInfoViewNearMe.removeFromSuperview()
            
        }
        
    }
    
    func savePlaceInfo() {
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        for (_, placeDictionary) in self.placeDictionaries.enumerated() {
            
            if placeDictionary["Place ID"] == self.placeDictionaries[self.tappedMarkerIndex]["Place ID"] {
                
                for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                    
                    if place["Place ID"] == placeDictionary["Place ID"] {
                        
                        
                        self.userAddedPlaceDictionaryArray[index]["Place Notes"] = self.editplaceInfoViewNearMe.placeNotes.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Name"] = self.editplaceInfoViewNearMe.placeName.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Address"] = self.editplaceInfoViewNearMe.placeAddress.text!
                        self.userAddedPlaceDictionaryArray[index]["Place City"] = self.editplaceInfoViewNearMe.placeCity.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Country"] = self.editplaceInfoViewNearMe.placeCountry.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Type"] = self.editplaceInfoViewNearMe.placeType.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Phone Number"] = self.editplaceInfoViewNearMe.placePhoneNumber.text!
                        self.userAddedPlaceDictionaryArray[index]["Place State"] = self.editplaceInfoViewNearMe.placeState.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Website"] = self.editplaceInfoViewNearMe.placeWebsite.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Latitude"] = self.editplaceInfoViewNearMe.placeLatitude.text!
                        self.userAddedPlaceDictionaryArray[index]["Place Longitude"] = self.editplaceInfoViewNearMe.placeLongitude.text!
                        
                        UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                        
                    }
                    
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.editplaceInfoViewNearMe.alpha = 0
                    self.blurEffectView3.alpha = 0
                    
                }) { _ in
                    
                    self.editplaceInfoViewNearMe.placeNotes.text! = ""
                    self.editplaceInfoViewNearMe.placeName.text! = ""
                    self.editplaceInfoViewNearMe.placeAddress.text! = ""
                    self.editplaceInfoViewNearMe.placeCity.text! = ""
                    self.editplaceInfoViewNearMe.placeCountry.text! = ""
                    self.editplaceInfoViewNearMe.placeType.text! = ""
                    self.editplaceInfoViewNearMe.placePhoneNumber.text! = ""
                    self.editplaceInfoViewNearMe.placeState.text! = ""
                    self.editplaceInfoViewNearMe.placeWebsite.text! = ""
                    self.editplaceInfoViewNearMe.placeLatitude.text! = ""
                    self.editplaceInfoViewNearMe.placeLongitude.text! = ""
                    
                    self.blurEffectView3.removeFromSuperview()
                    self.editplaceInfoViewNearMe.removeFromSuperview()
                    
                }
                
                self.displayAlert(title: "Place info saved", message: "")
                
            }
        }
        
   }
    
    func closeHoursOfOperation() {
        
        print("cancelPlaceInfo")
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.hoursOfOperation.alpha = 0
            self.blurEffectView4.alpha = 0
            
        }) { _ in
            
            self.blurEffectView4.removeFromSuperview()
            self.hoursOfOperation.removeFromSuperview()
            
        }
        
    }
    
    func topViewHasBeenTapped() {
        
        print("topViewHasBeenTapped")
        
        hoursOfOperation.hoursOfOperationTitle.text = NSLocalizedString("Hours Of Operation", comment: "")
        hoursOfOperation.close.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        hoursOfOperation.close.addTarget(self, action: #selector(self.closeHoursOfOperation), for: .touchUpInside)
        self.hoursOfOperation.frame = self.view.bounds
        self.hoursOfOperation.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView4.frame = self.view.bounds
        self.blurEffectView4.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView4.alpha = 0
        self.hoursOfOperation.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blurEffectView4.alpha = 1
            self.hoursOfOperation.alpha = 1
            self.view.addSubview(self.blurEffectView4)
            self.view.addSubview(self.hoursOfOperation)
            
        }) { _ in
            
        }

    }

    func imageHasBeenTapped(){
        
        print("image tapped")
        self.editplaceInfoViewNearMe.frame = self.view.bounds
        self.editplaceInfoViewNearMe.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView3.frame = self.view.bounds
        self.blurEffectView3.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView3.alpha = 0
        self.editplaceInfoViewNearMe.alpha = 0
        self.editplaceInfoViewNearMe.save.addTarget(self, action: #selector(self.savePlaceInfo), for: .touchUpInside)
        self.editplaceInfoViewNearMe.cancel.addTarget(self, action: #selector(self.cancelPlaceInfo), for: .touchUpInside)
        self.editplaceInfoViewNearMe.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        if UserDefaults.standard.object(forKey: "placeDictionaries") != nil {
         self.placeDictionaries = UserDefaults.standard.object(forKey: "placeDictionaries") as! [Dictionary<String,String>]
        }
        
        var placeSaved:Bool!
        
        if self.placeDictionaries != nil && self.placeDictionaries.count > 0 {
            
            for (_, placeDictionary) in self.placeDictionaries.enumerated() {
                
                if placeDictionary["Place ID"] == self.placeDictionaries[self.tappedMarkerIndex]["Place ID"] {
                    
                    if UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") != nil {
                        
                        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                        
                        placeSaved = false
                        
                        for (index2, place) in self.userAddedPlaceDictionaryArray.enumerated() {
                            
                            if place["Place ID"] == placeDictionary["Place ID"] {
                                
                                placeSaved = true
                                
                                self.editplaceInfoViewNearMe.nameLabel.adjustsFontSizeToFitWidth = true
                                self.editplaceInfoViewNearMe.cityLabel.adjustsFontSizeToFitWidth = true
                                self.editplaceInfoViewNearMe.editPlaceInfo.text = NSLocalizedString("Edit Place Info", comment: "")
                                self.editplaceInfoViewNearMe.nameLabel.text = NSLocalizedString("Place Name:", comment: "")
                                self.editplaceInfoViewNearMe.addressLabel.text = NSLocalizedString("Place Address: (optional)", comment: "")
                                self.editplaceInfoViewNearMe.phoneNumberLabel.text = NSLocalizedString("Place Phone Number:", comment: "")
                                self.editplaceInfoViewNearMe.websiteLabel.text = NSLocalizedString("Place Website:", comment: "")
                                self.editplaceInfoViewNearMe.countryLabel.text = NSLocalizedString("Place Country:", comment: "")
                                self.editplaceInfoViewNearMe.stateLabel.text = NSLocalizedString("Place State:", comment: "")
                                self.editplaceInfoViewNearMe.cityLabel.text = NSLocalizedString("Place City:", comment: "")
                                self.editplaceInfoViewNearMe.latitudeLabel.text = NSLocalizedString("Place Latitude", comment: "")
                                self.editplaceInfoViewNearMe.longitudeLabel.text = NSLocalizedString("Place Longitude", comment: "")
                                self.editplaceInfoViewNearMe.notesLabel.text = NSLocalizedString("Place Notes:", comment: "")
                                self.editplaceInfoViewNearMe.typeLabel.text = NSLocalizedString("Place Type:", comment: "")
                                self.editplaceInfoViewNearMe.cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
                                self.editplaceInfoViewNearMe.save.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place Address"] != nil {
                                    
                                    editplaceInfoViewNearMe.placeAddress.text = self.userAddedPlaceDictionaryArray[index2]["Place Address"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placeAddress.text = ""
                                }
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place City"] != nil {
                                    
                                    editplaceInfoViewNearMe.placeCity.text = self.userAddedPlaceDictionaryArray[index2]["Place City"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placeCity.text = ""
                                }
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place Country"] != nil {
                                    
                                    editplaceInfoViewNearMe.placeCountry.text = self.userAddedPlaceDictionaryArray[index2]["Place Country"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placeCountry.text = ""
                                }
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place Website"] != nil {
                                    
                                    editplaceInfoViewNearMe.placeWebsite.text = self.userAddedPlaceDictionaryArray[index2]["Place Website"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placeWebsite.text = ""
                                }
                                
                                editplaceInfoViewNearMe.placeName.text = self.userAddedPlaceDictionaryArray[index2]["Place Name"]
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place Type"] != nil {
                                    
                                    editplaceInfoViewNearMe.placeType.text = self.userAddedPlaceDictionaryArray[index2]["Place Type"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placeType.text = ""
                                }
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place Notes"] != nil {
                                    
                                    editplaceInfoViewNearMe.placeNotes.text = self.userAddedPlaceDictionaryArray[index2]["Place Notes"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placeNotes.text = ""
                                }
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place State"] != nil {
                                    
                                    editplaceInfoViewNearMe.placeState.text = self.userAddedPlaceDictionaryArray[index2]["Place State"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placeState.text = ""
                                }
                                
                                if self.userAddedPlaceDictionaryArray[index2]["Place Phone Number"] != nil {
                                    
                                    editplaceInfoViewNearMe.placePhoneNumber.text = self.userAddedPlaceDictionaryArray[index2]["Place Phone Number"]!
                                    
                                } else {
                                    
                                    editplaceInfoViewNearMe.placePhoneNumber.text = ""
                                }
                                
                                editplaceInfoViewNearMe.placeLatitude.text = self.userAddedPlaceDictionaryArray[index2]["Place Latitude"]!
                                editplaceInfoViewNearMe.placeLongitude.text = self.userAddedPlaceDictionaryArray[index2]["Place Longitude"]!
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    
                                    self.blurEffectView3.alpha = 1
                                    self.editplaceInfoViewNearMe.alpha = 1
                                    self.view.addSubview(self.blurEffectView3)
                                    self.view.addSubview(self.editplaceInfoViewNearMe)
                                    
                                }) { _ in
                                    
                                }
                                
                            }
                            
                        }
                        
                        if placeSaved == false {
                            
                            self.topViewHasBeenTapped()
                        }
                        
                    } else {
                        
                        
                            self.topViewHasBeenTapped()
                        
                    }
                    
                }
            }
        } else {
            
            self.topViewHasBeenTapped()
        }
        
        
        
    }
    
    func infoWindowHasBeenLongPressed(sender: UILongPressGestureRecognizer) {
        print("infoWindowHasBeenLongPressed")
        
        if sender.state == .began {
            
            let longitude = self.googleMapsView.camera.target.longitude
            let latitude = self.googleMapsView.camera.target.latitude
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let screenSize: CGRect = UIScreen.main.bounds
            self.panoView = GMSPanoramaView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            self.panoView.center = self.view.center
            self.panoView.alpha = 0
            self.panoView.moveNearCoordinate(coordinates)
            self.button.frame = CGRect(x: self.panoView.frame.size.width - 60, y: 20, width: 30, height: 30)
            self.button.backgroundColor = UIColor.red
            self.button.setTitle("X", for: .normal)
            self.button.layer.cornerRadius = 5
            self.button.addTarget(self, action: #selector(NearMeViewController.deletePanoView), for: .touchUpInside)
            self.panoView.addSubview(button)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.view.addSubview(self.panoView)
                self.panoView.alpha = 1
                
            }) { _ in
                
            }
        }
    }
    
    func newStreetViewButtonTap() {
        
        print("street view")
        
        let longitude = self.googleMapsView.camera.target.longitude
        let latitude = self.googleMapsView.camera.target.latitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let screenSize: CGRect = UIScreen.main.bounds
        self.panoView = GMSPanoramaView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.panoView.center = self.view.center
        self.panoView.alpha = 0
        self.panoView.isHidden = false
        self.panoView.moveNearCoordinate(coordinates)
        self.button.frame = CGRect(x: self.panoView.frame.size.width - 60, y: 20, width: 30, height: 30)
        self.button.backgroundColor = UIColor.red
        self.button.setTitle("X", for: .normal)
        self.button.layer.cornerRadius = 5
        self.button.addTarget(self, action: #selector(NearMeViewController.deletePanoView), for: .touchUpInside)
        self.panoView.addSubview(button)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.addSubview(self.panoView)
            self.panoView.alpha = 1
            
        }) { _ in
            
        }

    }

    let leisure = ["spa", "amusement_park", "aquarium", "art_gallery", "bowling_alley", "casino", "movie_rental", "movie_theater", "zoo"]
    let services = ["travel_agency", "accounting", "electrician", "funeral_home", "general_contractor", "insurance_agency", "laundry", "lawyer", "locksmith", "painter", "plumber", "roofing_contractor", "storage", "veterinary_care"]
    let banking = ["atm", "bank"]
    let food = ["restaurant", "bakery", "cafe", "convenience_store", "grocery_or_supermarket", "meal_delivery", "meal_takeaway", ]
    let nightlifeAlcohol = ["bar", "liquor_store", "night_club"]
    let transport = ["airport", "bus_station", "subway_station", "taxi_stand", "train_station", "car_dealer", "car_rental", "car_repair", "car_wash", "gas_station", "parking", "transit_station"]
    let shops = ["shopping_mall", "bicycle_store", "book_store", "clothing_store", "department_store", "electronics_store", "florist", "furniture_store", "hardware_store", "home_goods_store", "jewelry_store", "pet_store", "shoe_store", "store"]
    let outdoors = ["campground", "park", "rv_park"]
    let publicPlaces = ["university", "post_office", "school", "police", "cemetery", "church", "hindu_temple", "library", "mosque", "museum", "stadium", "synagogue"]
    let government = ["city_hall", "courthouse", "embassy", "fire_station", "local_government_office"]
    let healthPersonal = ["dentist", "doctor", "gym", "hair_care", "beauty_salon", "health", "hospital", "pharmacy", "physiotherapist"]
    let housing = ["lodging", "moving_company", "real_estate_agency"]
    
    let placeCategories = ["Accommodation", "Leisure", "Services", "Banking", "Food", "Nightlife / Alcohol", "Transport", "Shops", "Outdoors", "Public Places", "Government", "Health"]
    
    let leisure2 = [NSLocalizedString("Spa", comment: ""), NSLocalizedString("Amusement Park", comment: ""), NSLocalizedString("Aquarium", comment: ""), NSLocalizedString("Art Gallery", comment: ""), NSLocalizedString("Bowling Alley", comment: ""), NSLocalizedString("Casino", comment: ""), NSLocalizedString("Movie Rental", comment: ""), NSLocalizedString("Movie Theatre", comment: ""), NSLocalizedString("Zoo", comment: "")]
    let services2 = [NSLocalizedString("Travel Agency", comment: ""), NSLocalizedString("Accounting", comment: ""), NSLocalizedString("Electrician", comment: ""), NSLocalizedString("Funeral Home", comment: ""), NSLocalizedString("General Contractor", comment: ""), NSLocalizedString("Insurance Agency", comment: "") , NSLocalizedString("Laundry", comment: ""), NSLocalizedString("Lawyer", comment: ""), NSLocalizedString("Locksmith", comment: ""), NSLocalizedString("Painter", comment: ""), NSLocalizedString("Plumber", comment: ""), NSLocalizedString("Roofing Contractor", comment: ""), NSLocalizedString("Storage", comment: ""), NSLocalizedString("Veterinary Care", comment: "")]
    let banking2 = [NSLocalizedString("ATM", comment: ""), NSLocalizedString("Bank", comment: "")]
    let food2 = [NSLocalizedString("Restaurant", comment: ""), NSLocalizedString("Bakery", comment: ""), NSLocalizedString("Cafe", comment: ""), NSLocalizedString("Convenience Store", comment: ""), NSLocalizedString("Supermarket", comment: ""), NSLocalizedString("Meal Delivery", comment: ""), NSLocalizedString("Meal Takeaway", comment: "")]
    let nightlifeAlcohol2 = [NSLocalizedString("Bar", comment: ""), NSLocalizedString("Liquor Store", comment: ""), NSLocalizedString("Night Club", comment: "")]
    let transport2 = [NSLocalizedString("Airport", comment: ""), NSLocalizedString("Bus Station", comment: ""), NSLocalizedString("Subway Station", comment: ""), NSLocalizedString("Taxi Stand", comment: ""), NSLocalizedString("Train Station", comment: ""), NSLocalizedString("Car Dealer", comment: ""), NSLocalizedString("Car Rental", comment: ""), NSLocalizedString("Car Repair", comment: ""), NSLocalizedString("Car Wash", comment: ""), NSLocalizedString("Gas Station", comment: ""), NSLocalizedString("Parking", comment: ""), NSLocalizedString("Transit Station", comment: "")]
    let shops2 = [NSLocalizedString("Shopping Mall", comment: ""), NSLocalizedString("Bicycle Store", comment: ""), NSLocalizedString("Book Store", comment: ""), NSLocalizedString("Clothing Store", comment: ""), NSLocalizedString("Department Store", comment: ""), NSLocalizedString("Electronics Store", comment: ""), NSLocalizedString("Florist", comment: ""), NSLocalizedString("Furniture Store", comment: ""), NSLocalizedString("Hardware Store", comment: ""), NSLocalizedString("Homegoods Store", comment: ""), NSLocalizedString("Jewelry Store", comment: ""), NSLocalizedString("Pet Store", comment: ""), NSLocalizedString("Shoe Store", comment: ""), NSLocalizedString("Store", comment: "")]
    let outdoors2 = [NSLocalizedString("Campground", comment: ""), NSLocalizedString("Park", comment: ""), NSLocalizedString("RV Park", comment: "")]
    let publicPlaces2 = [NSLocalizedString("University", comment: ""), NSLocalizedString("Post Office", comment: ""), NSLocalizedString("School", comment: ""), NSLocalizedString("Police", comment: ""), NSLocalizedString("Cemetery", comment: ""), NSLocalizedString("Church", comment: ""), NSLocalizedString("Hindu Temple", comment: ""), NSLocalizedString("Library", comment: ""), NSLocalizedString("Mosque", comment: ""), NSLocalizedString("Museum", comment: ""), NSLocalizedString("Stadium", comment: ""), NSLocalizedString("Synagogue", comment: "")]
    let government2 = [NSLocalizedString("City Hall", comment: ""), NSLocalizedString("Courthouse", comment: ""), NSLocalizedString("Embassy", comment: ""), NSLocalizedString("Fire Station", comment: ""), NSLocalizedString("Local Government Office", comment: "")]
    let healthPersonal2 = [NSLocalizedString("Dentist", comment: ""), NSLocalizedString("Doctor", comment: ""), NSLocalizedString("Gym", comment: ""), NSLocalizedString("Hair Care", comment: ""), NSLocalizedString("Beauty Salon", comment: ""), NSLocalizedString("Health", comment: ""), NSLocalizedString("Hospital", comment: ""), NSLocalizedString("Pharmacy", comment: ""), NSLocalizedString("Physiotherapist", comment: "")]
    let housing2 = [NSLocalizedString("Places to stay", comment: ""), NSLocalizedString("Moving Company", comment: ""), NSLocalizedString("Real Estate Agency", comment: "")]
    
    @IBAction func addFlight(_ sender: Any) {
        
        
    }
    
    func userTappedMyPlaces() {
        
        self.placeDictionaries.removeAll()
        UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
        self.blurEffectViewTopView.removeFromSuperview()
        self.placeInfoWindow.removeFromSuperview()
        
        if self.placeMarkerArray.count > 0 {
            
            for marker in self.placeMarkerArray {
                
                marker.map = nil
            }
        }
        
        self.selectedPlaceCoordinates = nil
        self.selectedPlaceLongitude = nil
        self.selectedPlaceLatitude = nil
        
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLatitude")
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLongitude")
        self.placeMarkerArray = []
        self.biasmarker = nil
        
        
        
        
        
        self.performSegue(withIdentifier: "goToUserAddedPlaces", sender: self)
    }
    
    
    
    func newFindPlacesButtonTap() {
        
        print("find places")
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: nil , message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Go to My Places", style: .default, handler: { (action) in
                
                URLCache.shared.removeAllCachedResponses()
                
                print("my places")
                
                if CLLocationManager.locationServicesEnabled() {
                    
                    switch(CLLocationManager.authorizationStatus()) {
                        
                    case .notDetermined, .restricted, .denied:
                        
                        print("No access")
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "In order for the places feature to work TripKey needs to know your current location. Please tap settings and update the location permission for TripKey.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                                
                                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                                    //UIApplication.shared.openURL(url as URL)
                                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                                }
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    case .authorizedAlways:
                        
                        self.userTappedMyPlaces()
                        
                    case .authorizedWhenInUse:
                        
                        self.userTappedMyPlaces()
                    }
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Find Places", style: .default, handler: { (action) in
                
                //check for permissions
                
                if CLLocationManager.locationServicesEnabled() {
                    
                    switch(CLLocationManager.authorizationStatus()) {
                        
                    case .notDetermined, .restricted, .denied:
                        
                        print("No access")
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "In order for the places feature to work TripKey needs to know your current location. Please tap settings and update the location permission for TripKey.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                                
                                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                                    //UIApplication.shared.openURL(url as URL)
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
                        
                        self.userTappedFindPlaces()
                        
                    case .authorizedWhenInUse:
                        
                        self.userTappedFindPlaces()
                    }
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        

    }
    
    func userTappedFindPlaces() {
        
        self.int = nil
        
        self.placeDictionaries.removeAll()
        UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
        
        if self.biasmarker != nil {
            
            self.biasmarker.map = nil
        }
        
        UserDefaults.standard.removeObject(forKey: "streetNumber")
        UserDefaults.standard.removeObject(forKey: "neighborhood")
        UserDefaults.standard.removeObject(forKey: "route")
        
        if self.placeMarkerArray.count > 0 {
            
            for marker in self.placeMarkerArray {
                
                marker.map = nil
            }
        }
        
        self.placeDictionaries.removeAll()
        UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
        self.blurEffectViewTopView.removeFromSuperview()
        self.placeInfoWindow.removeFromSuperview()
        self.googleMapsView.selectedMarker = nil
        self.placeMarkerArray = []
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLatitude")
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLongitude")
        
        let alert = UIAlertController(title: NSLocalizedString("Choose category", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for (index, category) in placeCategories.enumerated() {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString(category, comment: ""), style: .default, handler: { (action) in
                
                let alert = UIAlertController(title: NSLocalizedString("Choose subcategory", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                self.int = index
                
                for (index, button) in self.placeSubCategories[index].enumerated() {
                    
                    alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
                        
                        self.parsePlaceCategory(category: self.placesSubCategories[self.int][index])
                        
                        self.category = self.placeSubCategories[self.int][index]
                        
                    }))
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                    self.placeDictionaries.removeAll()
                    UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                    self.googleMapsView.selectedMarker = nil
                    
                    if self.placeMarkerArray.count > 0 {
                        
                        for marker in self.placeMarkerArray {
                            
                            marker.map = nil
                        }
                    }
                    
                    self.int = nil
                    self.placeMarkerArray = []
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }))
            
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
            self.placeDictionaries.removeAll()
            UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
            
            self.googleMapsView.selectedMarker = nil
            
            if self.placeMarkerArray.count > 0 {
                
                for marker in self.placeMarkerArray {
                    
                    marker.map = nil
                }
            }
            
            self.int = nil
            self.placeMarkerArray = []
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func newAddPlaceButtonTap() {
        
        print("addPlace")
        
        self.placeDictionaries.removeAll()
        UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
        self.placeDictionary = Dictionary<String,String>()
        
        self.googleMapsView.selectedMarker = nil
        
        if self.placeMarkerArray.count > 0 {
            
            for marker in self.placeMarkerArray {
                
                marker.map = nil
                
            }
            
        }
        
        if self.biasmarker != nil {
            
            self.biasmarker.map = nil
        }
        
        self.placeMarkerArray = []
        
            let latitude = self.googleMapsView.camera.target.latitude
            let longitude = self.googleMapsView.camera.target.longitude
            
            getAddressForLatLng(latitude: String(latitude), longitude: String(longitude))
            //let address = self.address
            //let city = self.city
            //let country = self.country
            //let state = self.state
            self.userLongpressedCoordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            self.googleMapsView.animate(toLocation: position)
            self.biasmarker = GMSMarker(position: position)
            self.biasmarker.map = self.googleMapsView
            self.biasmarker.appearAnimation = GMSMarkerAnimation.pop
            self.biasmarker.icon = UIImage(named: "placesMarker copy.png")
            self.placeAddInput.alpha = 0
            self.blurEffectViewTopView.alpha = 0
            self.placeAddInput.center = self.view.center
            self.placeAddInput.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.placeAddInput.addPlace.addTarget(self, action: #selector(NearMeViewController.add), for: .touchUpInside)
            self.placeAddInput.cancel.addTarget(self, action: #selector(NearMeViewController.cancelAddPlace), for: .touchUpInside)
            self.blurEffectView.alpha = 0
            self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.view.addSubview(self.blurEffectView)
                self.blurEffectView.alpha = 1
                
            }) { _ in
                
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.view.addSubview(self.placeAddInput)
                self.placeAddInput.alpha = 1
                
            }) { _ in
                
            }
            
            if UserDefaults.standard.object(forKey: "streetNumber") != nil {
                
                placeAddInput.placeAddress.text = (UserDefaults.standard.object(forKey: "streetNumber") as! String)
                
            } else if UserDefaults.standard.object(forKey: "neighborhood") != nil {
                
                placeAddInput.placeAddress.text = (UserDefaults.standard.object(forKey: "neighborhood") as! String)
                
            } else if UserDefaults.standard.object(forKey: "route") != nil {
                
                placeAddInput.placeAddress.text = (UserDefaults.standard.object(forKey: "route") as! String)
                
            }
            
      }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight:CGFloat = keyboardSize.height
        
        var _:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        var _:CGFloat = keyboardSize.height
        
        var _:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform.identity
        }, completion: nil)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func cancelAddPlace() {
        
        UserDefaults.standard.removeObject(forKey: "streetNumber")
        UserDefaults.standard.removeObject(forKey: "neighborhood")
        UserDefaults.standard.removeObject(forKey: "route")
        self.placeAddInput.placeAddress.text = ""
        self.button.removeFromSuperview()
        
        if self.biasmarker != nil {
            
            self.biasmarker.map = nil
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blurEffectView.alpha = 0
            self.placeAddInput.alpha = 0
            
        }) { _ in
            
            self.blurEffectView.removeFromSuperview()
            self.placeAddInput.removeFromSuperview()
            
        }
        
    }
    
    func add() {
        
        print("add")
        
        self.dismissKeyboard()
        
        if placeAddInput.placeName.text == "" {
          
            let alert = UIAlertController(title: NSLocalizedString("Please add a place name first.", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            if placeAddInput.phoneNumber.text == "" {
                
                self.placeAddInput.phoneNumber.text = "N/A"
                
            }
            
            if placeAddInput.placeWebsite.text == "" {
                
                self.placeAddInput.placeWebsite.text = "N/A"
                
            }
            
            if placeAddInput.placeAddress.text == "" {
                
                self.placeAddInput.placeAddress.text = "N/A"
            }
            
            if placeAddInput.typeOfPlace.text == "" {
                
                self.placeAddInput.typeOfPlace.text = "N/A"
                
            }
            
            DispatchQueue.main.async {
                
                self.addActivityIndicatorCenter()
                self.activityLabel.text = NSLocalizedString("Adding Place", comment: "")
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
            }
            
            self.types = ["moving_company"]
            let placeCoordinates = self.userLongpressedCoordinates
            let placeName = placeAddInput.placeName.text
            let placeAddress = placeAddInput.placeAddress.text
            let placePhoneNumber = placeAddInput.phoneNumber.text
            let placeWebsite = placeAddInput.placeWebsite.text
            let placeType = placeAddInput.typeOfPlace.text
            let userAddedPlace = GMSUserAddedPlace()
            let placesClient = GMSPlacesClient()
            userAddedPlace.name = placeName!
            userAddedPlace.address = placeAddress!
            userAddedPlace.coordinate = self.userLongpressedCoordinates!
            userAddedPlace.phoneNumber = placePhoneNumber!
            userAddedPlace.website = placeWebsite!
            userAddedPlace.types = self.types
            
            placesClient.add(userAddedPlace, callback: { (place, error) -> Void in
                if let error = error {
                    print("Add Place error: \(error.localizedDescription)")
                    return
                }
                
                if let place = place {
                    
                    var userAddedPlaceDictionary:Dictionary<String,String>!
                    
                    userAddedPlaceDictionary = [
                        
                        "Place Name":"\(placeName!)",
                        "Place Type":"\(placeType!)",
                        "Place Category":"",
                        "Place Website":"\(placeWebsite!)",
                        "Place Phone Number":"\(placePhoneNumber!)",
                        "Place Address":"\(placeAddress!)",
                        "Place ID":"\(place.placeID)",
                        "Place Latitude":"\(self.userLongpressedCoordinates.latitude)",
                        "Place Longitude":"\(self.userLongpressedCoordinates.longitude)",
                        "Place Country":"\(self.country)",
                        "Place City":"\(self.city)",
                        "Place Notes":"",
                        "Place State":"\(self.state)"
                    ]
                    
                    if self.userAddedPlaceDictionaryArray.count > 0 {
                        
                        //for tripkey
                        self.nonConsumablePurchaseMade = true
                        
                        if self.userAddedPlaceDictionaryArray.count == 5 && self.nonConsumablePurchaseMade == false {
                            
                            self.fetchAvailableProducts()
                            
                            let alert = UIAlertController(title: NSLocalizedString("Youv'e reached your limit of saved places.", comment: ""), message: NSLocalizedString("This will be a one time charge that is valid even if you switch phones or uninstall TripKey.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Unlock Premium for $2.99", comment: ""), style: .default, handler: { (action) in
                                
                                self.purchaseMyProduct(product: self.iapProducts[0])
                                                               
                            }))
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: ""), style: .default, handler: { (action) in
                            }))
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Restore Purchases", comment: ""), style: .default, handler: { (action) in
                                
                                SKPaymentQueue.default().add(self)
                                SKPaymentQueue.default().restoreCompletedTransactions()
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                            
                            self.userAddedPlaceDictionaryArray.append(userAddedPlaceDictionary)
                            
                            UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                            
                            self.placeAddInput.removeFromSuperview()
                            
                            if self.biasmarker != nil {
                                
                                self.biasmarker.map = nil
                            }
                            
                            self.button.removeFromSuperview()
                            self.placeAddInput.phoneNumber.text = ""
                            self.placeAddInput.placeWebsite.text = ""
                            self.placeAddInput.placeAddress.text = ""
                            self.placeAddInput.placeName.text = ""
                            self.placeAddInput.typeOfPlace.text = ""
                            self.userLongpressedCoordinates = nil
                            
                            self.view.endEditing(true)
                            
                            let alert = UIAlertController(title: NSLocalizedString("Place succesfully added :)", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                                DispatchQueue.main.async {
                                    
                                    UIView.animate(withDuration: 0.5, animations: {
                                        self.blurEffectView.alpha = 0
                                        self.blurEffectView2.alpha = 0
                                   }) { _ in
                                        
                                        self.blurEffectView.removeFromSuperview()
                                        self.blurEffectView2.removeFromSuperview()
                                    }
                                }
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        }
                        
                    } else {
                        
                        self.userAddedPlaceDictionaryArray = [userAddedPlaceDictionary]
                        
                        UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                        
                        self.placeAddInput.isHidden = true
                        UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                        
                        if self.biasmarker != nil {
                            
                            self.biasmarker.map = nil
                        }
                        
                        self.button.removeFromSuperview()
                        self.placeAddInput.phoneNumber.text = ""
                        self.placeAddInput.placeWebsite.text = ""
                        self.placeAddInput.placeAddress.text = ""
                        self.placeAddInput.placeName.text = ""
                        self.placeAddInput.typeOfPlace.text = ""
                        self.userLongpressedCoordinates = nil
                        
                        self.view.endEditing(true)
                        
                        let alert = UIAlertController(title: NSLocalizedString("Place succesfully added :)", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                            DispatchQueue.main.async {
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    
                                    self.blurEffectView.alpha = 0
                                    self.blurEffectView2.alpha = 0
                                }) { _ in
                                    
                                    self.blurEffectView.removeFromSuperview()
                                    self.blurEffectView2.removeFromSuperview()
                                }
                            }
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                    }
                }
                
                //insert error pop up
            })
            
            UserDefaults.standard.removeObject(forKey: "streetNumber")
            UserDefaults.standard.removeObject(forKey: "neighborhood")
            UserDefaults.standard.removeObject(forKey: "route")
            
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.placeAddInput.typeOfPlace || textField == self.placeAddInput.placeWebsite {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
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
        
        UIAlertView(title: NSLocalizedString("TripKey", comment: ""),
                    message: NSLocalizedString("You've successfully restored your purchase!", comment: ""),
                    delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "")).show()
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
            
            UIAlertView(title: NSLocalizedString("TripKey", comment: ""),
                        message: NSLocalizedString("Purchases are disabled in your device!", comment: ""),
                        delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "")).show()
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
                        
                        //premiumLabel.text = "Premium version PURCHASED!"
                        
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            self.activityLabel.removeFromSuperview()
                            self.blurEffectViewActivity.removeFromSuperview()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            
                        }
                        
                        UIAlertView(title: NSLocalizedString("TripKey", comment: ""),
                                    message: NSLocalizedString("You've successfully unlocked the Premium version!", comment: ""),
                                    delegate: nil,
                                    cancelButtonTitle: NSLocalizedString("OK", comment: "")).show()
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
    
    
    @IBAction func goToCommunity(_ sender: Any) {
        
        //print("goToCommunity")
        
    }
    
    func flightWasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        print("flightWasDragged")
        
        let translation = gestureRecognizer.translation(in: self.arrivalInfoWindow)
        let flightView = gestureRecognizer.view!
        flightView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        let xFromCenter = flightView.center.x - self.view.bounds.width / 2
        let yFromCenter = flightView.center.y - self.view.bounds.width / 2
        
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
                    
                //flightView.center.x = self.view.center.x
                //for sliding up
                print("sliding up")
                let percentage = (translation.y)/(self.view.frame.size.height / 6)
                print("percentageUp = \(percentage)")
                self.arrivalInfoWindow.alpha = 1.0 - abs(percentage)
                self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0 - abs(percentage)
                self.blurEffectViewFlightInfoWindowTop.alpha = 1.0 - abs(percentage)
                    
            } else if flightView.center.y > (self.view.center.y - 50) {
                    
                flightView.center.x = self.view.center.x
                //for sliding down
                print("sliding down")
                let percentage = translation.y/(self.view.frame.size.height / 3)
                self.arrivalInfoWindow.alpha = 1.0 - percentage
                self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0 - percentage
                self.blurEffectViewFlightInfoWindowTop.alpha = 1.0 - percentage
                    
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    flightView.center = self.view.center
                    
                }, completion: { _ in
                    
                })
            }
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            if yFromCenter >= 300 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.arrivalInfoWindow.alpha = 0
                    self.blurEffectViewFlightInfoWindowBottom.alpha = 0
                    self.blurEffectViewFlightInfoWindowTop.alpha = 0
                    
                }) { _ in
                    
                    self.arrivalInfoWindow.removeFromSuperview()
                    self.blurEffectViewFlightInfoWindowTop.removeFromSuperview()
                    self.blurEffectViewFlightInfoWindowBottom.removeFromSuperview()
                    self.resetTimers()
                    
                    print("swiped down")
                }
            } else if yFromCenter <= 80 {
                
                print("swiped up")
                DispatchQueue.main.async {
                    self.resetTimers()
                }
                self.parseLeg2Only(dictionary: self.flights[self.flightIndex], index: self.flightIndex)
                
            } else {
                
                
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    flightView.center = self.view.center
                    self.arrivalInfoWindow.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowTop.alpha = 1.0
                    
                }, completion: { _ in
                    
                })
            }
            
            if xFromCenter <= -50 {
                
                print("swiped left")
                var latitude:Double!
                var longitude:Double!
                var newLocation:GMSCameraPosition!
               
                if self.flights.count > 1 {
                    
                    
                    
                    
                    if self.flightIndex < self.flights.count - 1 && (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                        //from arrival to departure for next flight add one to index
                        self.resetTimers()
                        self.tappedMarker = self.departureMarkerArray[self.flightIndex + 1]
                        self.showDepartureWindow(index: self.flightIndex + 1)
                        
                        latitude = Double(self.flights[self.flightIndex + 1]["Airport Departure Latitude"]!)!
                        longitude = Double(self.flights[self.flightIndex + 1]["Airport Departure Longitude"]!)!
                        newLocation = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.googleMapsView.camera.zoom)
                        
                        DispatchQueue.main.async {
                            CATransaction.begin()
                            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                            self.googleMapsView.animate(to: newLocation)
                            CATransaction.commit()
                        }
                        
                        self.addFlightViewFromRightToLeft()
                        
                        self.flightIndex = self.flightIndex + 1
                        
                        
                    
                    } else if self.flightIndex < self.flights.count - 1 && (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                        //from departure to arrival for same flight
                        //DispatchQueue.main.async {
                            self.resetTimers()
                        //}
                        self.tappedMarker = self.arrivalMarkerArray[self.flightIndex]
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
                        
                    } else if self.flightIndex == self.flights.count - 1 && (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                        //from departure to arrival for same flight
                        //DispatchQueue.main.async {
                            self.resetTimers()
                        //}
                        self.tappedMarker = self.arrivalMarkerArray[self.flightIndex]
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
                    
                    
                    
                } else if self.flights.count == 1 {
                    
                    
                    
                    
                    if self.flightIndex == self.flights.count - 1 && (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                        //from departure to arrival for same flight
                        //DispatchQueue.main.async {
                        self.resetTimers()
                        //}
                        self.tappedMarker = self.arrivalMarkerArray[self.flightIndex]
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
                    
                }, completion: { _ in
                    
                })
            }
            
            if xFromCenter >= 50 {
                
                print("swiped right")
                var latitude:Double!
                var longitude:Double!
                var newLocation:GMSCameraPosition!
                
                if self.flights.count > 1 {
                    
                    
                    
                    if self.flightIndex <= self.flights.count - 1 && (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                        //from arrival to departure for same flight
                        //DispatchQueue.main.async {
                            self.resetTimers()
                        //}
                        self.tappedMarker = self.departureMarkerArray[self.flightIndex]
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
                        
                    } else if self.flightIndex != 0 && self.flightIndex <= self.flights.count - 1 && (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                        //from departure to arrival for previous flight
                        //DispatchQueue.main.async {
                            self.resetTimers()
                        //}
                        self.tappedMarker = self.arrivalMarkerArray[self.flightIndex - 1]
                        self.showFlightInfoWindows(flightIndex: self.flightIndex - 1)
                        
                        latitude = Double(self.flights[self.flightIndex - 1]["Airport Arrival Latitude"]!)!
                        longitude = Double(self.flights[self.flightIndex - 1]["Airport Arrival Longitude"]!)!
                        newLocation = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.googleMapsView.camera.zoom)
                        
                        DispatchQueue.main.async {
                            CATransaction.begin()
                            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                            self.googleMapsView.animate(to: newLocation)
                            CATransaction.commit()
                        }
                        
                        self.addFlightViewFromLeftToRight()
                        self.flightIndex = self.flightIndex - 1
                        
                    }
                } else if self.flights.count == 1 {
                    
                    
                    
                    
                    if self.flightIndex == self.flights.count - 1 && (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                        //from arrival to departure for same flight
                        //DispatchQueue.main.async {
                            self.resetTimers()
                        //}
                        self.tappedMarker = self.departureMarkerArray[self.flightIndex]
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
                    
                    
                }
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    flightView.center = self.view.center
                    self.arrivalInfoWindow.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowBottom.alpha = 1.0
                    self.blurEffectViewFlightInfoWindowTop.alpha = 1.0
                    
                }, completion: { _ in
                    
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
            
            
        }) { _ in
            
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            let transition = CATransition()
            transition.duration = 0.35
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.arrivalInfoWindow.layer.add(transition, forKey: kCATransition)
            
            self.view.addSubview(self.arrivalInfoWindow)
            self.arrivalInfoWindow.alpha = 1
            
        }, completion: { _ in
            
        })
        

    }
    
    func addFlightViewFromLeftToRight() {
        
        self.view.addSubview(self.blurEffectViewFlightInfoWindowBottom)
        self.view.addSubview(self.blurEffectViewFlightInfoWindowTop)
        
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blurEffectViewFlightInfoWindowTop.alpha = 1
            self.blurEffectViewFlightInfoWindowBottom.alpha = 1
            
            
        }) { _ in
            
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            let transition = CATransition()
            transition.duration = 0.35
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.arrivalInfoWindow.layer.add(transition, forKey: kCATransition)
            
            self.view.addSubview(self.arrivalInfoWindow)
            self.arrivalInfoWindow.alpha = 1
            
        }, completion: { _ in
            
        })
        
        
    }
    
    
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        print("swasDragged")
        
        let translation = gestureRecognizer.translation(in: self.placeInfoWindow)
        let notificationView = gestureRecognizer.view!
        notificationView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        let xFromCenter = notificationView.center.x - self.view.bounds.width / 2
        let yFromCenter = notificationView.center.y - self.view.bounds.width / 2
        var swipeUp = false
        
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            
            if notificationView.center.x < (self.view.center.x - 50) {
                
                //for sliding left
                notificationView.center.x =  (notificationView.center.x + xFromCenter) + (self.view.frame.width / 2)
                notificationView.center.y = self.view.center.y
                let percentage = translation.x/(self.view.frame.size.width / 3)
                print("percentage = \(percentage)")
                self.placeInfoWindow.alpha = 1.0 - abs(percentage)
                self.blurEffectViewTopView.alpha = 1.0 - abs(percentage)
                self.blurEffectViewBottomView.alpha = 1.0 - abs(percentage)
                
                
                if self.swipingPic == true {
                    self.placeInfoWindow.icon.alpha = 1.0 - abs(percentage)
                    self.placeInfoWindow.pictureView.alpha = 1.0 - abs(percentage)
                    self.blurEffectView.alpha = 1.0 - abs(percentage)
                }
            
            } else if notificationView.center.x > self.view.center.x + 50 {
                
                //for slifing right
                notificationView.center.x =  (notificationView.center.x + xFromCenter) - (self.view.frame.width / 2)
                notificationView.center.y = self.view.center.y
                let percentage = translation.x/(self.view.frame.size.width / 3)
                self.placeInfoWindow.alpha = 1.0 - percentage
                self.blurEffectViewTopView.alpha = 1.0 - percentage
                self.blurEffectViewBottomView.alpha = 1.0 - percentage
                
                
                if self.swipingPic == true {
                    
                    self.placeInfoWindow.icon.alpha = 1.0 - percentage
                    self.placeInfoWindow.pictureView.alpha = 1.0 - percentage
                    self.blurEffectView.alpha = 1.0 - percentage
                }
                
            } else if notificationView.center.y < (self.view.center.y - 50) {
                
                //for sliding up
                print("sliding up")
                let percentage = (translation.y)/(self.view.frame.size.height / 6)
                print("percentageUp = \(percentage)")
                self.placeInfoWindow.alpha = 1.0 - abs(percentage)
                self.blurEffectViewTopView.alpha = 1.0 - abs(percentage)
                self.blurEffectViewBottomView.alpha = 1.0 - abs(percentage)
                
                
                if self.swipingPic == true {
                    self.placeInfoWindow.icon.alpha = 1.0 - abs(percentage)
                    self.placeInfoWindow.pictureView.alpha = 1.0 - abs(percentage)
                    self.blurEffectView.alpha = 1.0 - abs(percentage)
                }
            
            } else if notificationView.center.y > (self.view.center.y - 50) {
                //for sliding down
                notificationView.center.x = self.view.center.x
                
                let percentage = translation.y/(self.view.frame.size.height / 3)
                self.placeInfoWindow.alpha = 1.0 - percentage
                self.blurEffectViewTopView.alpha = 1.0 - percentage
                self.blurEffectViewBottomView.alpha = 1.0 - percentage
                
                
                if self.swipingPic == true {
                    self.placeInfoWindow.icon.alpha = 1.0 - percentage
                    self.placeInfoWindow.pictureView.alpha = 1.0 - percentage
                    self.blurEffectView.alpha = 1.0 - percentage
                }
                
                
                
            
                
                
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    notificationView.center = self.view.center
                    
                }, completion: { _ in
                    
                })
                
                
            }
            
            
            
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            if yFromCenter <= 80 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.placeInfoWindow.icon.alpha = 0
                    
                }) { _ in
                    
                    print("swipedUp")
                    swipeUp = true
                    
                }
                
                if self.imageArray.count >= 1 {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.swipingPic = true
                        
                        if self.ascending == true {
                            
                            if self.photoIndex == 0 {
                                
                                self.placeInfoWindow.icon.image = self.imageArray[self.photoIndex]
                                self.placeInfoWindow.copyright.text = self.attributedTextArray[self.photoIndex].string
                                self.photoIndex = self.photoIndex + 1
                                self.blurEffectView.alpha = 1
                                self.placeInfoWindow.icon.alpha = 1
                                self.placeInfoWindow.pictureView.alpha = 1
                                
                            } else if self.photoIndex < self.imageArray.count - 1 {
                                
                                self.photoIndex = self.photoIndex + 1
                                self.placeInfoWindow.icon.image = self.imageArray[self.photoIndex]
                                self.placeInfoWindow.copyright.text = self.attributedTextArray[self.photoIndex].string
                                self.blurEffectView.alpha = 1
                                self.placeInfoWindow.icon.alpha = 1
                                self.placeInfoWindow.pictureView.alpha = 1
                                
                            } else if self.photoIndex == self.imageArray.count - 1 {
                                
                                self.photoIndex = self.photoIndex - 1
                                self.placeInfoWindow.icon.image = self.imageArray[self.photoIndex]
                                self.placeInfoWindow.copyright.text = self.attributedTextArray[self.photoIndex].string
                                self.blurEffectView.alpha = 1
                                self.placeInfoWindow.icon.alpha = 1
                                self.placeInfoWindow.pictureView.alpha = 1
                                self.descending = true
                                self.ascending = false
                                
                            }

                        } else if self.descending == true {
                            
                            if self.photoIndex == 0 {
                                
                                self.placeInfoWindow.icon.image = self.imageArray[self.photoIndex]
                                self.placeInfoWindow.copyright.text = self.attributedTextArray[self.photoIndex].string
                                self.photoIndex = self.photoIndex + 1
                                self.blurEffectView.alpha = 1
                                self.placeInfoWindow.icon.alpha = 1
                                self.placeInfoWindow.pictureView.alpha = 1
                                self.descending = false
                                self.ascending = true
                                
                            } else if self.photoIndex < self.imageArray.count - 1 {
                                
                                self.photoIndex = self.photoIndex - 1
                                self.placeInfoWindow.icon.image = self.imageArray[self.photoIndex]
                                self.placeInfoWindow.copyright.text = self.attributedTextArray[self.photoIndex].string
                                self.blurEffectView.alpha = 1
                                self.placeInfoWindow.icon.alpha = 1
                                self.placeInfoWindow.pictureView.alpha = 1
                                
                            } else if self.photoIndex == self.imageArray.count - 1 {
                                
                                self.photoIndex = self.photoIndex - 1
                                self.placeInfoWindow.icon.image = self.imageArray[self.photoIndex]
                                self.placeInfoWindow.copyright.text = self.attributedTextArray[self.photoIndex].string
                                self.blurEffectView.alpha = 1
                                self.placeInfoWindow.icon.alpha = 1
                                self.placeInfoWindow.pictureView.alpha = 1
                                
                            }
                        }
                        
                    }) { _ in
                        
                        print("swipedUp")
                        
                    }
                }
           }
            
            if yFromCenter >= 270 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.placeInfoWindow.alpha = 0
                    self.blurEffectViewTopView.alpha = 0
                    self.blurEffectViewBottomView.alpha = 0
                    self.blurEffectView.alpha = 0
                    
                }) { _ in
                    
                    self.placeInfoWindow.removeFromSuperview()
                    self.blurEffectViewTopView.removeFromSuperview()
                    self.blurEffectViewBottomView.removeFromSuperview()
                    self.blurEffectView.removeFromSuperview()
                    self.setPlaceInfoWindow()
                    print("swiped down")
                    self.swiping = false
                    self.swipingPic = false
                    swipeUp = false
                    self.imageArray.removeAll()
                    self.photoIndex = 0
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.blurEffectViewActivity.removeFromSuperview()
                        self.activityLabel.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    notificationView.center = self.view.center
                    self.placeInfoWindow.alpha = 1.0
                    
                    self.blurEffectViewTopView.alpha = 1.0
                    self.blurEffectViewBottomView.alpha = 1.0
                    
                    if self.swipingPic == true {
                        
                        self.placeInfoWindow.icon.alpha = 1.0
                        self.placeInfoWindow.pictureView.alpha = 1.0
                        self.blurEffectView.alpha = 1.0
                    }
                    
                }) { _ in
                    
                }
            }
                
            if xFromCenter >= 50 {
                    
                print("swiped right")
                
                if self.placeDictionaries.count > 1 {
                  
                    if self.tappedMarkerIndex >= 1 {
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            self.placeInfoWindow.alpha = 0
                            self.placeInfoWindow.removeFromSuperview()
                            self.blurEffectView.alpha = 0
                            self.blurEffectView.removeFromSuperview()
                            
                        }) { _ in
                            
                            self.tappedMarkerIndex = (self.tappedMarkerIndex - 1)
                            self.parsePlaceInfoWindow(index: self.tappedMarkerIndex)
                            self.setPlaceInfoWindow()
                            let transition = CATransition()
                            transition.duration = 0.35
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromLeft
                            self.placeInfoWindow.layer.add(transition, forKey: kCATransition)
                            self.view.addSubview(self.blurEffectView)
                            self.view.addSubview(self.placeInfoWindow)
                            self.photoIndex = 0
                            
                        }
                        
                    } else {
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            notificationView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                            
                        }) { _ in
                            
                        }
                    }
                    
                } else {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        notificationView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                        
                    }) { _ in
                        
                    }
                }
            }
            
            print(xFromCenter)
                
            if xFromCenter <= -50 {
                    
                print("swiped left")
                
                if self.placeDictionaries.count > 1 {
                    
                    if self.tappedMarkerIndex < self.placeDictionaries.count - 1 {
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            self.placeInfoWindow.alpha = 0
                            self.placeInfoWindow.removeFromSuperview()
                            self.blurEffectView.alpha = 0
                            self.blurEffectView.removeFromSuperview()
                            
                        }) { _ in
                            
                            self.tappedMarkerIndex = (self.tappedMarkerIndex + 1)
                            self.parsePlaceInfoWindow(index: self.tappedMarkerIndex)
                            self.setPlaceInfoWindow()
                            //self.placeInfoWindow.alpha = 1
                            let transition = CATransition()
                            transition.duration = 0.35
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromRight
                            self.placeInfoWindow.layer.add(transition, forKey: kCATransition)
                            self.view.addSubview(self.blurEffectView)
                            self.view.addSubview(self.placeInfoWindow)
                            //self.placeInfoWindow.topView.addGestureRecognizer(self.recognizerTopView)
                            self.photoIndex = 0
                            
                        }
                        
                   } else if self.tappedMarkerIndex == self.placeDictionaries.count - 1 {
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            notificationView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                            
                        }) { _ in
                            
                        }
                        
                    } else {
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            notificationView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                            
                        }) { _ in
                            
                        }
                    }
                    
                } else {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        notificationView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                        
                    }) { _ in
                        
                    }
                }
            }
        }
    }
    
    func applicationWillResignActive(notification: NSNotification) {
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        view.endEditing(true)
        
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Why are you shaking me?")
            
            
             if PFUser.current() != nil {
             
             
             
             let sharedFlightquery = PFQuery(className: "SharedFlight")
             
             sharedFlightquery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
             
             do {
             
             let sharedFlights = try sharedFlightquery.findObjects()
             
             if let pfObjects = sharedFlights as? [PFObject] {
             
             for flight in pfObjects {
             
             var senderUsername = "unknown"
             
             if let username = flight["shareFromUsername"] as? String {
             
             senderUsername = username
             
             }
             
             DispatchQueue.main.async {
             
             let alertController = UIAlertController(title: "\(senderUsername) " + NSLocalizedString("shared a flight with you", comment: ""), message: "", preferredStyle: .alert)
             
             let getSharedFlightQuery = PFQuery(className: "SharedFlight")
             
             getSharedFlightQuery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
             
             getSharedFlightQuery.findObjectsInBackground { (sharedFlights, error) in
             
             if error != nil {
             
             print("error = \(error as Any)")
             
             } else {
             
             for flight in sharedFlights! {
             
             //parse flight
             UIApplication.shared.isNetworkActivityIndicatorVisible = true
             let flightDictionary = flight["flightDictionary"]
             let dictionary = flightDictionary as! NSDictionary
             self.flights.append(dictionary as! Dictionary<String, String>)
             self.parseLeg2Only(dictionary: dictionary as! Dictionary<String, String>, index: self.flights.count - 1)
             UserDefaults.standard.set(self.flights, forKey: "flights")
             self.resetFlightZeroViewdidappear()
             
             
             
             flight.deleteInBackground(block: { (success, error) in
             
             if error != nil {
             
             print("error = \(error as Any)")
             
             
             } else {
             
             print("place deleted")
             
             }
             
             })
             
             }
             
             }
             
             }
             
             alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
             
             }))
             
             self.present(alertController, animated: true, completion: nil)
             
             }
             
             }
             
             }
             
             } catch {
             
             print("could not get shard flights")
             }
             
             let sharedPlacequery = PFQuery(className: "SharedPlace")
             
             sharedPlacequery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
             
             do {
             
             let sharedPlaces = try sharedPlacequery.findObjects()
             
             if let pfObjects = sharedPlaces as? [PFObject] {
             
             for place in pfObjects {
             
             var senderUsername = "unknown"
             
             if let username = place["shareFromUsername"] as? String {
             
             senderUsername = username
             
             }
             
             DispatchQueue.main.async {
             
             let alertController = UIAlertController(title: "\(senderUsername) " + NSLocalizedString("shared a place with you", comment: ""), message: "", preferredStyle: .alert)
             
             alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
             
             self.performSegue(withIdentifier: "goToUserAddedPlaces", sender: self)
             
             }))
             
             self.present(alertController, animated: true, completion: nil)
             }
             
             }
             }
             
             } catch {
             
             print("could not get shard flights")
             }
             
             let userSharedLocationQuery = PFQuery(className: "MyLocationPermission")
             
             userSharedLocationQuery.whereKey("followerUsername", equalTo: (PFUser.current()?.username)!)
             
             do {
             
             let sharedUserLocations = try userSharedLocationQuery.findObjects()
             
             if let pfObjects = sharedUserLocations as? [PFObject] {
             
             for user in pfObjects {
             
             var senderUsername = "unknown"
             
             if let usernameCheck = user["username"] as? String {
             
             senderUsername = usernameCheck
             
             }
             
             }
             
             }
             
             } catch {
             
             print("could not get shard flights")
             }
             
             
             print("Timer activated")
             
             
             
             } else {
             
             self.performSegue(withIdentifier: "logIn", sender: self)
             }
             
            

            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload nearMe")
        /*
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
        */
        if WCSession.isSupported() {
            WCSession.default().delegate = self
            WCSession.default().activate()
        }
        else {
            print("\nViewController: connectionManager is nil\n")
        }
        
        self.becomeFirstResponder() // To get shake gesture
        
            self.arrivalInfoWindow.terminalLabel.text = NSLocalizedString("Terminal", comment: "")
            self.arrivalInfoWindow.gateLabel.text = NSLocalizedString("Gate", comment: "")
            self.arrivalInfoWindow.baggageLabel.text = NSLocalizedString("Baggage", comment: "")
        
        
        self.blurEffectViewFlightInfoWindowBottom.alpha = 0
        self.blurEffectViewFlightInfoWindowTop.alpha = 0
        self.arrivalInfoWindow.alpha = 0
        self.arrivalInfoWindow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.arrivalInfoWindow.topView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.arrivalInfoWindow.bottomView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.arrivalInfoWindow.frame = self.view.frame
        self.blurEffectViewFlightInfoWindowBottom.frame = CGRect(x: 0, y: self.view.frame.maxY - 106, width: self.view.frame.width, height: 106)
        self.blurEffectViewFlightInfoWindowTop.frame = CGRect(x: 0, y: self.view.frame.minY, width: self.view.frame.width, height: 166)
        self.arrivalInfoWindow.directions.addTarget(self, action: #selector(self.directionsToArrivalAirport), for: .touchUpInside)
        
        self.arrivalInfoWindow.flightAmenities.addTarget(self, action: #selector(self.flightAmenities), for: .touchUpInside)
        
        self.arrivalInfoWindow.share.addTarget(self, action: #selector(self.shareFlight), for: .touchUpInside)
        
        self.arrivalInfoWindow.call.addTarget(self, action: #selector(self.callAirline), for: .touchUpInside)
        
        self.arrivalInfoWindow.deleteFlight.addTarget(self, action: #selector(self.deleteFlight), for: .touchUpInside)
        
        let flightDragged = UIPanGestureRecognizer(target: self, action: #selector(self.flightWasDragged(gestureRecognizer:)))
        self.arrivalInfoWindow.addGestureRecognizer(flightDragged)
        
        
        if UserDefaults.standard.object(forKey: "howManyTimesUsed") != nil {
            
            howManyTimesUsed = UserDefaults.standard.object(forKey: "howManyTimesUsed") as! [Int]
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
                    
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                
        }
        
        //bottomToolBarVisible = true
        
        placeAddInput.nameLabel.adjustsFontSizeToFitWidth = true
        placeAddInput.addressLabel.adjustsFontSizeToFitWidth = true
        placeAddInput.phoneNumberLabel.adjustsFontSizeToFitWidth = true
        placeAddInput.websiteLabel.adjustsFontSizeToFitWidth = true
        placeAddInput.typeLabel.adjustsFontSizeToFitWidth = true
        placeAddInput.addPlace.titleLabel?.adjustsFontSizeToFitWidth = true
        placeAddInput.cancel.titleLabel?.adjustsFontSizeToFitWidth = true
        placeAddInput.addPlace.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        placeAddInput.cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        placeAddInput.nameLabel.text = NSLocalizedString("Place Name:", comment: "")
        placeAddInput.addressLabel.text = NSLocalizedString("Place Address: (optional)", comment: "")
        placeAddInput.phoneNumberLabel.text = NSLocalizedString("Place Phone Number:", comment: "")
        placeAddInput.websiteLabel.text = NSLocalizedString("Place Website:", comment: "")
        placeAddInput.typeLabel.text = NSLocalizedString("Place Type:", comment: "")
        
        
        self.isInternetAvailable()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        locationManager.delegate = self
        
        
        longPressRecognizer.addTarget(self, action: #selector(NearMeViewController.infoWindowHasBeenLongPressed))
        recognizer.addTarget(self, action: #selector(NearMeViewController.imageHasBeenTapped))
        recognizerTopView.addTarget(self, action: #selector(NearMeViewController.topViewHasBeenTapped))
        
        let app = UIApplication.shared
        //Register for the applicationWillResignActive anywhere in your app.
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        
        if UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") != nil {
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        }
        
        if UserDefaults.standard.object(forKey: "flights") != nil {
            
            flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
            
        }
            
        if UserDefaults.standard.object(forKey: "selectedPlaceLongitude") != nil {
            
            selectedPlaceLongitude = UserDefaults.standard.object(forKey: "selectedPlaceLongitude") as! Double
        }
        
        if UserDefaults.standard.object(forKey: "selectedPlaceLatitude") != nil {
            
            selectedPlaceLatitude = UserDefaults.standard.object(forKey: "selectedPlaceLatitude") as! Double
            selectedPlaceCoordinates = CLLocationCoordinate2D(latitude: selectedPlaceLatitude, longitude: selectedPlaceLongitude)
        }
        
        placesSubCategories = [housing, leisure, services, banking, food, nightlifeAlcohol, transport, shops, outdoors, publicPlaces, government, healthPersonal]
        
        placeSubCategories = [housing2, leisure2, services2, banking2, food2, nightlifeAlcohol2, transport2, shops2, outdoors2, publicPlaces2, government2, healthPersonal2]
        
        placeAddInput.phoneNumber.delegate = self
        placeAddInput.placeName.delegate = self
        placeAddInput.placeAddress.delegate = self
        placeAddInput.placeWebsite.delegate = self
        placeAddInput.typeOfPlace.delegate = self
        placeAddInput.placeAddress.delegate = self
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = true
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
        
        if userLongpressedCoordinates != nil {
            
            mapView(self.googleMapsView, didLongPressAt: self.userLongpressedCoordinates)
            
        }
        
        if tappedCoordinates != nil {
            
            mapView(googleMapsView, didTapAt: tappedCoordinates)
            
        }
        
        if self.connected == true {
           
            if (PFUser.current() != nil) {
                
                self.userNames.removeAll()
                
                print("User already logged in with Parse")
                
            } else {
                
                print("user is nil")
                
                //performSegue(withIdentifier: "logIn", sender: self)
            }
        }
        
        if howManyTimesUsed.count == 10 || howManyTimesUsed.count == 20 || howManyTimesUsed.count == 30 || howManyTimesUsed.count == 40 {
            
            self.askForReview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        URLCache.shared.removeAllCachedResponses()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPlaceOverview" {
           
            let nextScene = segue.destination as? placeOverviewViewController
            
            nextScene?.photosMode = self.photosMode
            nextScene?.reviewsMode = self.reviewsMode
            
        }
        
            //let indexPath = self.tableView.indexPathForSelectedRow {
            //let selectedVehicle = vehicles[indexPath.row]
            //nextScene.currentVehicle = selectedVehicle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLongitude")
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLatitude")
        self.userNames.removeAll()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    func setPlaceInfoWindow() {
        
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.center = self.view.center
        self.blurEffectView.alpha = 0
        
        self.placeInfoWindow.topView.addGestureRecognizer(self.recognizerTopView)
        self.placeInfoWindow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.placeInfoWindow.frame = self.view.bounds
        self.placeInfoWindow.center = self.view.center
        self.placeInfoWindow.alpha = 1
        
        self.placeInfoWindow.pictureView.center = self.mapView.center
        //self.placeInfoWindow.pictureView.frame = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: self.mapView.frame.width, height: self.mapView.frame.height)
        self.placeInfoWindow.pictureView.frame = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.bounds.maxY - self.placeInfoWindow.bottomView.frame.height, width: self.mapView.frame.width, height: self.mapView.frame.height - (self.placeInfoWindow.bottomView.frame.height + self.placeInfoWindow.topView.frame.height))
        self.placeInfoWindow.icon.center = self.placeInfoWindow.pictureView.center
        self.placeInfoWindow.icon.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.placeInfoWindow.icon.frame = self.placeInfoWindow.pictureView.frame
        self.placeInfoWindow.icon.image = UIImage(named: "output1.png")
        let dragged = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        self.placeInfoWindow.addGestureRecognizer(dragged)
        //self.placeInfoWindow.midView.addGestureRecognizer(self.recognizer)
        self.placeInfoWindow.copyright.text = ""
        self.placeInfoWindow.name.text = ""
        self.placeInfoWindow.openOrClosed.text = ""
        self.placeInfoWindow.priceRange.text = ""
        self.placeInfoWindow.addGestureRecognizer(longPressRecognizer)
        
         let theHeight = view.frame.size.height
        self.blurEffectViewTopView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: 95)
        self.blurEffectViewTopView.alpha = 1
        self.blurEffectViewBottomView.frame = CGRect(x: 0, y: theHeight - 150, width: self.view.frame.width, height: 150)
        self.blurEffectViewBottomView.alpha = 1
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("This is viewdidappear")
        
        if UserDefaults.standard.object(forKey: "placeId") != nil {
            
            placeId = UserDefaults.standard.object(forKey: "placeId") as! String
        }
        
        if UserDefaults.standard.object(forKey: "placeDictionaries") != nil {
            
            placeDictionaries = UserDefaults.standard.object(forKey: "placeDictionaries") as! [Dictionary<String,String>]
        }
        
        if UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") != nil {
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        }
        
        if UserDefaults.standard.object(forKey: "flights") != nil {
            
            flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
            
                let message = ["flights":flights]
                
                WCSession.default().sendMessage(message, replyHandler: { (replyMessage) in
                    print("Got a reply from the phone: \(replyMessage)")
                    
                    if let returnedValues = replyMessage["returned-value"] as? NSArray {
                        for val in returnedValues {
                            // do something here with the data
                            // Dispatch to Main Thread if affecting UI
                        }
                    }
                }, errorHandler: { (error) in
                    print("Got an error sending to the phone: \(error)")
                })
            //}
            
        }
        
        if UserDefaults.standard.object(forKey: "selectedPlaceLongitude") != nil {
            
            selectedPlaceLongitude = UserDefaults.standard.object(forKey: "selectedPlaceLongitude") as! Double
        }
        
        if UserDefaults.standard.object(forKey: "selectedPlaceLatitude") != nil {
            
            selectedPlaceLatitude = UserDefaults.standard.object(forKey: "selectedPlaceLatitude") as! Double
            selectedPlaceCoordinates = CLLocationCoordinate2D(latitude: selectedPlaceLatitude, longitude: selectedPlaceLongitude)
        }
        
        if UserDefaults.standard.object(forKey: "userSwipedBack") == nil {
            
            UserDefaults.standard.set(false, forKey: "userSwipedBack")
        }
        
        if self.connected == true {
            
            if UserDefaults.standard.object(forKey: "userSwipedBack") as! Bool != true {
                
                self.googleMapsView = GMSMapView(frame: self.mapView.frame)
                self.googleMapsView.delegate = self
                self.locationManager.startUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                self.googleMapsView.isMyLocationEnabled = true
                self.googleMapsView.isBuildingsEnabled = true
                self.googleMapsView.settings.compassButton = true
                googleMapsView.accessibilityElementsHidden = false
                self.googleMapsView.mapType = GMSMapViewType.hybrid
                self.googleMapsView.alpha = 0
                self.view.addSubview(self.googleMapsView)
                
                setPlaceInfoWindow()
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    //self.mapView.frame = self.view.frame
                    //self.googleMapsView.frame = self.mapView.frame
                    self.googleMapsView.alpha = 1
                    
                }, completion: { _ in
                    
                    self.addButtons()
                    //self.bottomToolBarVisible = true
                    //self.bottomToolbar.isHidden = true
                })
                
                
                
                if self.flights.count > 0 {
                    
                    self.resetFlightZeroViewdidappear()
                    
                    
                        var bounds = GMSCoordinateBounds()
                        
                        for marker in departureMarkerArray {
                            bounds = bounds.includingCoordinate(marker.position)
                        }
                        
                        for marker in arrivalMarkerArray {
                            bounds = bounds.includingCoordinate(marker.position)
                        }
                        
                        CATransaction.begin()
                        CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                    self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
                        CATransaction.commit()
                        
                    
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
                
            } else {
                
                if UserDefaults.standard.object(forKey: "selectedPlaceLongitude") != nil {
                    
                    self.setPlaceInfoWindow()
                    
                    //let placeId = UserDefaults.standard.object(forKey: "placeId") as! String
                    let longitude = UserDefaults.standard.object(forKey: "selectedPlaceLongitude") as! Double
                    let latitude = UserDefaults.standard.object(forKey: "selectedPlaceLatitude") as! Double
                    let position = CLLocationCoordinate2DMake(latitude, longitude)
                    self.placeDictionaries.removeAll()
                    self.placeDictionaries = UserDefaults.standard.object(forKey: "placeDictionaries") as! [Dictionary<String,String>]
                    
                    for (index, place) in self.placeDictionaries.enumerated() {
                        
                        let longitude = Double(place["Place Longitude"]!)
                        let latitude = Double(place["Place Latitude"]!)
                        let placeID = place["Place ID"]!
                        self.locatePlacesFromCategoryWithLongitude(longitude: longitude!, latitude: latitude!, placeId: placeID, index: index)
                    }
                    
                    CATransaction.begin()
                    CATransaction.setValue(Int(2), forKey: kCATransactionAnimationDuration)
                    self.googleMapsView.animate(toLocation: position)
                    CATransaction.commit()
                    
                    CATransaction.begin()
                    CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                    self.googleMapsView.animate(toZoom: 15)
                    CATransaction.commit()
                    
                    let index = UserDefaults.standard.object(forKey: "index") as! Int
                    
                    self.view.addSubview(self.blurEffectViewTopView)
                    
                    self.view.addSubview(self.blurEffectViewBottomView)
                    
                    self.view.addSubview(self.blurEffectView)
                    self.parsePlaceInfoWindow(index: index)
                    self.tappedMarkerIndex = (index)
                    
                    
                    self.view.addSubview(self.placeInfoWindow)
                    
                    
                }
                
            }
            
            if UserDefaults.standard.object(forKey: "userSwipedBack") as! Bool == true {
                
                UserDefaults.standard.set(false, forKey: "userSwipedBack")
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.displayAlert(title: NSLocalizedString("No internet connection.", comment: ""), message: NSLocalizedString("The map can't load without a signal", comment: ""))
                
            }
        }
        
        self.userNames.removeAll()
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            if let followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as? [Dictionary<String,Any>] {
                
                self.followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
                
                for (index, user) in followedUsers.enumerated() {
                    
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
        
        if usersLocationMode == true {
            
            DispatchQueue.main.async {
                if let followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as? [Dictionary<String,Any>] {
                    
                    self.followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
                    
                    if self.followedUsers.count > 0 {
                        
                        for (index, user) in followedUsers.enumerated() {
                            
                            self.userNames.append(user["Username"] as! String)
                            
                            //add users to map
                            if user["Latitude"] != nil && user["Latitude"] as! String != "" {
                                
                                if user["Longitude"] != nil && user["Longitude"] as! String != "" {
                                    
                                    let latitude = user["Latitude"] as! String
                                    let longitude = user["Longitude"] as! String
                                    print("latitude = \(latitude)")
                                    print("longitude = \(longitude)")
                                    
                                    var  followedUserMarker:GMSMarker!
                                    var location:CLLocationCoordinate2D!
                                    location = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
                                    followedUserMarker = GMSMarker(position: location)
                                    followedUserMarker.isTappable = true
                                    followedUserMarker.icon = UIImage(named: "User-Profile.png")
                                    followedUserMarker.map = self.googleMapsView
                                    followedUserMarker.accessibilityLabel = "Followed User - \(index)"
                                    followedUserMarker.snippet = "\(user["Username"] as! String)"
                                    followedUserMarker.appearAnimation = GMSMarkerAnimation.pop
                                    self.userMarkerArray.append(followedUserMarker)
                                    
                                    
                                    var bounds = GMSCoordinateBounds()
                                    
                                    for marker in self.userMarkerArray {
                                        
                                        bounds = bounds.includingCoordinate(marker.position)
                                        
                                        if self.latitude != nil && self.latitude != 0 {
                                            
                                            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude))
                                            
                                        }
                                        
                                    }
                                    
                                    CATransaction.begin()
                                    CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                                    self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
                                    CATransaction.commit()
                                    self.usersLocationMode = false
                                }
                            }
                        }
                    }
                }
            }
            
            
        }
    }
    
    func askForReview() {
        
        let alert = UIAlertController(title: "Are you happy with TripKey?" , message: "We'd greatly appreciate your feedback! It helps a lot!.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            //for tripkey
            self.rateApp(appId: "1191492035", completion: { (success) in
               //print("RateApp \(success)")
            })
            
            //for tripkeyLite
            //self.rateApp(appId: "1197157982", completion: { (success) in
              //print("RateApp \(success)")
            //})
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
            //please give us feedback
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
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
        buttonsVisible = false
       UIView.animate(withDuration: 0.5, animations: {
            
            self.findPlacesButtonNew.alpha = 0
            self.addPlaceButtonNew.alpha = 0
            self.streetViewButtonNew.alpha = 0
            self.searchButton.alpha = 0
            self.nearMeButtonNew.alpha = 0
            self.fitFlightsButton.alpha = 0
            self.showUsersButton.alpha = 0
            
        }) { _ in
            
            self.findPlacesButtonNew.removeFromSuperview()
            self.addPlaceButtonNew.removeFromSuperview()
            self.streetViewButtonNew.removeFromSuperview()
            self.searchButton.removeFromSuperview()
            self.nearMeButtonNew.removeFromSuperview()
            self.fitFlightsButton.removeFromSuperview()
            self.showUsersButton.removeFromSuperview()
            
        }
        
       
    }
    
    func addButtons() {
        
       if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case.notDetermined:
                
                self.locationManager.requestWhenInUseAuthorization()
                
            case .restricted, .denied:
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "In order for the places feature to work TripKey needs to know your current location. Please tap settings and update the location permission for TripKey.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        
                        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                            //UIApplication.shared.openURL(url as URL)
                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                        }
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            case .authorizedAlways, .authorizedWhenInUse: break
                
            }
        }
        
        //if self.followedUsers.count > 0 {
            buttonsVisible = true
            showUsersButton = UIButton(frame: CGRect(x: googleMapsView.bounds.maxX - 65, y: googleMapsView.bounds.maxY - 455, width: 55 , height: 55))
            showUsersButton.setImage(#imageLiteral(resourceName: "whiteCommunity.png"), for: .normal)
            showUsersButton.backgroundColor = UIColor.clear
            showUsersButton.layer.cornerRadius = 28
            showUsersButton.alpha = 0.95
            showUsersButton.layer.shadowColor = UIColor.black.cgColor
            showUsersButton.layer.shadowOpacity = 0.8
            showUsersButton.layer.shadowOffset = CGSize.zero
            showUsersButton.layer.shadowRadius = 5
            showUsersButton.addTarget(self, action: #selector(showUsers), for: .touchUpInside)
            googleMapsView.addSubview(showUsersButton)
            showUsersButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: {
                
                self.showUsersButton.transform = .identity
                
            }, completion: nil)
            
        //}
        
       
        fitFlightsButton = UIButton(frame: CGRect(x: googleMapsView.bounds.maxX - 65, y: googleMapsView.bounds.maxY - 390, width: 55 , height: 55))
        fitFlightsButton.setImage(#imageLiteral(resourceName: "Taking Off- Tripkey.png"), for: .normal)
        fitFlightsButton.backgroundColor = UIColor.clear
        fitFlightsButton.layer.cornerRadius = 28
        fitFlightsButton.alpha = 0.95
        fitFlightsButton.layer.shadowColor = UIColor.black.cgColor
        fitFlightsButton.layer.shadowOpacity = 0.8
        fitFlightsButton.layer.shadowOffset = CGSize.zero
        fitFlightsButton.layer.shadowRadius = 5
        fitFlightsButton.addTarget(self, action: #selector(fitAirports), for: .touchUpInside)
        googleMapsView.addSubview(fitFlightsButton)
        fitFlightsButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: {
                
            self.fitFlightsButton.transform = .identity
                
        }, completion: nil)
            
        
        nearMeButtonNew = UIButton(frame: CGRect(x: googleMapsView.bounds.maxX - 65, y: googleMapsView.bounds.maxY - 65, width: 55 , height: 55))
        nearMeButtonNew.setImage(#imageLiteral(resourceName: "Near me- Tripkey.png"), for: .normal)
        nearMeButtonNew.backgroundColor = UIColor.clear
        nearMeButtonNew.layer.cornerRadius = 28
        nearMeButtonNew.alpha = 0.95
        nearMeButtonNew.layer.shadowColor = UIColor.black.cgColor
        nearMeButtonNew.layer.shadowOpacity = 0.8
        nearMeButtonNew.layer.shadowOffset = CGSize.zero
        nearMeButtonNew.layer.shadowRadius = 5
        nearMeButtonNew.addTarget(self, action: #selector(goNearMe), for: .touchUpInside)
        googleMapsView.addSubview(nearMeButtonNew)
        nearMeButtonNew.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: {
            
            self.nearMeButtonNew.transform = .identity
            
        }, completion: nil)
        
        findPlacesButtonNew = UIButton(frame: CGRect(x: googleMapsView.bounds.maxX - 65, y: googleMapsView.bounds.maxY - 130, width: 55 , height: 55))
        findPlacesButtonNew.setImage(#imageLiteral(resourceName: "Find places- tripkey.png"), for: .normal)
        findPlacesButtonNew.backgroundColor = UIColor.clear
        findPlacesButtonNew.layer.cornerRadius = 28
        findPlacesButtonNew.alpha = 0.95
        findPlacesButtonNew.layer.shadowColor = UIColor.black.cgColor
        findPlacesButtonNew.layer.shadowOpacity = 0.8
        findPlacesButtonNew.layer.shadowOffset = CGSize.zero
        findPlacesButtonNew.layer.shadowRadius = 5
        findPlacesButtonNew.addTarget(self, action: #selector(newFindPlacesButtonTap), for: .touchUpInside)
        googleMapsView.addSubview(findPlacesButtonNew)
        
        findPlacesButtonNew.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: {
            
            self.findPlacesButtonNew.transform = .identity
        
        }, completion: nil)
        
        addPlaceButtonNew = UIButton(frame: CGRect(x: googleMapsView.bounds.maxX - 65, y: googleMapsView.bounds.maxY - 195, width: 55 , height: 55))
        addPlaceButtonNew.setImage(#imageLiteral(resourceName: "Add Pin - Trip key.png"), for: .normal)
        addPlaceButtonNew.backgroundColor = UIColor.clear
        addPlaceButtonNew.layer.cornerRadius = 28
        addPlaceButtonNew.alpha = 0.95
        addPlaceButtonNew.layer.shadowColor = UIColor.black.cgColor
        addPlaceButtonNew.layer.shadowOpacity = 0.8
        addPlaceButtonNew.layer.shadowOffset = CGSize.zero
        addPlaceButtonNew.layer.shadowRadius = 5
        addPlaceButtonNew.addTarget(self, action: #selector(newAddPlaceButtonTap), for: .touchUpInside)
        googleMapsView.addSubview(addPlaceButtonNew)
        
        addPlaceButtonNew.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: { self.addPlaceButtonNew.transform = .identity }, completion: nil)
        
        streetViewButtonNew = UIButton(frame: CGRect(x: googleMapsView.bounds.maxX - 65, y: googleMapsView.bounds.maxY - 260, width: 55 , height: 55))
        streetViewButtonNew.setImage(#imageLiteral(resourceName: "Streetview- Tripkey.png"), for: .normal)
        streetViewButtonNew.backgroundColor = UIColor.clear
        streetViewButtonNew.layer.cornerRadius = 28
        streetViewButtonNew.alpha = 0.95
        streetViewButtonNew.layer.shadowColor = UIColor.black.cgColor
        streetViewButtonNew.layer.shadowOpacity = 0.8
        streetViewButtonNew.layer.shadowOffset = CGSize.zero
        streetViewButtonNew.layer.shadowRadius = 5
        streetViewButtonNew.addTarget(self, action: #selector(newStreetViewButtonTap), for: .touchUpInside)
        googleMapsView.addSubview(streetViewButtonNew)
        
        streetViewButtonNew.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: { self.streetViewButtonNew.transform = .identity }, completion: nil)
        
        searchButton = UIButton(frame: CGRect(x: googleMapsView.bounds.maxX - 65, y: googleMapsView.bounds.maxY - 325, width: 55 , height: 55))
        searchButton.setImage(#imageLiteral(resourceName: "Search - tripkey.png"), for: .normal)
        searchButton.backgroundColor = UIColor.clear
        searchButton.layer.cornerRadius = 28
        searchButton.alpha = 0.95
        searchButton.layer.shadowColor = UIColor.black.cgColor
        searchButton.layer.shadowOpacity = 0.8
        searchButton.layer.shadowOffset = CGSize.zero
        searchButton.layer.shadowRadius = 5
        searchButton.addTarget(self, action: #selector(NearMeViewController.showSearchBar), for: .touchUpInside)
        googleMapsView.addSubview(searchButton)
        
        searchButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .allowUserInteraction, animations: { self.searchButton.transform = .identity }, completion: nil)
        
        
    }
    
    func showUsers() {
        
        if self.isUserLoggedIn() == true {
            
            if let followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as? [Dictionary<String,Any>] {
                    
                    self.followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
                    
                    if self.followedUsers.count > 0 {
                        
                        for (index, user) in followedUsers.enumerated() {
                            
                            self.userNames.append(user["Username"] as! String)
                            
                            //add users to map
                            if user["Latitude"] != nil && user["Latitude"] as! String != "" {
                                
                                if user["Longitude"] != nil && user["Longitude"] as! String != "" {
                                    
                                    let latitude = user["Latitude"] as! String
                                    let longitude = user["Longitude"] as! String
                                    print("latitude = \(latitude)")
                                    print("longitude = \(longitude)")
                                    
                                    var  followedUserMarker:GMSMarker!
                                    var location:CLLocationCoordinate2D!
                                    location = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
                                    followedUserMarker = GMSMarker(position: location)
                                    followedUserMarker.isTappable = true
                                    followedUserMarker.icon = UIImage(named: "User-Profile.png")
                                    followedUserMarker.map = self.googleMapsView
                                    followedUserMarker.accessibilityLabel = "Followed User - \(index)"
                                    followedUserMarker.snippet = "\(user["Username"] as! String)"
                                    followedUserMarker.appearAnimation = GMSMarkerAnimation.pop
                                    self.userMarkerArray.append(followedUserMarker)
                                    
                                    
                                    var bounds = GMSCoordinateBounds()
                                    
                                    for marker in self.userMarkerArray {
                                        
                                        bounds = bounds.includingCoordinate(marker.position)
                                        
                                        if self.latitude != nil && self.latitude != 0 {
                                            
                                            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude))
                                            
                                        }
                                        
                                    }
                                    
                                    CATransaction.begin()
                                    CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                                    self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds))
                                    CATransaction.commit()
                                    
                                }
                            }
                        }
                    }
                }
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Community", comment: ""), style: .default, handler: { (action) in
                    
                    self.performSegue(withIdentifier: "Show User Feed", sender: self)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            
            self.promptUserToLogIn()
        }
        
    }
    
    func fitAirports() {
        
        print("fitAirports()")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add Flights", comment: ""), style: .default, handler: { (action) in
            
            self.performSegue(withIdentifier: "goToAddFlights", sender: self)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        var bounds = GMSCoordinateBounds()
        
        for marker in departureMarkerArray {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        for marker in arrivalMarkerArray {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        CATransaction.begin()
        CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
        self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        CATransaction.commit()
    }
    
    func goNearMe() {
        
        //check for permissions
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "In order for the places feature to work TripKey needs to know your current location. Please tap settings and update the location permission for TripKey.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        
                        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                            //UIApplication.shared.openURL(url as URL)
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
        let userLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
        
        //if UserDefaults.standard.bool(forKey: "userSwipedBack") != true {
          
          //  self.googleMapsView.animate(toLocation: userLocation)
            
        //}
        
        UserDefaults.standard.set(latitude, forKey: "usersLatitude")
        UserDefaults.standard.set(longitude, forKey: "usersLongitude")
        
        var user = PFUser()
        
        if PFUser.current() != nil {
            
            user = PFUser.current()!
            
            //UserDefaults.standard.set(user.username, forKey: "username")
            
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
    
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    

    func parsePlaceCategory(category: String) {
        
        print("parsePlaceCategory")
        
        addActivityIndicatorCenter()
        self.activityLabel.text = NSLocalizedString("Finding Places", comment: "")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var url:NSURL!
        var placeId:String!
        let latitude = self.googleMapsView.camera.target.latitude
        let longitude = self.googleMapsView.camera.target.longitude
        
        url = NSURL(string: "https://maps.googleapis.com/maps/api/place/radarsearch/json?location=\(latitude),\(longitude)&radius=50000&type=\(category)&language=en-GB&key=AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    self.activityIndicator.stopAnimating()
                    self.activityLabel.removeFromSuperview()
                    self.blurEffectViewActivity.removeFromSuperview()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonPlacesResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            self.placeDictionaries.removeAll()
                            UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                            
                            if let placesArrayCheck = (jsonPlacesResult)["results"] as? NSArray {
                                
                                if placesArrayCheck.count == 0 {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.displayAlert(title: NSLocalizedString("There were no places in the", comment: "") + " \(category)" + "category found in that area.", message: NSLocalizedString("Make sure you center the map on the area you want to search, all searches are biased to the center of your map.", comment: ""))
                                        
                                    }
                                }
                                
                                for (index, place) in placesArrayCheck.enumerated() {
                                    
                                    if let placeIdCheck = ((place as? NSDictionary)?["place_id"]) as? String {
                                        
                                        DispatchQueue.main.async {
                                            
                                            placeId = placeIdCheck
                                            let latitude = (((place as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double
                                            let longitude = (((place as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double
                                            
                                            let placeCoordinates = CLLocation(latitude: latitude!, longitude: longitude!)
                                            
                                            if self.googleMapsView.myLocation != nil {
                                                
                                                let distanceInMeters = placeCoordinates.distance(from: self.googleMapsView.myLocation!)
                                                let distanceInMiles = Double(distanceInMeters) * 0.000621371
                                                let roundedDistance = String(round(10.0 * distanceInMiles) / 10.0)
                                                
                                                self.placeDictionary = [
                                                    
                                                    "Place Latitude":"\(latitude!)",
                                                    "Place Longitude":"\(longitude!)",
                                                    "Place ID":"\(placeId!)",
                                                    "Distance":"\(roundedDistance)",
                                                    "Index":"\(index)",
                                                    "Place Type":"\(category)"
                                                    
                                                ]
                                                
                                                self.placeDictionaries.append(self.placeDictionary)
                                                self.sortPlacesByDistanceAway()
                                                
                                            } else {
                                                
                                                var distance:String!
                                                
                                                if self.placeDictionaries.count > 1 {
                                                    
                                                    let previousLatitude = self.placeDictionaries[self.placeDictionaries.count - 1]["Place Latitude"]!
                                                    let previousLongitude = self.placeDictionaries[self.placeDictionaries.count - 1]["Place Longitude"]!
                                                    let previousLocation = CLLocation(latitude: Double(previousLatitude)!, longitude: Double(previousLongitude)!)
                                                    let distanceInMeters = placeCoordinates.distance(from: previousLocation)
                                                    let distanceInMiles = Double(distanceInMeters) * 0.000621371
                                                    distance = String(round(10.0 * distanceInMiles) / 10.0)
                                                    
                                                } else if self.placeDictionaries.count <= 1 {
                                                    
                                                    distance = "0"
                                                }
                                                
                                                self.placeDictionary = [
                                                    
                                                    "Place Latitude":"\(latitude!)",
                                                    "Place Longitude":"\(longitude!)",
                                                    "Place ID":"\(placeId!)",
                                                    "Distance":"\(distance!)",
                                                    "Index":"\(index)",
                                                    "Place Type":"\(category)"
                                                    
                                                ]
                                                
                                                self.placeDictionaries.append(self.placeDictionary)
                                                self.sortPlacesByDistanceAway()
                                            }
                                        }
                                    }
                                }
                                
                                let when = DispatchTime.now() + 0.5
                                DispatchQueue.main.asyncAfter(deadline: when) {
                                    
                                    UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                                  
                                    for (index, place) in self.placeDictionaries.enumerated() {
                                        
                                        let longitude = Double(place["Place Longitude"]!)
                                        let latitude = Double(place["Place Latitude"]!)
                                        let placeId = place["Place ID"]!
                                        self.locatePlacesFromCategoryWithLongitude(longitude: longitude!, latitude: latitude!, placeId: placeId, index: index)
                                        
                                        DispatchQueue.main.async {
                                            self.fitAllMarkers()
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
                            
                        } catch {
                            
                            DispatchQueue.main.async {
                                
                                self.activityIndicator.stopAnimating()
                                self.activityLabel.removeFromSuperview()
                                self.blurEffectViewActivity.removeFromSuperview()
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                            
                            print("JSon processing failed")
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                }
            }
        }
        
        task.resume()
        
    }
    
    func sortPlacesByDistanceAway() {
        
        print("sortPlacesByDistanceAway")
        
        sortedPlaces =  self.placeDictionaries.sorted {
            
            (dictOne, dictTwo) -> Bool in
            
            let d1 = Double(dictOne["Distance"]!)
            let d2 = Double(dictTwo["Distance"]!)
            
            return d1! < d2!
            
        };
        
        self.placeDictionaries = sortedPlaces
        
    }
    
    func fitAllMarkers() {
        
        print("fitAllMarkers")
        
            var bounds = GMSCoordinateBounds()
            
            for marker in placeMarkerArray {
                bounds = bounds.includingCoordinate(marker.position)
            }
        
        CATransaction.begin()
        CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
        self.googleMapsView.animate(with: GMSCameraUpdate.fit(bounds))
        CATransaction.commit()
        
    }
    
    func locatePlacesFromCategoryWithLongitude(longitude: Double, latitude: Double, placeId: String, index: Int) {
        
        print("locatePlacesFromCategoryWithLongitude")
        
        DispatchQueue.main.async() { () -> Void in
            
            self.addActivityIndicatorCenter()
            self.activityLabel.text = NSLocalizedString("Finding Places", comment: "")
            self.googleMapsView.delegate = self
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let marker = GMSMarker(position: position)
            marker.map = self.googleMapsView
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.accessibilityLabel = "Place - \(index)"
            marker.icon = UIImage(named: "placesMarker3.png")
            marker.tracksInfoWindowChanges = true
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 5)
            self.bounds.includingCoordinate(marker.position)
            self.placeMarkerArray.append(marker)
            self.activityIndicator.stopAnimating()
            self.blurEffectViewActivity.removeFromSuperview()
            self.activityLabel.removeFromSuperview()
            
        }
    }
    
    
    func deletePanoView() {
        
        print("deletePanoView")
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.panoView.alpha = 0
            
        }) { _ in
            
            self.button.removeFromSuperview()
            self.panoView.removeFromSuperview()
            
        }
        
    }
    
    func showSearchBar() {
        
        print("showSearchBar")
        
        self.placeDictionaries.removeAll()
        self.placeDictionary = Dictionary<String,String>()
        UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
        self.googleMapsView.selectedMarker = nil
        
        if self.placeMarkerArray.count > 0 {
            
            for marker in self.placeMarkerArray {
                
                marker.map = nil
            }
        }
        
        self.placeMarkerArray.removeAll()
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
        
    }
    
    
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String, placeId: String, index: Int) {
        
        print("locateWithLongitude")
        
        self.category = "N/A"
        
        DispatchQueue.main.async {
            
            self.googleMapsView.delegate = self
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            marker.map = self.googleMapsView
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.accessibilityLabel = "Place - \(index)"
            marker.icon = UIImage(named: "placesMarker copy.png")
            marker.tracksInfoWindowChanges = true
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 5)
            self.placeMarkerArray.append(marker)
            
            CATransaction.begin()
            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
            self.googleMapsView.animate(toLocation: position)
            CATransaction.commit()
            
            
            self.view.addSubview(self.blurEffectViewTopView)
            
            
            self.view.addSubview(self.blurEffectViewBottomView)
            
            
            self.view.addSubview(self.blurEffectView)
            
            self.tappedMarkerIndex = 0
            self.parsePlaceInfoWindow(index: 0)
            
            self.view.addSubview(self.placeInfoWindow)
            
            
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchBar.removeFromSuperview()
        self.searchButton.isHidden = false
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        let placesClient = GMSPlacesClient()
        
        let northEast = googleMapsView.projection.coordinate(for: CGPoint(x: googleMapsView.frame.width, y: 0 ))
        let southWest = googleMapsView.projection.coordinate(for: CGPoint(x: 0, y: googleMapsView.frame.height))
        
        let bounds:GMSCoordinateBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        
        placesClient.autocompleteQuery(searchText, bounds: bounds, filter: nil) { (results, error:Error?) -> Void in
            
            self.resultsArray.removeAll()
            
            if results == nil {
                
                return
                
            }
            
            for result in results!{
                
                if let result = result as? GMSAutocompletePrediction {
                    
                    self.resultsArray.append(result.attributedFullText.string)
                }
                
            }
            
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    func deleteBiasPanoView() {
        
        print("deleteBiasPanoView")
        
        UserDefaults.standard.removeObject(forKey: "streetNumber")
        UserDefaults.standard.removeObject(forKey: "neighborhood")
        UserDefaults.standard.removeObject(forKey: "route")
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.panoView.alpha = 0
            
        }) { _ in
            
           self.panoView.removeFromSuperview()
            
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        let zoom = Float(mapView.camera.zoom)
        
        self.iconZoom = zoom
        
        self.updateIcon()
        
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
        
        print("didTap marker = \(marker)")
        
        let tappedMarkerLatitude = marker.position.latitude
        let tappedMarkerLongitude = marker.position.longitude
        UserDefaults.standard.set(tappedMarkerLatitude, forKey: "tappedMarkerLatitude")
        UserDefaults.standard.set(tappedMarkerLongitude, forKey: "tappedMarkerLongitude")
        
        if marker.accessibilityLabel! == "selectedPlace" {
            
            let longitude = marker.position.longitude
            let latitude = marker.position.latitude
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let screenSize: CGRect = UIScreen.main.bounds
            self.panoView = GMSPanoramaView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            self.panoView.center = self.view.center
            self.panoView.alpha = 0
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gesture:)))
            swipeDown.direction = UISwipeGestureRecognizerDirection.down
            self.panoView.addGestureRecognizer(swipeDown)
            self.panoView.moveNearCoordinate(coordinates)
            self.buttonPanoView.frame = CGRect(x: self.panoView.frame.size.width - 60, y: 20, width: 30, height: 30)
            self.buttonPanoView.backgroundColor = UIColor.red
            self.buttonPanoView.setTitle("X", for: .normal)
            self.buttonPanoView.layer.cornerRadius = 5
            self.buttonPanoView.addTarget(self, action: #selector(NearMeViewController.deleteBiasPanoView), for: .touchUpInside)
            self.panoView.addSubview(buttonPanoView)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.view.addSubview(self.panoView)
                self.panoView.alpha = 1
                
                
            }) { _ in
                
                
            }
            
            
        } else if (marker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Followed User"  {
            
            let index:Int = Int((marker.accessibilityLabel?.components(separatedBy: " - ")[1])!)!
            
            print("directionsToArrivalAirport")
            let longitude = self.followedUsers[index]["Longitude"] as! String
            let latitude = self.followedUsers[index]["Latitude"] as! String
            let coordinate = CLLocationCoordinate2DMake(Double(latitude)!,Double(longitude)!)
            let name = self.followedUsers[index]["Username"] as! String
            
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                
                let alert = UIAlertController(title: NSLocalizedString("Which map would you like to use?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Apple Maps", comment: ""), style: .default, handler: { (action) in
                    
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                    mapItem.name = name
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Google Maps", comment: ""), style: .default, handler: { (action) in
                    
                    
                    let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")
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

            
        
            
            
        } else if (marker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" || (marker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
            
            
            self.resetTimers()
            self.userTappedRoute = false
            let index:Int = Int((marker.accessibilityLabel?.components(separatedBy: " - ")[1])!)!
            self.flightIndex = index
            self.tappedMarker = marker
            let tappedMarkerLatitude = marker.position.latitude
            let tappedMarkerLongitude = marker.position.longitude
            self.tappedCoordinates = CLLocationCoordinate2D(latitude: tappedMarkerLatitude, longitude: tappedMarkerLongitude)
            let newPosition = GMSCameraPosition(target: self.tappedCoordinates, zoom: 6, bearing: self.googleMapsView.camera.bearing, viewingAngle: self.googleMapsView.camera.viewingAngle)
            self.removeButtons()
            CATransaction.begin()
            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
            self.googleMapsView.animate(to: newPosition)
            CATransaction.commit()
            
            //self.parseLeg2Only(dictionary: flights[index], index: index)
            self.showFlightInfoWindows(flightIndex: self.flightIndex)
            self.addFlightViewFromRightToLeft()
             //self.infoWindowIsVisible = true
            
           return false
            
        } else if (marker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Place" {
            
            let index:Int = Int((marker.accessibilityLabel?.components(separatedBy: " - ")[1])!)!
            self.tappedMarkerIndex = (index)
            self.tappedMarker = marker
            let tappedMarkerLatitude = marker.position.latitude
            let tappedMarkerLongitude = marker.position.longitude
            self.tappedCoordinates = CLLocationCoordinate2D(latitude: tappedMarkerLatitude, longitude: tappedMarkerLongitude)
            
            self.view.addSubview(self.blurEffectViewTopView)
            
            //self.blurEffectViewBottomView.center = self.placeInfoWindow.bottomView.center
            
            self.view.addSubview(self.blurEffectViewBottomView)
            
            self.view.addSubview(self.blurEffectView)
            self.parsePlaceInfoWindow(index: index)
            
            self.view.addSubview(self.placeInfoWindow)
            
            
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
                self.displayAlert(title: NSLocalizedString("No phone number given", comment: ""), message: "")
            }
        }
        
        
    }
    
    func parsePlaceInfoWindow(index: Int) {
        
        print("parsePlaceInfoWindow")
        
        self.removeButtons()
        /*
        self.mapView.frame = self.view.frame
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.googleMapsView.frame = self.mapView.frame
            
            
        }, completion: { _ in
            
            self.bottomToolbar.isHidden = true
            self.bottomToolBarVisible = false
            
        })
        */
        
        self.placeDictionaries = UserDefaults.standard.object(forKey: "placeDictionaries") as! [Dictionary<String,String>]
        let placeId = self.placeDictionaries[index]["Place ID"]!
        self.placeId = placeId
        
        let placeDictionaryForOverview = [
            
            "Place ID":"\(placeId)"
            
        ]
        
        UserDefaults.standard.set(placeDictionaryForOverview, forKey: "placeDictionaryForOverview")
        
        DispatchQueue.main.async {
                
                let longitude = self.placeDictionaries[index]["Place Longitude"]!
                let latitude = self.placeDictionaries[index]["Place Latitude"]!
                let placeCoordinates = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
            
            if self.googleMapsView.myLocation != nil {
                
                let distanceInMeters = placeCoordinates.distance(from: self.googleMapsView.myLocation!)
                let distanceInMiles = Double(distanceInMeters) * 0.000621371
                let roundedDistance = String(round(10.0 * distanceInMiles) / 10.0)
                self.placeInfoWindow.distanceFromUser.text = "\(roundedDistance)\(NSLocalizedString(" miles from you", comment: ""))"
                
            } else {
                
                self.placeInfoWindow.distanceFromUser.text = ""
                
            }
            
                
            }
            
       let url = NSURL(string:"https://maps.googleapis.com/maps/api/place/details/json?placeid=" + placeId + "&key=AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw")
        
        var internationalPhoneNumber:String! = ""
        var address:String! = ""
        var priceLevel:Double! = -1
        var name:String! = ""
        var geometry:NSDictionary! = [:]
        var website:String! = ""
        var rating:Double! = -1
        var latitude:Double! = 0
        var longitude:Double! = 0
        
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            DispatchQueue.main.async {
                                self.addActivityIndicatorPhotos()
                                self.activityLabel.text = "Loading Photos"
                            }
                            
                            let jsonPlaceResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonPlaceResult = \(jsonPlaceResult)")
                            
                            if let placeDictionaryCheck = jsonPlaceResult["result"] as? NSDictionary {
                                
                                let place = placeDictionaryCheck
                                
                                if let countryCheck = place["address_components"] as? NSArray {
                                    
                                    for country in countryCheck {
                                        
                                        if let types = ((country as? NSDictionary)?["types"]) as? NSArray {
                                            
                                            if types.count > 0 {
                                              
                                                for type in types {
                                                    
                                                    let type = type as? String
                                                    
                                                    if type == "country" {
                                                        
                                                        if let countryName = (country as? NSDictionary)?["long_name"] as? String {
                                                            
                                                            self.country = countryName
                                                            
                                                        }
                                                        
                                                        
                                                    }
                                                    
                                                    if type == "locality" {
                                                        
                                                        if let cityName = (country as? NSDictionary)?["long_name"] as? String {
                                                            
                                                            self.city = cityName
                                                            
                                                        }
                                                        
                                                    }
                                                }

                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                
                                if let nameCheck = place["name"] as? String {
                                    
                                    name = nameCheck
                                    self.name = name
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.placeInfoWindow.name.text = name
                                        
                                    }
                                }
                                
                                if let openingHoursCheck = place["opening_hours"] as? NSDictionary {
                                    
                                    if let hoursOfOperationCheck = openingHoursCheck["weekday_text"] as? NSArray {
                                        
                                        if hoursOfOperationCheck.count > 0 {
                                          
                                            var days = [String]()
                                            
                                            for day in hoursOfOperationCheck {
                                                
                                                if let dayString = day as? String {
                                                    
                                                    var array1 = dayString.components(separatedBy: ": ")
                                                    var array2 = array1[1].components(separatedBy: "\\")
                                                    
                                                    if array2.count > 1 {
                                                        
                                                        var array3 = array2[1].components(separatedBy: " ")
                                                        let newString = "\(array1[0]) \(array3[1])\(array3[2])"
                                                        
                                                        
                                                        days.append(newString)
                                                        
                                                    } else {
                                                        
                                                        let newString = "\(array1[0]) \(array1[1])"
                                                        days.append(newString)
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                            DispatchQueue.main.async {
                                                self.hoursOfOperation.monday.text = days[0]
                                                self.hoursOfOperation.tuesday.text = days[1]
                                                self.hoursOfOperation.wedsnday.text = days[2]
                                                self.hoursOfOperation.thursday.text = days[3]
                                                self.hoursOfOperation.friday.text = days[4]
                                                self.hoursOfOperation.saturday.text = days[5]
                                                self.hoursOfOperation.sunday.text = days[6]
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    if let openNow = openingHoursCheck["open_now"] as? Bool {
                                        
                                        if openNow == false {
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.placeInfoWindow.openOrClosed.text = NSLocalizedString("Closed", comment: "")
                                            }
                                            
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.placeInfoWindow.openOrClosed.text = NSLocalizedString("Open", comment: "")
                                                
                                            }
                                            
                                        }
                                        
                                    } else {
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.placeInfoWindow.openOrClosed.text = ""
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                if let internationalPhoneNumberCheck = place["international_phone_number"] as? String {
                                    
                                    internationalPhoneNumber = internationalPhoneNumberCheck
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.phoneNumberString = internationalPhoneNumber
                                        
                                    }
                                    
                                } else if let phoneNumberCheck = place["formatted_phone_number"] as? String {
                                    
                                    internationalPhoneNumber = phoneNumberCheck
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.phoneNumberString = internationalPhoneNumber
                                        
                                    }
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.phoneNumberString = ""
                                        
                                    }
                                }
                                
                                if let addressCheck = place["formatted_address"] as? String {
                                    
                                    address = addressCheck
                                    
                                    let addressArray = address.replacingOccurrences(of: ", ", with: "\n")
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.address = addressArray
                                        
                                    }
                                }
                                
                                if let priceLevelCheck = place["price_level"] as? Double {
                                    
                                    priceLevel = priceLevelCheck
                                    
                                    var level:String!
                                    
                                    if priceLevel <= 2 {
                                        
                                        level = "Cheap"
                                        
                                    } else if priceLevel == 3 {
                                        
                                        level = "Average"
                                        
                                    } else if priceLevel > 3 {
                                        
                                        level = "Expensive"
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.placeInfoWindow.priceRange.text = level!
                                        
                                    }
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.placeInfoWindow.priceRange.text = ""
                                        
                                    }
                                    
                                }
                                /*
                                if let typesCheck = place["types"] as? NSArray {
                                    
                                    types = typesCheck
                                    
                                }
                                
                                */
                                
                                if let geometryCheck = place["geometry"] as? NSDictionary {
                                    
                                    geometry = geometryCheck
                                }
                                
                                if let latitudeCheck = (geometry["location"] as? NSDictionary)?["lat"] as? Double {
                                    
                                    latitude = latitudeCheck
                                    
                                    if let longitudeCheck = (geometry["location"] as? NSDictionary)?["lng"] as? Double {
                                        
                                        print("longitudeCheck")
                                        
                                        longitude = longitudeCheck
                                        
                                        DispatchQueue.main.async {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                
                                                CATransaction.begin()
                                                CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                                                self.googleMapsView.animate(toLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                                CATransaction.commit()
                                                
                                                
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                    
                                                    
                                                    
                                                    CATransaction.begin()
                                                    CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
                                                    self.googleMapsView.animate(toZoom: 18)
                                                    CATransaction.commit()
                                                    
                                                })
                                                
                                            })
                                            
                                            self.swiping = true
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                if let websiteCheck = place["website"] as? String {
                                    
                                    website = websiteCheck
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.website = website
                                        
                                    }
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.website = ""
                                        
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
                                        
                                        if let error = error {
                                            
                                            // TODO: handle the error.
                                            print("Error: \(error.localizedDescription)")
                                            
                                            DispatchQueue.main.async {
                                                self.activityIndicator.stopAnimating()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                self.activityLabel.removeFromSuperview()
                                            }
                                            
                                        } else {
                                            
                                            if let firstPhoto = photos?.results.first {
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                                                        (photo, error) -> Void in
                                                        
                                                        if let error = error {
                                                            
                                                            // TODO: handle the error.
                                                            print("Error: \(error.localizedDescription)")
                                                            DispatchQueue.main.async {
                                                                self.activityIndicator.stopAnimating()
                                                                self.blurEffectViewActivity.removeFromSuperview()
                                                                self.activityLabel.removeFromSuperview()
                                                            }
                                                            
                                                        } else {
                                                            
                                                            DispatchQueue.main.async {
                                                                
                                                                self.placeInfoWindow.alpha = 0
                                                                self.placeInfoWindow.icon.alpha = 0
                                                                self.placeInfoWindow.pictureView.alpha = 0
                                                                self.placeInfoWindow.icon.image = photo
                                                                self.placeInfoWindow.copyright.attributedText = firstPhoto.attributions
                                                                self.activityIndicator.stopAnimating()
                                                                self.blurEffectViewActivity.removeFromSuperview()
                                                                self.activityLabel.removeFromSuperview()
                                                                
                                                                UIView.animate(withDuration: 0.5, animations: {
                                                                    
                                                                    self.placeInfoWindow.alpha = 1
                                                                    
                                                                }) { _ in
                                                                    
                                                                }
                                                                
                                                                var launchedPlaceInfoWindowBefore = UserDefaults.standard.bool(forKey: "launchedPlaceInfoWindowBefore")
                                                                
                                                                if launchedPlaceInfoWindowBefore == false {
                                                                    
                                                                    UserDefaults.standard.set(true, forKey: "launchedPlaceInfoWindowBefore")
                                                                    let image = UIImage(named: "finger.png")
                                                                    let imageView = UIImageView(image: image!)
                                                                    imageView.frame = CGRect(x: 0, y: 0, width: 180 , height: 180)
                                                                    imageView.center = CGPoint(x: self.view.frame.size.width, y: self.view.center.y)
                                                                    imageView.contentMode = .scaleAspectFit
                                                                    imageView.backgroundColor = UIColor.clear
                                                                    imageView.layer.cornerRadius = 10
                                                                    imageView.alpha = 0
                                                                    self.blurEffectView5.frame = CGRect(x: 0, y: 0, width: 180 , height: 180)
                                                                    self.blurEffectView5.center = CGPoint(x: self.view.frame.size.width, y: self.view.center.y)
                                                                    self.blurEffectView5.layer.cornerRadius = 10
                                                                    self.blurEffectView5.clipsToBounds = true
                                                                    self.blurEffectView5.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                                                    self.blurEffectView5.alpha = 0
                                                                    self.view.addSubview(imageView)
                                                                    
                                                                    UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                                                                     
                                                                        imageView.alpha = 1
                                                                    
                                                                        
                                                                    }, completion: { (true) in
                                                                        
                                                                        UIView.animate(withDuration: 2.0, delay: 0, options: [], animations: {
                                                                            
                                                                            var imageFrame:CGRect!
                                                                            imageFrame = imageView.frame
                                                                            imageFrame.origin.x = (self.view.frame.size.width) * -1
                                                                            imageView.frame = imageFrame
                                                                            
                                                                        }, completion: { (true) in
                                                                            
                                                                            imageView.alpha = 0
                                                                            imageView.removeFromSuperview()
                                                                            
                                                                            DispatchQueue.main.async {
                                                                                
                                                                                self.displayAlert(title: "Swipe left or right to go to the next place.\n\nSwipe up to see photos.\n\nSwipe down to close the place.\n\nTap the map to see opening hours or place info.\n\nPress the map to see street view.", message: "")
                                                                                
                                                                            }
                                                                            
                                                                        })
                                                                        
                                                                    })
                                                                    
                                                                }
                                                                
                                                                
                                                                if self.swipingPic == true {
                                                                    
                                                                    UIView.animate(withDuration: 0.5, animations: {
                                                                        
                                                                        self.blurEffectView.alpha = 1
                                                                        self.placeInfoWindow.icon.alpha = 1
                                                                        self.placeInfoWindow.pictureView.alpha = 1
                                                                        
                                                                    }) { _ in
                                                                        
                                                                    }
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                    })
                                                    
                                                }
                                            } else {
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    self.placeInfoWindow.copyright.text = ""
                                                    self.activityIndicator.stopAnimating()
                                                    self.blurEffectViewActivity.removeFromSuperview()
                                                    self.activityLabel.removeFromSuperview()
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    GMSPlacesClient.shared().lookUpPhotos(forPlaceID: self.placeId) { (photos, error) -> Void in
                                        
                                        if let error = error {
                                            
                                            print("Error: \(error.localizedDescription)")
                                            
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.imageArray.removeAll()
                                                self.attributedTextArray.removeAll()
                                                self.imageArrayStrings.removeAll()
                                                
                                                if let photos = photos?.results {
                                                    
                                                    for picture in photos {
                                                        
                                                        DispatchQueue.main.async {
                                                            
                                                            GMSPlacesClient.shared().loadPlacePhoto(picture, callback: {
                                                                
                                                                (photo, error) -> Void in
                                                                
                                                                if let error = error {
                                                                    
                                                                    print("Error: \(error.localizedDescription)")
                                                                    
                                                                } else {
                                                                    
                                                                    DispatchQueue.main.async {
                                                                        
                                                                        if photo != nil {
                                                                            
                                                                            self.imageArray.append(photo!)
                                                                            self.imageArrayStrings.append("1 photo")
                                                                            
                                                                            if picture.attributions != nil {
                                                                                
                                                                             self.attributedTextArray.append(picture.attributions!)
                                                                                
                                                                            } else {
                                                                                
                                                                                self.attributedTextArray.append(NSAttributedString(string: "no copyright", attributes: nil))
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                            })
                                                            
                                                        }
                                                        
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                if let ratingCheck = place["rating"] as? Double {
                                    
                                    rating = ratingCheck
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.placeInfoWindow.rating.text = "\(NSLocalizedString("Rating: ", comment: "")) \(String(rating)) \(NSLocalizedString("out of 5", comment: ""))"
                                        
                                    }
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.placeInfoWindow.rating.text = ""
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        } catch {
                            
                            print("JSon processing failed")
                            
                        }
                    }
                }
            }
        }
        
        task.resume()
        
        self.placeInfoWindow.tapCall = {
            
            print("TapCall")
            self.callPlace()
        }
        
        self.placeInfoWindow.tapWebsite = {
            
            print("TapWebsite")
            let website = self.website
            
            if website != "" {
                
                UserDefaults.standard.set(website, forKey: "urlString")
                self.performSegue(withIdentifier: "goToWebsite", sender: self)
                
            } else {
                
                DispatchQueue.main.async {
                    self.displayAlert(title: "No Website registered.", message: "Sorry there is no website for this place.")
                }
            }
            
            
        }
        
        self.placeInfoWindow.tapShare = {
            
            if self.isUserLoggedIn() == true {
                
                let alert = UIAlertController(title: NSLocalizedString("Share place with", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                for user in self.userNames {
                    
                    alert.addAction(UIAlertAction(title: " \(user)", style: .default, handler: { (action) in
                        
                        let sharedPlace = PFObject(className: "SharedPlace")
                        
                        sharedPlace["shareToUsername"] = user
                        sharedPlace["shareFromUsername"] = PFUser.current()?.username
                        sharedPlace["placeName"] = name
                        sharedPlace["placeId"] = placeId
                        sharedPlace["placePhoneNumber"] = internationalPhoneNumber
                        sharedPlace["placeWebsite"] = website
                        sharedPlace["placeAddress"] = address
                        sharedPlace["placeLatitude"] = String(latitude)
                        sharedPlace["placeLongitude"] = String(longitude)
                        sharedPlace["placeCountry"] = self.country
                        sharedPlace["placeCity"] = self.city
                        sharedPlace["placeType"] = self.category!
                        
                        sharedPlace.saveInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                print("error = \(error as Any)")
                                
                                let alert = UIAlertController(title: NSLocalizedString("Could not share place", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                                
                                let alert = UIAlertController(title: NSLocalizedString("Place shared to", comment: "") + " \(user)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                
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
                                                    request.httpBody = "{\"to\":\"\(fcmToken)\",\"priority\":\"high\",\"notification\":{\"body\":\"\(username) shared a place with you.\"}}".data(using: .utf8)
                                                    
                                                    URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                                                        
                                                        if error != nil {
                                                            
                                                            print(error!)
                                                        }
                                                        
                                                        
                                                    }).resume()
                                                    
                                                }
                                                
                                            } else {
                                                
                                                //user not allowed notifications
                                            }
                                            
                                        }
                                    }
                                }
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                        
                    }))
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.promptUserToLogIn()
            }
            
        }
        
        self.placeInfoWindow.tapReviews = {
            
            print("tapReviews")
            self.reviewsMode = true
            self.photosMode = false
            UserDefaults.standard.set(longitude, forKey: "selectedPlaceLongitude")
            UserDefaults.standard.set(latitude, forKey: "selectedPlaceLatitude")
            UserDefaults.standard.set(placeId, forKey: "placeId")
            
            UserDefaults.standard.set(self.placeDictionaries[index], forKey: "placeDictionary")
            
            self.performSegue(withIdentifier: "goToPlaceOverview", sender: self)
            
        }
        
        self.placeInfoWindow.tapGoToPhotos = {
            
            print("tapReviews")
            self.reviewsMode = false
            self.photosMode = true
            UserDefaults.standard.set(longitude, forKey: "selectedPlaceLongitude")
            UserDefaults.standard.set(latitude, forKey: "selectedPlaceLatitude")
            UserDefaults.standard.set(placeId, forKey: "placeId")
            
            UserDefaults.standard.set(self.placeDictionaries[index], forKey: "placeDictionary")
            
            self.performSegue(withIdentifier: "goToPlaceOverview", sender: self)
            
            
        }
        
        self.placeInfoWindow.tapDirections = {
            
            print("tapDirections")
            let longitude = self.placeDictionaries[index]["Place Longitude"]!
            let latitude = self.placeDictionaries[index]["Place Latitude"]!
            let coordinate = CLLocationCoordinate2DMake(Double(latitude)!,Double(longitude)!)
            
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                
                let alert = UIAlertController(title: NSLocalizedString("Which map would you like to use?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Apple Maps", comment: ""), style: .default, handler: { (action) in
                    
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                    mapItem.name = name
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Google Maps", comment: ""), style: .default, handler: { (action) in
                    
                    
                    let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")
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
            
        }
        
        self.placeInfoWindow.tapPhotos = {
            
            print("tapSave")
            
            if self.category != nil {
                
                let longitude = self.placeDictionaries[index]["Place Longitude"]!
                let latitude = self.placeDictionaries[index]["Place Latitude"]!
                
                var userAddedPlaceDictionary:Dictionary<String,String>!
                
                if self.phoneNumberString == nil {
                    
                    self.phoneNumberString = "NA"
                }
                
                userAddedPlaceDictionary = [
                    
                    "Place Name":"\(name!)",
                    "Place Type":"\(self.category!)",
                    "Place Website":"\(website!)",
                    "Place Phone Number":"\(internationalPhoneNumber!)",
                    "Place Address":"\(address!)",
                    "Place ID":"\(placeId)",
                    "Place Latitude":"\(latitude)",
                    "Place Longitude":"\(longitude)",
                    "Place Country":"\(self.country)",
                    "Place City":"\(self.city)",
                    "Place Notes":"N/A",
                    "Place State":"\(self.state)"
                ]
                
                //for tripkey
                self.nonConsumablePurchaseMade = true
                
                if self.userAddedPlaceDictionaryArray.count > 0 {
                    
                    self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                    
                    if self.userAddedPlaceDictionaryArray.count == 5 && self.nonConsumablePurchaseMade == false {
                        
                        self.fetchAvailableProducts()
                        
                        let alert = UIAlertController(title: NSLocalizedString("Youv'e reached your limit of saved places.", comment: ""), message: NSLocalizedString("This will be a one time charge that is valid even if you switch phones or uninstall TripKey.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Unlock Premium for $2.99", comment: ""), style: .default, handler: { (action) in
                            
                            DispatchQueue.main.async {
                                
                                self.addActivityIndicatorCenter()
                                self.activityLabel.text = NSLocalizedString("Purchasing", comment: "")
                                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                                
                            }
                            
                            self.purchaseMyProduct(product: self.iapProducts[0])
                            
                            if self.nonConsumablePurchaseMade {
                                
                                self.userAddedPlaceDictionaryArray.append(userAddedPlaceDictionary)
                                
                                UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                                
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.activityLabel.removeFromSuperview()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    
                                }
                                
                                let alert = UIAlertController(title: NSLocalizedString("Place Saved", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Restore Purchases", comment: ""), style: .default, handler: { (action) in
                            
                            DispatchQueue.main.async {
                                
                                self.addActivityIndicatorCenter()
                                self.activityLabel.text = NSLocalizedString("Restoring", comment: "")
                                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                                
                            }
                            
                            SKPaymentQueue.default().add(self)
                            SKPaymentQueue.default().restoreCompletedTransactions()
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        self.userAddedPlaceDictionaryArray.append(userAddedPlaceDictionary)
                        
                        UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                        
                        let alert = UIAlertController(title: NSLocalizedString("Place Saved", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    self.userAddedPlaceDictionaryArray = [userAddedPlaceDictionary]
                    
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    
                    let alert = UIAlertController(title: NSLocalizedString("Place Saved", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
            } else {
                
                DispatchQueue.main.async {
                    self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("You've already saved this place.", comment: ""))
                }
            }
            
        }
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.blurEffectViewActivity.removeFromSuperview()
            self.activityLabel.removeFromSuperview()
        }
        
        self.selectedPlaceCoordinates = nil
        self.selectedPlaceLongitude = nil
        self.selectedPlaceLatitude = nil
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLatitude")
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLongitude")
        
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
        print("didLongPressAt coordinate")
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        if self.biasmarker != nil {
            
            self.biasmarker.map = nil
        }
        
        if self.placeMarkerArray.count > 0 {
            
            for marker in self.placeMarkerArray {
                
                marker.map = nil
                
            }
            
        }
        
        self.placeMarkerArray = []
        
        let position = CLLocationCoordinate2DMake(latitude, longitude)
        googleMapsView.animate(toLocation: position)
        biasmarker = GMSMarker(position: position)
        biasmarker.map = self.googleMapsView
        biasmarker.appearAnimation = GMSMarkerAnimation.pop
        biasmarker.icon = UIImage(named: "placesMarker copy.png")
        placeDictionaries.removeAll()
        UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
        googleMapsView.selectedMarker = nil
        UserDefaults.standard.removeObject(forKey: "streetNumber")
        UserDefaults.standard.removeObject(forKey: "neighborhood")
        UserDefaults.standard.removeObject(forKey: "route")
        
        getAddressForLatLng(latitude: String(latitude), longitude: String(longitude))
        
        self.userLongpressedCoordinates = CLLocationCoordinate2DMake(latitude, longitude)
        /*
        if self.userLongpressedCoordinates.latitude != 0 || self.userLongpressedCoordinates.longitude != 0 {
            
            self.button.frame = CGRect(x: 30, y: 30, width: 60, height: 60)
            self.button.backgroundColor = UIColor.red
            self.button.setTitle("X", for: .normal)
            self.button.layer.cornerRadius = 5
            self.button.addTarget(self, action: #selector(NearMeViewController.deleteBiasMarker(sender:)), for: .touchUpInside)
            self.googleMapsView.addSubview(button)
            
        }
        */
        self.placeAddInput.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeAddInput.center = view.center
        self.placeAddInput.addPlace.addTarget(self, action: #selector(NearMeViewController.add), for: .touchUpInside)
        self.placeAddInput.cancel.addTarget(self, action: #selector(NearMeViewController.cancelAddPlace), for: .touchUpInside)
        self.placeAddInput.alpha = 0
        self.blurEffectView.alpha = 0
        
        self.blurEffectView.frame = self.view.bounds
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffectView.alpha = 1
            
            self.view.addSubview(self.blurEffectView)
            
        }) { _ in
            
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.placeAddInput.alpha = 1
            self.view.addSubview(self.placeAddInput)
            
            
        }) { _ in
            
        }
        
        if UserDefaults.standard.object(forKey: "streetNumber") != nil {
            
            placeAddInput.placeAddress.text = (UserDefaults.standard.object(forKey: "streetNumber") as! String)
            
        } else if UserDefaults.standard.object(forKey: "neighborhood") != nil {
            
            placeAddInput.placeAddress.text = (UserDefaults.standard.object(forKey: "neighborhood") as! String)
            
        } else if UserDefaults.standard.object(forKey: "route") != nil {
            
            placeAddInput.placeAddress.text = (UserDefaults.standard.object(forKey: "route") as! String)
            
        }
        
    }
    
    func deleteBiasMarker(sender: UIButton!) {
        
        self.biasmarker.map = nil
        self.googleMapsView.selectedMarker = nil
        self.button.removeFromSuperview()
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        placeAddInput.phoneNumber.resignFirstResponder()
        placeAddInput.placeAddress.resignFirstResponder()
        placeAddInput.placeName.resignFirstResponder()
        placeAddInput.placeWebsite.resignFirstResponder()
        placeAddInput.typeOfPlace.resignFirstResponder()
        placeAddInput.placeAddress.resignFirstResponder()
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        self.placeAddInput.endEditing(true)
        return false
    }
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.down:
                
                if self.panoView != nil {
                    
                    if ( self.panoView.superview === self.view ) {
                        
                        self.panoView.removeFromSuperview()
                        
                    }
                    
                }
                
                if self.placeInfoWindow.isHidden == false {
                    
                }
                
               print("swiped down")
                
            default:
                break
                
            }
            
        }
        
    }
    
    func getAddressForLatLng(latitude: String, longitude: String) {
        
        print("getAddressForLatLng")
        
        self.country = ""
        self.city = ""
        self.state = ""
        
        let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
        let url = NSURL(string: "\(baseUrl)latlng=\(latitude),\(longitude)&key=AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw")
        let data = NSData(contentsOf: url! as URL)
        let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        
        if let results = json["results"] as? NSArray {
            
            if results.count > 0 {
                
                for result in results {
                    
                    if let types = ((((result as! NSDictionary)["address_components"]) as? NSArray)?[0] as? NSDictionary)?["types"] as? NSArray {
                        
                        if types.count > 0 {
                            
                            if let addressTypeDescriptor = types[0] as? String {
                                
                                if addressTypeDescriptor == "country" {
                                    
                                    if let countryCheck = ((result as! NSDictionary)["formatted_address"]) as? String {
                                        
                                        self.country = countryCheck
                                    }
                                    
                                } else if addressTypeDescriptor == "route" {
                                    
                                    if let routeCheck = ((result as! NSDictionary)["formatted_address"]) as? String {
                                        
                                        UserDefaults.standard.set(routeCheck, forKey: "route")
                                        self.address = routeCheck
                                    }
                                    
                                } else if addressTypeDescriptor == "neighborhood"{
                                    
                                    if let neighborhoodCheck = ((result as! NSDictionary)["formatted_address"]) as? String {
                                        
                                        self.address = neighborhoodCheck
                                        
                                        UserDefaults.standard.set(neighborhoodCheck, forKey: "neighborhood")
                                        
                                    }
                                    
                                } else if addressTypeDescriptor == "street_number" {
                                    
                                    if let streetNumberCheck = ((result as! NSDictionary)["formatted_address"]) as? String {
                                        
                                        UserDefaults.standard.set(streetNumberCheck, forKey: "streetNumber")
                                        
                                        self.address = streetNumberCheck
                                    }
                                    
                                } else if addressTypeDescriptor == "locality" {
                                    
                                    if let localityCheck = ((result as! NSDictionary)["formatted_address"]) as? String {
                                        
                                        if let localityArray = localityCheck.components(separatedBy: ", ") as? [String] {
                                            
                                            if localityArray.isEmpty == false {
                                                
                                                self.city = localityArray[0]
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                } else if addressTypeDescriptor == "administrative_area_level_1" {
                                    
                                    if let administrative_area_level_1Check = ((result as! NSDictionary)["formatted_address"]) as? String {
                                        
                                        //state
                                        self.state = administrative_area_level_1Check
                                        
                                        
                                        if let stateArray = administrative_area_level_1Check.components(separatedBy: ", ") as? [String] {
                                            
                                            if stateArray.isEmpty == false {
                                                
                                                self.state = stateArray[0]
                                                
                                                
                                            }
                                        }
                                    }
                                }
                                
                            } else {
                                
                                print("Unable to parse addressTypeDescriptor")
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        userTappedRoute = false
        
        if infoWindowIsVisible == false {
            
            if buttonsVisible == true {
                
                self.removeButtons()
                
            } else if buttonsVisible == false {
                
                DispatchQueue.main.async {
                    
                    self.addButtons()
                    
                }
                
            }
        }
        
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
            
        }) { (true) in
            
            
        }
    }
    
    func addActivityIndicatorPhotos() {
        
        activityLabel.frame = CGRect(x: self.view.center.x, y: self.view.frame.maxY - 191, width: 150, height: 20)
        activityLabel.center.x = self.view.center.x
        activityLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        activityLabel.textColor = UIColor.white
        activityLabel.textAlignment = .center
        activityLabel.alpha = 0
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: (self.view.frame.maxY - 241), width: 50, height: 50))
        activityIndicator.center.x = self.view.center.x
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.isUserInteractionEnabled = true
        activityIndicator.startAnimating()
        activityIndicator.alpha = 0
        blurEffectViewActivity.frame = CGRect(x: self.view.center.x, y: self.view.frame.maxY - 250, width: 150, height: 90)
        blurEffectViewActivity.center.x = self.view.center.x
        blurEffectViewActivity.alpha = 0
        blurEffectViewActivity.layer.cornerRadius = 20
        blurEffectViewActivity.clipsToBounds = true
        view.addSubview(self.blurEffectViewActivity)
        view.addSubview(self.activityLabel)
        view.addSubview(activityIndicator)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blurEffectViewActivity.alpha = 1
            self.activityIndicator.alpha = 1
            self.activityLabel.alpha = 1
            
        }) { (true) in
            
            
        }
    }
    
    func parseFlightID(dictionary: Dictionary<String,String>, index: Int) {
        
        print("parseFlightID")
        self.activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + "\(self.flightId!)" + "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.blurEffectViewActivity.removeFromSuperview()
                        self.activityLabel.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                            //self.showFlightInfoWindows(flightIndex: self.flightIndex)
                            //self.infoWindowIsVisible = true
                            
                        }))
                        
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
                                    
                                    if self.flightStatusUnformatted! == "S" {
                                        
                                        self.flightStatusFormatted = "Scheduled"
                                        
                                    } else if self.flightStatusUnformatted! == "A" {
                                        
                                        self.flightStatusFormatted = "Departed"
                                        
                                    } else if self.flightStatusUnformatted! == "D" {
                                        
                                        self.flightStatusFormatted = "Diverted"
                                        
                                    } else if self.flightStatusUnformatted! == "DN" {
                                        
                                        self.flightStatusFormatted = "Data Source Needed"
                                        
                                    } else if self.flightStatusUnformatted! == "L" {
                                        
                                        self.flightStatusFormatted = "Landed"
                                        
                                    } else if self.flightStatusUnformatted! == "NO" {
                                        
                                        self.flightStatusFormatted = "Not Operational"
                                        
                                    } else if self.flightStatusUnformatted! == "R" {
                                        
                                        self.flightStatusFormatted = "Redirected"
                                        
                                    } else if self.flightStatusUnformatted! == "U" {
                                        
                                        self.flightStatusFormatted = "Unknown"
                                        
                                    } else if self.flightStatusUnformatted! == "C" {
                                        
                                        self.flightStatusFormatted = "Cancelled"
                                        
                                        DispatchQueue.main.async {
                                            
                                            let alert = UIAlertController(title: NSLocalizedString("Flight has been Cancelled!", comment: ""), message: NSLocalizedString("Contact your airline to get replacement flight number.", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                
                                                //self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                                //self.infoWindowIsVisible = true
                                                
                                            }))
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                        
                                    } else {
                                        
                                        print("Error formatting flight status")
                                        
                                    }
                                    
                                    //unambiguos data
                                    var baggageClaim = "-"
                                    var irregularOperationsMessage1:String = ""
                                    var irregularOperationsMessage2:String = ""
                                    var irregularOperationsType1:String = ""
                                    var irregularOperationsType2:String = ""
                                    var updatedFlightEquipment:String! = ""
                                    var confirmedIncidentDate:String! = ""
                                    var confirmedIncidentTime:String! = ""
                                    var confirmedIncidentMessage:String! = ""
                                    var flightDurationScheduled:String! = ""
                                    var replacementFlightId:Double! = 0
                                    var primaryCarrier:String = ""
                                    
                                    if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                        
                                        baggageClaim = baggageCheck
                                    }
                                    
                                    if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                        
                                        primaryCarrier = primaryCarrierCheck
                                    }
                                    
                                    if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: scheduledFlightEquipment)
                                        
                                    }
                                    
                                    if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                        
                                        updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: actualFlightEquipment)
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
                                        
                                        confirmedIncidentDate = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["confirmedIncident"] as? NSDictionary)?["publishedDate"] as? String
                                        
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
                                    var publishedDeparture:String! = ""
                                    var publishedDepartureWhole:String! = ""
                                    var convertedPublishedDeparture:String! = ""
                                    var actualGateDeparture:String! = ""
                                    var actualGateDepartureUtc:String! = ""
                                    var actualGateDepartureWhole:String! = ""
                                    var convertedActualGateDeparture:String! = ""
                                    var scheduledGateDeparture:String! = ""
                                    var scheduledGateDepartureDateTimeWhole:String! = ""
                                    var convertedScheduledGateDeparture:String! = ""
                                    var estimatedGateDeparture:String! = ""
                                    var estimatedGateDepartureWholeNumber:String! = ""
                                    var convertedEstimatedGateDeparture:String! = ""
                                    var actualRunwayDepartureWhole:String! = ""
                                    var convertedActualRunwayDeparture:String! = ""
                                    var actualRunwayDepartureUtc:String! = ""
                                    var actualRunwayDeparture:String! = ""
                                    var scheduledRunwayDepartureWhole:String! = ""
                                    var convertedScheduledRunwayDeparture:String! = ""
                                    var scheduledRunwayDepartureUtc:String! = ""
                                    var scheduledRunwayDeparture:String! = ""
                                    var estimatedRunwayDeparture:String! = ""
                                    var estimatedRunwayDepartureWholeNumber:String! = ""
                                    var convertedEstimatedRunwayDeparture:String! = ""
                                    
                                    if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayDeparture = estimatedRunwayDepartureCheck
                                        estimatedRunwayDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedRunwayDepartureCheck)
                                        convertedEstimatedRunwayDeparture = self.convertDateTime(date: estimatedRunwayDepartureCheck)
                                    }
                                    
                                    if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledRunwayDeparture = scheduledRunwayDepartureCheck
                                        convertedScheduledRunwayDeparture = self.convertDateTime(date: scheduledRunwayDeparture)
                                        scheduledRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: scheduledRunwayDeparture)
                                        scheduledRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayDeparture = actualRunwayDepartureCheck
                                        convertedActualRunwayDeparture = self.convertDateTime(date: actualRunwayDepartureCheck)
                                        actualRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: actualRunwayDepartureCheck)
                                        actualRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let publishedDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedDeparture = publishedDepartureCheck
                                        convertedPublishedDeparture = self.convertDateTime(date: publishedDepartureCheck)
                                        publishedDepartureWhole = self.formatDateTimetoWhole(dateTime: publishedDepartureCheck)
                                        
                                    }
                                    
                                    if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateDeparture = scheduledGateDepartureCheck
                                        scheduledGateDepartureDateTimeWhole = self.formatDateTimetoWhole(dateTime: scheduledGateDepartureCheck)
                                        convertedScheduledGateDeparture = self.convertDateTime(date: scheduledGateDepartureCheck)
                                        
                                    }
                                    
                                    if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateDeparture = estimatedGateDepartureCheck
                                        estimatedGateDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateDepartureCheck)
                                        convertedEstimatedGateDeparture = self.convertDateTime(date: estimatedGateDepartureCheck)
                                    }
                                    
                                    if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateDeparture = actualGateDepartureCheck
                                        convertedActualGateDeparture = self.convertDateTime(date: actualGateDepartureCheck)
                                        actualGateDepartureWhole = self.formatDateTimetoWhole(dateTime: actualGateDepartureCheck)
                                        actualGateDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    //arrival data
                                    var arrivalTerminal:String!
                                    var arrivalGate:String!
                                    
                                    //diverted airport data
                                    var divertedAirportArrivalCode:String!
                                    var divertedAirportArrivalCountryName:String!
                                    var divertedAirportArrivalLongitudeDouble:Double!
                                    var divertedAirportArrivalIata:String!
                                    var divertedAirportArrivalLatitudeDouble:Double!
                                    var divertedAirportArrivalCityCode:String!
                                    var divertedAirportArrivalName:String!
                                    var divertedAirportArrivalCity:String!
                                    var divertedAirportArrivalTimeZone:String!
                                    var divertedAirportArrivalUtcOffsetHours:Double!
                                    
                                    if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                        
                                        divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String!
                                        divertedAirportArrivalCountryName = divertedAirportCheck["countryName"] as! String!
                                        divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double!
                                        divertedAirportArrivalIata = divertedAirportCheck["iata"] as! String!
                                        divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double!
                                        divertedAirportArrivalCityCode = divertedAirportCheck["cityCode"] as! String!
                                        divertedAirportArrivalName = divertedAirportCheck["name"] as! String!
                                        divertedAirportArrivalCity = divertedAirportCheck["city"] as! String!
                                        divertedAirportArrivalTimeZone = divertedAirportCheck["timeZoneRegionName"] as! String!
                                        divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double!
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.flights[index]["Arrival Airport Code"] = "\(divertedAirportArrivalCode!)"
                                            self.flights[index]["Airport Arrival Longitude"] = "\(divertedAirportArrivalLongitudeDouble!)"
                                            self.flights[index]["Airport Arrival Latitude"] = "\(divertedAirportArrivalLatitudeDouble!)"
                                            self.flights[index]["Airport Arrival FS"] = "\(divertedAirportArrivalCode!)"
                                            self.flights[index]["Arrival Country"] = "\(divertedAirportArrivalCountryName!)"
                                            self.flights[index]["Airport Arrival IATA"] = "\(divertedAirportArrivalIata!)"
                                            self.flights[index]["Airport Arrival City Code"] = "\(divertedAirportArrivalCityCode!)"
                                            self.flights[index]["Airport Arrival Name"] = "\(divertedAirportArrivalName!)"
                                            self.flights[index]["Arrival City"] = "\(divertedAirportArrivalCity!)"
                                            self.flights[index]["Airport Arrival Time Zone"] = "\(divertedAirportArrivalTimeZone!)"
                                            self.flights[index]["Arrival Airport UTC Offset"] = "\(divertedAirportArrivalUtcOffsetHours!)"
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
                                    var publishedArrival:String! = ""
                                    var convertedPublishedArrival:String! = ""
                                    var publishedArrivalWhole:String! = ""
                                    var scheduledGateArrivalUtc:String! = ""
                                    var scheduledGateArrivalWholeNumber:String! = ""
                                    var scheduledGateArrival:String! = ""
                                    var convertedScheduledGateArrival:String! = ""
                                    var scheduledRunwayArrivalWholeNumber:String! = ""
                                    var scheduledRunwayArrivalUtc:String! = ""
                                    var scheduledRunwayArrival:String! = ""
                                    var convertedScheduledRunwayArrival:String! = ""
                                    var estimatedGateArrivalUtc:String! = ""
                                    var estimatedGateArrivalWholeNumber:String! = ""
                                    var convertedEstimatedGateArrival:String! = ""
                                    var estimatedGateArrival:String! = ""
                                    var convertedActualGateArrival:String! = ""
                                    var actualGateArrivalWhole:String! = ""
                                    var actualGateArrival:String! = ""
                                    var convertedEstimatedRunwayArrival:String! = ""
                                    var estimatedRunwayArrivalUtc:String! = ""
                                    var estimatedRunwayArrivalWhole:String! = ""
                                    var estimatedRunwayArrival:String! = ""
                                    var convertedActualRunwayArrival:String! = ""
                                    var actualRunwayArrivalUtc:String! = ""
                                    var actualRunwayArrivalWhole:String! = ""
                                    var actualRunwayArrival:String! = ""
                                    
                                    if let scheduledRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledRunwayArrival = scheduledRunwayArrivalCheck
                                        scheduledRunwayArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: scheduledRunwayArrivalCheck)
                                        convertedScheduledRunwayArrival = self.convertDateTime(date: scheduledRunwayArrivalCheck)
                                        scheduledRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualRunwayArrival = actualRunwayArrivalCheck
                                        actualRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: actualRunwayArrivalCheck)
                                        convertedActualRunwayArrival = self.convertDateTime(date: actualRunwayArrivalCheck)
                                        actualRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let publishedArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        publishedArrival = publishedArrivalCheck
                                        convertedPublishedArrival = self.convertDateTime(date: publishedArrival!)
                                        publishedArrivalWhole = self.formatDateTimetoWhole(dateTime: publishedArrival!)
                                        
                                    }
                                    
                                    if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedRunwayArrival = estimatedRunwayArrivalCheck
                                        estimatedRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: estimatedRunwayArrivalCheck)
                                        convertedEstimatedRunwayArrival = self.convertDateTime(date: estimatedRunwayArrivalCheck)
                                        estimatedRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        scheduledGateArrival = scheduledGateArrivalCheck
                                        scheduledGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: scheduledGateArrivalCheck)
                                        convertedScheduledGateArrival = self.convertDateTime(date: scheduledGateArrivalCheck)
                                        scheduledGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        
                                    }
                                    
                                    if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        estimatedGateArrival = estimatedGateArrivalCheck
                                        estimatedGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateArrivalCheck)
                                        convertedEstimatedGateArrival = self.convertDateTime(date: estimatedGateArrivalCheck)
                                        estimatedGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                    }
                                    
                                    if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                        
                                        actualGateArrival = actualGateArrivalCheck
                                        convertedActualGateArrival = self.convertDateTime(date: actualGateArrivalCheck)
                                        actualGateArrivalWhole = self.formatDateTimetoWhole(dateTime: actualGateArrivalCheck)
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        //unambiguos data
                                        self.flights[index]["Flight Status"] = "\(NSLocalizedString(self.flightStatusFormatted!, comment: ""))"
                                        self.flights[index]["Flight Duration Scheduled"] = "\(flightDurationScheduled!)"
                                        self.flights[index]["Baggage Claim"] = "\(baggageClaim)"
                                        self.flights[index]["Primary Carrier"] = "\(primaryCarrier)"
                                        self.flights[index]["Irregular Operation Message 1"] = "\(irregularOperationsMessage1)"
                                        self.flights[index]["Irregular Operation Message 2"] = "\(irregularOperationsMessage2)"
                                        self.flights[index]["Irregular Operation Type 1"] = "\(irregularOperationsType1)"
                                        self.flights[index]["Irregular Operation Type 2"] = "\(irregularOperationsType2)"
                                        self.flights[index]["Confirmed Incident Message"] = "\(confirmedIncidentMessage!)"
                                        self.flights[index]["Updated Flight Equipment"] = "\(updatedFlightEquipment!)"
                                        
                                        //departure data
                                        self.flights[index]["Airport Departure Terminal"] = "\(departureTerminal!)"
                                        self.flights[index]["Departure Gate"] = "\(departureGate!)"
                                        
                                        //departure timings
                                        self.flights[index]["Converted Actual Runway Departure"] = "\(convertedActualRunwayDeparture!)"
                                        self.flights[index]["Actual Runway Departure Whole"] = "\(actualRunwayDepartureWhole!)"
                                        self.flights[index]["Actual Runway Departure UTC"] = "\(actualRunwayDepartureUtc!)"
                                        self.flights[index]["Actual Runway Departure"] = "\(actualRunwayDeparture!)"
                                        
                                        self.flights[index]["Scheduled Runway Departure Whole Number"] = "\(scheduledRunwayDepartureWhole!)"
                                        self.flights[index]["Converted Scheduled Runway Departure"] = "\(convertedScheduledRunwayDeparture!)"
                                        self.flights[index]["Scheduled Runway Departure"] = "\(scheduledRunwayDeparture!)"
                                        self.flights[index]["Scheduled Runway Departure UTC"] = "\(scheduledRunwayDepartureUtc!)"
                                        
                                        self.flights[index]["Converted Estimated Runway Departure"] = "\(convertedEstimatedRunwayDeparture!)"
                                        self.flights[index]["Estimated Runway Departure Whole Number"] = "\(estimatedRunwayDepartureWholeNumber!)"
                                        self.flights[index]["Estimated Runway Departure"] = "\(estimatedRunwayDeparture!)"
                                        
                                        self.flights[index]["Scheduled Gate Departure Whole Number"] = "\(scheduledGateDepartureDateTimeWhole!)"
                                        self.flights[index]["Converted Scheduled Gate Departure"] = "\(convertedScheduledGateDeparture!)"
                                        self.flights[index]["Scheduled Gate Departure"] = "\(scheduledGateDeparture!)"
                                        
                                        self.flights[index]["Converted Published Departure"] = "\(convertedPublishedDeparture!)"
                                        self.flights[index]["Published Departure Whole"] = "\(publishedDepartureWhole!)"
                                        self.flights[index]["Published Departure"] = "\(publishedDeparture!)"
                                        
                                        self.flights[index]["Converted Estimated Gate Departure"] = "\(convertedEstimatedGateDeparture!)"
                                        self.flights[index]["Estimated Gate Departure Whole Number"] = "\(estimatedGateDepartureWholeNumber!)"
                                        self.flights[index]["Estimated Gate Departure"] = "\(estimatedGateDeparture!)"
                                        
                                        self.flights[index]["Converted Actual Gate Departure"] = "\(convertedActualGateDeparture!)"
                                        self.flights[index]["Actual Gate Departure Whole"] = "\(actualGateDepartureWhole!)"
                                        self.flights[index]["Actual Gate Departure UTC"] = "\(actualGateDepartureUtc!)"
                                        self.flights[index]["Actual Gate Departure"] = "\(actualGateDeparture!)"
                                        
                                        
                                        
                                        //arrival data
                                        self.flights[index]["Airport Arrival Terminal"] = "\(arrivalTerminal!)"
                                        self.flights[index]["Arrival Gate"] = "\(arrivalGate!)"
                                        
                                        //arrival timings
                                        self.flights[index]["Actual Runway Arrival Whole Number"] = "\(actualRunwayArrivalWhole!)"
                                        self.flights[index]["Converted Actual Runway Arrival"] = "\(convertedActualRunwayArrival!)"
                                        self.flights[index]["Actual Runway Arrival UTC"] = "\(actualRunwayArrivalUtc!)"
                                        self.flights[index]["Actual Runway Arrival"] = "\(actualRunwayArrival!)"
                                        
                                        self.flights[index]["Scheduled Runway Arrival Whole Number"] = "\(scheduledRunwayArrivalWholeNumber!)"
                                        self.flights[index]["Converted Scheduled Runway Arrival"] = "\(convertedScheduledRunwayArrival!)"
                                        self.flights[index]["Scheduled Runway Arrival UTC"] = "\(scheduledRunwayArrivalUtc!)"
                                        self.flights[index]["Scheduled Runway Arrival"] = "\(scheduledRunwayArrival!)"
                                        
                                        self.flights[index]["Estimated Runway Arrival Whole Number"] = "\(estimatedRunwayArrivalWhole!)"
                                        self.flights[index]["Converted Estimated Runway Arrival"] = "\(convertedEstimatedRunwayArrival!)"
                                        self.flights[index]["Estimated Runway Arrival UTC"] = "\(estimatedRunwayArrivalUtc!)"
                                        self.flights[index]["Estimated Runway Arrival"] = "\(estimatedRunwayArrival!)"
                                        
                                        self.flights[index]["Scheduled Gate Arrival Whole Number"] = "\(scheduledGateArrivalWholeNumber!)"
                                        self.flights[index]["Converted Scheduled Gate Arrival"] = "\(convertedScheduledGateArrival!)"
                                        self.flights[index]["Scheduled Gate Arrival UTC"] = "\(scheduledGateArrivalUtc!)"
                                        self.flights[index]["Scheduled Gate Arrival"] = "\(scheduledGateArrival!)"
                                        
                                        self.flights[index]["Converted Published Arrival"] = "\(convertedPublishedArrival!)"
                                        self.flights[index]["Published Arrival Whole"] = "\(publishedArrivalWhole!)"
                                        self.flights[index]["Published Arrival"] = "\(publishedArrival!)"
                                        
                                        self.flights[index]["Estimated Gate Arrival Whole Number"] = "\(estimatedGateArrivalWholeNumber!)"
                                        self.flights[index]["Converted Estimated Gate Arrival"] = "\(convertedEstimatedGateArrival!)"
                                        self.flights[index]["Estimated Gate Arrival UTC"] = "\(estimatedGateArrivalUtc!)"
                                        self.flights[index]["Estimated Gate Arrival"] = "\(estimatedGateArrival!)"
                                        
                                        self.flights[index]["Converted Actual Gate Arrival"] = "\(convertedActualGateArrival!)"
                                        self.flights[index]["Actual Gate Arrival Whole"] = "\(actualGateArrivalWhole!)"
                                        self.flights[index]["Actual Gate Arrival"] = "\(actualGateArrival!)"
                                        
                                        UserDefaults.standard.set(self.flights, forKey: "flights")
                                        
                                        self.getAirportCoordinates()
                                        
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
                                                
                                                let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n" + NSLocalizedString("Would you like to add the replacement flight automatically?", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                    
                                                    self.parseFlightID(dictionary: self.flights[index], index: index)
                                                    
                                                }))
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" {
                                                
                                                let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)" , preferredStyle: UIAlertControllerStyle.alert)
                                                
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
                                        
                                        //self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                        //self.infoWindowIsVisible = true
                                        
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
                                            
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                
                                                //self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                                //self.infoWindowIsVisible = true
                                                
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
    
    func parseLeg2Only(dictionary: Dictionary<String,String>, index: Int) {
        
        print("parseLeg2Only")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        addActivityIndicatorPhotos()
        self.activityLabel.text = NSLocalizedString("Updating Flight Info", comment: "")
        
        
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
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            self.blurEffectViewActivity.removeFromSuperview()
                            self.activityLabel.removeFromSuperview()
                            
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    } else {
                        
                        if let urlContent = data {
                            
                            do {
                                
                                let jsonFlightStatusData = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                
                                print("flightData = \(jsonFlightStatusData)")
                                
                                //check status
                                
                                if let flightStatusesArray = jsonFlightStatusData["flightStatuses"] as? NSArray {
                                    
                                    
                                    if flightStatusesArray.count == 0 {
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.activityIndicator.stopAnimating()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            self.activityLabel.removeFromSuperview()
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            //self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                            //self.infoWindowIsVisible = true
                                            
                                        }
                                        
                                    } else if flightStatusesArray.count > 0 {
                                        
                                        
                                        
                                        self.flightStatusUnformatted = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["status"] as? String
                                        
                                        if self.flightStatusUnformatted! == "S" {
                                            
                                            self.flightStatusFormatted = "Scheduled"
                                            
                                        } else if self.flightStatusUnformatted! == "A" {
                                            
                                            self.flightStatusFormatted = "Departed"
                                            
                                        } else if self.flightStatusUnformatted! == "D" {
                                            
                                            self.flightStatusFormatted = "Diverted"
                                            
                                        } else if self.flightStatusUnformatted! == "DN" {
                                            
                                            self.flightStatusFormatted = "Data Source Needed"
                                            
                                        } else if self.flightStatusUnformatted! == "L" {
                                            
                                            self.flightStatusFormatted = "Landed"
                                            
                                        } else if self.flightStatusUnformatted! == "NO" {
                                            
                                            self.flightStatusFormatted = "Not Operational"
                                            
                                        } else if self.flightStatusUnformatted! == "R" {
                                            
                                            self.flightStatusFormatted = "Redirected"
                                            
                                        } else if self.flightStatusUnformatted! == "U" {
                                            
                                            self.flightStatusFormatted = "Unknown"
                                            
                                        } else if self.flightStatusUnformatted! == "C" {
                                            
                                            self.flightStatusFormatted = "Cancelled"
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.activityIndicator.stopAnimating()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                self.activityLabel.removeFromSuperview()
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Flight has been Cancelled!", comment: ""), message: NSLocalizedString("Contact your airline to get replacement flight number.", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                    
                                                }))
                                                
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                            
                                        } else {
                                            
                                            print("Error formatting flight status")
                                            self.activityIndicator.stopAnimating()
                                            self.blurEffectViewActivity.removeFromSuperview()
                                            self.activityLabel.removeFromSuperview()
                                            
                                        }
                                        
                                        //unambiguos data
                                        var baggageClaim = "-"
                                        var irregularOperationsMessage1:String = ""
                                        var irregularOperationsMessage2:String = ""
                                        var irregularOperationsType1:String = ""
                                        var irregularOperationsType2:String = ""
                                        var updatedFlightEquipment:String! = ""
                                        var confirmedIncidentDate:String! = ""
                                        var confirmedIncidentTime:String! = ""
                                        var confirmedIncidentMessage:String! = ""
                                        var flightDurationScheduled:String! = ""
                                        var replacementFlightId:Double! = 0
                                        var primaryCarrier:String = ""
                                        var flightId:Int!
                                        
                                        if let baggageCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["airportResources"] as? NSDictionary)?["baggage"] as? String {
                                            
                                            baggageClaim = baggageCheck
                                        }
                                        
                                        if let primaryCarrierCheck = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["primaryCarrier"] as? NSDictionary)?["name"] as? String {
                                            
                                            primaryCarrier = primaryCarrierCheck
                                        }
                                        
                                        if let scheduledFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["scheduledEquipment"] as? NSDictionary)?["name"] as? String {
                                            
                                            updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: scheduledFlightEquipment)
                                            
                                        }
                                        
                                        if let actualFlightEquipment = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightEquipment"] as? NSDictionary)?["actualEquipment"] as? NSDictionary)?["name"] as? String {
                                            
                                            updatedFlightEquipment = self.formatFlightEquipment(flightEquipment: actualFlightEquipment)
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
                                            
                                            let confirmedIncidentDate = ((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["confirmedIncident"] as? NSDictionary)?["publishedDate"] as? String
                                            
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
                                        var publishedDeparture:String! = ""
                                        var publishedDepartureWhole:String! = ""
                                        var convertedPublishedDeparture:String! = ""
                                        
                                        var actualGateDeparture:String! = ""
                                        var actualGateDepartureUtc:String! = ""
                                        var actualGateDepartureWhole:String! = ""
                                        var convertedActualGateDeparture:String! = ""
                                        
                                        var scheduledGateDeparture:String! = ""
                                        var scheduledGateDepartureDateTimeWhole:String! = ""
                                        var convertedScheduledGateDeparture:String! = ""
                                        var scheduledGateDepartureUTC:String! = ""
                                        
                                        var estimatedGateDeparture:String! = ""
                                        var estimatedGateDepartureWholeNumber:String! = ""
                                        var convertedEstimatedGateDeparture:String! = ""
                                        var estimatedGateDepartureUTC:String! = ""
                                        
                                        var actualRunwayDepartureWhole:String! = ""
                                        var convertedActualRunwayDeparture:String! = ""
                                        var actualRunwayDepartureUtc:String! = ""
                                        var actualRunwayDeparture:String! = ""
                                        
                                        var scheduledRunwayDepartureWhole:String! = ""
                                        var convertedScheduledRunwayDeparture:String! = ""
                                        var scheduledRunwayDepartureUtc:String! = ""
                                        var scheduledRunwayDeparture:String! = ""
                                        
                                        var estimatedRunwayDeparture:String! = ""
                                        var estimatedRunwayDepartureWholeNumber:String! = ""
                                        var convertedEstimatedRunwayDeparture:String! = ""
                                        
                                        if let estimatedRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedRunwayDeparture = estimatedRunwayDepartureCheck
                                            estimatedRunwayDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedRunwayDepartureCheck)
                                            convertedEstimatedRunwayDeparture = self.convertDateTime(date: estimatedRunwayDepartureCheck)
                                        }
                                        
                                        if let scheduledRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledRunwayDeparture = scheduledRunwayDepartureCheck
                                            convertedScheduledRunwayDeparture = self.convertDateTime(date: scheduledRunwayDeparture)
                                            scheduledRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: scheduledRunwayDeparture)
                                            scheduledRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                        }
                                        
                                        if let actualRunwayDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualRunwayDeparture = actualRunwayDepartureCheck
                                            convertedActualRunwayDeparture = self.convertDateTime(date: actualRunwayDepartureCheck)
                                            actualRunwayDepartureWhole = self.formatDateTimetoWhole(dateTime: actualRunwayDepartureCheck)
                                            actualRunwayDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                        }
                                        
                                        if let publishedDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            publishedDeparture = publishedDepartureCheck
                                            convertedPublishedDeparture = self.convertDateTime(date: publishedDepartureCheck)
                                            publishedDepartureWhole = self.formatDateTimetoWhole(dateTime: publishedDepartureCheck)
                                            
                                        }
                                        
                                        if let scheduledGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledGateDeparture = scheduledGateDepartureCheck
                                            scheduledGateDepartureDateTimeWhole = self.formatDateTimetoWhole(dateTime: scheduledGateDepartureCheck)
                                            convertedScheduledGateDeparture = self.convertDateTime(date: scheduledGateDepartureCheck)
                                            scheduledGateDepartureUTC = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                            
                                        }
                                        
                                        if let estimatedGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedGateDeparture = estimatedGateDepartureCheck
                                            estimatedGateDepartureWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateDepartureCheck)
                                            convertedEstimatedGateDeparture = self.convertDateTime(date: estimatedGateDepartureCheck)
                                            estimatedGateDepartureUTC = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                        }
                                        
                                        if let actualGateDepartureCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualGateDeparture = actualGateDepartureCheck
                                            convertedActualGateDeparture = self.convertDateTime(date: actualGateDepartureCheck)
                                            actualGateDepartureWhole = self.formatDateTimetoWhole(dateTime: actualGateDepartureCheck)
                                            actualGateDepartureUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateDeparture"] as? NSDictionary)?["dateUtc"] as? String
                                            
                                        }
                                        
                                        //arrival data
                                        var arrivalTerminal:String!
                                        var arrivalGate:String!
                                        
                                        //diverted airport data
                                        var divertedAirportArrivalCode:String!
                                        var divertedAirportArrivalCountryName:String!
                                        var divertedAirportArrivalLongitudeDouble:Double!
                                        var divertedAirportArrivalIata:String!
                                        var divertedAirportArrivalLatitudeDouble:Double!
                                        var divertedAirportArrivalCityCode:String!
                                        var divertedAirportArrivalName:String!
                                        var divertedAirportArrivalCity:String!
                                        var divertedAirportArrivalTimeZone:String!
                                        var divertedAirportArrivalUtcOffsetHours:Double!
                                        
                                        if let divertedAirportCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["divertedAirport"] as? NSDictionary {
                                            
                                            divertedAirportArrivalCode = divertedAirportCheck["fs"] as! String!
                                            divertedAirportArrivalCountryName = divertedAirportCheck["countryName"] as! String!
                                            divertedAirportArrivalLongitudeDouble = divertedAirportCheck["longitude"] as! Double!
                                            divertedAirportArrivalIata = divertedAirportCheck["iata"] as! String!
                                            divertedAirportArrivalLatitudeDouble = divertedAirportCheck["latitude"] as! Double!
                                            divertedAirportArrivalCityCode = divertedAirportCheck["cityCode"] as! String!
                                            divertedAirportArrivalName = divertedAirportCheck["name"] as! String!
                                            divertedAirportArrivalCity = divertedAirportCheck["city"] as! String!
                                            divertedAirportArrivalTimeZone = divertedAirportCheck["timeZoneRegionName"] as! String!
                                            divertedAirportArrivalUtcOffsetHours = divertedAirportCheck["utcOffsetHours"] as! Double!
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.flights[index]["Arrival Airport Code"] = "\(divertedAirportArrivalCode!)"
                                                self.flights[index]["Airport Arrival Longitude"] = "\(divertedAirportArrivalLongitudeDouble!)"
                                                self.flights[index]["Airport Arrival Latitude"] = "\(divertedAirportArrivalLatitudeDouble!)"
                                                self.flights[index]["Airport Arrival FS"] = "\(divertedAirportArrivalCode!)"
                                                self.flights[index]["Arrival Country"] = "\(divertedAirportArrivalCountryName!)"
                                                self.flights[index]["Airport Arrival IATA"] = "\(divertedAirportArrivalIata!)"
                                                self.flights[index]["Airport Arrival City Code"] = "\(divertedAirportArrivalCityCode!)"
                                                self.flights[index]["Airport Arrival Name"] = "\(divertedAirportArrivalName!)"
                                                self.flights[index]["Arrival City"] = "\(divertedAirportArrivalCity!)"
                                                self.flights[index]["Airport Arrival Time Zone"] = "\(divertedAirportArrivalTimeZone!)"
                                                self.flights[index]["Arrival Airport UTC Offset"] = "\(divertedAirportArrivalUtcOffsetHours!)"
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
                                        var publishedArrival:String! = ""
                                        var convertedPublishedArrival:String! = ""
                                        var publishedArrivalWhole:String! = ""
                                        var scheduledGateArrivalUtc:String! = ""
                                        var scheduledGateArrivalWholeNumber:String! = ""
                                        var scheduledGateArrival:String! = ""
                                        var convertedScheduledGateArrival:String! = ""
                                        var scheduledRunwayArrivalWholeNumber:String! = ""
                                        var scheduledRunwayArrivalUtc:String! = ""
                                        var scheduledRunwayArrival:String! = ""
                                        var convertedScheduledRunwayArrival:String! = ""
                                        var estimatedGateArrivalUtc:String! = ""
                                        var estimatedGateArrivalWholeNumber:String! = ""
                                        var convertedEstimatedGateArrival:String! = ""
                                        var estimatedGateArrival:String! = ""
                                        var convertedActualGateArrival:String! = ""
                                        var actualGateArrivalWhole:String! = ""
                                        var actualGateArrival:String! = ""
                                        var convertedEstimatedRunwayArrival:String! = ""
                                        var estimatedRunwayArrivalUtc:String! = ""
                                        var estimatedRunwayArrivalWhole:String! = ""
                                        var estimatedRunwayArrival:String! = ""
                                        var convertedActualRunwayArrival:String! = ""
                                        var actualRunwayArrivalUtc:String! = ""
                                        var actualRunwayArrivalWhole:String! = ""
                                        var actualRunwayArrival:String! = ""
                                        
                                        if let actualRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualRunwayArrival = actualRunwayArrivalCheck
                                            actualRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: actualRunwayArrivalCheck)
                                            convertedActualRunwayArrival = self.convertDateTime(date: actualRunwayArrivalCheck)
                                            actualRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                            
                                        }
                                        
                                        if let publishedArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["publishedArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            publishedArrival = publishedArrivalCheck
                                            convertedPublishedArrival = self.convertDateTime(date: publishedArrival!)
                                            publishedArrivalWhole = self.formatDateTimetoWhole(dateTime: publishedArrival!)
                                            
                                        }
                                        
                                        if let scheduledRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledRunwayArrival = scheduledRunwayArrivalCheck
                                            scheduledRunwayArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: scheduledRunwayArrivalCheck)
                                            convertedScheduledRunwayArrival = self.convertDateTime(date: scheduledRunwayArrivalCheck)
                                            scheduledRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                            
                                        }
                                        
                                        if let estimatedRunwayArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedRunwayArrival = estimatedRunwayArrivalCheck
                                            estimatedRunwayArrivalWhole = self.formatDateTimetoWhole(dateTime: estimatedRunwayArrivalCheck)
                                            convertedEstimatedRunwayArrival = self.convertDateTime(date: estimatedRunwayArrivalCheck)
                                            estimatedRunwayArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedRunwayArrival"] as? NSDictionary)?["dateUtc"] as? String
                                            
                                        }
                                        
                                        if let scheduledGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            scheduledGateArrival = scheduledGateArrivalCheck
                                            scheduledGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: scheduledGateArrivalCheck)
                                            convertedScheduledGateArrival = self.convertDateTime(date: scheduledGateArrivalCheck)
                                            scheduledGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["scheduledGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                            
                                        }
                                        
                                        if let estimatedGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            estimatedGateArrival = estimatedGateArrivalCheck
                                            estimatedGateArrivalWholeNumber = self.formatDateTimetoWhole(dateTime: estimatedGateArrivalCheck)
                                            convertedEstimatedGateArrival = self.convertDateTime(date: estimatedGateArrivalCheck)
                                            estimatedGateArrivalUtc = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["estimatedGateArrival"] as? NSDictionary)?["dateUtc"] as? String
                                        }
                                        
                                        if let actualGateArrivalCheck = (((((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["operationalTimes"] as? NSDictionary)?["actualGateArrival"] as? NSDictionary)?["dateLocal"] as? String {
                                            
                                            actualGateArrival = actualGateArrivalCheck
                                            convertedActualGateArrival = self.convertDateTime(date: actualGateArrivalCheck)
                                            actualGateArrivalWhole = self.formatDateTimetoWhole(dateTime: actualGateArrivalCheck)
                                            
                                        }
                                        
                                        DispatchQueue.main.async {
                                            
                                            //unambiguos data
                                            self.flights[index]["Flight Status"] = "\((NSLocalizedString(self.flightStatusFormatted!, comment: "")))"
                                            self.flights[index]["Flight Duration Scheduled"] = "\(flightDurationScheduled!)"
                                            self.flights[index]["Baggage Claim"] = "\(baggageClaim)"
                                            self.flights[index]["Primary Carrier"] = "\(primaryCarrier)"
                                            self.flights[index]["Irregular Operation Message 1"] = "\(irregularOperationsMessage1)"
                                            self.flights[index]["Irregular Operation Message 2"] = "\(irregularOperationsMessage2)"
                                            self.flights[index]["Irregular Operation Type 1"] = "\(irregularOperationsType1)"
                                            self.flights[index]["Irregular Operation Type 2"] = "\(irregularOperationsType2)"
                                            self.flights[index]["Confirmed Incident Message"] = "\(confirmedIncidentMessage!)"
                                            self.flights[index]["Updated Flight Equipment"] = "\(updatedFlightEquipment!)"
                                            
                                            //departure data
                                            self.flights[index]["Airport Departure Terminal"] = "\(departureTerminal!)"
                                            self.flights[index]["Departure Gate"] = "\(departureGate!)"
                                            
                                            //departure timings
                                            self.flights[index]["Converted Actual Runway Departure"] = "\(convertedActualRunwayDeparture!)"
                                            self.flights[index]["Actual Runway Departure Whole"] = "\(actualRunwayDepartureWhole!)"
                                            self.flights[index]["Actual Runway Departure UTC"] = "\(actualRunwayDepartureUtc!)"
                                            self.flights[index]["Actual Runway Departure"] = "\(actualRunwayDeparture!)"
                                            self.flights[index]["Scheduled Runway Departure Whole Number"] = "\(scheduledRunwayDepartureWhole!)"
                                            self.flights[index]["Converted Scheduled Runway Departure"] = "\(convertedScheduledRunwayDeparture!)"
                                            self.flights[index]["Scheduled Runway Departure"] = "\(scheduledRunwayDeparture!)"
                                            self.flights[index]["Scheduled Runway Departure UTC"] = "\(scheduledRunwayDepartureUtc!)"
                                            self.flights[index]["Converted Estimated Runway Departure"] = "\(convertedEstimatedRunwayDeparture!)"
                                            self.flights[index]["Estimated Runway Departure Whole Number"] = "\(estimatedRunwayDepartureWholeNumber!)"
                                            self.flights[index]["Estimated Runway Departure"] = "\(estimatedRunwayDeparture!)"
                                            self.flights[index]["Scheduled Gate Departure Whole Number"] = "\(scheduledGateDepartureDateTimeWhole!)"
                                            self.flights[index]["Converted Scheduled Gate Departure"] = "\(convertedScheduledGateDeparture!)"
                                            self.flights[index]["Scheduled Gate Departure"] = "\(scheduledGateDeparture!)"
                                            self.flights[index]["Scheduled Gate Departure UTC"] = "\(scheduledGateDepartureUTC!)"
                                            self.flights[index]["Converted Published Departure"] = "\(convertedPublishedDeparture!)"
                                            self.flights[index]["Published Departure Whole"] = "\(publishedDepartureWhole!)"
                                            self.flights[index]["Published Departure"] = "\(publishedDeparture!)"
                                            self.flights[index]["Converted Estimated Gate Departure"] = "\(convertedEstimatedGateDeparture!)"
                                            self.flights[index]["Estimated Gate Departure Whole Number"] = "\(estimatedGateDepartureWholeNumber!)"
                                            self.flights[index]["Estimated Gate Departure"] = "\(estimatedGateDeparture!)"
                                            self.flights[index]["Estimated Gate Departure UTC"] = "\(estimatedGateDepartureUTC!)"
                                            self.flights[index]["Converted Actual Gate Departure"] = "\(convertedActualGateDeparture!)"
                                            self.flights[index]["Actual Gate Departure Whole"] = "\(actualGateDepartureWhole!)"
                                            self.flights[index]["Actual Gate Departure UTC"] = "\(actualGateDepartureUtc!)"
                                            self.flights[index]["Actual Gate Departure"] = "\(actualGateDeparture!)"
                                            
                                            
                                            //arrival data
                                            self.flights[index]["Airport Arrival Terminal"] = "\(arrivalTerminal!)"
                                            self.flights[index]["Arrival Gate"] = "\(arrivalGate!)"
                                            
                                            //arrival timings
                                            self.flights[index]["Scheduled Runway Arrival Whole Number"] = "\(scheduledRunwayArrivalWholeNumber!)"
                                            self.flights[index]["Converted Scheduled Runway Arrival"] = "\(convertedScheduledRunwayArrival!)"
                                            self.flights[index]["Scheduled Runway Arrival UTC"] = "\(scheduledRunwayArrivalUtc!)"
                                            self.flights[index]["Scheduled Runway Arrival"] = "\(scheduledRunwayArrival!)"
                                            self.flights[index]["Actual Runway Arrival Whole Number"] = "\(actualRunwayArrivalWhole!)"
                                            self.flights[index]["Converted Actual Runway Arrival"] = "\(convertedActualRunwayArrival!)"
                                            self.flights[index]["Actual Runway Arrival UTC"] = "\(actualRunwayArrivalUtc!)"
                                            self.flights[index]["Actual Runway Arrival"] = "\(actualRunwayArrival!)"
                                            self.flights[index]["Estimated Runway Arrival Whole Number"] = "\(estimatedRunwayArrivalWhole!)"
                                            self.flights[index]["Converted Estimated Runway Arrival"] = "\(convertedEstimatedRunwayArrival!)"
                                            self.flights[index]["Estimated Runway Arrival UTC"] = "\(estimatedRunwayArrivalUtc!)"
                                            self.flights[index]["Estimated Runway Arrival"] = "\(estimatedRunwayArrival!)"
                                            self.flights[index]["Scheduled Gate Arrival Whole Number"] = "\(scheduledGateArrivalWholeNumber!)"
                                            self.flights[index]["Converted Scheduled Gate Arrival"] = "\(convertedScheduledGateArrival!)"
                                            self.flights[index]["Scheduled Gate Arrival UTC"] = "\(scheduledGateArrivalUtc!)"
                                            self.flights[index]["Scheduled Gate Arrival"] = "\(scheduledGateArrival!)"
                                            self.flights[index]["Converted Published Arrival"] = "\(convertedPublishedArrival!)"
                                            self.flights[index]["Published Arrival Whole"] = "\(publishedArrivalWhole!)"
                                            self.flights[index]["Published Arrival"] = "\(publishedArrival!)"
                                            self.flights[index]["Estimated Gate Arrival Whole Number"] = "\(estimatedGateArrivalWholeNumber!)"
                                            self.flights[index]["Converted Estimated Gate Arrival"] = "\(convertedEstimatedGateArrival!)"
                                            self.flights[index]["Estimated Gate Arrival UTC"] = "\(estimatedGateArrivalUtc!)"
                                            self.flights[index]["Estimated Gate Arrival"] = "\(estimatedGateArrival!)"
                                            self.flights[index]["Converted Actual Gate Arrival"] = "\(convertedActualGateArrival!)"
                                            self.flights[index]["Actual Gate Arrival Whole"] = "\(actualGateArrivalWhole!)"
                                            self.flights[index]["Actual Gate Arrival"] = "\(actualGateArrival!)"
                                            
                                            DispatchQueue.main.async {
                                                self.activityIndicator.stopAnimating()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                self.activityLabel.removeFromSuperview()
                                            }
                                            
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            UserDefaults.standard.set(self.flights, forKey: "flights")
                                            //self.getAirportCoordinates()
                                            /*
                                            if self.tappedCoordinates != nil {
                                                
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
                                                
                                            }
                                            */
                                            
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.activityIndicator.stopAnimating()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                self.activityLabel.removeFromSuperview()
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                                if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && self.flightId != 0 {
                                                    
                                                    DispatchQueue.main.async {
                                                        self.activityIndicator.stopAnimating()
                                                        self.blurEffectViewActivity.removeFromSuperview()
                                                        self.activityLabel.removeFromSuperview()
                                                    }
                                                    
                                                    let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n" + NSLocalizedString("Would you like to add the replacement flight automatically?", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                        
                                                        self.parseFlightID(dictionary: self.flights[index], index: index)
                                                        
                                                    }))
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" {
                                                    
                                                    DispatchQueue.main.async {
                                                        self.activityIndicator.stopAnimating()
                                                        self.blurEffectViewActivity.removeFromSuperview()
                                                        self.activityLabel.removeFromSuperview()
                                                    }
                                                    
                                                    let alert = UIAlertController(title: "\(confirmedIncidentMessage)", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)" , preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                } else if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" {
                                                    
                                                    DispatchQueue.main.async {
                                                        self.activityIndicator.stopAnimating()
                                                        self.blurEffectViewActivity.removeFromSuperview()
                                                        self.activityLabel.removeFromSuperview()
                                                    }
                                                    
                                                    let alert = UIAlertController(title: NSLocalizedString("Irregular operation!", comment: ""), message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)", preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                } else if irregularOperationsMessage1 != "" {
                                                    
                                                    DispatchQueue.main.async {
                                                        self.activityIndicator.stopAnimating()
                                                        self.blurEffectViewActivity.removeFromSuperview()
                                                        self.activityLabel.removeFromSuperview()
                                                    }
                                                    
                                                    let alert = UIAlertController(title: "\(irregularOperationsType1)", message: "\n\(irregularOperationsMessage1)", preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                } else if irregularOperationsType1 != "" {
                                                    
                                                    DispatchQueue.main.async {
                                                        self.activityIndicator.stopAnimating()
                                                        self.blurEffectViewActivity.removeFromSuperview()
                                                        self.activityLabel.removeFromSuperview()
                                                    }
                                                    
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
                                                    
                                                    delegate?.schedule48HrNotification(estimatedDeparture: estimatedGateDeparture!, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["4 Hour Notification"] == "true" {
                                                
                                                delegate?.schedule4HrNotification(estimatedDeparture: estimatedGateDeparture!, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["2 Hour Notification"] == "true" {
                                                
                                                delegate?.schedule2HrNotification(estimatedDeparture: estimatedGateDeparture!, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["1 Hour Notification"] == "true" {
                                                
                                                 delegate?.schedule1HourNotification(estimatedDeparture: estimatedGateDeparture!, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                if dictionary["Taking Off Notification"] == "true" {
                                                
                                                delegate?.scheduleTakeOffNotification(estimatedDeparture: estimatedGateDeparture!, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                }
                                                
                                                if dictionary["Landing Notification"] == "true" {
                                                
                                                delegate?.scheduleLandingNotification(estimatedArrival: estimatedGateArrival!, arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                    
                                                }
                                                
                                                print("scheduled notifications")
                                                
                                            }
                                            /*
                                            if self.timer != nil {
                                                
                                                self.timer.invalidate()
                                                self.timer = nil
                                                
                                            }
                                            */
                                            
                                            
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
                                        
                                        
                                        
                                        self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                        
                                        
                                        
                                        
                                    } else {
                                        
                                        if let errorMessage = ((jsonFlightStatusData)["error"] as? NSDictionary)?["errorMessage"] as? String {
                                            
                                            DispatchQueue.main.async {
                                                
                                                self.activityIndicator.stopAnimating()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                self.activityLabel.removeFromSuperview()
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

            
        } else {
            
            //self.showFlightInfoWindows(flightIndex: self.flightIndex)
            //self.infoWindowIsVisible = true
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.blurEffectViewActivity.removeFromSuperview()
                self.activityLabel.removeFromSuperview()
                
                self.displayAlert(title: "Flights do not update until 72 hours before departure.", message: "Try again later.")
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
            
            if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Departure Airport" {
                
                longitude = self.flights[self.flightIndex]["Airport Departure Longitude"]!
                latitude = self.flights[self.flightIndex]["Airport Departure Latitude"]!
                name = self.flights[self.flightIndex]["Departure Airport Code"]!
                
            } else if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                
                longitude = self.flights[self.flightIndex]["Airport Arrival Longitude"]!
                latitude = self.flights[self.flightIndex]["Airport Arrival Latitude"]!
                name = self.flights[self.flightIndex]["Arrival Airport Code"]!
                
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
            let didFlightTakeOff = self.didFlightAlreadyTakeoff(departureDate: departureDate, utcOffset: utcOffset)
                    
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
                            
                            self.blurEffectViewTopView.alpha = 0
                            self.blurEffectViewBottomView.alpha = 0
                            self.blurEffectViewFlightInfoWindow.alpha = 0
                            self.arrivalInfoWindow.alpha = 0
                            
                            self.blurEffectViewFlightInfoWindowBottom.alpha = 0
                            self.blurEffectViewFlightInfoWindowTop.alpha = 0
                            
                        }) { _ in
                            
                            self.blurEffectViewTopView.removeFromSuperview()
                            self.blurEffectViewBottomView.removeFromSuperview()
                            self.blurEffectViewFlightInfoWindow.removeFromSuperview()
                            self.arrivalInfoWindow.removeFromSuperview()
                            
                            self.blurEffectViewFlightInfoWindowTop.removeFromSuperview()
                            self.blurEffectViewFlightInfoWindowBottom.removeFromSuperview()
                            
                            self.infoWindowIsVisible = false
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
                        self.addActivityIndicatorPhotos()
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
                                                
                                                let username = (PFUser.current()?.username)!
                                                
                                                
                                                if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
                                                    
                                                    var request = URLRequest(url: url)
                                                    request.allHTTPHeaderFields = ["Content-Type":"application/json", "Authorization":"key=AAAASkgYWy4:APA91bFMTuMvXfwcVJbsKJqyBitkb9EUpvaHOkciT5wvtVHsaWmhxfLpqysRIdjgRaEDWKcb9tD5WCvqz67EvDyeSGswL-IEacN54UpVT8bhK1iAvKDvicOge6I6qaZDu8tAHOvzyjHs"]
                                                    request.httpMethod = "POST"
                                                    request.httpBody = "{\"to\":\"\(fcmToken)\",\"priority\":\"high\",\"notification\":{\"body\":\"\(username) shared a flight with you.\"}}".data(using: .utf8)
                                                    
                                                    URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                                                        
                                                        if error != nil {
                                                            
                                                            print(error!)
                                                        }
                                                        
                                                        
                                                    }).resume()
                                                    
                                                }
                                                
                                            } else {
                                                
                                                //user not enabled push notifications
                                                
                                            }
                                            
                                        }
                                    }
                                }
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                    
                                }))
                                
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
        
        let index:Int = flightIndex
        
        if self.tappedMarker != nil && self.userTappedRoute != true {
            
            /*
            DispatchQueue.main.async {
                self.resetTimers()
            }
            */
            if (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])! == "Arrival Airport" {
                
                //self.resetArrivalTimer()
                
                self.arrivalInfoWindow.topView.alpha = 1
                self.arrivalInfoWindow.bottomView.alpha = 1
                var departureTimeDuration:String!
                let departureOffset = self.flights[index]["Departure Airport UTC Offset"]!
                var departureTime:String!
                let departureDate = self.flights[index]["Published Departure"]!
                let arrivalDate = self.flights[index]["Published Arrival"]!
                let arrivalOffset = self.flights[index]["Arrival Airport UTC Offset"]!
                var flightDuration = self.getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                var arrivalTimeDuration:String!
                var arrivalCountdown:String!
                var arrivalTime:String!
                
                
                
                
                //Departure heirarchy
                if self.flights[index]["Converted Published Departure"]! != "" {
                    
                    departureTime = self.flights[index]["Converted Published Departure"]!
                    departureTimeDuration = self.flights[index]["Published Departure"]!
                    flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    publishedDeparture = departureTimeDuration
                    
                }
                
                if self.flights[index]["Converted Scheduled Gate Departure"]! != "" {
                    
                    departureTime = self.flights[index]["Converted Scheduled Gate Departure"]!
                    departureTimeDuration = self.flights[index]["Scheduled Gate Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    
                    
                }
                
                if self.flights[index]["Converted Estimated Gate Departure"]! != "" {
                    
                    departureTime = self.flights[index]["Converted Estimated Gate Departure"]!
                    departureTimeDuration = self.flights[index]["Estimated Gate Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    
                    
                }
                
                if self.flights[index]["Converted Actual Gate Departure"]! != "" {
                    
                    departureTime = self.flights[index]["Converted Actual Gate Departure"]!
                    departureTimeDuration = self.flights[index]["Actual Gate Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    
                }
                
                if self.flights[index]["Converted Actual Runway Departure"]! != "" {
                    
                    departureTime = self.flights[index]["Converted Actual Runway Departure"]!
                    departureTimeDuration = self.flights[index]["Actual Runway Departure"]!
                    self.actualTakeOff = departureTimeDuration
                    flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    
                }
                
                
                //arrival heirarchy
                if self.flights[index]["Converted Published Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Published Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Published Arrival"]!
                    //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Arriving in", comment: "")
                    flightDuration = self.getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Scheduled Gate Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Scheduled Gate Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Scheduled Gate Arrival"]!
                    //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Arriving at gate in", comment: "")
                    flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    
                }
                
                if self.flights[index]["Converted Estimated Runway Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Estimated Runway Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Estimated Runway Arrival"]!
                    //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Landing in", comment: "")
                    flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Estimated Gate Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Estimated Gate Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Estimated Gate Arrival"]!
                    //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Arriving at gate in", comment: "")
                    flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Actual Runway Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Actual Runway Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Actual Runway Arrival"]!
                    //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Flight landed", comment: "")
                    flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                if self.flights[index]["Converted Actual Gate Arrival"]! != "" {
                    
                    arrivalTime = self.flights[index]["Converted Actual Gate Arrival"]!
                    arrivalTimeDuration = self.flights[index]["Actual Gate Arrival"]!
                    //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Flight arrived at gate", comment: "")
                    flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                    }
                }
                
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalFlightNumber.text = self.flights[index]["Airline Code"]! + self.flights[index]["Flight Number"]!
                self.arrivalInfoWindow.arrivalDistance.text = self.flights[index]["Distance"]!
                self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
                }
                if self.flights[index]["Flight Status"] == "" {
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalStatus.text = "Swipe Up to Update"
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
                    
                    if weather == "clear sky" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "sunny_25.png")
                        }
                    } else if weather == "light snow" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "snow_25.png")
                        }
                    } else if weather == "few clouds" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "prtly_cloudy_sun_25.png")
                        }
                    } else if weather == "mist" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "fog_mist_25.png")
                        }
                    } else if weather == "scattered clouds" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "prtly_cloudy_sun_25.png")
                        }
                    } else if weather == "broken clouds" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "prtly_cloudy_sun_25.png")
                        }
                    } else if weather == "light rain" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                        }
                    } else if weather == "fog" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "fog_mist_25.png")
                        }
                    } else if weather == "haze" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "haze_25.png")
                        }
                    } else if weather == "snow" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "snow_25.png")
                        }
                    } else if weather == "shower rain" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                        }
                    } else if weather == "overcast clouds" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "mostly_cloudy_25.png")
                        }
                    } else if weather == "heavy intensity rain" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "heavy_rain_25.png")
                        }
                    } else if weather == "light intensity shower rain" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                        }
                    } else if weather == "moderate rain" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "heavy_rain_25.png")
                        }
                    } else if weather == "light intensity drizzle" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                        }
                    } else if weather == "thunderstorm" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "thunderstorm_25.png")
                        }
                    } else if weather == "dust" {
                        DispatchQueue.main.async {
                        self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "haze_25.png")
                        }
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
                self.arrivalInfoWindow.arrivalTime.text = arrivalTime!
                }
                //work out whether it landed on time or late and by how much
                let arrivalTimeDifference = self.getTimeDifference(publishedTime: publishedArrival, actualTime: arrivalTimeDuration)
                if arrivalTimeDifference == "0min" {
                    DispatchQueue.main.async {
                    self.arrivalInfoWindow.arrivalDelayTime.text = NSLocalizedString("Arriving on time", comment: "")
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
                        
                        
                        
                        let monthsLeft = self.countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).months
                        let daysLeft = self.countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).days
                        let hoursLeft = self.countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).hours
                        let minutesLeft = self.countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).minutes
                        let secondsLeft = self.countDown(departureDate: arrivalCountdown, departureUtcOffset: arrivalOffset).seconds
                        self.arrivalInfoWindow.arrivalMonths.text = "\(monthsLeft)"
                        self.arrivalInfoWindow.arrivaldays.text = "\(daysLeft)"
                        self.arrivalInfoWindow.arrivalHours.text = "\(hoursLeft)"
                        self.arrivalInfoWindow.arrivalMins.text = "\(minutesLeft)"
                        self.arrivalInfoWindow.arrivalSeconds.text = "\(secondsLeft)"
                        
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
                            //self.arrivalInfoWindow.arrivalCountdownLabel.isHidden = true
                            
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

    func getAirportCoordinates() {
        
        print("getAirportCoordinates")
        
        if self.flights.count > 0 {
            
            for marker in departureMarkerArray {
                
                marker.map = nil
            }
            
            for marker in arrivalMarkerArray {
                
                marker.map = nil
                
            }
            
            self.departureMarkerArray.removeAll()
            self.arrivalMarkerArray.removeAll()
            
            
        
            let path = GMSMutablePath()
            let polylinePath = GMSMutablePath()
        
            if routePolylineArray.count > 0 {
          
                for polyLine in routePolylineArray {
                
                    polyLine.map = nil
                }
            
                routePolylineArray.removeAll()
            
            }
            
        
            for (index, flight) in flights.enumerated() {
                
                var departureAirportCoordinates = CLLocationCoordinate2D()
                var arrivalAirportCoordinates = CLLocationCoordinate2D()
            
            polylinePath.removeAllCoordinates()
            let departureLongitude = Double(flight["Airport Departure Longitude"]!)
            let departureLatitude = Double(flight["Airport Departure Latitude"]!)
            let arrivalLongitude = Double(flight["Airport Arrival Longitude"]!)
            let arrivalLatitude = Double(flight["Airport Arrival Latitude"]!)
            departureAirportCoordinates = CLLocationCoordinate2D(latitude: departureLatitude!, longitude: departureLongitude!)
            arrivalAirportCoordinates = CLLocationCoordinate2D(latitude: arrivalLatitude!, longitude: arrivalLongitude!)
            let flightDistanceMeters = GMSGeometryDistance(departureAirportCoordinates, arrivalAirportCoordinates)
            let flightDistanceKilometers = Int(flightDistanceMeters / 1000)
            let flightDistanceMiles = Int(flightDistanceMeters * 0.000621371)
            self.flights[index]["Distance"] = "\(flightDistanceMiles)\(NSLocalizedString("miles", comment: "")) (\(flightDistanceKilometers)\(NSLocalizedString("km", comment: "")))"
            UserDefaults.standard.set(self.flights, forKey: "flights")
            let departurePosition = departureAirportCoordinates
            self.departureMarker = GMSMarker(position: departurePosition)
                
            path.add(departurePosition)
            self.departureMarker.tracksInfoWindowChanges = true
            self.departureMarker.appearAnimation = GMSMarkerAnimation.pop
            let departurePoint = CGPoint(x: 0.5,y: -0.1)
            departureMarker.infoWindowAnchor = departurePoint
            self.departureMarker.isTappable = true
            self.departureMarker.icon = UIImage(named: "takingOffIcon.png")
            self.departureMarker.map = self.googleMapsView
            self.departureMarker.accessibilityLabel = "Departure Airport - \(index)"
            let arrivalPosition = arrivalAirportCoordinates
            path.add(arrivalPosition)
            self.arrivalMarker = GMSMarker(position: arrivalPosition)
            self.arrivalMarker.tracksInfoWindowChanges = true
            self.arrivalMarker.appearAnimation = GMSMarkerAnimation.pop
            let arrivalPoint = CGPoint(x: 0.5,y: -0.1)
            arrivalMarker.infoWindowAnchor = arrivalPoint
                arrivalMarker.rotation = 180
            self.arrivalMarker.isTappable = true
            self.arrivalMarker.icon = UIImage(named: "Landing Plane- Tripkey.png")
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
            let scale = 1.0 / googleMapsView.projection.points(forMeters: 1, at: googleMapsView.camera.target)
            let lengths: [Double] = [(Double(8.0 * scale)), (Double(5.0 * scale))]
            self.routePolyline.spans = GMSStyleSpans(self.routePolyline.path!, styles, lengths as [NSNumber], GMSLengthKind.rhumb)
            
        }
        
        }
        
    }
    
    func updateIcon() {
        
        if self.overlay != nil {
            
            DispatchQueue.main.async {
                
                self.overlay.map = nil
                self.overlay = GMSGroundOverlay(position: self.position, icon: self.icon, zoomLevel: CGFloat(self.iconZoom))
                self.overlay.bearing = self.bearing
                self.overlay.accessibilityLabel = "Airplane Location, \(self.flightIndex!)"
                self.overlay.isTappable = true
                self.overlay.map = self.googleMapsView

            }
            
            
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
    
    func formatFlightEquipment(flightEquipment: String) -> String {
        
        var seperatedArray = flightEquipment.components(separatedBy: " (sharklets)")
        let aircraftString = seperatedArray[0]
        
        return aircraftString
        
    }
    
    func isDepartureDate72HoursAwayOrLess (date: String) -> (Bool) {
        
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
    
    func didFlightAlreadyLand (arrivalDate: String, utcOffset: String) -> (Bool) {
        
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
        let arrivalDateUtc = self.getUtcTime(time: arrivalDate, utcOffset: utcOffset)
        
        let arrivalDateUtcDate = dateFormatter.date(from: arrivalDateUtc)
        
        if arrivalDateUtcDate! < currentDateUtc as Date {
            
            return true
            
        } else {
            
            return false
        }
        
    }
    
    func didFlightAlreadyTakeoff (departureDate: String, utcOffset: String) -> (Bool) {
        
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
        let departureDateUtc = self.getUtcTime(time: departureDate, utcOffset: utcOffset)
        
        let departureDateUtcDate = dateFormatter.date(from: departureDateUtc)
        
        if departureDateUtcDate! < currentDateUtc as Date {
            
            return true
            
        } else {
            
            return false
        }
        
    }
    
    func convertDateTime (date: String) -> (String) {
        
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
    
    func convertCurrentDateToWhole (date: NSDate) -> (String) {
        
        let currentDate = NSDate()
        let dateString = String(describing: currentDate)
        let date1 = dateString.replacingOccurrences(of: "-", with: "")
        let date2 = date1.replacingOccurrences(of: ":", with: "")
        let date3 = date2.replacingOccurrences(of: "+", with: "")
        let date4 = date3.replacingOccurrences(of: "-", with: "")
        let date5 = date4.replacingOccurrences(of: " ", with: "")
        
        return date5
        
    }
    /*
    func secondsTillLanding (arrivalDateUTC: String) -> (Int) {
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateToCheck = dateTimeFormatter.date(from: arrivalDateUTC)! as NSDate
        let secondsFromNow = dateToCheck.timeIntervalSinceNow
        
        return Int(secondsFromNow)
        
    }
    
    func secondsSinceTakeOff (departureDateUTC: String) -> (Int) {
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateToCheck = dateTimeFormatter.date(from: departureDateUTC)! as NSDate
        let secondsSinceTakeOff = dateToCheck.timeIntervalSinceNow
        
        return Int(abs(secondsSinceTakeOff))
        
    }
    */
    
    //check to make sure this is working as flight still saying 0 minutes late...
    func getTimeDifference(publishedTime: String, actualTime: String) -> (String) {
        
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
    
    func getFlightDuration(departureDate: String, arrivalDate: String, departureOffset: String, arrivalOffset: String) -> (String) {
        
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
    
    func getUtcTimes(publishedDeparture: String, publishedArrival: String, departureOffset: String, arrivalOffset: String) -> (departureDateUtc: String, arrivalDateUtc: String) {
        
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
    
    func convertDuration(flightDurationScheduled: String) -> (String) {
        
        let flightDurationScheduledInt = (Int(flightDurationScheduled)! * 60)
        
        let hours1 = (Int(flightDurationScheduledInt) / 3600)
        
        let minutes1 = (Int(flightDurationScheduledInt) % 3600) / 60
        
        if hours1 > 0 {
            
            return("\(hours1)hr \(minutes1)min")
            
        } else {
            
            return("\(minutes1)min")
            
        }
        
    }
    
    func getUtcTime(time: String, utcOffset: String) -> (String) {
        
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
    
    
    func getWeather(dictionary: Dictionary<String,String>, index: Int) {
        
        print("get weather for all flights")
        
        print("flights.count = \(self.flights.count)")
        
        var departureWeatherDescription:String! = ""
        var departureTemperature:String! = ""
        var arrivalWeatherDescription:String! = ""
        var arrivalTemperature:String! = ""
        
        let departureLatitude = self.flights[index]["Airport Departure Latitude"]!
        let departureLongitude = self.flights[index]["Airport Departure Longitude"]!
        
        let departureUrl = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=" + departureLatitude + "&lon=" + departureLongitude + "&units=imperial&appid=08e64df2d3f3bc0822de1f0fc22fcb2d")!
        
        let departureTask = URLSession.shared.dataTask(with: departureUrl) { (data, response, error) in
            
            if error != nil {
                
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
                            
                            self.flights[index]["Departure Weather"] = "\(departureWeatherDescription!)"
                            self.flights[index]["Departure Temperature"] = "\(departureTemperature!)"
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
                            
                            self.flights[index]["Arrival Weather"] = "\(arrivalWeatherDescription!)"
                            self.flights[index]["Arrival Temperature"] = "\(arrivalTemperature!)"
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
    
    func formatDateTimetoWhole(dateTime: String) -> String {
        
        let dateTimeAsNumberStep1 = dateTime.replacingOccurrences(of: "-", with: "")
        let dateTimeAsNumberStep2 = dateTimeAsNumberStep1.replacingOccurrences(of: "T", with: "")
        let dateTimeAsNumberStep3 = dateTimeAsNumberStep2.replacingOccurrences(of: ":", with: "")
        let dateTimeWhole = dateTimeAsNumberStep3.replacingOccurrences(of: ".", with: "")
        
        return dateTimeWhole
    }
    
    func countDown(departureDate: String, departureUtcOffset: String) -> (months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        
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
    
    func resetFlightZeroViewdidappear() {
        
        print("resetFlightZeroViewdidappear")
        
        for (index, flight) in self.flights.enumerated() {
            
            getWeather(dictionary: flight, index: index)
            
        }
        
        if self.overlay != nil {
            
            DispatchQueue.main.async {
                
                self.overlay = GMSGroundOverlay(position: self.position, icon: UIImage(named: "noImage.png"), zoomLevel: CGFloat(self.googleMapsView.camera.zoom))
                self.overlay.map = nil
                self.icon = nil
            }
            
        }
        
        getAirportCoordinates()
    }
    
    func parseFlightIDForTracking(index: Int) {
        
        print("parseFlightIDForTracking")
        
        let url = URL(string: "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/track/\(self.flightIDString!)?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87&includeFlightPlan=false&maxPositions=1&sourceType=derived")
        
        if self.overlay != nil {
            
            DispatchQueue.main.async {
                
                self.overlay.map = nil
                self.icon = nil
            }
       }
        
       let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        self.blurEffectViewActivity.removeFromSuperview()
                        self.activityLabel.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
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
                                                    var newPosition:GMSCameraPosition!
                                                self.removeButtons()
                                                self.position = CLLocationCoordinate2DMake(latitude!, longitude!)
                                                self.icon = UIImage(named: "airPlane75by75.png")
                                                self.overlay = GMSGroundOverlay(position: self.position, icon: self.icon, zoomLevel: CGFloat(self.googleMapsView.camera.zoom))
                                                self.overlay.bearing = self.bearing
                                                self.overlay.accessibilityLabel = "Airplane Location, \(index)"
                                                self.flightIndex = index
                                                self.overlay.isTappable = true
                                                self.overlay.map = self.googleMapsView
                                                
                                                    if self.updateFlightFirstTime == true {
                                                        
                                                      newPosition = GMSCameraPosition.camera(withLatitude: self.position.latitude, longitude: self.position.longitude, zoom: 14, bearing: self.bearing, viewingAngle: 25)
                                                    } else {
                                                        
                                                        newPosition = GMSCameraPosition.camera(withLatitude: self.position.latitude, longitude: self.position.longitude, zoom: self.googleMapsView.camera.zoom, bearing: self.googleMapsView.camera.bearing, viewingAngle: self.googleMapsView.camera.viewingAngle)
                                                    }
                                                
                                                    
                                                self.updateFlightFirstTime = false
                                                
                                                CATransaction.begin()
                                                CATransaction.setValue(Int(2), forKey: kCATransactionAnimationDuration)
                                                self.googleMapsView.animate(to: newPosition)
                                                CATransaction.commit()
                                                    
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
    
    @IBAction func backToNearMe(segue:UIStoryboardSegue) {
    }
    
    func showDepartureWindow(index: Int) {
        
        
        /*
        DispatchQueue.main.async {
            self.resetTimers()
        }
        */
        /*
        self.blurEffectViewFlightInfoWindowBottom.alpha = 0
        self.blurEffectViewFlightInfoWindowTop.alpha = 0
        self.arrivalInfoWindow.alpha = 0
        
        //self.arrivalInfoWindow.topView.alpha = 1
        //self.arrivalInfoWindow.bottomView.alpha = 1
        */
        var departureTimeDuration:String!
        var departureCountDown:String!
        let departureOffset = self.flights[index]["Departure Airport UTC Offset"]!
        var departureTime:String!
        let departureDate = self.flights[index]["Published Departure"]!
        let arrivalDate = self.flights[index]["Published Arrival"]!
        let arrivalOffset = self.flights[index]["Arrival Airport UTC Offset"]!
        var flightDuration = self.getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
        var arrivalTimeDuration:String!
        var arrivalTime:String!
        /*
        self.arrivalInfoWindow.directions.addTarget(self, action: #selector(self.directionsToArrivalAirport), for: .touchUpInside)
        
        self.arrivalInfoWindow.flightAmenities.addTarget(self, action: #selector(self.flightAmenities), for: .touchUpInside)
        
        self.arrivalInfoWindow.share.addTarget(self, action: #selector(self.shareFlight), for: .touchUpInside)
        
        self.arrivalInfoWindow.call.addTarget(self, action: #selector(self.directionsToArrivalAirport), for: .touchUpInside)
        
        self.arrivalInfoWindow.deleteFlight.addTarget(self, action: #selector(self.deleteFlight), for: .touchUpInside)
        
        let flightDragged = UIPanGestureRecognizer(target: self, action: #selector(self.flightWasDragged(gestureRecognizer:)))
        self.arrivalInfoWindow.addGestureRecognizer(flightDragged)
        */
        //Departure heirarchy
        if self.flights[index]["Converted Published Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Published Departure"]!
            departureTimeDuration = self.flights[index]["Published Departure"]!
            flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
            }
            
            publishedDeparture = departureTimeDuration
            
        }
        
        if self.flights[index]["Converted Scheduled Gate Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Scheduled Gate Departure"]!
            departureTimeDuration = self.flights[index]["Scheduled Gate Departure"]!
            //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Departing gate in", comment: "")
            self.actualTakeOff = departureTimeDuration
            flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
            
        }
        
        if self.flights[index]["Converted Estimated Gate Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Estimated Gate Departure"]!
            departureTimeDuration = self.flights[index]["Estimated Gate Departure"]!
            //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Departing gate in", comment: "")
            self.actualTakeOff = departureTimeDuration
            flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
            
        }
        
        if self.flights[index]["Converted Actual Gate Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Actual Gate Departure"]!
            departureTimeDuration = self.flights[index]["Actual Gate Departure"]!
            //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Flight has departed", comment: "")
            self.actualTakeOff = departureTimeDuration
            flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        
        if self.flights[index]["Converted Actual Runway Departure"]! != "" {
            
            departureTime = self.flights[index]["Converted Actual Runway Departure"]!
            departureTimeDuration = self.flights[index]["Actual Runway Departure"]!
            //self.arrivalInfoWindow.arrivalCountdownLabel.text = NSLocalizedString("Flight took off", comment: "")
            self.actualTakeOff = departureTimeDuration
            flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        
        //arrival heirarchy
        if self.flights[index]["Converted Published Arrival"]! != "" {
            
            arrivalTime = self.flights[index]["Converted Published Arrival"]!
            arrivalTimeDuration = self.flights[index]["Published Arrival"]!
            flightDuration = self.getFlightDuration(departureDate: departureDate, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        
        if self.flights[index]["Converted Scheduled Gate Arrival"]! != "" {
            
            arrivalTime = self.flights[index]["Converted Scheduled Gate Arrival"]!
            arrivalTimeDuration = self.flights[index]["Scheduled Gate Arrival"]!
            flightDuration = self.getFlightDuration(departureDate: departureTimeDuration, arrivalDate: arrivalDate, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        
        if self.flights[index]["Converted Estimated Runway Arrival"]! != "" {
            
            arrivalTime = self.flights[index]["Converted Estimated Runway Arrival"]!
            arrivalTimeDuration = self.flights[index]["Estimated Runway Arrival"]!
            flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        
        if self.flights[index]["Converted Estimated Gate Arrival"]! != "" {
            
            arrivalTime = self.flights[index]["Converted Estimated Gate Arrival"]!
            arrivalTimeDuration = self.flights[index]["Estimated Gate Arrival"]!
            flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        
        if self.flights[index]["Converted Actual Runway Arrival"]! != "" {
            
            arrivalTime = self.flights[index]["Converted Actual Runway Arrival"]!
            arrivalTimeDuration = self.flights[index]["Actual Runway Arrival"]!
            flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        
        if self.flights[index]["Converted Actual Gate Arrival"]! != "" {
            
            arrivalTime = self.flights[index]["Converted Actual Gate Arrival"]!
            arrivalTimeDuration = self.flights[index]["Actual Gate Arrival"]!
            flightDuration = self.getFlightDuration(departureDate: self.actualTakeOff, arrivalDate: arrivalTimeDuration, departureOffset: departureOffset, arrivalOffset: arrivalOffset)
            
        }
        DispatchQueue.main.async {
        self.arrivalInfoWindow.arrivalFlightNumber.text = self.flights[index]["Airline Code"]! + self.flights[index]["Flight Number"]!
        self.arrivalInfoWindow.arrivalDistance.text = self.flights[index]["Distance"]!
        self.arrivalInfoWindow.arrivalFlightDuration.text = flightDuration
        }
        if self.flights[index]["Flight Status"] == "" {
            DispatchQueue.main.async {
            self.arrivalInfoWindow.arrivalStatus.text = "Swipe Up to Update"
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
            
            if weather == "clear sky" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "sunny_25.png")
                }
            } else if weather == "light snow" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "snow_25.png")
                }
            } else if weather == "few clouds" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "prtly_cloudy_sun_25.png")
                }
            } else if weather == "mist" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "fog_mist_25.png")
                }
            } else if weather == "scattered clouds" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "prtly_cloudy_sun_25.png")
                }
            } else if weather == "broken clouds" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "prtly_cloudy_sun_25.png")
                }
            } else if weather == "light rain" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                }
            } else if weather == "fog" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "fog_mist_25.png")
                }
            } else if weather == "haze" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "haze_25.png")
                }
            } else if weather == "snow" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "snow_25.png")
                }
            } else if weather == "shower rain" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                }
            } else if weather == "overcast clouds" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "mostly_cloudy_25.png")
                }
            } else if weather == "heavy intensity rain" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "heavy_rain_25.png")
                }
            } else if weather == "light intensity shower rain" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                }
            } else if weather == "moderate rain" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "heavy_rain_25.png")
                }
            } else if weather == "light intensity drizzle" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "light_rain_25.png")
                }
            } else if weather == "thunderstorm" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "thunderstorm_25.png")
                }
            } else if weather == "dust" {
                DispatchQueue.main.async {
                self.arrivalInfoWindow.arrivalWeatherImage.image = UIImage(named: "haze_25.png")
                }
            }
            
        }
        DispatchQueue.main.async {
        self.arrivalInfoWindow.arrivalAirportCode.text = "\(self.flights[index]["Departure City"]!) " + "(\(self.flights[index]["Departure Airport Code"]!))"
        self.arrivalInfoWindow.arrivalTerminal.text = self.flights[index]["Airport Departure Terminal"]!
        self.arrivalInfoWindow.arrivalGate.text = self.flights[index]["Departure Gate"]!
        self.arrivalInfoWindow.arrivalBaggageClaim.text = "-"
        }
        
        //work out whether it took off on time or late and by how much
        let departureTimeDifference = self.getTimeDifference(publishedTime: publishedDeparture, actualTime: departureTimeDuration)
        
        
        
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
        self.arrivalInfoWindow.arrivalTime.text = departureTime!
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
                
                let monthsLeft = self.countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).months
                let daysLeft = self.countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).days
                let hoursLeft = self.countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).hours
                let minutesLeft = self.countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).minutes
                let secondsLeft = self.countDown(departureDate: departureCountDown, departureUtcOffset: departureOffset).seconds
                self.arrivalInfoWindow.arrivalMonths.text = "\(monthsLeft)"
                self.arrivalInfoWindow.arrivaldays.text = "\(daysLeft)"
                self.arrivalInfoWindow.arrivalHours.text = "\(hoursLeft)"
                self.arrivalInfoWindow.arrivalMins.text = "\(minutesLeft)"
                self.arrivalInfoWindow.arrivalSeconds.text = "\(secondsLeft)"
                
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
                    //self.arrivalInfoWindow.arrivalCountdownLabel.isHidden = true
                    
                } else {
                    
                    self.arrivalInfoWindow.arrivalCoutdownView.isHidden = false
                    
                }
                
            }
        }
    }

}

extension ViewController : WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("0. ViewController: ", "activationDidCompleteWith activationState")
    }
    
    
    /** ------------------------- iOS App State For Watch ------------------------ */
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("1. ViewController: ", "sessionDidBecomeInactive")
    }
    
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("2. ViewController: ", "sessionDidDeactivate")
    }
    
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("3. ViewController: ", "sessionDidDeactivate")
    }
    
    
    /** ------------------------- Interactive Messaging ------------------------- */
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("4. ViewController: ", "sessionReachabilityDidChange")
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("5. ViewController: ", "didReceiveMessage")
    }
    
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        print("6. ViewController: ", "didReceiveMessage")
        // This is where you handle any requests coming from your Watch App
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("7. ViewController: ", "didReceiveMessageData")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Swift.Void) {
        print("8. ViewController: ", "didReceiveMessageData")
    }
    
    /** -------------------------- Background Transfers ------------------------- */
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("9. ViewController: ", "didReceiveApplicationContext")
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("10. ViewController: ", "didFinish userInfoTransfer")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("11. ViewController: ", "didReceiveUserInfo")
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("12. ViewController: ", "didFinish fileTransfer")
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("13. ViewController: ", "didReceive file")
    }
}
