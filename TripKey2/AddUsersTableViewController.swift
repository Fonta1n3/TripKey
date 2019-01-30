//
//  AddUsersTableViewController.swift
//  TripKey
//
//  Created by Peter on 28/10/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import Parse

class AddUsersTableViewController: UITableViewController, UISearchBarDelegate {
    
    var activityIndicator:UIActivityIndicatorView!
    @IBOutlet var autoCompleteTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var autoComplete = [String]()
    var followedUserDictionaryArray = [Dictionary<String,Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            self.followedUserDictionaryArray = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoComplete.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath)
        
        cell.textLabel?.text = autoComplete[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = autoComplete[indexPath.row]
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
                            
                            let dictionary = [
                                
                                "Username":"\(selectedUser)",
                                "Profile Image":""
                                
                            ]
                            
                            self.followedUserDictionaryArray.append(dictionary)
                            
                            for (index, _) in self.followedUserDictionaryArray.enumerated() {
                                self.followedUserDictionaryArray[index]["Profile Image"] = ""
                            }
                            
                            UserDefaults.standard.set(self.followedUserDictionaryArray, forKey: "followedUsernames")
                            
                            self.autoComplete.removeAll()
                            self.autoCompleteTable.reloadData()
                            self.searchBar.text = ""
                            displayAlert(viewController: self, title: "\(NSLocalizedString("You are now following", comment: "")) \(user["username"]!)", message: "")
                            
                            
                        } else {
                            
                            print("error = \(String(describing: error))")
                        }
                    }
                }
            }
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("text did change")
        let query = PFUser.query()
        query?.whereKey("username", equalTo: searchText)
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
                
                print(error as Any)
                displayAlert(viewController: self, title: "Error", message: "Internet connection appears to be offline")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            } else if let users = objects {
                
                for user in users {
                    self.autoComplete.append(user["username"] as! String)
                    DispatchQueue.main.async {
                        self.autoCompleteTable.reloadData()
                    }
                }
            }
        })
    }
}
