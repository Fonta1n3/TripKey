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
import CoreData

class CommunityFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageBackground: UIView!
    var resultsArray = [String]()
    @IBOutlet var goToProfile: UIBarButtonItem!
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    @IBOutlet var addUserButton: UIBarButtonItem!
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
    var followedUsername:String!
    var followedUserDictionary = Dictionary<String,Any>()
    var followedUserDictionaryArray = [Dictionary<String,Any>]()
    let backButton = UIButton()
    let addButton = UIButton()
    
    func addButtons() {
        
        DispatchQueue.main.async {
            
            self.backButton.removeFromSuperview()
            self.backButton.frame = CGRect(x: 10, y: 30, width: 25, height: 25)
            self.backButton.showsTouchWhenHighlighted = true
            let image = UIImage(imageLiteralResourceName: "backButton.png")
            self.backButton.setImage(image, for: .normal)
            self.backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
            self.addButton.removeFromSuperview()
            self.addButton.frame = CGRect(x: self.view.frame.maxX - 35, y: 30, width: 25, height: 25)
            self.addButton.showsTouchWhenHighlighted = true
            let addImage = UIImage(imageLiteralResourceName: "Add Pin - Trip key.png")
            self.addButton.setImage(addImage, for: .normal)
            self.addButton.addTarget(self, action: #selector(self.add), for: .touchUpInside)
            self.view.addSubview(self.addButton)
            
        }
        
    }
    
    @objc func goBack() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func add() {
        self.performSegue(withIdentifier: "addUsers", sender: self)
    }
    
    func shareFlight(indexPath: Int) {
        
        let alert = UIAlertController(title: NSLocalizedString("Share Flight", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
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
                        let alert = UIAlertController(title: NSLocalizedString("Could not share flight", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        self.activityIndicator.stopAnimating()
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
    }
    
    @IBAction func goToProfile(_ sender: Any) {
        
        if PFUser.current() != nil {
            
            DispatchQueue.main.async {
                PFUser.logOut()
                if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
                    UserDefaults.standard.removeObject(forKey: "followedUsernames")
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func goToUsers(_ sender: Any) {
        print("searchUsers")
        DispatchQueue.main.async {
            displayAlert(viewController: self, title: "Your Username:", message: "\(String(describing: PFUser.current()!.username!))")
        }
    }
    
    @IBAction func back(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        print("refresh")
        
        UserDefaults.standard.removeObject(forKey: "followedUsernames")
        self.followedUserDictionaryArray.removeAll()
        let query = PFQuery(className: "Followers")
        
        query.whereKey("followerUsername", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
                
                displayAlert(viewController: self, title: "Error", message: "Please try later.")
                
            } else {
                
                if let objects = objects {
                    
                    if objects.count > 0 {
                        
                        self.followedUserDictionaryArray.removeAll()
                        
                        for object in objects {
                            
                            let dictionary = [
                                
                                "Username":"\(object["followedUsername"] as! String)",
                                "Profile Image":""
                                
                                ] as [String : Any]
                            
                            self.followedUserDictionaryArray.append(dictionary)
                            UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
                            self.createDictionaryArray()
                            
                        }
                        
                        self.refresher.endRefreshing()
                        
                    } else {
                        //not following anyone
                        self.followedUserDictionaryArray.removeAll()
                        UserDefaults.standard.removeObject(forKey: "followedUsernames")
                        self.refresher.endRefreshing()
                        
                    }
                    
                }
                
            }
            
        })

   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        
        addButtons()
        addUserButton.title = NSLocalizedString("Add Users", comment: "")
        goToProfile.title = NSLocalizedString("Log Out", comment: "")
        
        if (UserDefaults.standard.object(forKey: "flights") != nil) {
            flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
        }
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            self.followedUserDictionaryArray = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
        }
        
        feedTable.delegate = self
        feedTable.dataSource = self
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CommunityFeedViewController.refreshNow), for: UIControlEvents.valueChanged)
        feedTable.addSubview(refresher)
        blurEffectView.alpha = 0
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshNow()
    }
    
    func refreshNow() {
        self.createDictionaryArray()
        refresher.endRefreshing()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = feedTable.dequeueReusableCell(withIdentifier: "Community Feed", for: indexPath) as! FeedTableViewCell
        cell.userName.text = followedUserDictionaryArray[indexPath.row]["Username"] as? String
        
        cell.tapShareFlightAction = {
            (cell) in self.shareFlight(indexPath: (tableView.indexPath(for: cell)!.row))
        }
        
        return cell
 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followedUserDictionaryArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unfollow"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let query = PFQuery(className: "Followers")
            query.whereKey("followerUsername", equalTo: (PFUser.current()?.username!)!)
            query.whereKey("followedUsername", equalTo: self.followedUserDictionaryArray[indexPath.row]["Username"] as! String)
            query.findObjectsInBackground(block: { (objects, error) in
                    
                if error != nil {
                        
                    DispatchQueue.main.async {
                        displayAlert(viewController: self, title: "Error", message: "Unable to unfollow. Please check your connection and try again later.")
                    }
                        
                } else {
                        
                    if let objects = objects {
                            
                        for object in objects {
                                    
                                DispatchQueue.main.async {
                                        
                                    let userUnfollowed = self.followedUserDictionaryArray[indexPath.row]["Username"] as! String
                                    self.followedUserDictionaryArray.remove(at: indexPath.row)
                                    for (index, _) in self.followedUserDictionaryArray.enumerated() {
                                        self.followedUserDictionaryArray[index]["Profile Image"] = ""
                                    }
                                    UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
                                    displayAlert(viewController: self, title: "\(NSLocalizedString("You unfollowed", comment: "")) \(userUnfollowed)", message: "")
                                    object.deleteInBackground()
                                    self.feedTable.deleteRows(at: [indexPath], with: .fade)
                                    
                                }
                        }
                    }
                }
            })
        }
    }
    
    func addActivityIndicatorCenter() {
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
    
    /*func updateProfileImages() {
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
                                                let indexPath = IndexPath(item: index, section: 0)
                                                print("index = \(index)")
                                                //DispatchQueue.main.async {
                                                  //  self.feedTable.reloadRows(at: [indexPath], with: .none)
                                                //}
                                                /*if index == 0 {
                                                    DispatchQueue.main.async {
                                                        self.feedTable.reloadData()
                                                    }
                                                } else {
                                                    DispatchQueue.main.async {
                                                        self.feedTable.reloadRows(at: [indexPath], with: .none)
                                                    }
                                                }*/
                                                
                                                
                                                //let image = UIImage(named: "User-Profile.png")
                                                //let imageData = UIImagePNGRepresentation(image!)!
                                                /*let success = self.saveProfileImageToCoreData(imageData: imageData, username: username)
                                                if success {
                                                    print("saved users profile image")
                                                }*/
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                })
                
            }
           
        }
        
    }*/
    
    func createDictionaryArray() {
        print("createDictionaryArray")
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            self.followedUserDictionaryArray = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
            let sortedArray = (self.followedUserDictionaryArray as NSArray).sortedArray(using: [NSSortDescriptor(key: "Username", ascending: true)]) as! [[String:AnyObject]]
            self.followedUserDictionaryArray = sortedArray
            DispatchQueue.main.async {
                self.feedTable.reloadData()
            }
            
        } else {
            
            self.followedUserDictionaryArray.removeAll()
            self.feedTable.reloadData()
            self.refresh()
        }
    }
 
    func saveProfileImageToCoreData(imageData: Data, username: String) -> Bool {
        print("saveProfileImageToCoreData")
        
        var appDelegate = AppDelegate()
        var success = Bool()
        
        
        if let appDelegateCheck = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate = appDelegateCheck
            
        } else {
            
            displayAlert(viewController: self, title: "Error", message: "Something strange has happened and we do not have access to app delegate, please try again.")
            success = false
            
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FollowedUsers")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest) as [NSManagedObject]
            
            if results.count > 0 {
                print("results exist")
                
                for data in results {
                    
                    if data.value(forKey: "username") as! String == username {
                        
                        let entity = NSEntityDescription.entity(forEntityName: "FollowedUsers", in: context)
                        let followedUser = NSManagedObject(entity: entity!, insertInto: context)
                        followedUser.setValue(imageData, forKey: "profilePic")
                        
                        do {
                            
                            try context.save()
                            success = true
                            print("success saving to coredata")
                            
                        } catch {
                            
                            print("Failed saving")
                            success = false
                            
                        }
                    }
                }
                
            } else {
                
                print("no results so create one")
                
                let entity = NSEntityDescription.entity(forEntityName: "FollowedUsers", in: context)
                let followedUser = NSManagedObject(entity: entity!, insertInto: context)
                
                followedUser.setValue(imageData, forKey: "profileImage")
                followedUser.setValue(username, forKey: "username")
                
                do {
                    
                    try context.save()
                    success = true
                    print("success saving to coredata")
                    
                } catch {
                    
                    print("Failed saving")
                    success = false
                    
                }
                
            }
            
        } catch {
            
            print("Failed")
            
        }
        
        return success
    }
}
