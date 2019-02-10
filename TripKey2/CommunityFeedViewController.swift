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
    var followedUsername:String!
    //var followedUserDictionary = Dictionary<String,Any>()
    //var followedUserDictionaryArray = [Dictionary<String,Any>]()
    let backButton = UIButton()
    let addButton = UIButton()
    var flightArray = [[String:Any]]()
    
    
    
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
            self.addButton.frame = CGRect(x: self.view.frame.maxX - 40, y: 30, width: 30, height: 30)
            self.addButton.showsTouchWhenHighlighted = true
            let addImage = UIImage(imageLiteralResourceName: "icons8-add-user-male-filled-50.png")
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
        
        let user = self.userNames[indexPath]
        
        let alert = UIAlertController(title: "\(NSLocalizedString("Share Flight", comment: ""))" + " " + "to \(user)", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for flight in self.flightArray {
            
            let flightNumber = flight["flightNumber"] as! String
            let depCity = flight["departureAirport"] as! String
            let arrCity = flight["arrivalAirportCode"] as! String
            let date = convertDateTime(date: flight["departureTime"] as! String)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("\(flightNumber) \(depCity) to \(arrCity), on \(date)", comment: ""), style: .default, handler: { (action) in
                
                let flight = flight
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
                for user in self.userNames {
                    deleteUserFromCoreData(viewController: self, username: user)
                }
                self.userNames.removeAll()
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
        
        
        let query = PFQuery(className: "Followers")
        query.whereKey("followerUsername", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
                
                displayAlert(viewController: self, title: "Error", message: "Please try later.")
                
            } else {
                
                if let objects = objects {
                    
                    if objects.count > 0 {
                        
                        for user in self.userNames {
                            deleteUserFromCoreData(viewController: self, username: user)
                        }
                        
                        self.userNames.removeAll()
                        
                        
                        
                        for object in objects {
                            
                            let success = saveFollowedUserToCoreData(viewController: self, username: object["followedUsername"] as! String)
                            
                            if success {
                                print("success refreshing followed users")
                            } else {
                                print("error refreshing followed users")
                            }
                        }
                        
                        self.userNames = getFollowedUsers()
                        
                        self.refresher.endRefreshing()
                        
                        self.feedTable.reloadData()
                        
                    } else {
                        //not following anyone
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
        feedTable.delegate = self
        feedTable.dataSource = self
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CommunityFeedViewController.refresh), for: UIControlEvents.valueChanged)
        feedTable.addSubview(refresher)
        blurEffectView.alpha = 0
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
        //feedTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = feedTable.dequeueReusableCell(withIdentifier: "Community Feed", for: indexPath) as! FeedTableViewCell
        cell.userName.text = userNames[indexPath.row]
        
        cell.tapShareFlightAction = {
            (cell) in self.shareFlight(indexPath: (tableView.indexPath(for: cell)!.row))
        }
        
        return cell
 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userNames.count
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unfollow"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let query = PFQuery(className: "Followers")
            query.whereKey("followerUsername", equalTo: (PFUser.current()?.username!)!)
            query.whereKey("followedUsername", equalTo: self.userNames[indexPath.row])
            query.findObjectsInBackground(block: { (objects, error) in
                    
                if error != nil {
                        
                    DispatchQueue.main.async {
                        displayAlert(viewController: self, title: "Error", message: "Unable to unfollow. Please check your connection and try again later.")
                    }
                        
                } else {
                        
                    if let objects = objects {
                            
                        for object in objects {
                                    
                            DispatchQueue.main.async {
                                    
                                let userUnfollowed = self.userNames[indexPath.row]
                                deleteUserFromCoreData(viewController: self, username: userUnfollowed)
                                self.userNames.remove(at: indexPath.row)
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
}
