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

class CommunityFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
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
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addUser", sender: self)
        }
        
    }
    
    func shareFlight(indexPath: Int) {
        
        let user = self.userNames[indexPath]
        let followedUsers = getFollowedUsers()
        var userIdToShareWith = ""
        var myusername = ""
        
        for u in followedUsers {
            if user == u["username"]! {
                userIdToShareWith = u["userid"]!
            }
        }
        
        let alert = UIAlertController(title: "\(NSLocalizedString("Share Flight", comment: ""))" + " " + "to \(user)", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for dict in self.flightArray {
            
            let flight = FlightStruct(dictionary: dict)
            let departureAirport = flight.departureAirport
            let departureCity = flight.departureCity
            let arrivalAirport = flight.arrivalAirportCode
            let arrivalCity = flight.arrivalCity
            let departureDate = convertDateTime(date: flight.departureDate)
            let flightNumber = flight.flightNumber
            let arrivalDate = convertDateTime(date: flight.arrivalDate)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("\(flightNumber) \(departureCity) to \(arrivalCity), on \(departureDate)", comment: ""), style: .default, handler: { (action) in
                
                self.addActivityIndicatorCenter()
                let myuserid = UserDefaults.standard.object(forKey: "userId") as! String
                let query = PFQuery(className: "Posts")
                query.whereKey("userid", equalTo: myuserid)
                query.findObjectsInBackground(block: { (objects, error) in
                    if let posts = objects {
                        if posts.count > 0 {
                            myusername = posts[0]["username"] as! String
                            
                            let sharedFlight = PFObject(className: "SharedFlight")
                            sharedFlight["shareToUsername"] = userIdToShareWith
                            sharedFlight["shareFromUsername"] = myuserid
                            sharedFlight["flightDictionary"] = dict
                            
                            sharedFlight.saveInBackground(block: { (success, error) in
                                
                                if error != nil {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.activityIndicator.stopAnimating()
                                        
                                    }
                                    
                                    
                                    let alert = UIAlertController(title: NSLocalizedString("Could not share flight", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                } else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.activityIndicator.stopAnimating()
                                        
                                    }
                                    
                                    let alert = UIAlertController(title: "\(NSLocalizedString("Flight shared to " , comment: ""))\(user)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                    
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
    }
    
    @IBAction func goToProfile(_ sender: Any) {
        
        
    }
    
    @IBAction func goToUsers(_ sender: Any) {
        print("searchUsers")
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToMyAccount", sender: self)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        print("refresh")
        
        self.userNames.removeAll()
        let followedUsers = getFollowedUsers()
        print("followedUsers = \(followedUsers)")
        for user in followedUsers {
            let username = user["username"]!
            self.userNames.append(username)
        }
        self.refresher.endRefreshing()
        self.feedTable.reloadData()

   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        addButtons()
        addUserButton.title = NSLocalizedString("Add Users", comment: "")
        feedTable.delegate = self
        feedTable.dataSource = self
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CommunityFeedViewController.refresh), for: UIControlEvents.valueChanged)
        feedTable.addSubview(refresher)
        blurEffectView.alpha = 0
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imagePicker.delegate = self
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
            
            deleteUserFromCoreData(viewController: self, username: self.userNames[indexPath.row])
            self.userNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    @objc func chooseQRCodeFromLibrary() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage = CIImage(image:pickedImage)!
            var qrCodeLink = ""
            let features = detector.features(in: ciImage)
            
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
            print(qrCodeLink)
            
            if qrCodeLink != "" {
                
                DispatchQueue.main.async {
                    
                    //follow user
                    let query = PFQuery(className: "Posts")
                    query.whereKey("userid", equalTo: qrCodeLink)
                    query.findObjectsInBackground(block: { (objects, error) in
                        if let posts = objects {
                            if posts.count > 0 {
                                //user exists, follow them, add username to coredata
                                let username = posts[0]["username"] as! String
                                let followed = saveFollowedUserToCoreData(viewController: self, username: username, userId: qrCodeLink)
                                if followed {
                                    self.refresh()
                                    displayAlert(viewController: self, title: "Success", message: "You followed \(username), now you can easliy share flights with them!")
                                }
                            } else {
                                //user doesnt exist
                                displayAlert(viewController: self, title: "Error", message: "It appears that user no longer exists.")
                            }
                        }
                    })
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
}
