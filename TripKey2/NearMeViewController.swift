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
import Foundation
import WatchConnectivity
import UserNotifications

class NearMeViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, WCSessionDelegate, UITabBarControllerDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    let menuButton = UIButton()
    let myLocationButton = UIButton()
    let cityLabel = UILabel()
    let onTimeLabel = UILabel()
    let locationManager = CLLocationManager()
    var timerLabel = Timer()
    var blurViewArray = [UIVisualEffectView]()
    var circleBlurViewArray = [UIVisualEffectView]()
    var infoLabelsArray = [UIVisualEffectView]()
    var flightArray = [[String:Any]]()
    let liveFlightMarker = GMSMarker()
    let nextFlightButton = UIButton()
    var didTapMarker = Bool()
    var session: WCSession?
    var howManyTimesUsed:[Int]! = []
    var usersHeading:Double!
    var flightIndex:Int! = 0
    var bearing:Double!
    var iconZoom:Float!
    var position:CLLocationCoordinate2D!
    var icon:UIImage!
    var overlay:GMSGroundOverlay!
    let topLabelsView = Bundle.main.loadNibNamed("TopView", owner: self, options: nil)?[0] as! TopLabelView
    let countDownView = Bundle.main.loadNibNamed("CountDownView", owner: self, options: nil)?[0] as! CountDown
    let departureInfoView = Bundle.main.loadNibNamed("DepartureInfo", owner: self, options: nil)?[0] as! DepartureInfo
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let circleView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var departureMarkerArray:[GMSMarker] = []
    var arrivalMarkerArray:[GMSMarker] = []
    var routePolyline:GMSPolyline!
    var routePolylineArray:[GMSPolyline] = []
    var departureMarker:GMSMarker!
    var arrivalMarker:GMSMarker!
    var tappedMarker:GMSMarker!
    var bounds = GMSCoordinateBounds()
    var airportBounds = GMSCoordinateBounds()
    var activityIndicator:UIActivityIndicatorView!
    var timer:Timer!
    var latitude:Double!
    var longitude:Double!
    @IBOutlet weak var mapView: GMSMapView!
    var menuVisible = false
    
    func promptUserToFollowPeople() {
        
        DispatchQueue.main.async {
            displayAlert(viewController: self, title: "Oops", message: "You have not followed anyone yet. Get a friend to send their QR Code to you, then tap the add user button in the community table to upload the QR code. You can then easily share flights with them anytime.")
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
        switch overlay.accessibilityLabel?.components(separatedBy: ", ")[0] {
        case "Airplane Location":
            let index = Int((overlay.accessibilityLabel?.components(separatedBy: ", ")[1])!)!
            let flightId = self.flightArray[index]["flightId"] as! String
            self.parseFlightIDForTracking(flightId: flightId, index: index)
        
        default:
            break
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
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
    
    func firstTimeHere() {
        print("firstTimeHere")
        //Checks if User has used this version of the app before
        //UserDefaults.standard.removeObject(forKey: "firstTime")
        if UserDefaults.standard.object(forKey: "firstTime") == nil {
            print("firstTime == nil")
            
            //delete followed users
            UserDefaults.standard.removeObject(forKey: "followedUsernames")
            let getusers = getFollowedUsers()
            for u in getusers {
                let username = u["username"]!
                deleteUserFromCoreData(viewController: self, username: username)
                
            }
            
            func randomString(length: Int) -> String {
                let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                return String((0...length-1).map{ _ in letters.randomElement()! })
            }
            let userId = randomString(length: 35)
            print("userId = \(userId)")
            UserDefaults.standard.set(userId, forKey: "userId")
            UserDefaults.standard.set(true, forKey: "firstTime")
            
            if PFUser.current() != nil {
                
                //user already logged in
                //update userid
                let post = PFObject(className: "Posts")
                post["userid"] = userId
                post["username"] = PFUser.current()!.username!
                post.saveInBackground { (success, error) in
                    if error != nil {
                        print("error adding userid and username to posts")
                    } else {
                        print("User signed up with Parse")
                    }
                }
                
                //change username to user id to ensure backwards compatibility
                PFUser.current()!.setObject(userId, forKey: "username")
                PFUser.current()!.saveInBackground { (success, error) in
                    if error != nil {
                        print("error = \(String(describing: error))")
                    } else {
                        print("succesfully changed username to the userid")
                    }
                }
                
                
            } else {
                
                //create account for new user
                // temporary username
                let temporaryUserName = randomString(length: 7)
                let user = PFUser()
                user.username = userId
                user.password = userId
                user.signUpInBackground { (success, error) in
                    if error != nil {
                        print("error signing user up \(error as Any)")
                    } else {
                        let query = PFQuery(className: "Posts")
                        query.whereKey("userid", equalTo: (PFUser.current()?.objectId!)!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if let posts = objects {
                                for post in posts {
                                    post.deleteInBackground(block: { (success, error) in
                                        if error != nil {
                                            print("post can not be deleted")
                                        } else {
                                            print("post deleted")
                                        }
                                    })
                                }
                            }
                        })
                        let post = PFObject(className: "Posts")
                        post["userid"] = userId
                        post["username"] = temporaryUserName
                        post.saveInBackground { (success, error) in
                            if error != nil {
                                print("error adding userid and username to posts")
                            } else {
                                print("User signed up with Parse")
                            }
                        }
                    }
                }
            }
        } else {
            //get user ids first
            let userArray = getFollowedUsers()
            
                if userArray.count > 0 {
                
                for user in userArray {
                    
                    if let id = user["userid"] as? String {
                        
                        let username = user["username"]!
                        
                        let query = PFQuery(className: "Posts")
                        query.whereKey("userid", equalTo: id)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if let posts = objects {
                                if posts.count > 0 {
                                    if username != posts[0]["username"] as! String {
                                        //update in coredata
                                        let newusername  = posts[0]["username"] as! String
                                        let success = updateUserNameInCoreData(viewController: self, username: newusername, userId: id)
                                        if success {
                                            print("succesfully updated \(username) to \(newusername)")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload nearMe")
        
        tabBarController!.delegate = self
        firstTimeHere()
        didTapMarker = false
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = true
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.isBuildingsEnabled = true
        mapView.settings.compassButton = false
        mapView.accessibilityElementsHidden = false
        mapView.mapType = GMSMapViewType.hybrid
        convertUserDefaultsToCoreData()
        isUsersFirstTime()
           
        if howManyTimesUsed.count % 10 == 0 {
            self.askForReview()
        }
        
        //check location permission
        switch(CLLocationManager.authorizationStatus()) {
            
        case.notDetermined:
            
            print("not determined")
            
        case .restricted, .denied:
            
            print("denied, restricted")
            
        case .authorizedAlways, .authorizedWhenInUse:
            
            self.mapView.isMyLocationEnabled = true
            
        default:
            
            break
            
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
                    self.tabBarController!.selectedIndex = 1
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
                    
                }
                
            }
            
        }
        
    }
    
    func showFlightOrUserLocation() {
        print("showFlightOrUserLocation")
        
        if flightArray.count > 0 {
            
            self.flightIndex = 0
            
        } else {
            
            navigateToUsersLocation()
        
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.liveFlightMarker.map = nil
        
        if timerLabel.isValid {
            
            timerLabel.invalidate()
            
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewdidappear")
        
        flightArray = getFlightArray()
        showFlightOrUserLocation()
        getSharedFlights()
        
        
        if flightArray.count > 0 {
            
            getFlightData(flightDictionary: flightArray[0], completion: self.resetFlightZeroViewdidappear)
            
            if flightArray.count > 1 {
                
                let flightIndexMax = flightArray.count - 1
                
                for i in 1 ... flightIndexMax {
                    
                    parseLeg2Only(dictionary: flightArray[i], index: i)
                    
                }
                
            }
            
        }
        
        addButtons()
        
    }
    
   func askForReview() {
    
        DispatchQueue.main.async {
            
            if #available( iOS 10.3,*){
                
                SKStoreReviewController.requestReview()
                
            }
            
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.liveFlightMarker.map = nil
        
        switch segue.identifier {
        case "seatGuru":
            if let vc = segue.destination as? SeatGuruViewController {
                vc.selectedFlight = self.flightArray[self.flightIndex]
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
        
    }
    
    @objc func nextFlight() {
        
        self.liveFlightMarker.map = nil
        if timerLabel.isValid {
            timerLabel.invalidate()
        }
        
        if self.flightArray.count == 0 {
            
            DispatchQueue.main.async {
                self.tabBarController!.selectedIndex = 1
            }
            
        } else if self.flightArray.count > self.flightIndex + 1 {
            
            self.getAirportCoordinates(flight: self.flightArray[self.flightIndex + 1], index: self.flightIndex + 1)
            self.flightIndex = self.flightIndex + 1
            updateLabelText()
            
        } else if self.flightArray.count == self.flightIndex + 1 {
            
            self.flightIndex = 0
            self.getAirportCoordinates(flight: self.flightArray[self.flightIndex], index: self.flightIndex)
            updateLabelText()
            
        }
    }
    
    func addAllButtons() {
        
        if flightArray.count > 0 {
            
            let deleteButton = UIButton()
            let shareButton = UIButton()
            let myProfileButton = UIButton()
            let getDirectionsButton = UIButton()
            let callButton = UIButton()
            let infoButton = UIButton()
            
            let deleteButtonImage = UIImage(named: "delete-512.png")
            let deleteButtonFrame = CGRect(x: mapView.frame.maxX - 55, y: mapView.bounds.maxY - (55 + 40), width: 45, height: 45)
            deleteButton.frame = CGRect(x: (45/2) - (30/2), y: (45/2) - (30/2), width: 30 , height: 30)
            deleteButton.setImage(deleteButtonImage, for: .normal)
            deleteButton.backgroundColor = UIColor.clear
            deleteButton.addTarget(self, action: #selector(removeFlight), for: .touchUpInside)
            
            let shareButtonImage = UIImage(named: "share.png")
            let shareButtonFrame = CGRect(x: mapView.frame.maxX - 55, y: mapView.bounds.maxY - (55 + 40), width: 45, height: 45)
            shareButton.frame = CGRect(x: (45/2) - (30/2), y: (45/2) - (30/2), width: 30 , height: 30)
            shareButton.setImage(shareButtonImage, for: .normal)
            shareButton.backgroundColor = UIColor.clear
            shareButton.addTarget(self, action: #selector(shareFlight), for: .touchUpInside)
            
            let myProfileImage = UIImage(named: "qr")
            let myProfileFrame = CGRect(x: mapView.frame.maxX - 55, y: mapView.bounds.maxY - (55 + 40), width: 45, height: 45)
            myProfileButton.frame = CGRect(x: (45/2) - (30/2), y: (45/2) - (30/2), width: 30 , height: 30)
            myProfileButton.setImage(myProfileImage, for: .normal)
            myProfileButton.backgroundColor = UIColor.clear
            myProfileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
            
            let getDirectionsImage = UIImage(named: "directions.png")
            let getDirectionsFrame = CGRect(x: mapView.frame.maxX - 55, y: mapView.bounds.maxY - (55 + 40), width: 45, height: 45)
            getDirectionsButton.frame = CGRect(x: (45/2) - (30/2), y: 5, width: 30 , height: 30)
            getDirectionsButton.setImage(getDirectionsImage, for: .normal)
            getDirectionsButton.backgroundColor = UIColor.clear
            getDirectionsButton.addTarget(self, action: #selector(directionsToAirport), for: .touchUpInside)
            
            let callImage = UIImage(named: "whitePhone.png")
            let callFrame = CGRect(x: mapView.frame.maxX - 55, y: mapView.bounds.maxY - (55 + 40), width: 45, height: 45)
            callButton.frame = CGRect(x: (45/2) - (30/2), y: (45/2) - (30/2), width: 30 , height: 30)
            callButton.setImage(callImage, for: .normal)
            callButton.backgroundColor = UIColor.clear
            callButton.addTarget(self, action: #selector(callAirline), for: .touchUpInside)
            
            let infoImage = UIImage(named: "info.png")
            let infoFrame = CGRect(x: mapView.frame.maxX - 55, y: mapView.bounds.maxY - (55 + 40), width: 45, height: 45)
            infoButton.frame = CGRect(x: (45/2) - (30/2), y: (45/2) - (30/2), width: 30 , height: 30)
            infoButton.setImage(infoImage, for: .normal)
            infoButton.backgroundColor = UIColor.clear
            infoButton.addTarget(self, action: #selector(flightAmenities), for: .touchUpInside)
            
            if menuVisible {
                
                UIView.animate(withDuration: 0.75, animations: {
                    
                    var y:CGFloat! = 0
                    
                    for (index, v) in self.circleBlurViewArray.enumerated() {
                        
                        UIView.animate(withDuration: 0.75) {
                            
                            v.frame = CGRect(x: self.circleBlurViewArray[index].frame.minX, y: self.circleBlurViewArray[index].frame.minY + y, width: self.circleBlurViewArray[index].frame.width, height: self.circleBlurViewArray[index].frame.height)
                            
                        }
                        
                        y = y + 55
                        
                    }
                    
                    for v in self.circleBlurViewArray {
                        
                        v.alpha = 0
                        
                    }
                    
                }) { _ in
                    
                    deleteButton.removeFromSuperview()
                    shareButton.removeFromSuperview()
                    myProfileButton.removeFromSuperview()
                    getDirectionsButton.removeFromSuperview()
                    callButton.removeFromSuperview()
                    infoButton.removeFromSuperview()
                    
                    for v in self.circleBlurViewArray {
                        v.removeFromSuperview()
                    }
                    
                    self.circleBlurViewArray.removeAll()
                    self.menuVisible = false
                    
                }
                
            } else {
                
                addCircleBlurBackground(frame: deleteButtonFrame, button: deleteButton)
                addCircleBlurBackground(frame: shareButtonFrame, button: shareButton)
                addCircleBlurBackground(frame: myProfileFrame, button: myProfileButton)
                addCircleBlurBackground(frame: getDirectionsFrame, button: getDirectionsButton)
                addCircleBlurBackground(frame: callFrame, button: callButton)
                addCircleBlurBackground(frame: infoFrame, button: infoButton)
                menuVisible = true
                
                var y:CGFloat! = 0
                
                for (index, v) in self.circleBlurViewArray.enumerated() {
                    
                    UIView.animate(withDuration: 0.75) {
                        
                        v.alpha = 1
                        
                        v.frame = CGRect(x: self.circleBlurViewArray[index].frame.minX, y: self.circleBlurViewArray[index].frame.minY - y, width: self.circleBlurViewArray[index].frame.width, height: self.circleBlurViewArray[index].frame.height)
                        
                    }
                    
                    y = y + 55
                    
                }
                
            }
            
        }
        
    }
    
    @objc func goToMyLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                
                print("location services not enabled")
                locationManager.requestWhenInUseAuthorization()
                
            case .authorizedAlways:
                print("authorizedAlways")
                
            case .authorizedWhenInUse:
                print("authorizedWhenInUse")
                
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                mapView.isMyLocationEnabled = true
            }
        }
    }
    
    func addButtons() {
        
        myLocationButton.removeFromSuperview()
        myLocationButton.setImage(UIImage(named: "myLocation.png"), for: .normal)
        myLocationButton.frame = CGRect(x: 10, y: mapView.frame.maxY - 60, width: 30, height: 30)
        addShadow(view: myLocationButton)
        myLocationButton.addTarget(self, action: #selector(goToMyLocation), for: .allEvents)
        mapView.addSubview(myLocationButton)
        
        if flightArray.count > 1 {
            
            circleView.frame = CGRect(x: (mapView.bounds.maxX / 2) - 70, y: mapView.bounds.maxY - 55, width: 140, height: 35)
            circleView.removeFromSuperview()
            circleView.clipsToBounds = true
            circleView.layer.cornerRadius = 18
            nextFlightButton.frame = CGRect(x: 0, y: 0, width: 140, height: 35)
            addShadow(view: nextFlightButton)
            nextFlightButton.setTitle("Next Flight", for: .normal)
            nextFlightButton.addTarget(self, action: #selector(nextFlight), for: .touchUpInside)
            nextFlightButton.setTitleColor(UIColor.white, for: .normal)
            nextFlightButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Thin", size: 15)
            nextFlightButton.backgroundColor = UIColor.clear
            nextFlightButton.showsTouchWhenHighlighted = true
            mapView.addSubview(circleView)
            circleView.contentView.addSubview(nextFlightButton)
            
        }
        
        if flightArray.count > 0 {
            
            let menuImage = UIImage(named: "menu.png")
            menuButton.removeFromSuperview()
            menuButton.frame = CGRect(x: self.view.frame.maxX - 50, y: mapView.bounds.maxY - 45, width: 35, height: 35)
            menuButton.setImage(menuImage, for: .normal)
            menuButton.backgroundColor = UIColor.clear
            menuButton.addTarget(self, action: #selector(addAllButtons), for: .touchUpInside)
            addShadow(view: menuButton)
            mapView.addSubview(menuButton)
            
        }
        
     }
    
    @objc func goToProfile() {
    
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "logIn", sender: self)
        }
        
    }
    
    func addCircleBlurBackground(frame: CGRect, button: UIButton) {
        
        let circleBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
        circleBlurView.alpha = 0
        circleBlurView.removeFromSuperview()
        circleBlurView.frame = frame
        circleBlurView.clipsToBounds = true
        circleBlurView.layer.cornerRadius = 22.5
        addShadow(view: button)
        circleBlurView.contentView.addSubview(button)
        mapView.addSubview(circleBlurView)
        circleBlurViewArray.append(circleBlurView)
        
    }
    
    @objc func showTable() {
        
        if flightArray.count > 0 {
            
            DispatchQueue.main.async {
                
                self.tabBarController!.selectedIndex = 2
                
            }
            
        } else {
            
            displayAlert(viewController: self, title: "No Flights", message: "You havent added a flight yet, tap the plus button to get started.")
        }
        
    }
    
    func navigateToUsersLocation() {
        print("navigateToUsersLocation")
        
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                
                print("location services not enabled")
                
            case .authorizedAlways:
                print("authorizedAlways")
                
            case .authorizedWhenInUse:
                print("authorizedWhenInUse")
                
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        locationManager.stopUpdatingHeading()
        
    }
    
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("didupdatelocation")
    
        if locations.count > 0 {
        
            let location = locations.last
            let longitude = location!.coordinate.longitude
            let latitude = location!.coordinate.latitude
            locationManager.stopUpdatingLocation()
            
            let newLocation = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.mapView.camera.zoom)
            
            DispatchQueue.main.async {
                CATransaction.begin()
                CATransaction.setValue(Int(1.5), forKey: kCATransactionAnimationDuration)
                self.mapView.animate(to: newLocation)
                CATransaction.commit()
            }
        
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
            self.flightIndex = index
            //parseLeg2Only(dictionary: self.flightArray[self.flightIndex], index: self.flightIndex)
            self.tappedMarker = marker
            let tappedMarkerLatitude = marker.position.latitude
            let tappedMarkerLongitude = marker.position.longitude
            let tappedCoordinates = CLLocationCoordinate2D(latitude: tappedMarkerLatitude, longitude: tappedMarkerLongitude)
            let newPosition = GMSCameraPosition(target: tappedCoordinates, zoom: self.mapView.camera.zoom, bearing: self.mapView.camera.bearing, viewingAngle: self.mapView.camera.viewingAngle)
            CATransaction.begin()
            CATransaction.setValue(Int(1), forKey: kCATransactionAnimationDuration)
            self.mapView.animate(to: newPosition)
            CATransaction.commit()
            self.showFlightInfoWindows(flightIndex: self.flightIndex)
            //self.addFlightViewFromRightToLeft()
            
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
        
        if phoneNumber != "" {
            
            let formattedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            let url = URL(string: "tel://+\(formattedPhoneNumber)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        } else {
            
            DispatchQueue.main.async {
                
                displayAlert(viewController: self, title: NSLocalizedString("No phone number given", comment: ""), message: "")
                
            }
        }
        
    }
    
    func addActivityIndicatorCenter() {
        
        DispatchQueue.main.async {
            
            self.activityLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
            self.activityLabel.center = CGPoint(x: self.view.frame.width/2 , y: self.view.frame.height/1.815)
            self.activityLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            self.activityLabel.textColor = UIColor.white
            self.activityLabel.text = "Getting Flight Data"
            self.activityLabel.textAlignment = .center
            self.activityLabel.alpha = 0
            self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.activityIndicator.isUserInteractionEnabled = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.alpha = 0
            self.blurEffectViewActivity.frame = CGRect(x: 0, y: 0, width: 150, height: 120)
            self.blurEffectViewActivity.center = CGPoint(x: self.view.center.x, y: ((self.view.center.y) + 14))
            self.blurEffectViewActivity.alpha = 0
            self.blurEffectViewActivity.layer.cornerRadius = 30
            self.blurEffectViewActivity.clipsToBounds = true
            self.view.addSubview(self.blurEffectViewActivity)
            self.view.addSubview(self.activityLabel)
            self.view.addSubview(self.activityIndicator)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.blurEffectViewActivity.alpha = 1
                self.activityIndicator.alpha = 1
                self.activityLabel.alpha = 1
            })
            
        }
        
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
                                        }
                                    }
                                    
                                    if let flightIdCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightId"] as? Double {
                                        
                                        flightId = String(flightIdCheck).replacingOccurrences(of: ".0", with: "")
                                        updateFlight(viewController: self, id: id, newValue: flightId, keyToEdit: "flightId")
                                        
                                        if flightStatusFormatted == "Departed" {
                                            DispatchQueue.main.async {
                                                //self.parseFlightIDForTracking(flightId: flightId, index: index)
                                            }
                                        }
                                    }
                                    
                                    if self.didTapMarker {
                                        self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                    }
                                    
                                    self.flightArray = getFlightArray()
                                    
                                    DispatchQueue.main.async {
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
                                        
                                        delegate?.schedule48HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                        
                                        delegate?.schedule4HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                        
                                        delegate?.schedule2HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                        
                                        delegate?.schedule1HourNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                        
                                        delegate?.scheduleTakeOffNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                        
                                        delegate?.scheduleLandingNotification(id: id, arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                        
                                        print("scheduled notifications")
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
    
    func removeSpinner() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.blurEffectViewActivity.removeFromSuperview()
            self.activityLabel.removeFromSuperview()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
        
    }
    
    @objc func directionsToAirport() {
        print("directionsToAirport")
        
        func getDirectionsTo(lon: Double, lat: Double, name: String) {
            
            let coordinate = CLLocationCoordinate2DMake(lat,lon)
            
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
            
            
        }
        
        //check location permission
        
            switch(CLLocationManager.authorizationStatus()) {
                
            case.notDetermined:
                
                //let locationManager = CLLocationManager()
                locationManager.requestWhenInUseAuthorization()
                print("not determined")
                
            case .restricted, .denied:
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "In order to get you directions to the airport we need to get your current location, we don't save it or share it wit any third parties, it is only for your convenience", preferredStyle: UIAlertControllerStyle.alert)
                    
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
                
                //let locationManager = CLLocationManager()
                locationManager.delegate = self
                
                let flight = FlightStruct(dictionary: self.flightArray[self.flightIndex])
                var name = String()
                var lat = Double()
                var lon = Double()
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "Which airport?", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alert.addAction(UIAlertAction(title: flight.departureCity, style: .default, handler: { (action) in
                        
                        lon = flight.departureLon
                        lat = flight.departureLat
                        name = flight.departureAirport
                        getDirectionsTo(lon: lon, lat: lat, name: name)
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: flight.arrivalCity, style: .default, handler: { (action) in
                        
                        lon = flight.arrivalLon
                        lat = flight.arrivalLat
                        name = flight.arrivalAirportCode
                        getDirectionsTo(lon: lon, lat: lat, name: name)
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                default:
                    
                    break
                
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
        let flightnumber = flight.flightNumber
        let identifier  = flight.identifier
        let center = UNUserNotificationCenter.current()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete flight \(flightnumber)", comment: ""), style: .destructive, handler: { (action) in
                
                center.delegate = self as? UNUserNotificationCenterDelegate
                center.getPendingNotificationRequests(completionHandler: { (notifications) in
                    
                    for notification in notifications {
                        
                        let id = notification.identifier
                        
                        if self.flightArray.count > 0 {
                            
                            switch id {
                            case "\(identifier)1HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(identifier)2HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(identifier)4HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(identifier)48HrNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(identifier)TakeOffNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            case "\(identifier)LandingNotification":
                                center.removePendingNotificationRequests(withIdentifiers: [id])
                            default:
                                break
                            }
                        }
                    }
                    
                    deleteFlight(viewController: self, flightIdentifier: identifier)
                    self.flightArray = getFlightArray()
                    
                    DispatchQueue.main.async {
                        
                        if self.liveFlightMarker.map != nil {
                            self.liveFlightMarker.map = nil
                        }
                        
                        if self.flightArray.count == 0 {
                            
                            for v in self.blurViewArray {
                                v.removeFromSuperview()
                            }
                            
                            for v in self.infoLabelsArray {
                                v.removeFromSuperview()
                            }
                            
                            self.blurViewArray.removeAll()
                            
                            if self.menuVisible {
                                
                                UIView.animate(withDuration: 0.75, animations: {
                                    
                                    var y:CGFloat! = 0
                                    
                                    for (index, v) in self.circleBlurViewArray.enumerated() {
                                        
                                        UIView.animate(withDuration: 0.75) {
                                            
                                            v.frame = CGRect(x: self.circleBlurViewArray[index].frame.minX, y: self.circleBlurViewArray[index].frame.minY + y, width: self.circleBlurViewArray[index].frame.width, height: self.circleBlurViewArray[index].frame.height)
                                            
                                        }
                                        
                                        y = y + 55
                                        
                                    }
                                    
                                    for v in self.circleBlurViewArray {
                                        
                                        v.alpha = 0
                                        
                                    }
                                    
                                }) { _ in
                                    
                                    for v in self.circleBlurViewArray {
                                        v.removeFromSuperview()
                                    }
                                    
                                    self.circleBlurViewArray.removeAll()
                                    self.menuVisible = false
                                    
                                }
                                
                            }
                            
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
        
        let followedUsers = getFollowedUsers()
        if followedUsers.count > 0 {
            
            let alert = UIAlertController(title: NSLocalizedString("Share flight with", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            for user in followedUsers {
                
                let username = user["username"]!
                let userid = user["userid"]!
                
                alert.addAction(UIAlertAction(title: " \(username)", style: .default, handler: { (action) in
                    
                    let myuserid = UserDefaults.standard.object(forKey: "userId") as! String
                    let query = PFQuery(className: "Posts")
                    query.whereKey("userid", equalTo: myuserid)
                    query.findObjectsInBackground(block: { (objects, error) in
                        
                        if let posts = objects {
                            
                            if posts.count > 0 {
                                
                                self.activityLabel.text = "Sharing"
                                let sharedFlight = PFObject(className: "SharedFlight")
                                sharedFlight["shareToUsername"] = userid
                                sharedFlight["shareFromUsername"] = myuserid
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
                                        
                                        let alert = UIAlertController(title: "\(NSLocalizedString("Flight shared to " , comment: ""))\(username)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                                                                
                                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                })
                            }
                        }
                    })
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: NSLocalizedString("You have not followed anyone yet", comment: ""), message: NSLocalizedString("Tap \"Users\" then tap the \"add user\" button to follow people.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
                DispatchQueue.main.async {
                  
                    self.tabBarController!.selectedIndex = 3
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showFlightInfoWindows(flightIndex: Int) {
        
        let index:Int = flightIndex
        if tappedMarker != nil {
            
            let label = (self.tappedMarker.accessibilityLabel?.components(separatedBy: " - ")[0])!
            
            if label == "Arrival Airport" {
                
                self.showFlightInfoWindow(index: index, type: "Arrival")
                
            } else if label == "Departure Airport" {
                
                self.showFlightInfoWindow(index: index, type: "Departure")
                
            }
        }
    }
    
    func addInfoLabels(frame: CGRect, cornerRadius: CGFloat, viewToAdd: UIView) {
        
        DispatchQueue.main.async {
            
            let infoLabel = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
            infoLabel.removeFromSuperview()
            infoLabel.frame = frame
            addShadow(view: viewToAdd)
            infoLabel.clipsToBounds = true
            infoLabel.layer.cornerRadius = cornerRadius
            infoLabel.alpha = 0
            self.mapView.addSubview(infoLabel)
            infoLabel.contentView.addSubview(viewToAdd)
            self.infoLabelsArray.append(infoLabel)
            
            UIView.animate(withDuration: 0.75) {
                
                infoLabel.alpha = 1
                
            }
            
        }
        
    }
    
    func addCircleView(frame: CGRect, cornerRadius: CGFloat, viewToAdd: UIView) {
        
        DispatchQueue.main.async {
            
            let circleBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
            circleBlurView.removeFromSuperview()
            circleBlurView.frame = frame
            addShadow(view: viewToAdd)
            circleBlurView.clipsToBounds = true
            circleBlurView.layer.cornerRadius = cornerRadius
            circleBlurView.alpha = 0
            self.mapView.addSubview(circleBlurView)
            circleBlurView.contentView.addSubview(viewToAdd)
            self.blurViewArray.append(circleBlurView)
            
            UIView.animate(withDuration: 0.75) {
                
                circleBlurView.alpha = 1
                
            }
            
         }
        
    }
    
    func onTime(label: UILabel, publishedTime: String, estimatedTime: String) -> String {
        
        var stringToReturn = ""
        let wholenumberpublished = formatDateTimetoWhole(dateTime: publishedTime)
        let wholenumberestimated = formatDateTimetoWhole(dateTime: estimatedTime)
        let difference = wholenumberestimated - wholenumberpublished
        
        if difference > 10 {
            
            stringToReturn = "Late"
            label.backgroundColor = UIColor.red
            
        } else if difference < -10 {
            
            stringToReturn = "Early"
            label.backgroundColor = UIColor.orange
            
        } else if difference < 10 && difference > -10 {
            
            stringToReturn = "On Time"
            label.backgroundColor = UIColor.clear
            
        }
        
        return stringToReturn
        
    }

    func getAirportCoordinates(flight: [String : Any], index: Int) {
        print("getAirportCoordinates")
        
        let path = GMSMutablePath()
        let polylinePath = GMSMutablePath()
        
        DispatchQueue.main.async {
            
            for marker in self.departureMarkerArray {
                marker.map = nil
            }
            
            for marker in self.arrivalMarkerArray {
                marker.map = nil
            }
            
            self.departureMarkerArray.removeAll()
            self.arrivalMarkerArray.removeAll()
            
            polylinePath.removeAllCoordinates()
            if self.routePolyline != nil {
                self.routePolyline.map = nil
            }
            
            for line in self.routePolylineArray {
                line.map = nil
            }
            
            self.routePolylineArray.removeAll()
            
        }
        
        let device = UIDevice.modelName
        
        for circleview in blurViewArray {
            circleview.removeFromSuperview()
        }
        
        for v in infoLabelsArray {
            v.removeFromSuperview()
        }
        
        infoLabelsArray.removeAll()
        
        blurViewArray.removeAll()
        
        let currentFlight = FlightStruct(dictionary: flight)
        let flightActive = didFlightAlreadyTakeoff(departureDate: currentFlight.departureDate, utcOffset: currentFlight.departureUtcOffset)
        let flightStatus = currentFlight.flightStatus
        
        var dateForCountDown = String()
        var offsetForCountdown = Double()
        
        if currentFlight.flightStatus == "Departed" {
            
            dateForCountDown = currentFlight.arrivalDate
            offsetForCountdown = currentFlight.arrivalUtcOffset
            
        } else {
            
            dateForCountDown = currentFlight.departureDate
            offsetForCountdown = currentFlight.departureUtcOffset
            
        }
        
        DispatchQueue.main.async {
            
            if self.timerLabel.isValid {
                self.timerLabel.invalidate()
            }
            
            self.timerLabel = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                (_) in
                
                DispatchQueue.main.async {
                    
                    let countDownLabels = countDown(departureDate: dateForCountDown, departureUtcOffset: offsetForCountdown)
                    self.countDownView.months.text = "\(countDownLabels.months)"
                    self.countDownView.days.text = "\(countDownLabels.days)"
                    self.countDownView.hours.text = "\(countDownLabels.hours)"
                    self.countDownView.minutes.text = "\(countDownLabels.minutes)"
                    self.countDownView.seconds.text = "\(countDownLabels.seconds)"
                    
                }
                
            }
            
           self.countDownView.frame = CGRect(x: 0, y: 0, width: 170, height: 32)
            
        }
        
        if flightActive && flightStatus != "Landed" && currentFlight.flightId != "" {
            
            self.parseFlightIDForTracking(flightId: currentFlight.flightId, index: index)
            
        }
        
        topLabelsView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 32)
        topLabelsView.flightNumberLabel.text = currentFlight.flightNumber
        
        let statusLabel = UILabel()
        statusLabel.removeFromSuperview()
        statusLabel.frame = CGRect(x: 0, y: 0, width: 110, height: 30)
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.backgroundColor = UIColor.clear
        statusLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 17)
        statusLabel.textColor = UIColor.white
        statusLabel.textAlignment = .center
        statusLabel.text = currentFlight.flightStatus
        if currentFlight.flightStatus == "" {
           statusLabel.text = "Scheduled"
        }
    
        onTimeLabel.removeFromSuperview()
        onTimeLabel.accessibilityIdentifier = "onTimeLabel"
        onTimeLabel.frame = CGRect(x: 0, y: 0, width: 110, height: 32)
        onTimeLabel.adjustsFontSizeToFitWidth = true
        onTimeLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 17)
        onTimeLabel.textColor = UIColor.white
        onTimeLabel.textAlignment = .center
        
        let status = currentFlight.flightStatus
        
        switch status {
            
        case "Departed":
            
            topLabelsView.timeLabel.text = "Arriving \(convertDateTime(date: currentFlight.arrivalDate))"
            onTimeLabel.text = onTime(label: onTimeLabel,
                                      publishedTime: currentFlight.publishedArrival,
                                      estimatedTime: currentFlight.arrivalDate)
            
        case "Landed":
            
            topLabelsView.timeLabel.text = "Landed \(convertDateTime(date: currentFlight.arrivalDate))"
            onTimeLabel.text = onTime(label: onTimeLabel,
                                      publishedTime: currentFlight.publishedArrival,
                                      estimatedTime: currentFlight.arrivalDate)
            
        case "Cancelled":
            
            statusLabel.backgroundColor = UIColor.red
            
        case "Diverted", "Redirected":
            
            topLabelsView.timeLabel.text = "Arriving \(convertDateTime(date: currentFlight.arrivalDate))"
            onTimeLabel.text = onTime(label: onTimeLabel,
                                      publishedTime: currentFlight.publishedArrival,
                                      estimatedTime: currentFlight.arrivalDate)
            statusLabel.backgroundColor = UIColor.red
            
        default:
            
            topLabelsView.timeLabel.text = "Departing \(convertDateTime(date: currentFlight.departureDate))"
            onTimeLabel.text = onTime(label: onTimeLabel,
                                      publishedTime: currentFlight.publishedDeparture,
                                      estimatedTime: currentFlight.departureDate)
            
        }
        
        var statusLabelFrame = CGRect()
        var cframe = CGRect()
        var onTimeLabelFrame = CGRect()
        var topLabelsViewFrame = CGRect()
        
        if device == "Simulator iPhone X" || device == "iPhone X" || device == "Simulator iPhone XS" || device == "Simulator iPhone XR" || device == "Simulator iPhone XS Max" {
            
            statusLabelFrame = CGRect(x: 10, y: 75, width: 110, height: 32)
            cframe = CGRect(x: self.mapView.frame.maxX - 180, y: 75, width: 170, height: 32)
            onTimeLabelFrame = CGRect(x: view.frame.maxX - 120, y: 112, width: 110, height: 32)
            topLabelsViewFrame = CGRect(x: 10, y: 38, width: view.frame.width - 20, height: 32)
            
        } else {
            
            statusLabelFrame = CGRect(x: 10, y: 55, width: 110, height: 32)
            cframe = CGRect(x: self.mapView.frame.maxX - 180, y: 55, width: 170, height: 32)
            onTimeLabelFrame = CGRect(x: view.frame.maxX - 120, y: 92, width: 110, height: 32)
            topLabelsViewFrame = CGRect(x: 10, y: 18, width: view.frame.width - 20, height: 32)
            
        }
        
        addCircleView(frame: topLabelsViewFrame, cornerRadius: 18, viewToAdd: topLabelsView)
        addCircleView(frame: cframe, cornerRadius: 18, viewToAdd: self.countDownView)
        addCircleView(frame: statusLabelFrame, cornerRadius: 18, viewToAdd: statusLabel)
        addCircleView(frame: onTimeLabelFrame, cornerRadius: 18, viewToAdd: onTimeLabel)
        
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
                
            
                
                    DispatchQueue.main.async {
                        
                        var departureAirportCoordinates = CLLocationCoordinate2D()
                        var arrivalAirportCoordinates = CLLocationCoordinate2D()
                        
                        let departureLongitude = currentFlight.departureLon
                        let departureLatitude = currentFlight.departureLat
                        let arrivalLongitude = currentFlight.arrivalLon
                        let arrivalLatitude = currentFlight.arrivalLat
                        departureAirportCoordinates = CLLocationCoordinate2D(latitude: departureLatitude, longitude: departureLongitude)
                        arrivalAirportCoordinates = CLLocationCoordinate2D(latitude: arrivalLatitude, longitude: arrivalLongitude)
                        
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
                        self.departureMarker.map = self.mapView
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
                        self.arrivalMarker.map = self.mapView
                        self.arrivalMarker.accessibilityLabel = "Arrival Airport - \(index)"
                        
                        polylinePath.add(departurePosition)
                        polylinePath.add(arrivalPosition)
                        self.routePolyline = GMSPolyline(path: path)
                        self.routePolyline.accessibilityLabel = "routePolyline, \(index)"
                        self.routePolyline.strokeWidth = 5.0
                        self.routePolyline.geodesic = true
                        self.routePolylineArray.append(self.routePolyline)
                        
                        self.departureMarkerArray.append(self.departureMarker)
                        self.arrivalMarkerArray.append(self.arrivalMarker)
                        
                        self.routePolyline.map = self.mapView
                        let styles = [GMSStrokeStyle.solidColor(.clear), GMSStrokeStyle.solidColor(.white)]
                        let scale = 1.0 / self.mapView.projection.points(forMeters: 1, at: self.mapView.camera.target)
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
                    self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
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
                    polyLine.map = self.mapView
                    let styles = [GMSStrokeStyle.solidColor(.clear), GMSStrokeStyle.solidColor(.white)]
                    let scale = 1.0 / self.mapView.projection.points(forMeters: 1, at: self.mapView.camera.target)
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
                        
                        if let _ = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String {
                            
                            if let tempCheck = (jsonResult["main"] as? NSDictionary)?["temp"] as? Double {
                                
                                DispatchQueue.main.async {
                                    
                                    let formatter = MeasurementFormatter()
                                    let temp = Measurement(value: tempCheck, unit: UnitTemperature.fahrenheit)
                                    var temperature = formatter.string(from: temp)
                                    if temperature.contains(".") {
                                        var array = temperature.split(separator: ".")
                                        let array2 = array[1].split(separator: "°")
                                        temperature = String(array[0] + "°" + array2[1])
                                    }
                                    self.cityLabel.text = "\(String(describing: self.cityLabel.text!)) \(temperature)"
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
                            
                            print("jsonFlightTrackData = \(jsonFlightTrackData)")
                            
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
                                                self.liveFlightMarker.map = self.mapView
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
    
    func showFlightInfoWindow(index: Int, type: String) {
        
        for v in infoLabelsArray {
            v.removeFromSuperview()
        }
        
        departureInfoView.removeFromSuperview()
        
        let flight = FlightStruct(dictionary: self.flightArray[index])
        self.getWeather(dictionary: self.flightArray[index], index: index, type: type)
            let publishedArrival = flight.publishedArrival
            let departureOffset = flight.departureUtcOffset
            let departureDate = flight.departureDate
            let arrivalDate = flight.arrivalDate
            let arrivalOffset = flight.arrivalUtcOffset
            let flightStatus = flight.flightStatus
            let departureCity = flight.departureCity
            let departureAirport = flight.departureAirport
            let departureTerminal = flight.departureTerminal
            let departureGate = flight.departureGate
            let arrivalCity = flight.arrivalCity
            let arrivalAirportCode = flight.arrivalAirportCode
            let arrivalTerminal = flight.arrivalTerminal
            var baggageClaim = flight.baggageClaim
        
        var dateForCountDown = String()
        var offsetForCountdown = Double()
        
        cityLabel.removeFromSuperview()
        cityLabel.frame = CGRect(x: 0, y: 0, width: 190, height: 30)
        cityLabel.adjustsFontSizeToFitWidth = true
        cityLabel.backgroundColor = UIColor.clear
        cityLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 17)
        cityLabel.textColor = UIColor.white
        cityLabel.textAlignment = .center
        
        if type == "Departure" {
            
            dateForCountDown = departureDate
            offsetForCountdown = departureOffset
            cityLabel.text = "\(departureCity) (\(departureAirport))"
            departureInfoView.departureGate.text = departureGate
            departureInfoView.departureTerminal.text = departureTerminal
            departureInfoView.descriptor.text = "Gate"
            
            switch flightStatus {
                
            case "Diverted", "Redirected", "Departed":
                
                topLabelsView.timeLabel.text = "Arriving \(convertDateTime(date: arrivalDate))"
                onTimeLabel.text = onTime(label: onTimeLabel,
                                          publishedTime: publishedArrival,
                                          estimatedTime: arrivalDate)
                
            case "Landed":
                
                topLabelsView.timeLabel.text = "Landed \(convertDateTime(date: arrivalDate))"
                onTimeLabel.text = onTime(label: onTimeLabel,
                                          publishedTime: publishedArrival,
                                          estimatedTime: arrivalDate)
                
            default:
                
                topLabelsView.timeLabel.text = "Departing \(convertDateTime(date: departureDate))"
                
            }
            
        } else {
            
            dateForCountDown = arrivalDate
            offsetForCountdown = arrivalOffset
            cityLabel.text = "\(arrivalCity) (\(arrivalAirportCode))"
            if baggageClaim == "" {
                baggageClaim = "-"
            }
            departureInfoView.departureGate.text = baggageClaim
            departureInfoView.departureTerminal.text = arrivalTerminal
            departureInfoView.descriptor.text = "Bags"
            
            switch flightStatus {
                
            case "Departed", "Diverted", "Redirected":
                
                topLabelsView.timeLabel.text = "Arriving \(convertDateTime(date: arrivalDate))"
                onTimeLabel.text = onTime(label: onTimeLabel,
                                          publishedTime: publishedArrival,
                                          estimatedTime: arrivalDate)
                
            case "Landed":
                
                topLabelsView.timeLabel.text = "Landed \(convertDateTime(date: arrivalDate))"
                onTimeLabel.text = onTime(label: onTimeLabel,
                                          publishedTime: publishedArrival,
                                          estimatedTime: arrivalDate)
                
            default:
                
                topLabelsView.timeLabel.text = "Arriving \(convertDateTime(date: arrivalDate))"
                
            }
            
        }
        
        DispatchQueue.main.async {
            
            if self.timerLabel.isValid {
                self.timerLabel.invalidate()
            }
            
            self.timerLabel = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                (_) in
                
                DispatchQueue.main.async {
                    
                    let countDownLabels = countDown(departureDate: dateForCountDown, departureUtcOffset: offsetForCountdown)
                    self.countDownView.months.text = "\(countDownLabels.months)"
                    self.countDownView.days.text = "\(countDownLabels.days)"
                    self.countDownView.hours.text = "\(countDownLabels.hours)"
                    self.countDownView.minutes.text = "\(countDownLabels.minutes)"
                    self.countDownView.seconds.text = "\(countDownLabels.seconds)"
                    
                }
                
            }
            
        }
        
        var cityLableFrame = CGRect()
        var departureInfoFrame = CGRect()
        departureInfoView.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        
        let device = UIDevice.modelName
        
        if device == "Simulator iPhone X" || device == "iPhone X" || device == "Simulator iPhone XS" || device == "Simulator iPhone XR" || device == "Simulator iPhone XS Max" {
            
            cityLableFrame = CGRect(x: 10, y: 112, width: 190, height: 32)
            departureInfoFrame = CGRect(x: view.frame.maxX - 110, y: 148, width: 100, height: 32)
            
        } else {
            
            cityLableFrame = CGRect(x: 10, y: 92, width: 190, height: 32)
            departureInfoFrame = CGRect(x: view.frame.maxX - 110, y: 129, width: 100, height: 32)
            
        }
        
        addInfoLabels(frame: cityLableFrame, cornerRadius: 18, viewToAdd: cityLabel)
        addInfoLabels(frame: departureInfoFrame, cornerRadius: 18, viewToAdd: departureInfoView)
            
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
                            var sharedFrom = ""
                            let dispatchGroup = DispatchGroup()
                            
                            for flight in sharedFlights! {
                                
                                dispatchGroup.enter()
                                let flightDictionary = flight["flightDictionary"]
                                let dictionary = flightDictionary as! NSDictionary
                                let query = PFQuery(className: "Posts")
                                query.whereKey("userid", equalTo: flight["shareFromUsername"] as! String)
                                query.findObjectsInBackground(block: { (objects, error) in
                                    
                                    if let posts = objects {
                                        if posts.count > 0 {
                                            
                                            sharedFrom = posts[0]["username"] as! String
                                            print("sharedFrom = \(sharedFrom)")
                                            sharedFromArray.append(sharedFrom)
                                            sharedFlightArray.append(dictionary as! [String:Any])
                                            
                                                flight.deleteInBackground(block: { (success, error) in
                                                    
                                                    if error != nil {
                                                        print("error = \(error as Any)")
                                                    } else {
                                                        print("flight deleted from parse database")
                                                        
                                                    }
                                                })
                                        }
                                        
                                        dispatchGroup.leave()
                                    }
                                })
                            }
                            
                            dispatchGroup.notify(queue: .main) {
                                
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
    
    func getFlightData(flightDictionary: [String:Any], completion: @escaping () -> Void) {
        print("getFlightData")
        
        self.addActivityIndicatorCenter()
            
            let flight = FlightStruct(dictionary: flightDictionary)
            let departureDateTime = flight.publishedDepartureUtc
            
            if isDepartureDate72HoursAwayOrLess(date: departureDateTime) == true && flight.flightStatus != "Landed" {
                
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
                                
                                completion()
                                self.removeSpinner()
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
                                            
                                            self.removeSpinner()
                                            completion()
                                            
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
                                                    
                                                   
                                                    
                                                    if irregularOperationsMessage1 != "" && irregularOperationsMessage2 != "" && confirmedIncidentMessage != "" && flightId != "" {
                                                        
                                                        let alert = UIAlertController(title: "\(String(describing: confirmedIncidentMessage))", message: "\(irregularOperationsType1)\n\(irregularOperationsMessage1)\n\(irregularOperationsType2)\n\(irregularOperationsMessage2)\n\n" + NSLocalizedString("Would you like to add the replacement flight automatically?", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
                                                        
                                                        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                                                            
                                                            self.parseFlightID(dictionary: self.flightArray[0], index: 0)
                                                            
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
                                                }
                                            
                                            if let flightIdCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightId"] as? Double {
                                                
                                                flightId = String(flightIdCheck).replacingOccurrences(of: ".0", with: "")
                                                updateFlight(viewController: self, id: id, newValue: flightId, keyToEdit: "flightId")
                                                
                                            }
                                            
                                            DispatchQueue.main.async {
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
                                                
                                                delegate?.schedule48HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.schedule4HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.schedule2HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.schedule1HourNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.scheduleTakeOffNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                delegate?.scheduleLandingNotification(id: id, arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                                
                                                print("scheduled notifications")
                                            }
                                            
                                            self.flightArray = getFlightArray()
                                            completion()
                                            self.removeSpinner()
                                            
                                        } else {
                                            
                                            if (((jsonFlightStatusData)["error"] as? NSDictionary)?["errorMessage"] as? String) != nil {
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    self.removeSpinner()
                                                    completion()
                                                    
                                                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("It looks like the flight number was changed by the airline, please check with your airline to ensure you have the updated flight number.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                                        
                                                    }))
                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    } else {
                                        DispatchQueue.main.async {
                                            self.removeSpinner()
                                            completion()
                                        }
                                    }
                                }
                            }
                        }
                        
                    } catch {
                        
                        DispatchQueue.main.async {
                            self.removeSpinner()
                            completion()
                        }
                        
                        print("Error parsing")
                        
                    }
                    
                }
                
                task.resume()
                
                
            } else {
                
                print("more then 3 days")
                DispatchQueue.main.async {
                    self.removeSpinner()
                    completion()
                }
            }
            
    }
    
    func parseLeg2Only(dictionary: [String:Any], index: Int) {
        
        print("parseLeg2Only")
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let flight = FlightStruct(dictionary: dictionary)
        let departureDateTime = flight.publishedDepartureUtc
        
        if isDepartureDate72HoursAwayOrLess(date: departureDateTime) == true && flight.flightStatus != "Landed" {
            
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
                                            }
                                        
                                        if let flightIdCheck = (((jsonFlightStatusData)["flightStatuses"] as? NSArray)?[0] as? NSDictionary)?["flightId"] as? Double {
                                            
                                            flightId = String(flightIdCheck).replacingOccurrences(of: ".0", with: "")
                                            updateFlight(viewController: self, id: id, newValue: flightId, keyToEdit: "flightId")
                                            
                                        }
                                        
                                        if self.didTapMarker {
                                            self.showFlightInfoWindows(flightIndex: self.flightIndex)
                                        }
                                        
                                        self.flightArray = getFlightArray()
                                        
                                        DispatchQueue.main.async {
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
                                            
                                            delegate?.schedule48HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                            
                                            delegate?.schedule4HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                            
                                            delegate?.schedule2HrNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                            
                                            delegate?.schedule1HourNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                            
                                            delegate?.scheduleTakeOffNotification(id: id, departureDate: departureDate, departureOffset: utcOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                            
                                            delegate?.scheduleLandingNotification(id: id, arrivalDate: arrivalDate, arrivalOffset: arrivalOffset, departureCity: departureCity, arrivalCity: arrivalCity, flightNumber: flightNumber, departingTerminal: departingTerminal, departingGate: departingGate, departingAirport: departingAirport, arrivingAirport: arrivalAirport)
                                            
                                            print("scheduled notifications")
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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

}

extension NearMeViewController  {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}




