//
//  CommunityFeedViewController.swift
//  TripKey
//
//  Created by Peter on 5/15/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import Parse
import MapKit
import Instructions

class CommunityFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UINavigationBarDelegate, UISearchBarDelegate {
    
    
    var resultsArray = [String]()
    @IBOutlet var autoCompleteTable: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var goToProfile: UIBarButtonItem!
    @IBOutlet var navigationBar: UINavigationBar!
    var autoComplete = [String]()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    @IBOutlet var addUserButton: UIBarButtonItem!
    @IBOutlet var goBackButton: UIBarButtonItem!
    var usernamesDuplicate = [String]()
    let pointOfInterest = UIView()
    let coachMarksController = CoachMarksController()
    @IBOutlet var myProfileButton: UILabel!
    @IBOutlet var addUsersButton: UILabel!
    var activityIndicator:UIActivityIndicatorView!
    @IBOutlet var feedTable: UITableView!
    var refresher: UIRefreshControl!
    var users = [String: String]()
    var userNames = [String]()
    var imageFiles = [PFFile]()
    var flights = [Dictionary<String,String>]()
    var userAddedPlaceDictionaryArray = [Dictionary<String,String>]()
    let locationPermissionSettings  = Bundle.main.loadNibNamed("CommunitySettings", owner: self, options: nil)?[0] as! userLocationPermission
    var locationManager = CLLocationManager()
    var followedUsername:String!
    
    var followedUserDictionary = Dictionary<String,Any>()
    var followedUserDictionaryArray = [Dictionary<String,Any>]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNearMe" {
            
            let nextScene = segue.destination as? NearMeViewController
            
            nextScene?.usersLocationMode = true
            
        }
    }
    
    func sharePlace(indexPath: Int) {
        
        print("sharePlace")
        
        let alert = UIAlertController(title: NSLocalizedString("Choose Place", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for place in self.userAddedPlaceDictionaryArray {
            
            let placeName = place["Place Name"]!
            let placeId = place["Place ID"]!
            let placePhoneNumber = place["Place Phone Number"]!
            let placeWebsite = place["Place Website"]!
            let placeAddress = place["Place Address"]!
            let placeLatitude = place["Place Latitude"]!
            let placeLongitude = place["Place Longitude"]!
            
            var placeCountry = ""
            var placeCity = ""
            var placeType = ""
            
            if place["Place Country"] != nil {
                
                placeCountry = place["Place Country"]!
                
            }
            
            if place["Place City"] != nil {
                
                placeCity = place["Place City"]!
                
            }
            
            if place["Place Type"] != nil {
                
                placeType = place["Place Type"]!
                
            }
            
            alert.addAction(UIAlertAction(title: "\(placeName)", style: .default, handler: { (action) in
                
                self.addActivityIndicatorCenter()
                let sharedPlace = PFObject(className: "SharedPlace")
                
                sharedPlace["shareToUsername"] = self.followedUserDictionaryArray[indexPath]["Username"]!
                sharedPlace["shareFromUsername"] = PFUser.current()?.username
                sharedPlace["placeName"] = placeName
                sharedPlace["placeId"] = placeId
                sharedPlace["placePhoneNumber"] = placePhoneNumber
                sharedPlace["placeWebsite"] = placeWebsite
                sharedPlace["placeAddress"] = placeAddress
                sharedPlace["placeLatitude"] = placeLatitude
                sharedPlace["placeLongitude"] = placeLongitude
                sharedPlace["placeType"] = placeType
                sharedPlace["placeCountry"] = placeCountry
                sharedPlace["placeCity"] = placeCity
                
                sharedPlace.saveInBackground(block: { (success, error) in
                    
                    if error != nil {
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: NSLocalizedString("Could not share place", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "\(NSLocalizedString("Place shared to", comment: "")) \(self.followedUserDictionaryArray[indexPath]["Username"]!)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let getUserFCM = PFUser.query()
                        
                        getUserFCM?.whereKey("username", equalTo: self.followedUserDictionaryArray[indexPath]["Username"]!)
                        
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
                                        
                                        //user not enabled notifications
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

    }
    
    func shareLocation(indexPath: Int) {
        
        self.followedUsername = self.followedUserDictionaryArray[indexPath]["Username"]! as! String
        UserDefaults.standard.set(self.followedUserDictionaryArray[indexPath]["Username"]!, forKey: "usernameFollowed")
        
        let draggedDown = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        self.locationPermissionSettings.center = self.view.center
        self.locationPermissionSettings.alpha = 0
        self.blurEffectView.alpha = 0
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.locationPermissionSettings.addGestureRecognizer(draggedDown)
        self.locationPermissionSettings.save.addTarget(self, action: #selector(self.updatePermission), for: .touchUpInside)
        self.locationPermissionSettings.disclaimerLabel.text = "\(NSLocalizedString("Allow", comment: "")) \(self.followedUsername!) \(NSLocalizedString("to see your location while you are using TripKey", comment: ""))"
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.addSubview(self.blurEffectView)
            self.view.addSubview(self.locationPermissionSettings)
            self.blurEffectView.alpha = 1
            self.locationPermissionSettings.alpha = 1
            
        }) { _ in
            
            
        }
        
    }
    
    func getUsersLocation(indexPath: Int) {
        
        var latitude:Double!
        var longitude:Double!
        var location:CLLocationCoordinate2D!
        
        let query = PFUser.query()
        
        query?.whereKey("username", equalTo: self.followedUserDictionaryArray[indexPath]["Username"]!)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let array = objects {
                
                for (index, users) in self.followedUserDictionaryArray.enumerated() {
                    
                   self.followedUserDictionaryArray[index]["Profile Image"] = ""
                }
                
                for user in objects! {
                    
                    let usersLocation = user["userlocation"] as! PFGeoPoint
                    
                    print("usersLocation = \(usersLocation)")
                    
                    latitude = Double(usersLocation.latitude)
                    longitude = Double(usersLocation.longitude)
                    
                    self.followedUserDictionaryArray[indexPath]["Latitude"] = String(latitude)
                    self.followedUserDictionaryArray[indexPath]["Longitude"] = String(longitude)
                    
                    
                    
                    UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
                    
                    self.performSegue(withIdentifier: "goNearMe", sender: self)
                    
                    
                    
                }
                
                
                
            }
            
        })
        
        //return location
        
    }
    
    
    
    func seeLocation(indexPath: Int) {
        
        //check for permissions
        
        self.addActivityIndicatorCenter()
        
        UserDefaults.standard.set(self.followedUserDictionaryArray[indexPath]["Username"]!, forKey: "usernameFollowed")
        
        let query = PFQuery(className: "MyLocationPermission")
        
        query.whereKey("followerUsername", equalTo: (PFUser.current()?.username)!)
        query.whereKey("username", equalTo: self.followedUserDictionaryArray[indexPath]["Username"]!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
                
                print("error")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: error as! String)
                
                
            } else {
                
                if (objects?.count)! > 0 {
                    
                    for permission in objects! {
                        
                        if permission["userPermission"] as! Bool == true {
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            //self.performSegue(withIdentifier: "goToUserLocation", sender: self)
                            
                            
                            self.getUsersLocation(indexPath: indexPath)
                            
                            
                        } else {
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            let alert = UIAlertController(title: "\(NSLocalizedString("You don't have permission to see", comment: "")) \(String(describing: self.followedUserDictionaryArray[indexPath]["Username"]!)) \(NSLocalizedString("location", comment: ""))", message: "\(self.followedUserDictionaryArray[indexPath]["Username"]!) \(NSLocalizedString("must go tap \"Share Your Location\" in Community to turn the permission on", comment: "")).", preferredStyle: UIAlertControllerStyle.actionSheet)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                                //send followeduser a notification
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                } else {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.displayAlert(title: "\(self.followedUserDictionaryArray[indexPath]["Username"]!) \(NSLocalizedString("has not shared their location with you", comment: "")).", message: "")
                }
                
                
            }
        })
        
        //self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()

        
    }
    
    func shareFlight(indexPath: Int) {
        
        let alert = UIAlertController(title: NSLocalizedString("Choose Flight", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for flight in self.flights {
            
            alert.addAction(UIAlertAction(title: "\(flight["Departure City"]!) \(NSLocalizedString("to", comment: "")) \(flight["Arrival City"]!)", style: .default, handler: { (action) in
                
                let flight = flight
                let user = self.followedUserDictionaryArray[indexPath]["Username"]!
                
                self.addActivityIndicatorCenter()
                let sharedFlight = PFObject(className: "SharedFlight")
                
                sharedFlight["shareToUsername"] = user
                sharedFlight["shareFromUsername"] = PFUser.current()?.username
                sharedFlight["flightDictionary"] = flight
                
                sharedFlight.saveInBackground(block: { (success, error) in
                    
                    if error != nil {
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: NSLocalizedString("Could not share flight", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        
                        
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
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
        
        
        print("shareflight")
        
    
    
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        
        return 2
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        switch(index) {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: self.addUsersButton)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.myProfileButton)
            
        default:
            return coachMarksController.helper.makeCoachMark()
        }
        
        
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        var hintText = ""
        
        switch(index) {
        case 0:
            hintText = NSLocalizedString("Tap the \"Add Users\" button to see which users you are following and unfollow users. Here you will also be able to search for new users by tapping the search button and typing a valid username (usernames are case sensitive).", comment: "")
        case 1:
            hintText = NSLocalizedString("Tap the \"My Profile\" button to see your profile, edit your profile and change your profile picture.", comment: "")
            
            
            
            
            
        default: break
        }
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation, hintText: hintText, nextText: NSLocalizedString("OK", comment: ""))
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
    }

    
    
    @IBAction func goToProfile(_ sender: Any) {
        
        performSegue(withIdentifier: "goToProfile", sender: self)
        
    }
    
    @IBAction func goToUsers(_ sender: Any) {
        
        //performSegue(withIdentifier: "goToFollowing", sender: self)
        
        print("searchUsers")
        self.searchBar.isHidden = false
        searchBar.becomeFirstResponder()
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchBar.isHidden = true
        self.autoCompleteTable.isHidden = true
    }
    
    func reloadDataWithArray(_ array:[String]){
        
        self.autoComplete = array
        self.autoCompleteTable.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("text did change")
        
        autoCompleteTable.isHidden = false
        
        let query = PFUser.query()
        
        query?.whereKey("username", equalTo: searchText)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
                
                print(error as Any)
                self.displayAlert(title: "Error", message: "Internet connection appears to be offline")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            } else if let users = objects {
                
                for user in users {
                    
                    print("user = \(user)")
                    //self.autoCompleteTable.isHidden = false
                    print("username = \(user["username"])")
                    self.autoComplete.append(user["username"] as! String)
                    DispatchQueue.main.async {
                        self.autoCompleteTable.reloadData()
                    }
                    
                }
                
            }
            
            
            
        })
        
        
        
    }

    
    @IBAction func back(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        
        
        print("refresh")
        //UIApplication.shared.beginIgnoringInteractionEvents()
        
        UserDefaults.standard.removeObject(forKey: "followedUsernames")
            
        self.followedUserDictionaryArray.removeAll()
        
        //self.feedTable.reloadData()
        
        
        let query = PFQuery(className: "Followers")
        
        query.whereKey("followerUsername", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
                
                print("error = \(String(describing: error))")
                //self.activityIndicator.stopAnimating()
                //self.refresher.endRefreshing()
                self.displayAlert(title: "Error", message: "Please try later.")
                
            } else {
                
                if let objects = objects {
                    
                    
                    if objects.count > 0 {
                        
                        self.followedUserDictionaryArray.removeAll()
                        
                        for object in objects {
                            
                            print("object = \(object)")
                            
                            let dictionary = [
                                
                                "Username":"\(object["followedUsername"] as! String)",
                                "Profile Image":""
                                
                                ] as [String : Any]
                            
                            self.followedUserDictionaryArray.append(dictionary)
                            UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
                            self.createDictionaryArray()
                            self.feedTable.reloadData()
                            
                        }
                        
                        
                        
                        
                        self.refresher.endRefreshing()
                        
                        
                    } else {
                        
                        //not following anyone
                        self.followedUserDictionaryArray.removeAll()
                        UserDefaults.standard.removeObject(forKey: "followedUsernames")
                        self.refresher.endRefreshing()
                        
                        
                    }
                    
                } else {
                    
                    
                }
                
            }
            
        })

        //above is new
        
       
        
        /*
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blurEffectView.alpha = 0
            self.feedTable.alpha = 1
            
            
        }) { _ in
            
            self.feedTable.isHidden = false
            
        }
        
        self.feedTable.reloadData()
        */
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.isHidden = true
        searchBar.delegate = self
        
        self.autoCompleteTable.isHidden = true
        
        locationPermissionSettings.save.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        locationPermissionSettings.save.titleLabel?.adjustsFontSizeToFitWidth = true
        
        addUserButton.title = NSLocalizedString("Add Users", comment: "")
        goToProfile.title = NSLocalizedString("My Profile", comment: "")
        navigationBar.topItem?.title = NSLocalizedString("Community", comment: "")
        
        
        self.coachMarksController.dataSource = self
        
        coachMarksController.overlay.windowLevel = UIWindowLevelStatusBar + 1
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle(NSLocalizedString("Skip", comment: ""), for: .normal)
        
        self.coachMarksController.skipView = skipView
        
        if (UserDefaults.standard.object(forKey: "flights") != nil) {
            
            flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
            
        }
        
        if UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") != nil {
            
            userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            
        }
        
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            self.followedUserDictionaryArray = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
            
        }
        

        feedTable.delegate = self
        
        
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        
        refresher.addTarget(self, action: #selector(CommunityFeedViewController.refreshNow), for: UIControlEvents.valueChanged)
        
        feedTable.addSubview(refresher)
        
        
        
        blurEffectView.alpha = 0
        
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        createDictionaryArray()
        updateProfileImages()
        
        
        
    }
    
    func refreshNow() {
        
        self.createDictionaryArray()
        self.updateProfileImages()
        
        refresher.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
    }
    
    func tutorial() {
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "communityLaunchedBefore")
        
        if launchedBefore  {
        } else {
            self.coachMarksController.start(on: self)
            UserDefaults.standard.set(true, forKey: "communityLaunchedBefore")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        refresh()
        //feedTable.reloadData()
        autoCompleteTable.reloadData()
        
        
        
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.feedTable {
            
            let cell = feedTable.dequeueReusableCell(withIdentifier: "Community Feed", for: indexPath) as! FeedTableViewCell
            
            cell.userName.text = followedUserDictionaryArray[indexPath.row]["Username"] as? String
            cell.sharePlaceLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.seeLocationLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.shareFlightLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.shareMyLocationLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            
            
            
            cell.seeLocationLabel.setTitle(NSLocalizedString("See Location", comment: ""), for: .normal)
            cell.shareFlightLabel.setTitle(NSLocalizedString("Share Flight", comment: ""), for: .normal)
            cell.sharePlaceLabel.setTitle(NSLocalizedString("Share Place", comment: ""), for: .normal)
            cell.shareMyLocationLabel.setTitle(NSLocalizedString("Share My Location", comment: ""), for: .normal)
            cell.postedImage.image = followedUserDictionaryArray[indexPath.row]["Profile Image"] as? UIImage
            
            cell.tapShareLocationAction = {
                
                (cell) in self.shareLocation(indexPath: (tableView.indexPath(for: cell)!.row))
                
            }
            
            cell.tapSeeLocationAction = {
                
                (cell) in self.seeLocation(indexPath: (tableView.indexPath(for: cell)!.row))
                
            }
            
            cell.tapShareFlightAction = {
                
                (cell) in self.shareFlight(indexPath: (tableView.indexPath(for: cell)!.row))
                
            }
            
            cell.tapSharePlaceAction = {
                
                (cell) in self.sharePlace(indexPath: (tableView.indexPath(for: cell)!.row))
                
            }
            
            return cell
 
        } else if tableView == self.autoCompleteTable {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath)
            
            cell.textLabel?.text = autoComplete[indexPath.row]
            
            return cell
            
            
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            return cell
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return 1
        
        if tableView == self.autoCompleteTable {
            
            return 1
            
        } else {
            
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.feedTable {
            
            return self.followedUserDictionaryArray.count
            
        } else if tableView == self.autoCompleteTable {
            
            print("autoComplete.count = \(autoComplete.count)")
            return autoComplete.count
            
        } else {
            
            return 0
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Unfollow"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            if tableView == feedTable {
                
                let query = PFQuery(className: "Followers")
                
                query.whereKey("followerUsername", equalTo: (PFUser.current()?.username!)!)
                query.whereKey("followedUsername", equalTo: self.followedUserDictionaryArray[indexPath.row]["Username"] as! String)
                
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if error != nil {
                        
                        print("error = \(error as Any)")
                        
                        DispatchQueue.main.async {
                            self.displayAlert(title: "Error", message: "Unable to unfollow. Please check your connection and try again later.")
                        }
                        
                    } else {
                        
                        
                        
                        if let objects = objects {
                            
                            if objects.count < 1 {
                                
                                self.followedUserDictionaryArray.remove(at: indexPath.row)
                                DispatchQueue.main.async {
                                    self.feedTable.deleteRows(at: [indexPath], with: .fade)
                                    self.feedTable.reloadData()
                                }
                                
                                for (index, user) in self.followedUserDictionaryArray.enumerated() {
                                    
                                    
                                    self.followedUserDictionaryArray[index]["Profile Image"] = ""
                                }
                                
                                UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
                                
                                
                            } else{
                                
                                for object in objects {
                                    
                                    print("object = \(object)")
                                    
                                    self.displayAlert(title: "\(NSLocalizedString("You unfollowed", comment: "")) \(self.followedUserDictionaryArray[indexPath.row]["Username"] as! String)", message: "")
                                    
                                    self.followedUserDictionaryArray.remove(at: indexPath.row)
                                    DispatchQueue.main.async {
                                        
                                        UIView.animate(withDuration: 0.5, animations: {
                                            self.feedTable.deleteRows(at: [indexPath], with: .fade)
                                        }, completion: { _ in
                                            self.feedTable.reloadData()
                                        })
                                        
                                        
                                    }
                                    
                                    for (index, user) in self.followedUserDictionaryArray.enumerated() {
                                        
                                        
                                        self.followedUserDictionaryArray[index]["Profile Image"] = ""
                                    }
                                    
                                    UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
                                    //self.createDictionaryArray()
                                    
                                    object.deleteInBackground()
                                    
                                    
                                    
                                    
                                }
                            }
                            
                            
                        }
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.autoCompleteTable {
            
            let selectedUser = autoComplete[indexPath.row]
            print("selectedUser = \(selectedUser)")
            
            self.autoCompleteTable.isHidden = true
            self.searchBar.isHidden = true
            //self.activityIndicator.stopAnimating()
            //UIApplication.shared.endIgnoringInteractionEvents()
            self.searchBar.resignFirstResponder()
            
            
            let dictionary = [
                
                "Username":"\(selectedUser)",
                "Profile Image":""
                
            ]
            
            self.followedUserDictionaryArray.append(dictionary)
            
            for (index, user) in followedUserDictionaryArray.enumerated() {
                
                self.followedUserDictionaryArray[index]["Profile Image"] = ""
            }
            
            UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
            self.createDictionaryArray()
            self.feedTable.reloadData()
            
            let query = PFUser.query()
            
            query?.whereKey("username", equalTo: selectedUser)
            
            query?.findObjectsInBackground(block: { (objects, error) in
                
                if let users = objects {
                    
                    for user in users {
                        
                        let following = PFObject(className: "Followers")
                        following["followerUsername"] = PFUser.current()?.username
                        following["followedUsername"] = user["username"]
                        
                        
                        following.saveInBackground { (success, error) in
                            
                            if success == true {
                                
                                self.displayAlert(title: "\(NSLocalizedString("You are now following", comment: "")) \(user["username"]!)", message: "")
                                self.refresh()
                                self.updateProfileImages()
                                
                            } else {
                                
                                print("error = \(String(describing: error))")
                                
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            })
            
            autoCompleteTable.isHidden = true
            
        }
        
        }
    
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        
        let translation = gestureRecognizer.translation(in: self.locationPermissionSettings)
        
        let locationSettingsView = gestureRecognizer.view!
        
        locationSettingsView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        let xFromCenter = locationSettingsView.center.x - self.view.bounds.width / 2
        let yFromCenter = locationSettingsView.center.y - self.view.bounds.width / 2
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            if yFromCenter >= 200 {
                
                print("swiped down")
                
            }
            
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            if yFromCenter <= 100 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    locationSettingsView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                    
                }) { _ in
                    
                    print("swiped up")
                    
                }
                
            }
            
            if yFromCenter >= 200 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.locationPermissionSettings.alpha = 0
                    self.blurEffectView.alpha = 0
                    self.blurEffectView.removeFromSuperview()
                    self.locationPermissionSettings.removeFromSuperview()
                    
                }) { _ in
                    
                    
                    print("swiped down")
                    
                }
                
                
                
            }
            
            if xFromCenter >= 50 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    locationSettingsView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                    
                }) { _ in
                    
                    
                    print("right")
                    
                }
                
            }
            
            if xFromCenter <= -50 {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    locationSettingsView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                    
                }) { _ in
                    
                    print("left")
                    
                }
                
            }
            
        }
        
        print(translation)
        
    }
    
    func updatePermission() {
        
        self.addActivityIndicatorCenter()
        let userPermissionQuery = PFQuery(className: "MyLocationPermission")
        
        userPermissionQuery.whereKey("followerUsername", equalTo: self.followedUsername)
        userPermissionQuery.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        userPermissionQuery.findObjectsInBackground { (objects, error) in
            
            if error != nil {
              
                self.activityIndicator.stopAnimating()
                   UIApplication.shared.endIgnoringInteractionEvents()
                self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: error as! String)
                
            } else {
                
                if (objects?.count)! > 0 {
                  
                    for permission in objects! {
                        
                        permission.deleteInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                //alert unable to update settings try again later
                                print("alert unable to update settings try again later")
                                self.activityIndicator.stopAnimating()
                   UIApplication.shared.endIgnoringInteractionEvents()
                                self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: error as! String)
                                
                            } else {
                                
                                //previous permission deleted
                                print("previous permission deleted")
                                self.activityIndicator.stopAnimating()
                   UIApplication.shared.endIgnoringInteractionEvents()
                                
                                
                                
                            }
                        })
                    }
                    
                } else {
                    
                   self.activityIndicator.stopAnimating()
                   UIApplication.shared.endIgnoringInteractionEvents()
                }
                
                
            }
            
        }
        
        //create updated one
        print("create updated one")
        
        let userPermision = PFObject(className: "MyLocationPermission")
        
        userPermision["followerUsername"] = self.followedUsername!
        userPermision["username"] = PFUser.current()?.username!
        userPermision["userPermission"] = self.locationPermissionSettings.shareLocation.isOn
        
        print("userpermission = \(self.locationPermissionSettings.shareLocation.isOn)")
        
        userPermision.saveInBackground(block: { (success, error) in
            
            if error != nil {
                
                UIApplication.shared.endIgnoringInteractionEvents()
                
                let alert = UIAlertController(title: NSLocalizedString("Unable to share location.", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.blurEffectView.alpha = 0
                        self.locationPermissionSettings.alpha = 0
                        self.blurEffectView.removeFromSuperview()
                        self.locationPermissionSettings.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                        
                    }) { _ in
                        
                        
                        
                        
                    }
                    
                }))

                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                if self.locationPermissionSettings.shareLocation.isOn == true {
                    
                    self.locationManager = CLLocationManager()
                    self.locationManager.delegate = self
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    
                    
                    if CLLocationManager.locationServicesEnabled() {
                        
                        switch(CLLocationManager.authorizationStatus()) {
                            
                        case .notDetermined, .restricted, .denied:
                            
                            print("No access")
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "You have not allowed TripKey to see your location." , message: "In order for the share location feature to work TripKey needs to know your current location. Please tap settings and update the location permission for TripKey.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                                    
                                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                                        UIApplication.shared.openURL(url as URL)
                                    }
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                
                                
                                
                            }
                            
                            self.locationManager.startUpdatingLocation()
                            
                        case .authorizedAlways:
                            
                            print("Always Access")
                            self.locationManager.startUpdatingLocation()
                            self.userTappedShareLocation()
                            
                        case .authorizedWhenInUse:
                            
                            print("When in use")
                            
                            self.locationManager.startUpdatingLocation()
                            self.userTappedShareLocation()
                        }
                        
                        
                        
                    }
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                  
                    
                    
                } else {
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    self.locationManager.stopUpdatingLocation()
                    
                    let alert = UIAlertController(title: NSLocalizedString("You have not given", comment: "") + "\(self.followedUsername!)" + NSLocalizedString("permission to see your location", comment: ""), message: "\(self.followedUsername!)" + NSLocalizedString(" will not be able to see your location, you can change the permission at any time.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                        
                        
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            self.blurEffectView.alpha = 0
                            self.locationPermissionSettings.alpha = 0
                            self.blurEffectView.removeFromSuperview()
                            self.locationPermissionSettings.removeFromSuperview()
                            self.activityIndicator.stopAnimating()
                            
                        }) { _ in
                            
                            
                            
                            
                        }
                        
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                        
                        self.addActivityIndicatorCenter()
                        let followedUserPermissionQuery = PFQuery(className: "MyLocationPermission")
                        
                        followedUserPermissionQuery.whereKey("followerUsername", equalTo: self.followedUsername!)
                        followedUserPermissionQuery.whereKey("username", equalTo: (PFUser.current()?.username)!)
                        
                        followedUserPermissionQuery.findObjectsInBackground(block: { (objects, error) in
                            
                            if let permissions = objects {
                                
                                for permission in permissions {
                                    
                                    permission.deleteInBackground(block: { (success, error) in
                                        
                                        if error != nil {
                                            
                                            print("error = \(String(describing: error))")
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            
                                        } else {
                                            
                                            print("deleted permission")
                                            
                                            UIView.animate(withDuration: 0.5, animations: {
                                                
                                                self.blurEffectView.alpha = 0
                                                self.locationPermissionSettings.alpha = 0
                                                self.blurEffectView.removeFromSuperview()
                                                self.locationPermissionSettings.removeFromSuperview()
                                                self.activityIndicator.stopAnimating()
                                                
                                            }) { _ in
                                                
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                
                                                
                                            }
                                            
                                        }
                                    })
                                }
                            }
                        })
                        
                     self.activityIndicator.stopAnimating()
                     UIApplication.shared.endIgnoringInteractionEvents()
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                
                
            }
            
        })
        
    }
    
    func userTappedShareLocation() {
        
        let alert = UIAlertController(title: NSLocalizedString("You have allowed", comment: "") + " \(self.followedUsername!)" + NSLocalizedString(" to see your location.", comment: "") , message: NSLocalizedString("You can remove permission at any time.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let getUserFCM = PFUser.query()
        print("let getUserFCM = PFUser.query()")
        
        getUserFCM?.whereKey("username", equalTo: self.followedUsername!)
        
        
        getUserFCM?.findObjectsInBackground { (tokens, error) in
            
            if error != nil {
                
                print("error = \(String(describing: error))")
                
            } else {
                
                print("tokens = \(String(describing: tokens))")
                
                for token in tokens! {
                    
                    if let fcmToken = token["firebaseToken"] as? String {
                        
                        let username = (PFUser.current()?.username)!
                        
                        if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
                            
                            var request = URLRequest(url: url)
                            request.allHTTPHeaderFields = ["Content-Type":"application/json", "Authorization":"key=AAAASkgYWy4:APA91bFMTuMvXfwcVJbsKJqyBitkb9EUpvaHOkciT5wvtVHsaWmhxfLpqysRIdjgRaEDWKcb9tD5WCvqz67EvDyeSGswL-IEacN54UpVT8bhK1iAvKDvicOge6I6qaZDu8tAHOvzyjHs"]
                            request.httpMethod = "POST"
                            request.httpBody = "{\"to\":\"\(fcmToken)\",\"priority\":\"high\",\"notification\":{\"body\":\"\(username) shared their location with you.\"}}".data(using: .utf8)
                            
                            URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                                
                                if error != nil {
                                    
                                    print(error!)
                                }
                                
                                
                            }).resume()
                            
                        }
                        
                    } else {
                        
                        //user has not enabled notifications
                    }
                    
                }
            }
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.blurEffectView.alpha = 0
                self.locationPermissionSettings.alpha = 0
                self.blurEffectView.removeFromSuperview()
                self.locationPermissionSettings.removeFromSuperview()
                self.activityIndicator.stopAnimating()
                
            }) { _ in
                
                
                
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
            
            self.locationManager.stopUpdatingLocation()
            
            let followedUserPermissionQuery = PFQuery(className: "MyLocationPermission")
            
            followedUserPermissionQuery.whereKey("followerUsername", equalTo: self.followedUsername!)
            followedUserPermissionQuery.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            followedUserPermissionQuery.findObjectsInBackground(block: { (objects, error) in
                
                if let permissions = objects {
                    
                    for permission in permissions {
                        
                        permission.deleteInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                print("error = \(error as Any)")
                                
                            } else {
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    
                                    self.blurEffectView.alpha = 0
                                    self.locationPermissionSettings.alpha = 0
                                    self.blurEffectView.removeFromSuperview()
                                    self.locationPermissionSettings.removeFromSuperview()
                                    self.activityIndicator.stopAnimating()
                                    
                                }) { _ in
                                    
                                    
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    
                                }
                                
                            }
                        })
                    }
                }
            })
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addActivityIndicatorCenter() {
        
        //UIApplication.shared.beginIgnoringInteractionEvents()
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        //activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    func updateProfileImages() {
        print("updateProfileImages")
        
        if self.followedUserDictionaryArray.count > 0 {
            
            
            for (index, user) in self.followedUserDictionaryArray.enumerated() {
                
                let username = user["Username"] as! String
                
                let query = PFQuery(className: "Posts")
                
                query.whereKey("username", equalTo: username)
                
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if error != nil {
                        
                        print("error")
                        
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            self.addUserButton.isEnabled = true
                            self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline", comment: ""))
                        }
                        
                        
                    } else {
                        
                        for object in objects! {
                            
                            if let post = object as? PFObject {
                                
                                (post["imageFile"] as! PFFile).getDataInBackground { (data, error) in
                                    
                                    if let imageData = data {
                                        
                                        if let downloadedImage = UIImage(data: imageData) {
                                            
                                            if self.followedUserDictionaryArray.count > 0 {
                                                
                                              self.followedUserDictionaryArray[index]["Profile Image"] = downloadedImage
                                                
                                            }
                                            
                                            
                                            
                                            self.feedTable.reloadData()
                                            
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                })
                
            }
           
        }
        
    }
    
    func createDictionaryArray() {
        
        print("createDictionaryArray")
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            self.followedUserDictionaryArray = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
            let sortedArray = (self.followedUserDictionaryArray as NSArray).sortedArray(using: [NSSortDescriptor(key: "Username", ascending: true)]) as! [[String:AnyObject]]
                
            self.followedUserDictionaryArray = sortedArray
            self.feedTable.reloadData()
            
        } else {
            
            self.followedUserDictionaryArray.removeAll()
            self.feedTable.reloadData()
            self.refresh()
        }
    }
 

}
