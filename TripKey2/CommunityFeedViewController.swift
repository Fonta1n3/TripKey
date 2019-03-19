//
//  CommunityFeedViewController.swift
//  TripKey
//
//  Created by Peter on 5/15/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import CoreData

class CommunityFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let activityCenter = CenterActivityView()
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet var goToProfile: UIBarButtonItem!
    @IBOutlet var addUserButton: UIBarButtonItem!
    @IBOutlet var myProfileButton: UILabel!
    @IBOutlet var addUsersButton: UILabel!
    @IBOutlet var feedTable: UITableView!
    var refresher: UIRefreshControl!
    var users = [String: String]()
    var userNames = [[String:Any]]()
    var flightArray = [[String:Any]]()
    var selectedIndex = Int()
    
    @IBAction func goToUserInfo(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "goToMyAccount", sender: self)
            
        }
        
    }
    
    @IBAction func goToAddUser(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "addUser", sender: self)
            
        }
        
    }
    
    func shareFlight(indexPath: Int) {
        
        let user = self.userNames[indexPath]["username"] as! String
        let followedUsers = getFollowedUsers()
        var userIdToShareWith = self.userNames[indexPath]["userid"] as! String
        
        let alert = UIAlertController(title: "\(NSLocalizedString("Share Flight", comment: ""))" + " " + "to \(user)", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for dict in self.flightArray {
            
            let flight = FlightStruct(dictionary: dict)
            let departureCity = flight.departureCity
            let arrivalCity = flight.arrivalCity
            let departureDate = convertDateTime(date: flight.departureDate)
            let flightNumber = flight.flightNumber
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("\(flightNumber) \(departureCity) to \(arrivalCity), on \(departureDate)", comment: ""), style: .default, handler: { (action) in
                
                self.addActivityIndicatorCenter(description: "Sharing Flight")
                
                let shareFlight = ShareFlight.sharedInstance
                
                func success() {
                    
                    self.activityCenter.remove()
                    
                    if !shareFlight.errorBool {
                        
                        let successView = SuccessAlertView()
                        successView.labelText = "Flight Shared to \(user)"
                        successView.addSuccessView(viewController: self)
                        
                    } else {
                        
                        displayAlert(viewController: self,
                                     title: "\(NSLocalizedString("Error sharing flight with", comment: "")) \(String(describing: user))", message: "")
                        
                    }
                    
                }
                
                shareFlight.shareFlight(flightToShare: dict, toUserID: userIdToShareWith, completion: success)
           }))
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func refresh() {
        print("refresh")
        
        self.userNames.removeAll()
        let followedUsers = getFollowedUsers()
        print("followedUsers = \(followedUsers)")
        for user in followedUsers {
            let username = user["username"] as! String
            let userid = user["userid"] as! String
            if user["profileImage"] != nil {
              
                let data = user["profileImage"] as! Data
                let dict = ["username":username, "userid":userid, "profileData":data] as [String : Any]
                self.userNames.append(dict)
                
            } else {
                
                let dict = ["username":username, "userid":userid]
                self.userNames.append(dict as [String : Any])
                
            }
            
        }
        self.refresher.endRefreshing()
        self.feedTable.reloadData()

   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.delegate = self
        imagePicker.delegate = self
        feedTable.delegate = self
        feedTable.dataSource = self
        refresher = UIRefreshControl()
        refresher.tintColor = UIColor.white
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        feedTable.addSubview(refresher)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        flightArray = getFlightArray()
        refresh()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = feedTable.dequeueReusableCell(withIdentifier: "Community Feed", for: indexPath) as! FeedTableViewCell
        let username = userNames[indexPath.row]["username"] as! String
        cell.userName.text = username
        
        cell.tapShareFlightAction = {
            (cell) in self.shareFlight(indexPath: (tableView.indexPath(for: cell)!.row))
        }
        
        cell.profileImageAction = {
            
            (cell) in self.updateImage(indexPath: (tableView.indexPath(for: cell)!.row))
            
        }
        
        if userNames[indexPath.row]["profileData"] != nil {
            
            if let data = userNames[indexPath.row]["profileData"] as? Data {
                
                if let profileImage = UIImage(data: data) as? UIImage {
                    
                    cell.profile.layer.cornerRadius = cell.profile.frame.width / 2
                    cell.profile.clipsToBounds = true
                    cell.profile.setImage(profileImage, for: .normal)
                    cell.profile.imageView?.contentMode = .scaleAspectFill
                    
                }
                
            }
            
        }
        
        
        return cell
 
    }
    
    func updateImage(indexPath: Int) {
        
        print("updateImage at row \(indexPath)")
        selectedIndex = indexPath
        chooseImageFromLibrary()
        
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
            
            deleteUserFromCoreData(viewController: self, userid: self.userNames[indexPath.row]["userid"] as! String)
            self.userNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
    }
    
    func addActivityIndicatorCenter(description: String) {
        
        DispatchQueue.main.async {
            
            self.activityCenter.activityDescription = description
            self.activityCenter.add(viewController: self)
            
        }
        
    }
    
    @objc func chooseImageFromLibrary() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if let cell = self.feedTable.cellForRow(at: IndexPath.init(row: self.selectedIndex, section: 0)) as? FeedTableViewCell {
                
                cell.profile.layer.cornerRadius = cell.profile.frame.width / 2
                cell.profile.clipsToBounds = true
                cell.profile.setImage(pickedImage, for: .normal)
                cell.profile.imageView?.contentMode = .scaleAspectFill
                
                if let imageData = UIImageJPEGRepresentation(pickedImage, 1.0) as? Data {
                    
                    let userid = self.userNames[self.selectedIndex]["userid"] as! String
                    saveImageToCoreData(viewController: self, imageData: imageData, userId: userid)
                    
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension CommunityFeedViewController  {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}
