//
//  CommunityFeedViewController.swift
//  TripKey
//
//  Created by Peter on 5/15/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import CoreData

class CommunityFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {
    
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet var goToProfile: UIBarButtonItem!
    @IBOutlet var addUserButton: UIBarButtonItem!
    @IBOutlet var myProfileButton: UILabel!
    @IBOutlet var addUsersButton: UILabel!
    @IBOutlet var feedTable: UITableView!
    var refresher: UIRefreshControl!
    var users = [String: String]()
    var userNames = [String]()
    var flightArray = [[String:Any]]()
    
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
        
        let user = self.userNames[indexPath]
        let followedUsers = getFollowedUsers()
        var userIdToShareWith = ""
        
        for u in followedUsers {
            if user == u["username"]! {
                userIdToShareWith = u["userid"]!
            }
        }
        
        let alert = UIAlertController(title: "\(NSLocalizedString("Share Flight", comment: ""))" + " " + "to \(user)", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for dict in self.flightArray {
            
            let flight = FlightStruct(dictionary: dict)
            let departureCity = flight.departureCity
            let arrivalCity = flight.arrivalCity
            let departureDate = convertDateTime(date: flight.departureDate)
            let flightNumber = flight.flightNumber
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("\(flightNumber) \(departureCity) to \(arrivalCity), on \(departureDate)", comment: ""), style: .default, handler: { (action) in
                
                let shareFlight = ShareFlight.sharedInstance
                
                func success() {
                    
                    if !shareFlight.errorBool {
                        
                        displayAlert(viewController: self,
                                     title: "\(NSLocalizedString("Flight shared to", comment: "")) \(String(describing: user))", message: "")
                        
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
        for user in followedUsers {
            let username = user["username"]!
            self.userNames.append(username)
        }
        self.refresher.endRefreshing()
        self.feedTable.reloadData()

   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.delegate = self
        feedTable.delegate = self
        feedTable.dataSource = self
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CommunityFeedViewController.refresh), for: UIControlEvents.valueChanged)
        feedTable.addSubview(refresher)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        flightArray = getFlightArray()
        refresh()
        
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
    
}

extension CommunityFeedViewController  {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}
