//
//  UserAddedPlacesViewController.swift
//  TripKey2
//
//  Created by Peter on 2/20/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import MapKit
import Parse
import SystemConfiguration

class UserAddedPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    var filteredArray = [Dictionary<String,String>]()
    var connected:Bool!
    var indexPath:Int!
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    //let addCategory = Bundle.main.loadNibNamed("AddCategory", owner: self, options: nil)?[0] as! AddCategory
    //let addNotesView = Bundle.main.loadNibNamed("addPlaceNotes", owner: self, options: nil)?[0] as! addPlaceNotes
    let editPlaceInfoView = Bundle.main.loadNibNamed("editPlaceInfoView", owner: self, options: nil)?[0] as! editPlaceInfoView
    var activityIndicator:UIActivityIndicatorView!
    var refresher: UIRefreshControl!
    var sortedPlaces = [Dictionary<String,String>]()
    var flights = [Dictionary<String,String>]()
    var placeNameArray:[String] = []
    var placeLatitudeArray:[Double] = []
    var placeLongitudeArray:[Double] = []
    var placePhoneNumberArray:[String] = []
    var placeAddressArray:[String] = []
    var placeWebsiteArray:[String] = []
    var placeTypeArray:[String] = []
    var placeIdArray:[String] = []
    var userAddedPlaceDictionaryArray = [Dictionary<String,String>]()
    var textField:UITextView!
    var users = [String: String]()
    var userNames = [String]()
    
    @IBOutlet var userPlaceTable: UITableView!
    
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

    
    @IBAction func searchPlaces(_ sender: Any) {
        
        
        let alert = UIAlertController(title: NSLocalizedString("Search places by:", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString(NSLocalizedString("Name", comment: ""), comment: ""), style: .default, handler: { (action) in
            
            let alert = UIAlertController(title: NSLocalizedString("Search by Name", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            
            self.filteredArray.removeAll()
            var buttonArray = [String]()
            var uniqueButtonArray = [String]()
            buttonArray.removeAll()
            uniqueButtonArray.removeAll()
            
            for place in self.userAddedPlaceDictionaryArray {
                
                buttonArray.append(place["Place Name"]!)
                
                uniqueButtonArray = Array(Set(buttonArray))
                
            }
            
            for button in uniqueButtonArray {
                
                if button != "" {
                    
                    alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
                        
                        self.filteredArray.removeAll()
                        
                        for place in self.userAddedPlaceDictionaryArray {
                            
                            if button == place["Place Name"] {
                                
                                self.filteredArray.append(place)
                                self.userAddedPlaceDictionaryArray = self.filteredArray
                                
                                DispatchQueue.main.async {
                                    self.userPlaceTable.reloadData()
                                }
                                
                            }
                            
                            
                            
                        }
                        
                    }))
                    
                }
                
                
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                self.userPlaceTable.reloadData()
                self.filteredArray.removeAll()
                
            }))
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            
            self.present(alert, animated: true, completion: nil)

            
        }))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Type", comment: ""), style: .default, handler: { (action) in
            
            let alert = UIAlertController(title: NSLocalizedString("Search by type", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            self.filteredArray.removeAll()
            var buttonArray = [String]()
            var uniqueButtonArray = [String]()
            buttonArray.removeAll()
            uniqueButtonArray.removeAll()
            
            for place in self.userAddedPlaceDictionaryArray {
                
                if place["Place Type"] != nil && place["Place Type"] != "" && place["Place Type"] != "N/A" {
                    
                    buttonArray.append(place["Place Type"]!)
                    
                    uniqueButtonArray = Array(Set(buttonArray))
                }
                
                
                
            }
            
            for button in uniqueButtonArray {
                
                alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
                    
                    self.filteredArray.removeAll()
                    
                    for place in self.userAddedPlaceDictionaryArray {
                        
                        
                        
                        if button == place["Place Type"] {
                            
                            self.filteredArray.append(place)
                            self.userAddedPlaceDictionaryArray = self.filteredArray
                            
                            DispatchQueue.main.async {
                                self.userPlaceTable.reloadData()
                            }
                            
                        }
                        
                        
                        
                    }
                    
                }))
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                self.userPlaceTable.reloadData()
                self.filteredArray.removeAll()
                
            }))
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            
            self.present(alert, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Country", comment: ""), style: .default, handler: { (action) in
            
            let alert = UIAlertController(title: NSLocalizedString("Search by Country", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            self.filteredArray.removeAll()
            var buttonArray = [String]()
            var uniqueButtonArray = [String]()
            buttonArray.removeAll()
            uniqueButtonArray.removeAll()
            
            for place in self.userAddedPlaceDictionaryArray {
                
                if place["Place Country"] != nil && place["Place Country"] != "" {
                    
                    buttonArray.append(place["Place Country"]!)
                    
                    uniqueButtonArray = Array(Set(buttonArray))
                }
                
                
                
            }
            
            for button in uniqueButtonArray {
                
                if button != "" {
                    
                    alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
                        
                        self.filteredArray.removeAll()
                        
                        for place in self.userAddedPlaceDictionaryArray {
                            
                            
                            
                            if button == place["Place Country"] {
                                
                                self.filteredArray.append(place)
                                self.userAddedPlaceDictionaryArray = self.filteredArray
                                
                                DispatchQueue.main.async {
                                    self.userPlaceTable.reloadData()
                                }
                                
                            }
                            
                            
                            
                        }
                        
                    }))
                    
                }
                
                
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                self.userPlaceTable.reloadData()
                self.filteredArray.removeAll()
                
            }))
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            
            self.present(alert, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("City", comment: ""), style: .default, handler: { (action) in
            
            let alert = UIAlertController(title: NSLocalizedString("Search by City", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            self.filteredArray.removeAll()
            var buttonArray = [String]()
            var uniqueButtonArray = [String]()
            buttonArray.removeAll()
            uniqueButtonArray.removeAll()
            
            for place in self.userAddedPlaceDictionaryArray {
                
                buttonArray.append(place["Place City"]!)
                
                uniqueButtonArray = Array(Set(buttonArray))
                
            }
            
            for button in uniqueButtonArray {
                
                if button != "" {
                    
                    alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
                        
                        self.filteredArray.removeAll()
                        
                        for place in self.userAddedPlaceDictionaryArray {
                            
                            
                            
                            if button == place["Place City"] {
                                
                                self.filteredArray.append(place)
                                self.userAddedPlaceDictionaryArray = self.filteredArray
                                
                                DispatchQueue.main.async {
                                    self.userPlaceTable.reloadData()
                                }
                                
                            }
                            
                            
                            
                        }
                        
                    }))
                    
                }
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                self.userPlaceTable.reloadData()
                self.filteredArray.removeAll()
                
            }))
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            
            self.present(alert, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("All Places", comment: ""), style: .default, handler: { (action) in
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            self.userPlaceTable.reloadData()
            self.filteredArray.removeAll()
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
            self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            self.userPlaceTable.reloadData()
            self.filteredArray.removeAll()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func action(_ sender: Any) {
        
        if self.isUserLoggedIn() == true {
            
            let alert = UIAlertController(title: NSLocalizedString("Cloud actions", comment: ""), message: NSLocalizedString("If you back up your places you will still be able to access all your saved locations even if you change phones.", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
            
            if self.userAddedPlaceDictionaryArray.count > 0 {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Back up to Cloud", comment: ""), style: .default, handler: { (action) in
                    
                    self.activityLabel.text = NSLocalizedString("Backing Up", comment: "")
                    self.addActivityIndicatorCenter()
                    
                    
                    let getBackedUpPlaceQuery = PFQuery(className: "BackedUpPlace")
                    
                    getBackedUpPlaceQuery.whereKey("fromUsername", equalTo: (PFUser.current()?.username)!)
                    
                    getBackedUpPlaceQuery.findObjectsInBackground { (backedUpPlaces, error) in
                        
                        if error != nil {
                            
                            print("error = \(error as Any)")
                            
                            DispatchQueue.main.async {
                                
                                self.activityIndicator.stopAnimating()
                                self.activityLabel.removeFromSuperview()
                                self.blurEffectViewActivity.removeFromSuperview()
                                
                                self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Try again later.", comment: ""))
                            }
                            
                            
                            
                            
                        } else {
                            
                            if (backedUpPlaces?.count)! > 0 {
                                
                                for place in backedUpPlaces! {
                                    
                                    
                                    place.deleteInBackground(block: { (success, error) in
                                        
                                        if error != nil {
                                            
                                            print("error = \(error as Any)")
                                            self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Try again later.", comment: ""))
                                            
                                        } else {
                                            
                                            print("place deleted")
                                            
                                        }
                                        
                                    })
                                    
                                }
                                
                                for place in self.userAddedPlaceDictionaryArray {
                                    
                                    let backedUpPlace = PFObject(className: "BackedUpPlace")
                                    
                                    let placeName = place["Place Name"]
                                    let placeId = place["Place ID"]
                                    let placePhoneNumber = place["Place Phone Number"]
                                    let placeWebsite = place["Place Website"]
                                    let placeAddress = place["Place Address"]
                                    let placeLatitude = place["Place Latitude"]
                                    let placeLongitude = place["Place Longitude"]
                                    let placeType = place["Place Type"]
                                    let placeCountry = place["Place Country"]
                                    let placeCity = place["Place City"]
                                    let placeState = place["Place State"]
                                    let placeNotes = place["Place Notes"]
                                    
                                    
                                    
                                    backedUpPlace["fromUsername"] = PFUser.current()?.username
                                    backedUpPlace["placeName"] = placeName
                                    backedUpPlace["placeId"] = placeId
                                    backedUpPlace["placePhoneNumber"] = placePhoneNumber
                                    backedUpPlace["placeWebsite"] = placeWebsite
                                    backedUpPlace["placeAddress"] = placeAddress
                                    backedUpPlace["placeLatitude"] = placeLatitude
                                    backedUpPlace["placeLongitude"] = placeLongitude
                                    backedUpPlace["placeType"] = placeType
                                    backedUpPlace["placeCountry"] = placeCountry
                                    backedUpPlace["placeCity"] = placeCity
                                    backedUpPlace["placeState"] = placeState
                                    backedUpPlace["placeNotes"] = placeNotes
                                    
                                    backedUpPlace.saveInBackground(block: { (success, error) in
                                        
                                        if error != nil {
                                            
                                            DispatchQueue.main.async {
                                                self.displayAlert(title: NSLocalizedString("Could not back place up.", comment: ""), message: NSLocalizedString("Please try again later.", comment: ""))
                                            }
                                            
                                            
                                            
                                        } else {
                                            
                                            print("place backed up")
                                            
                                        }
                                    })
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    self.activityIndicator.stopAnimating()
                                    self.activityLabel.removeFromSuperview()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    self.displayAlert(title: NSLocalizedString("Places backed up", comment: ""), message: "")
                                    
                                    
                                }
                                
                            } else {
                                
                                for place in self.userAddedPlaceDictionaryArray {
                                    
                                    let backedUpPlace = PFObject(className: "BackedUpPlace")
                                    
                                    let placeName = place["Place Name"]
                                    let placeId = place["Place ID"]
                                    let placePhoneNumber = place["Place Phone Number"]
                                    let placeWebsite = place["Place Website"]
                                    let placeAddress = place["Place Address"]
                                    let placeLatitude = place["Place Latitude"]
                                    let placeLongitude = place["Place Longitude"]
                                    let placeType = place["Place Type"]
                                    let placeCountry = place["Place Country"]
                                    let placeCity = place["Place City"]
                                    let placeState = place["Place State"]
                                    let placeNotes = place["Place Notes"]
                                    
                                    
                                    
                                    backedUpPlace["fromUsername"] = PFUser.current()?.username
                                    backedUpPlace["placeName"] = placeName
                                    backedUpPlace["placeId"] = placeId
                                    backedUpPlace["placePhoneNumber"] = placePhoneNumber
                                    backedUpPlace["placeWebsite"] = placeWebsite
                                    backedUpPlace["placeAddress"] = placeAddress
                                    backedUpPlace["placeLatitude"] = placeLatitude
                                    backedUpPlace["placeLongitude"] = placeLongitude
                                    backedUpPlace["placeType"] = placeType
                                    backedUpPlace["placeCountry"] = placeCountry
                                    backedUpPlace["placeCity"] = placeCity
                                    backedUpPlace["placeState"] = placeState
                                    backedUpPlace["placeNotes"] = placeNotes
                                    
                                    backedUpPlace.saveInBackground(block: { (success, error) in
                                        
                                        if error != nil {
                                            
                                            DispatchQueue.main.async {
                                                self.displayAlert(title: NSLocalizedString("Could not back place up.", comment: ""), message: NSLocalizedString("Please try again later.", comment: ""))
                                            }
                                            
                                            
                                            
                                        } else {
                                            
                                            print("place backed up")
                                            
                                        }
                                    })
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.activityLabel.removeFromSuperview()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    
                                    self.displayAlert(title: NSLocalizedString("Places backed up", comment: ""), message: "")
                                    
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    
                }))  
            }
            
            
            
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Download Places From Cloud", comment: ""), style: .default, handler: { (action) in
                
                let alert = UIAlertController(title: NSLocalizedString("This will upload all backed up places", comment: ""), message: NSLocalizedString("Are you sure you want to continue?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
                    
                    DispatchQueue.main.async {
                        
                        self.activityLabel.text = NSLocalizedString("Downloading", comment: "")
                        self.addActivityIndicatorCenter()
                        
                    }
                    
                    let getBackedUpPlaceQuery = PFQuery(className: "BackedUpPlace")
                    
                    getBackedUpPlaceQuery.whereKey("fromUsername", equalTo: (PFUser.current()?.username)!)
                    
                    getBackedUpPlaceQuery.findObjectsInBackground { (backedUpPlaces, error) in
                        
                        if error != nil {
                            
                            print("error = \(error as Any)")
                            
                            DispatchQueue.main.async {
                                
                                self.activityIndicator.stopAnimating()
                                self.activityLabel.removeFromSuperview()
                                self.blurEffectViewActivity.removeFromSuperview()
                                self.displayAlert(title: NSLocalizedString("Unable to download all places.", comment: ""), message: NSLocalizedString("Try again later.", comment: ""))
                                
                            }
                            
                        } else {
                            
                            if (backedUpPlaces?.count)! > 0 {
                                
                                for place in backedUpPlaces! {
                                    
                                    print("place = \(place)")
                                    
                                    var userAddedPlaceDictionary:Dictionary<String,String>!
                                    
                                    userAddedPlaceDictionary = [
                                        
                                        "Place Name":"\(place["placeName"]!)",
                                        "Place Type":"\(place["placeType"]!)",
                                        "Place Website":"\(place["placeWebsite"]!)",
                                        "Place Phone Number":"\(place["placePhoneNumber"]!)",
                                        "Place Address":"\(place["placeAddress"]!)",
                                        "Place ID":"\(place["placeId"]!)",
                                        "Place Latitude":"\(place["placeLatitude"]!)",
                                        "Place Longitude":"\(place["placeLongitude"]!)",
                                        "Place Country":"\(place["placeCountry"]!)",
                                        "Place City":"\(place["placeCity"]!)",
                                        "Place Notes":"\(place["placeNotes"]!)",
                                        "Place State":"\(place["placeState"]!)",
                                        "Distance":""
                                    ]
                                    
                                    self.userAddedPlaceDictionaryArray.append(userAddedPlaceDictionary)
                                    
                                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    self.createArrays()
                                    self.userPlaceTable.reloadData()
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.activityLabel.removeFromSuperview()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    
                                }
                                
                                
                            } else {
                                
                                DispatchQueue.main.async {
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.activityLabel.removeFromSuperview()
                                    self.blurEffectViewActivity.removeFromSuperview()
                                    self.displayAlert(title: NSLocalizedString("You don't have any backed up places.", comment: ""), message: "")
                                    
                                }
                            }
                            
                            
                            
                            
                            
                        }
                        
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            
            self.promptUserToLogIn()
        }
        
        
 
        
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
            
            let alert = UIAlertController(title: NSLocalizedString("You are not logged in.", comment: ""), message: NSLocalizedString("Please log in to share and access \"Community\" and \"Cloud\" features.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("No Thanks", comment: ""), style: .default, handler: { (action) in
                
                
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Log In", comment: ""), style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "logIn", sender: self)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        
        dismiss(animated: true, completion: nil)
    }
    

    func refresh() {
        
        if self.isUserLoggedIn() == true {
           
            let getSharedPlaceQuery = PFQuery(className: "SharedPlace")
            
            getSharedPlaceQuery.whereKey("shareToUsername", equalTo: (PFUser.current()?.username)!)
            
            getSharedPlaceQuery.findObjectsInBackground { (sharedPlaces, error) in
                
                if error != nil {
                    
                    print("error = \(error as Any)")
                    self.refresher.endRefreshing()
                    
                } else {
                    
                    print("sharedPlace = \(sharedPlaces as Any)")
                    
                    
                    
                    for place in sharedPlaces! {
                        
                        var userAddedPlaceDictionary:Dictionary<String,String>!
                        
                        var placeCountry = ""
                        var placeCity = ""
                        var placeType = ""
                        
                        if place["placeCountry"] != nil {
                            
                            placeCountry = place["placeCountry"] as! String
                        }
                        
                        if place["placeCity"] != nil {
                            
                            placeCity = place["placeCity"] as! String
                        }
                        
                        if place["placeType"] != nil {
                            
                            placeType = place["placeType"] as! String
                        }
                        
                        userAddedPlaceDictionary = [
                            
                            "Place Name":"\(place["placeName"]!)",
                            "Place Type":"\(placeType)",
                            "Place Website":"\(place["placeWebsite"]!)",
                            "Place Phone Number":"\(place["placePhoneNumber"]!)",
                            "Place Address":"\(place["placeAddress"]!)",
                            "Place ID":"\(place["placeId"]!)",
                            "Place Latitude":"\(place["placeLatitude"]!)",
                            "Place Longitude":"\(place["placeLongitude"]!)",
                            "Place Country":"\(placeCountry)",
                            "Place City":"\(placeCity)"
                        ]
                        
                        self.userAddedPlaceDictionaryArray.append(userAddedPlaceDictionary)
                        
                        UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                        
                        self.deleteArrays()
                        self.sortPlacesByDistanceAway()
                        self.createArrays()
                        self.userPlaceTable.reloadData()
                        self.refresher.endRefreshing()
                        
                        place.deleteInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                print("error = \(error as Any)")
                                
                                
                            } else {
                                
                                print("place deleted")
                                
                            }
                            
                        })
                        
                        
                        
                    }
                    
                    
                    
                }
                
                self.refresher.endRefreshing()
                
            }
            
            self.sortPlacesByDistanceAway()
            self.filteredArray.removeAll()
            //userPlaceTable.reloadData()
            
        }
       
    }
    
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("userAddedPlacesViewController")
        
        isInternetAvailable()
        
        
        //addNotesView.addNotesTextView.delegate = self
        //addCategory.categoryTextField.delegate = self
        
        
        editPlaceInfoView.placeAddress.delegate = self
        editPlaceInfoView.placeCity.delegate = self
        editPlaceInfoView.placeLongitude.delegate = self
        editPlaceInfoView.placeLatitude.delegate = self
        editPlaceInfoView.placeWebsite.delegate = self
        editPlaceInfoView.placeState.delegate = self
        editPlaceInfoView.placePhoneNumber.delegate = self
        editPlaceInfoView.placeType.delegate = self
        editPlaceInfoView.placeName.delegate = self
        editPlaceInfoView.placeNotes.delegate = self
        
        
        userPlaceTable.delegate = self
        userPlaceTable.dataSource = self
        
        //addCategory.addButton.setTitle(NSLocalizedString("Save Type", comment: ""), for: .normal)
        //addCategory.cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        //addNotesView.cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        //addNotesView.save.setTitle(NSLocalizedString("Save Notes", comment: ""), for: .normal)
        
        
        editPlaceInfoView.nameLabel.adjustsFontSizeToFitWidth = true
        editPlaceInfoView.cityLabel.adjustsFontSizeToFitWidth = true
        editPlaceInfoView.countryLabel.adjustsFontSizeToFitWidth = true
        editPlaceInfoView.stateLabel.adjustsFontSizeToFitWidth = true
        
        editPlaceInfoView.editPlaceInfo.text = NSLocalizedString("Edit Place Info", comment: "")
        editPlaceInfoView.nameLabel.text = NSLocalizedString("Place Name:", comment: "")
        editPlaceInfoView.addressLabel.text = NSLocalizedString("Place Address: (optional)", comment: "")
        editPlaceInfoView.phoneNumberLabel.text = NSLocalizedString("Place Phone Number:", comment: "")
        editPlaceInfoView.websiteLabel.text = NSLocalizedString("Place Website:", comment: "")
        editPlaceInfoView.countryLabel.text = NSLocalizedString("Place Country:", comment: "")
        editPlaceInfoView.stateLabel.text = NSLocalizedString("Place State:", comment: "")
        editPlaceInfoView.cityLabel.text = NSLocalizedString("Place City:", comment: "")
        editPlaceInfoView.latitudeLabel.text = NSLocalizedString("Place Latitude", comment: "")
        editPlaceInfoView.longitudeLabel.text = NSLocalizedString("Place Longitude", comment: "")
        editPlaceInfoView.notesLabel.text = NSLocalizedString("Place Notes:", comment: "")
        editPlaceInfoView.typeLabel.text = NSLocalizedString("Place Type:", comment: "")
        editPlaceInfoView.cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        editPlaceInfoView.save.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        
        refresher.addTarget(self, action: #selector(CommunityFeedViewController.refresh), for: UIControlEvents.valueChanged)
        
        userPlaceTable.addSubview(refresher)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)

        
        
        
        
        
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        view.endEditing(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        self.editPlaceInfoView.endEditing(true)
        //self.addCategory.endEditing(true)
        //self.addNotesView.endEditing(true)
        textField.resignFirstResponder()
        return false
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.filteredArray.count > 0 {
            
            return self.filteredArray.count
            
        } else {
            
            return self.userAddedPlaceDictionaryArray.count
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let placeCell = tableView.dequeueReusableCell(withIdentifier: "userPlace", for: indexPath) as! userPlace
        
        //placeCell.callPlace.setTitle(NSLocalizedString("Call", comment: ""), for: .normal)
      //  placeCell.directionsButton.setTitle(NSLocalizedString("Directions", comment: ""), for: .normal)
       // placeCell.photos.setTitle(NSLocalizedString("Photos", comment: ""), for: .normal)
        //placeCell.addTypeButton.setTitle(NSLocalizedString("Type", comment: ""), for: .normal)
        //placeCell.shareButton.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
        //placeCell.editButton.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
       // placeCell.websiteButton.setTitle(NSLocalizedString("Website", comment: ""), for: .normal)
       // placeCell.mapButton.setTitle(NSLocalizedString("Map", comment: ""), for: .normal)
        //placeCell.notesButton.setTitle(NSLocalizedString("Notes", comment: ""), for: .normal)
        
        placeCell.addressLabel.text = NSLocalizedString("Address:", comment: "")
        
        placeCell.coordinatesLabel.text = NSLocalizedString("Coordinates:", comment: "")
        
        if self.filteredArray.count > 0 {
            
            placeCell.placeName.text = filteredArray[indexPath.row]["Place Name"]!
            placeCell.address.text = filteredArray[indexPath.row]["Place Address"]!
            let placeLongitude = filteredArray[indexPath.row]["Place Longitude"]!
            let placeLatitude = filteredArray[indexPath.row]["Place Latitude"]!
            let placeCoordinates = CLLocation(latitude: Double(placeLatitude)!, longitude: Double(placeLongitude)!)
            
            var usersLatitude:Double!
            var usersLongitude:Double!
            
            if UserDefaults.standard.object(forKey: "usersLatitude") != nil {
                
                usersLatitude = UserDefaults.standard.object(forKey: "usersLatitude") as! Double!
                
                if UserDefaults.standard.object(forKey: "usersLongitude") != nil {
                    
                    usersLongitude = UserDefaults.standard.object(forKey: "usersLongitude") as! Double!
                    
                    let usersLocation:CLLocation = CLLocation(latitude: usersLatitude!, longitude: usersLongitude!)
                    
                    let distanceInMeters = placeCoordinates.distance(from: usersLocation)
                    let distanceInMiles = Double(distanceInMeters) * 0.000621371
                    let roundedDistance = String(round(10.0 * distanceInMiles) / 10.0)
                    placeCell.distance.text = "\(roundedDistance)\(NSLocalizedString(" miles from you", comment: ""))"
                    
                }
            } else {
                
                placeCell.distance.text = ""
                
            }
            
            
            placeCell.coordinates.text = "\(placeLatitude),\(placeLongitude)"
            
            
            
            
        } else {
            
            placeCell.placeName.text = userAddedPlaceDictionaryArray[indexPath.row]["Place Name"]!
            placeCell.address.text = userAddedPlaceDictionaryArray[indexPath.row]["Place Address"]!
            let placeLongitude = userAddedPlaceDictionaryArray[indexPath.row]["Place Longitude"]!
            let placeLatitude = userAddedPlaceDictionaryArray[indexPath.row]["Place Latitude"]!
            let placeCoordinates = CLLocation(latitude: Double(placeLatitude)!, longitude: Double(placeLongitude)!)
            placeCell.coordinates.text = "\(placeLatitude),\(placeLongitude)"
            var usersLatitude:Double!
            var usersLongitude:Double!
            
            if UserDefaults.standard.object(forKey: "usersLatitude") != nil {
                
                usersLatitude = UserDefaults.standard.object(forKey: "usersLatitude") as! Double!
                
                if UserDefaults.standard.object(forKey: "usersLongitude") != nil {
                    
                    usersLongitude = UserDefaults.standard.object(forKey: "usersLongitude") as! Double!
                    
                    let usersLocation:CLLocation = CLLocation(latitude: usersLatitude!, longitude: usersLongitude!)
                    
                    let distanceInMeters = placeCoordinates.distance(from: usersLocation)
                    let distanceInMiles = Double(distanceInMeters) * 0.000621371
                    let roundedDistance = String(round(10.0 * distanceInMiles) / 10.0)
                    placeCell.distance.text = "\(roundedDistance)\(NSLocalizedString(" miles from you", comment: ""))"
                    
                }
                
            } else {
                
                placeCell.distance.text = ""
                
            }
            
            
            
            
            
        }
        
        
        
        
        placeCell.tapCallAction = {
            
            (placeCell) in self.callPlace(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        }
        
        placeCell.tapShareAction = {
            
            (placeCell) in self.sharePlace(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        }
        
        placeCell.tapDirectionsAction = {
            
            (placeCell) in self.getDirections(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        }
        
        placeCell.tapWebsiteAction = {
            
            (placeCell) in self.getWebsite(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        }
        
        placeCell.tapMapAction = {
            
           (placeCell) in self.goToSelectedPlace(indexPath: (tableView.indexPath(for: placeCell)!.row))
        }
        
        placeCell.tapPhotoAction = {
            
           (placeCell) in self.goToPlaceOverview(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        }
        
        //placeCell.tapAddCategoryAction = {
            
            //(placeCell) in self.addCatgory(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        //}
        
        placeCell.tapEditAction = {
            
            (placeCell) in self.editPlaceInfo(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        }
        
        //placeCell.tapNotesAction = {
            
            //(placeCell) in self.editNote(indexPath: (tableView.indexPath(for: placeCell)!.row))
            
        //}
        
        
        
        
        
        
        
        
        
        
        
        
        return placeCell
            
        
        
    }
    
    
    
   

    
    func goToPlaceOverview(indexPath: Int) {
        
        print("goToPlaceOverview")
        
        
        
        var placeId:String!
        var latitude:Double!
        var longitude:Double!
        
        if self.filteredArray.isEmpty == true {
            
            longitude = Double(self.userAddedPlaceDictionaryArray[indexPath]["Place Longitude"]!)
            latitude = Double(self.userAddedPlaceDictionaryArray[indexPath]["Place Latitude"]!)
            placeId = self.userAddedPlaceDictionaryArray[indexPath]["Place ID"]!
            
            let placeDictionary = [
                
                "Place ID":"\(placeId!)"
                
            ]
            
            UserDefaults.standard.set(placeDictionary, forKey: "placeDictionaryForOverview")
            
            UserDefaults.standard.set(longitude, forKey: "selectedPlaceLongitude")
            UserDefaults.standard.set(latitude, forKey: "selectedPlaceLatitude")
            UserDefaults.standard.set(placeId, forKey: "placeId")
            UserDefaults.standard.set(indexPath, forKey: "index")
            
            performSegue(withIdentifier: "goToPlaceOverview", sender: self)
            
        } else {
            
            longitude = Double(self.filteredArray[indexPath]["Place Longitude"]!)
            latitude = Double(self.filteredArray[indexPath]["Place Latitude"]!)
            placeId = self.filteredArray[indexPath]["Place ID"]!
            
            let placeDictionary = [
                
                "Place ID":"\(placeId!)"
                
            ]
            
            UserDefaults.standard.set(placeDictionary, forKey: "placeDictionaryForOverview")
            
            UserDefaults.standard.set(longitude, forKey: "selectedPlaceLongitude")
            UserDefaults.standard.set(latitude, forKey: "selectedPlaceLatitude")
            UserDefaults.standard.set(placeId, forKey: "placeId")
            UserDefaults.standard.set(indexPath, forKey: "index")
            
            performSegue(withIdentifier: "goToPlaceOverview", sender: self)
            
        }
    }
    
    func goToSelectedPlace(indexPath: Int) {
        
        print("goToSelectedPlace")
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        if self.filteredArray.isEmpty == true {
            
            let longitude = Double(self.userAddedPlaceDictionaryArray[indexPath]["Place Longitude"]!)
            let latitude = Double(self.userAddedPlaceDictionaryArray[indexPath]["Place Latitude"]!)
            let placeId = self.userAddedPlaceDictionaryArray[indexPath]["Place ID"]!
            UserDefaults.standard.set(indexPath, forKey: "index")
            
            UserDefaults.standard.set(longitude, forKey: "selectedPlaceLongitude")
            UserDefaults.standard.set(latitude, forKey: "selectedPlaceLatitude")
            UserDefaults.standard.set(placeId, forKey: "placeId")
            UserDefaults.standard.set(true, forKey: "userSwipedBack")
             UserDefaults.standard.set(userAddedPlaceDictionaryArray, forKey: "placeDictionaries")
            
            dismiss(animated: true, completion: nil)
            
        } else {
            
            let longitude = Double(self.filteredArray[indexPath]["Place Longitude"]!)
            let latitude = Double(self.filteredArray[indexPath]["Place Latitude"]!)
            let placeId = self.filteredArray[indexPath]["Place ID"]!
           
            
            
            UserDefaults.standard.set(longitude, forKey: "selectedPlaceLongitude")
            UserDefaults.standard.set(latitude, forKey: "selectedPlaceLatitude")
            UserDefaults.standard.set(placeId, forKey: "placeId")
            UserDefaults.standard.set(indexPath, forKey: "index")
            
            UserDefaults.standard.set(true, forKey: "userSwipedBack")
            UserDefaults.standard.set(self.filteredArray, forKey: "placeDictionaries")
            dismiss(animated: true, completion: nil)
        }
        
        
        
    }
    
    func getWebsite(indexPath: Int) {
        
        print("getWebsite")
        
        if self.filteredArray.isEmpty == true {
         
            let website = self.userAddedPlaceDictionaryArray[indexPath]["Place Website"]!
            UserDefaults.standard.set(website, forKey: "urlString")
            
        } else {
            
            let website = self.filteredArray[indexPath]["Place Website"]!
            UserDefaults.standard.set(website, forKey: "urlString")
            
        }
        
     }
    
    func addCatgory(indexPath: Int) {
        /*
        print("addCategory")
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        self.userPlaceTable.reloadData()
        
        self.addCategory.frame = self.view.bounds
        self.addCategory.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.alpha = 0
        self.addCategory.alpha = 0
        self.addCategory.addButton.addTarget(self, action: #selector(self.saveCategory), for: .touchUpInside)
        self.addCategory.cancel.addTarget(self, action: #selector(self.cancelCategory), for: .touchUpInside)
        self.indexPath = indexPath
        
        if self.filteredArray.isEmpty == true {
            
            addCategory.label.text = "\(NSLocalizedString("Add a Place Type to", comment: "")) \(self.userAddedPlaceDictionaryArray[indexPath]["Place Name"]!)\n\n\(NSLocalizedString("Current Place Type = ", comment: ""))\(self.userAddedPlaceDictionaryArray[indexPath]["Place Type"]!)"
            
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.blurEffectView.alpha = 1
                self.addCategory.alpha = 1
                self.view.addSubview(self.blurEffectView)
                self.view.addSubview(self.addCategory)
                
                
            }) { _ in
                
                
            }
            
        } else {
            
            for (index, place) in self.userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place ID"] == self.filteredArray[indexPath]["Place ID"] {
                    
                    addCategory.label.text = "\(NSLocalizedString("Add a Place Type to ", comment: ""))\(place["Place Name"]!)\n\n\(NSLocalizedString("Current Place Type = ", comment: ""))\(place["Place Type"]!)"
                    
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.blurEffectView.alpha = 1
                        self.addCategory.alpha = 1
                        self.view.addSubview(self.blurEffectView)
                        self.view.addSubview(self.addCategory)
                        
                        
                    }) { _ in
                        
                        
                    }
                }
            }
            
            
        }
        
        
        
    */
    }
    /*
    func cancelCategory() {
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.addCategory.alpha = 0
            self.blurEffectView.alpha = 0
            
            
        }) { _ in
            
            self.blurEffectView.removeFromSuperview()
            self.addCategory.removeFromSuperview()
        }
    }
    
    func saveCategory() {
        
        print("saveCategory")
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        if self.filteredArray.isEmpty == true {
            
            for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place ID"] == userAddedPlaceDictionaryArray[self.indexPath]["Place ID"] {
                    
                    self.userAddedPlaceDictionaryArray[index]["Place Type"] = self.addCategory.categoryTextField.text!
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                }
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.addCategory.alpha = 0
                self.blurEffectView.alpha = 0
                
                
            }) { _ in
                
                //self.filteredArray.removeAll()
                self.addCategory.categoryTextField.text = ""
                self.blurEffectView.removeFromSuperview()
                self.addCategory.removeFromSuperview()
            }
            
            self.displayAlert(title: NSLocalizedString("Place Type added", comment: ""), message: "")
            //self.filteredArray.removeAll()
            //self.userPlaceTable.reloadData()
            
            
        } else {
            
            for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place ID"] == filteredArray[self.indexPath]["Place ID"] {
                    
                    self.userAddedPlaceDictionaryArray[index]["Place Type"] = self.addCategory.categoryTextField.text!
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.addCategory.alpha = 0
                        self.blurEffectView.alpha = 0
                        
                        
                    }) { _ in
                        
                        self.addCategory.categoryTextField.text = ""
                        self.blurEffectView.removeFromSuperview()
                        self.addCategory.removeFromSuperview()
                    }
                    
                    self.displayAlert(title: NSLocalizedString("Place Type added", comment: ""), message: "")
                    
                    
                }
            }
            
            
            
            
        }
        
        
        
    }
    */
    func sharePlace(indexPath: Int) {
        
        if self.isUserLoggedIn() == true {
            
            if self.filteredArray.isEmpty == true {
                
                let alert = UIAlertController(title: NSLocalizedString("Share place with", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                for user in self.userNames {
                    
                    alert.addAction(UIAlertAction(title: "\(user)", style: .default, handler: { (action) in
                        
                        
                        
                        let place = self.userAddedPlaceDictionaryArray[indexPath]
                        let placeName = place["Place Name"]
                        let placeId = place["Place ID"]
                        let placePhoneNumber = place["Place Phone Number"]
                        let placeWebsite = place["Place Website"]
                        let placeAddress = place["Place Address"]
                        let placeLatitude = place["Place Latitude"]
                        let placeLongitude = place["Place Longitude"]
                        let placeCountry = place["Place Country"]
                        let placeCity = place["Place City"]
                        
                        let sharedPlace = PFObject(className: "SharedPlace")
                        
                        sharedPlace["shareToUsername"] = user
                        sharedPlace["shareFromUsername"] = PFUser.current()?.username
                        sharedPlace["placeName"] = placeName
                        sharedPlace["placeId"] = placeId
                        sharedPlace["placePhoneNumber"] = placePhoneNumber
                        sharedPlace["placeWebsite"] = placeWebsite
                        sharedPlace["placeAddress"] = placeAddress
                        sharedPlace["placeLatitude"] = placeLatitude
                        sharedPlace["placeLongitude"] = placeLongitude
                        sharedPlace["placeCountry"] = placeCountry
                        sharedPlace["placeCity"] = placeCity
                        
                        sharedPlace.saveInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                let alert = UIAlertController(title: NSLocalizedString("Could not share place", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                                
                                let alert = UIAlertController(title: "\(NSLocalizedString("Place shared to", comment: "")) \(user)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                
                                let getUserFCM = PFUser.query()
                                
                                getUserFCM?.whereKey("username", equalTo: user)
                                
                                getUserFCM?.findObjectsInBackground { (tokens, error) in
                                    
                                    if error != nil {
                                        
                                        print("error = \(String(describing: error))")
                                        
                                    } else {
                                        
                                        for token in tokens! {
                                            
                                            if let fcmToken = token["firebaseToken"] as? String {
                                                
                                                let fcm = fcmToken.data(using: .utf8)!
                                                
                                                let username = (PFUser.current()?.username)!
                                                //let usernameData = username.data(using: .utf8)!
                                                
                                                //this is the code that runs to send the push as per the course
                                                if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
                                                    
                                                    var request = URLRequest(url: url)
                                                    request.allHTTPHeaderFields = ["Content-Type":"application/json", "Authorization":"key=AAAASkgYWy4:APA91bFMTuMvXfwcVJbsKJqyBitkb9EUpvaHOkciT5wvtVHsaWmhxfLpqysRIdjgRaEDWKcb9tD5WCvqz67EvDyeSGswL-IEacN54UpVT8bhK1iAvKDvicOge6I6qaZDu8tAHOvzyjHs"]
                                                    request.httpMethod = "POST"
                                                    request.httpBody = "{\"to\":\"\(fcmToken)\",\"priority\":\"high\",\"notification\":{\"body\":\"\(username) shared a place with you.\"}}".data(using: .utf8)
                                                    
                                                    URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                                                        
                                                        if error != nil {
                                                            
                                                            print(error!)
                                                        }
                                                        
                                                        //this prints success but no notification shows up on my device.
                                                        print("request data = \(String(data: data!, encoding: .utf8)!)")
                                                        
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
                
                
                print("shareplace")
                
                
                
            } else {
                
                let alert = UIAlertController(title: NSLocalizedString("Share place with", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                for user in self.userNames {
                    
                    alert.addAction(UIAlertAction(title: "\(user)", style: .default, handler: { (action) in
                        
                        
                        
                        let place = self.filteredArray[indexPath]
                        let placeName = place["Place Name"]
                        let placeId = place["Place ID"]
                        let placePhoneNumber = place["Place Phone Number"]
                        let placeWebsite = place["Place Website"]
                        let placeAddress = place["Place Address"]
                        let placeLatitude = place["Place Latitude"]
                        let placeLongitude = place["Place Longitude"]
                        let placeCountry = place["Place Country"]
                        let placeCity = place["Place City"]
                        
                        let sharedPlace = PFObject(className: "SharedPlace")
                        
                        sharedPlace["shareToUsername"] = user
                        sharedPlace["shareFromUsername"] = PFUser.current()?.username
                        sharedPlace["placeName"] = placeName
                        sharedPlace["placeId"] = placeId
                        sharedPlace["placePhoneNumber"] = placePhoneNumber
                        sharedPlace["placeWebsite"] = placeWebsite
                        sharedPlace["placeAddress"] = placeAddress
                        sharedPlace["placeLatitude"] = placeLatitude
                        sharedPlace["placeLongitude"] = placeLongitude
                        sharedPlace["placeCountry"] = placeCountry
                        sharedPlace["placeCity"] = placeCity
                        
                        sharedPlace.saveInBackground(block: { (success, error) in
                            
                            if error != nil {
                                
                                let alert = UIAlertController(title: NSLocalizedString("Could not share place", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                                
                                let alert = UIAlertController(title: "\(NSLocalizedString("Place shared to", comment: "")) \(user)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                
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
                
                
                print("shareplace")
                
                
            }

        } else {
            
            self.promptUserToLogIn()
        }
        
        
        }
    
    func getDirections(indexPath: Int) {
        
        var longitude:String!
        var latitude:String!
        
        if self.filteredArray.isEmpty == true {
           
            longitude = self.userAddedPlaceDictionaryArray[indexPath]["Place Longitude"]!
            latitude = self.userAddedPlaceDictionaryArray[indexPath]["Place Latitude"]!
            
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                
                let alert = UIAlertController(title: NSLocalizedString("Which map would you like to use?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Apple Maps", comment: ""), style: .default, handler: { (action) in
                    
                    
                    let coordinate = CLLocationCoordinate2DMake(Double(latitude)!,Double(longitude)!)
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                    mapItem.name = self.userAddedPlaceDictionaryArray[indexPath]["Place Name"]!
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
                let coordinate = CLLocationCoordinate2DMake(Double(latitude)!,Double(longitude)!)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                mapItem.name = self.userAddedPlaceDictionaryArray[indexPath]["Place Name"]!
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            }
            
        } else {
            
            longitude = self.filteredArray[indexPath]["Place Longitude"]!
            latitude = self.filteredArray[indexPath]["Place Latitude"]!
            
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                
                let alert = UIAlertController(title: NSLocalizedString("Which map would you like to use?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Apple Maps", comment: ""), style: .default, handler: { (action) in
                    
                    
                    let coordinate = CLLocationCoordinate2DMake(Double(latitude)!,Double(longitude)!)
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                    mapItem.name = self.filteredArray[indexPath]["Place Name"]!
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
                let coordinate = CLLocationCoordinate2DMake(Double(latitude)!,Double(longitude)!)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                mapItem.name = self.filteredArray[indexPath]["Place Name"]!
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            }
        }
        
        
        
        
        
    }
    
    func callPlace(indexPath: Int) {
        
        if self.filteredArray.isEmpty == true {
            
            let formattedPhoneNumber = self.userAddedPlaceDictionaryArray[indexPath]["Place Phone Number"]!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Phone Number"]! == "N/A" || self.userAddedPlaceDictionaryArray[indexPath]["Place Phone Number"]! == "" || self.userAddedPlaceDictionaryArray[indexPath]["Place Phone Number"]! == " na" {
                
                DispatchQueue.main.async {
                    self.displayAlert(title: NSLocalizedString("No phone number added for this place", comment: ""), message: "")
                }
                
                
                
            } else {
                
                let url = URL(string: "tel://+\(formattedPhoneNumber)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
            
        } else {
            
            let formattedPhoneNumber = self.filteredArray[indexPath]["Place Phone Number"]!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            
            if self.filteredArray[indexPath]["Place Phone Number"]! == "N/A" || self.filteredArray[indexPath]["Place Phone Number"]! == "" || self.filteredArray[indexPath]["Place Phone Number"]! == " na" {
                
                DispatchQueue.main.async {
                    self.displayAlert(title: NSLocalizedString("No phone number added for this place", comment: ""), message: "")
                }
                
                
                
            } else {
                
                let url = URL(string: "tel://+\(formattedPhoneNumber)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
            
        }
        
        
        
        
    }
    
    func editPlaceInfo(indexPath: Int) {
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        if self.filteredArray.isEmpty == true {
            
            self.editPlaceInfoView.frame = self.view.bounds
            self.editPlaceInfoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurEffectView.alpha = 0
            
            self.editPlaceInfoView.alpha = 0
            self.editPlaceInfoView.save.addTarget(self, action: #selector(self.savePlaceInfo), for: .touchUpInside)
            self.editPlaceInfoView.cancel.addTarget(self, action: #selector(self.cancelPlaceInfo), for: .touchUpInside)
            self.editPlaceInfoView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            self.indexPath = indexPath
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Address"] != nil {
                
                editPlaceInfoView.placeAddress.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Address"]!
                
            } else {
                
                editPlaceInfoView.placeAddress.text = ""
            }
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place City"] != nil {
                
                editPlaceInfoView.placeCity.text = self.userAddedPlaceDictionaryArray[indexPath]["Place City"]!
                
            } else {
                
                editPlaceInfoView.placeCity.text = ""
            }
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Country"] != nil {
                
                editPlaceInfoView.placeCountry.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Country"]!
                
            } else {
                
                editPlaceInfoView.placeCountry.text = ""
            }
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Website"] != nil {
                
                editPlaceInfoView.placeWebsite.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Website"]!
                
            } else {
                
                editPlaceInfoView.placeWebsite.text = ""
            }
            
            editPlaceInfoView.placeName.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Name"] as? String
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Type"] != nil {
                
                editPlaceInfoView.placeType.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Type"]!
                
            } else {
                
                editPlaceInfoView.placeType.text = ""
            }
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Notes"] != nil {
                
                editPlaceInfoView.placeNotes.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Notes"]!
                
            } else {
                
                editPlaceInfoView.placeNotes.text = ""
            }
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place State"] != nil {
                
                editPlaceInfoView.placeState.text = self.userAddedPlaceDictionaryArray[indexPath]["Place State"]!
                
            } else {
                
                editPlaceInfoView.placeState.text = ""
            }
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Phone Number"] != nil {
                
                editPlaceInfoView.placePhoneNumber.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Phone Number"]!
                
            } else {
                
                editPlaceInfoView.placePhoneNumber.text = ""
            }
            
            
            editPlaceInfoView.placeLatitude.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Latitude"]!
            editPlaceInfoView.placeLongitude.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Longitude"]!
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.blurEffectView.alpha = 1
                self.editPlaceInfoView.alpha = 1
                self.view.addSubview(self.blurEffectView)
                self.view.addSubview(self.editPlaceInfoView)
                
                
            }) { _ in
                
                
            }

            
        } else {
            
            
            
            self.editPlaceInfoView.frame = self.view.bounds
            self.editPlaceInfoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurEffectView.alpha = 0
            
            self.editPlaceInfoView.alpha = 0
            self.editPlaceInfoView.save.addTarget(self, action: #selector(self.savePlaceInfo), for: .touchUpInside)
            self.editPlaceInfoView.cancel.addTarget(self, action: #selector(self.cancelPlaceInfo), for: .touchUpInside)
            
            self.indexPath = indexPath
            
            for (_, place) in self.userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place ID"] == self.filteredArray[indexPath]["Place ID"] {
                    
                    if place["Place Address"] != nil {
                        
                        editPlaceInfoView.placeAddress.text = place["Place Address"]!
                        
                    } else {
                        
                        editPlaceInfoView.placeAddress.text = ""
                    }
                    
                    if place["Place City"] != nil {
                        
                        editPlaceInfoView.placeCity.text = place["Place City"]!
                        
                    } else {
                        
                        editPlaceInfoView.placeCity.text = ""
                    }
                    
                    if place["Place Country"] != nil {
                        
                        editPlaceInfoView.placeCountry.text = place["Place Country"]!
                        
                    } else {
                        
                        editPlaceInfoView.placeCountry.text = ""
                    }
                    
                    if place["Place Website"] != nil {
                        
                        editPlaceInfoView.placeWebsite.text = place["Place Website"]!
                        
                    } else {
                        
                        editPlaceInfoView.placeWebsite.text = ""
                    }
                    
                    editPlaceInfoView.placeName.text = place["Place Name"] as! String
                    
                    if place["Place Type"] != nil {
                        
                        editPlaceInfoView.placeType.text = place["Place Type"]!
                        
                    } else {
                        
                        editPlaceInfoView.placeType.text = ""
                    }
                    
                    if place["Place Notes"] != nil {
                        
                        editPlaceInfoView.placeNotes.text = place["Place Notes"]!
                        
                    } else {
                        
                        editPlaceInfoView.placeNotes.text = ""
                    }
                    
                    if place["Place State"] != nil {
                        
                        editPlaceInfoView.placeState.text = place["Place State"]!
                        
                    } else {
                        
                        editPlaceInfoView.placeState.text = ""
                    }
                    
                    if place["Place Phone Number"] != nil {
                        
                        editPlaceInfoView.placePhoneNumber.text = place["Place Phone Number"]!
                        
                    } else {
                        
                        editPlaceInfoView.placePhoneNumber.text = ""
                    }
                    
                    
                    editPlaceInfoView.placeLatitude.text = place["Place Latitude"]!
                    editPlaceInfoView.placeLongitude.text = place["Place Longitude"]!
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.blurEffectView.alpha = 1
                        self.editPlaceInfoView.alpha = 1
                        self.view.addSubview(self.blurEffectView)
                        self.view.addSubview(self.editPlaceInfoView)
                        
                        
                    }) { _ in
                        
                        
                    }

                    
                }
                
            }
            
            
            
            
        }
        
        
        
    }
    /*
    func editNote(indexPath: Int) {
        
        print("edit note")
        
        if filteredArray.isEmpty == true {
            
            if self.userAddedPlaceDictionaryArray[indexPath]["Place Notes"] != nil {
                
                //self.addNotesView.frame = self.view.bounds
                //self.addNotesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                self.blurEffectView.frame = self.view.bounds
                self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.blurEffectView.alpha = 0
                //self.addNotesView.alpha = 0
                //self.addNotesView.save.addTarget(self, action: #selector(self.saveNotes), for: .touchUpInside)
                //self.addNotesView.cancel.addTarget(self, action: #selector(self.cancelNotes), for: .touchUpInside)
                
                if self.addNotesView.addNotesTextView.text != nil {
                    
                    self.addNotesView.addNotesTextView.text = self.userAddedPlaceDictionaryArray[indexPath]["Place Notes"]!
                    
                }
                
                
                self.indexPath = indexPath
                addNotesView.addNotesTitleLabel.text = "\(NSLocalizedString("Add Notes to", comment: "")) \(self.userAddedPlaceDictionaryArray[indexPath]["Place Name"]!)"
                
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.blurEffectView.alpha = 1
                    self.addNotesView.alpha = 1
                    self.view.addSubview(self.blurEffectView)
                    self.view.addSubview(self.addNotesView)
                    
                    
                }) { _ in
                    
                    
                }
                
                
            } else {
                
                
                
                
                
            }
            
            
        } else {
            
            self.addNotesView.frame = self.view.bounds
            self.addNotesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurEffectView.alpha = 0
            self.addNotesView.alpha = 0
            self.addNotesView.save.addTarget(self, action: #selector(self.saveNotes), for: .touchUpInside)
            self.addNotesView.cancel.addTarget(self, action: #selector(self.cancelNotes), for: .touchUpInside)
            
            
            
            
            self.indexPath = indexPath
            
            for (_, place) in self.userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place ID"] == self.filteredArray[indexPath]["Place ID"] {
                    
                    addNotesView.addNotesTitleLabel.text = "\(NSLocalizedString("Add Notes to", comment: "")) \(place["Place Name"]!)"
                    
                    addNotesView.addNotesTextView.text = place["Place Notes"]!
                    
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.blurEffectView.alpha = 1
                        self.addNotesView.alpha = 1
                        self.view.addSubview(self.blurEffectView)
                        self.view.addSubview(self.addNotesView)
                        
                        
                    }) { _ in
                        
                        
                    }
                }
                
            }
            
        }
        
        
        
        
    }
    */
    
    
    func savePlaceInfo() {
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        if self.filteredArray.isEmpty == true {
            
            for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place Name"] == userAddedPlaceDictionaryArray[self.indexPath]["Place Name"] {
                    
                    
                    self.userAddedPlaceDictionaryArray[index]["Place Notes"] = self.editPlaceInfoView.placeNotes.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Name"] = self.editPlaceInfoView.placeName.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Address"] = self.editPlaceInfoView.placeAddress.text!
                    self.userAddedPlaceDictionaryArray[index]["Place City"] = self.editPlaceInfoView.placeCity.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Country"] = self.editPlaceInfoView.placeCountry.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Type"] = self.editPlaceInfoView.placeType.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Phone Number"] = self.editPlaceInfoView.placePhoneNumber.text!
                    self.userAddedPlaceDictionaryArray[index]["Place State"] = self.editPlaceInfoView.placeState.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Website"] = self.editPlaceInfoView.placeWebsite.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Latitude"] = self.editPlaceInfoView.placeLatitude.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Longitude"] = self.editPlaceInfoView.placeLongitude.text!
                    
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                    
                }
                
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.editPlaceInfoView.alpha = 0
                self.blurEffectView.alpha = 0
                
                
            }) { _ in
                
                self.editPlaceInfoView.placeNotes.text! = ""
                self.editPlaceInfoView.placeName.text! = ""
                self.editPlaceInfoView.placeAddress.text! = ""
                self.editPlaceInfoView.placeCity.text! = ""
                self.editPlaceInfoView.placeCountry.text! = ""
                self.editPlaceInfoView.placeType.text! = ""
                self.editPlaceInfoView.placePhoneNumber.text! = ""
                self.editPlaceInfoView.placeState.text! = ""
                self.editPlaceInfoView.placeWebsite.text! = ""
                self.editPlaceInfoView.placeLatitude.text! = ""
                self.editPlaceInfoView.placeLongitude.text! = ""
                
                self.blurEffectView.removeFromSuperview()
                self.editPlaceInfoView.removeFromSuperview()
                
            }
            
            self.displayAlert(title: NSLocalizedString("Place info saved", comment: ""), message: "")
            
            //self.filteredArray.removeAll()
            userPlaceTable.reloadData()
            
        } else {
            
            for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place Name"] == self.filteredArray[self.indexPath]["Place Name"] {
                    
                    
                    self.userAddedPlaceDictionaryArray[index]["Place Notes"] = self.editPlaceInfoView.placeNotes.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Name"] = self.editPlaceInfoView.placeName.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Address"] = self.editPlaceInfoView.placeAddress.text!
                    self.userAddedPlaceDictionaryArray[index]["Place City"] = self.editPlaceInfoView.placeCity.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Country"] = self.editPlaceInfoView.placeCountry.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Type"] = self.editPlaceInfoView.placeType.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Phone Number"] = self.editPlaceInfoView.placePhoneNumber.text!
                    self.userAddedPlaceDictionaryArray[index]["Place State"] = self.editPlaceInfoView.placeState.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Website"] = self.editPlaceInfoView.placeWebsite.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Latitude"] = self.editPlaceInfoView.placeLatitude.text!
                    self.userAddedPlaceDictionaryArray[index]["Place Longitude"] = self.editPlaceInfoView.placeLongitude.text!
                    
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                    
                }
                
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.editPlaceInfoView.alpha = 0
                self.blurEffectView.alpha = 0
                
                
            }) { _ in
                
                self.editPlaceInfoView.placeNotes.text! = ""
                self.editPlaceInfoView.placeName.text! = ""
                self.editPlaceInfoView.placeAddress.text! = ""
                self.editPlaceInfoView.placeCity.text! = ""
                self.editPlaceInfoView.placeCountry.text! = ""
                self.editPlaceInfoView.placeType.text! = ""
                self.editPlaceInfoView.placePhoneNumber.text! = ""
                self.editPlaceInfoView.placeState.text! = ""
                self.editPlaceInfoView.placeWebsite.text! = ""
                self.editPlaceInfoView.placeLatitude.text! = ""
                self.editPlaceInfoView.placeLongitude.text! = ""
                
                self.blurEffectView.removeFromSuperview()
                self.editPlaceInfoView.removeFromSuperview()
                
            }
            
            self.displayAlert(title: NSLocalizedString("Place info saved", comment: ""), message: "")
            //self.filteredArray.removeAll()
            //userPlaceTable.reloadData()
            
            
        }
        
        
        
        
    }
    
    func cancelPlaceInfo() {
        
        print("cancelPlaceInfo")
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        //self.filteredArray.removeAll()
        //self.userPlaceTable.reloadData()
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.editPlaceInfoView.alpha = 0
            self.blurEffectView.alpha = 0
            
            
        }) { _ in
            
            self.blurEffectView.removeFromSuperview()
            self.editPlaceInfoView.removeFromSuperview()
            
        }
        
        
    }
    
    /*
    func saveNotes() {
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        if filteredArray.isEmpty == true {
            
            for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place ID"] == userAddedPlaceDictionaryArray[self.indexPath]["Place ID"] {
                    
                    
                    self.userAddedPlaceDictionaryArray[index]["Place Notes"] = self.addNotesView.addNotesTextView.text!
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                    
                    
                    
                    
                    
                }
            }
            
            
            
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.addNotesView.alpha = 0
                self.blurEffectView.alpha = 0
                
                
            }) { _ in
                
                self.blurEffectView.removeFromSuperview()
                self.addNotesView.addNotesTextView.text = ""
                self.addNotesView.removeFromSuperview()
                
            }
            
            self.displayAlert(title: NSLocalizedString("Place notes added", comment: ""), message: "")
            //self.filteredArray.removeAll()
            //self.userPlaceTable.reloadData()
            
        } else {
            
            for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                
                if place["Place ID"] == filteredArray[self.indexPath]["Place ID"] {
                    
                    
                    self.userAddedPlaceDictionaryArray[index]["Place Notes"] = self.addNotesView.addNotesTextView.text!
                    UserDefaults.standard.set(self.userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
                    self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
                    
                    
                    
                    
                    
                }
            }
            
            
            
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.addNotesView.alpha = 0
                self.blurEffectView.alpha = 0
                
                
            }) { _ in
                
                self.blurEffectView.removeFromSuperview()
                self.addNotesView.addNotesTextView.text = ""
                self.addNotesView.removeFromSuperview()
                
            }
            
            self.displayAlert(title: NSLocalizedString("Place notes added", comment: ""), message: "")
            //self.filteredArray.removeAll()
            //self.userPlaceTable.reloadData()
            
        }
        
        
        
        
    }
    */
    /*
    func cancelNotes() {
        
        self.userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.addNotesView.alpha = 0
            self.blurEffectView.alpha = 0
            
            
        }) { _ in
            
            self.blurEffectView.removeFromSuperview()
            self.addNotesView.removeFromSuperview()
        }
        
        //self.filteredArray.removeAll()
        //userPlaceTable.reloadData()
        
    }
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return nil
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            userAddedPlaceDictionaryArray.remove(at: indexPath.row)
            UserDefaults.standard.set(userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
            self.deleteArrays()
            self.createArrays()
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.userPlaceTable.deleteRows(at: [indexPath], with: .fade)
                }, completion: { _ in
                    self.userPlaceTable.reloadData()
                })
                
                
            }
            
              
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPlaceOverview" {
            
            let nextScene = segue.destination as? placeOverviewViewController
            
            nextScene?.photosMode = true
            //nextScene?.reviewsMode = self.reviewsMode
            
        }
        
        //let indexPath = self.tableView.indexPathForSelectedRow {
        //let selectedVehicle = vehicles[indexPath.row]
        //nextScene.currentVehicle = selectedVehicle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("viewDidAppear")
        
        self.filteredArray.removeAll()
        print("self.filteredArray.removeAll()")
        
        if UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") != nil {
            
            
            userAddedPlaceDictionaryArray = UserDefaults.standard.object(forKey: "userAddedPlaceDictionaryArray") as! [Dictionary<String,String>]
            print("userAddedPlaceDictionaryArray")
            self.sortPlacesByDistanceAway()
            
            createArrays()
            
            if userAddedPlaceDictionaryArray.count == 0 {
                
                DispatchQueue.main.async {
                    self.displayAlert(title: NSLocalizedString("You haven't added any places yet.", comment: ""), message: NSLocalizedString("To add a place go to the map and find a place then save it, or press the map to a drop a pin.", comment: ""))
                }
                
                
                
            }
            
        } else {
            print("else")
            
            DispatchQueue.main.async {
                self.displayAlert(title: NSLocalizedString("You haven't added any places yet.", comment: ""), message: NSLocalizedString("To add a place go to the map and find a place then save it, or press the map to a drop a pin.", comment: ""))
            }
            
        }

        
        self.userNames.removeAll()
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            if let followedUsers = UserDefaults.standard.object(forKey: "followedUsernames") as? [Dictionary<String,Any>] {
                
                for user in followedUsers {
                    
                    self.userNames.append(user["Username"] as! String)
                }
                
            } else {
                
                self.userNames = UserDefaults.standard.object(forKey: "followedUsernames") as! [String]
                
                for user in self.userNames {
                    
                    let dictionary = [
                        
                        "Username":"\(user)",
                        "Profile Image":""
                        
                    ]
                    
                    var followedUsers = [Dictionary<String,Any>]()
                    followedUsers.append(dictionary)
                    UserDefaults.standard.set(followedUsers, forKey: "followedUsernames")
                }
            }
            
            
        }
        
        if self.connected == true {
            
          refresh()
            
            
        } else {
            
            DispatchQueue.main.async {
                self.displayAlert(title: NSLocalizedString("There is no internet connection.", comment: ""), message: NSLocalizedString("Please connect to be able to use all the functionality.", comment: "Please connect to be able to use all the functionality."))
            }
        }
        
       sortPlacesByDistanceAway()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.userNames.removeAll()
        //self.filteredArray.removeAll()
        
    }
    
    
    
    
    
    func createArrays() {
        
        print("createArrays")
        
        for place in userAddedPlaceDictionaryArray {
            
            if let placeName = place["Place Name"] {
                
                self.placeNameArray.append(placeName)
                
            }
            
            if let placeId = place["Place ID"] {
                
                self.placeIdArray.append(placeId)
                
            }
            
            if let placePhoneNumber = place["Place Phone Number"] {
                
                self.placePhoneNumberArray.append(placePhoneNumber)
                
            }
            
            if let placeWebsite = place["Place Website"] {
                
                self.placeWebsiteArray.append(placeWebsite)
                
            }
            
            if let placeAddress = place["Place Address"] {
                
                self.placeAddressArray.append(placeAddress)
                
            }
            
            if let placeLatitude = place["Place Latitude"] {
                
                self.placeLatitudeArray.append(Double(placeLatitude)!)
                
            }
            
            if let placeLongitude = place["Place Longitude"] {
                
                self.placeLongitudeArray.append(Double(placeLongitude)!)
            }
            
            
            
            
        }
        
    }
    

    func deleteArrays() {
        
        self.placeNameArray = []
        self.placePhoneNumberArray = []
        self.placeWebsiteArray = []
        self.placeAddressArray = []
        self.placeLatitudeArray = []
        self.placeLongitudeArray = []
        
    }
    
    
    func sortPlacesByDistanceAway() {
        
        print("sortPlacesByDistanceAway")
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                
                print("No access")
                
                                
            case .authorizedAlways:
                print("authorizedAlways")
                
                
                
                
            case .authorizedWhenInUse:
                print("authorizedWhenInUse")
                
                if self.userAddedPlaceDictionaryArray.count > 0 {
                    
                    for (index, place) in userAddedPlaceDictionaryArray.enumerated() {
                        
                        let placeLongitude = Double(place["Place Longitude"]!)
                        let placeLatitude = Double(place["Place Latitude"]!)
                        
                        let placeCoordinates = CLLocation(latitude: placeLatitude!, longitude: placeLongitude!)
                        var usersLatitude:Double!
                        var usersLongitude:Double!
                        
                        
                        
                        if UserDefaults.standard.object(forKey: "usersLatitude") != nil {
                            
                            usersLatitude = UserDefaults.standard.object(forKey: "usersLatitude") as! Double!
                            print("usersLatitude")
                            
                                
                                usersLongitude = UserDefaults.standard.object(forKey: "usersLongitude") as! Double!
                                print("usersLongitude")
                                let usersLocation:CLLocation = CLLocation(latitude: usersLatitude!, longitude: usersLongitude!)
                                print("usersLocation")
                                let distanceInMeters = placeCoordinates.distance(from: usersLocation)
                                print("distanceInMeters")
                                let distanceInMiles = Double(distanceInMeters) * 0.000621371
                                print("distanceInMiles")
                                var roundedDistance = String(round(10.0 * distanceInMiles) / 10.0)
                                print("roundedDistance = \(roundedDistance)")
                                
                                self.userAddedPlaceDictionaryArray[index]["Distance"] = "\(roundedDistance)"
                                
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                    self.sortPlacesByDistance()
                    
                    userPlaceTable.reloadData()
                    
                }
                
                
                
                
                
            }
        }
        
       
        
        
    }
    
    func sortPlacesByDistance() {
        
        print("sortPlacesByDistance")
        
        sortedPlaces = userAddedPlaceDictionaryArray.sorted {
            
            (dictOne, dictTwo) -> Bool in
            
            let d1 = Double(dictOne["Distance"]!)
            let d2 = Double(dictTwo["Distance"]!)
            
            return d1! < d2!
            
        };
        
        userAddedPlaceDictionaryArray = sortedPlaces
        
        UserDefaults.standard.set(userAddedPlaceDictionaryArray, forKey: "userAddedPlaceDictionaryArray")
        
        

    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        self.present(alertcontroller, animated: true, completion: nil)
        
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
        activityIndicator.isUserInteractionEnabled = true
        activityIndicator.startAnimating()
        self.activityIndicator.alpha = 0
        
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


}
