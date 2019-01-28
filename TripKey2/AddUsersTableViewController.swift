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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
            
            self.followedUserDictionaryArray = UserDefaults.standard.object(forKey: "followedUsernames") as! [Dictionary<String,Any>]
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return autoComplete.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath)
        
        cell.textLabel?.text = autoComplete[indexPath.row]
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = autoComplete[indexPath.row]
        print("selectedUser = \(selectedUser)")
        
        
        
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
                            self.displayAlert(title: "\(NSLocalizedString("You are now following", comment: "")) \(user["username"]!)", message: "")
                            
                            
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
                self.displayAlert(title: "Error", message: "Internet connection appears to be offline")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            } else if let users = objects {
                
                for user in users {
                    
                    print("user = \(user)")
                    //self.autoCompleteTable.isHidden = false
                    print("username = \(String(describing: user["username"]))")
                    self.autoComplete.append(user["username"] as! String)
                    DispatchQueue.main.async {
                        self.autoCompleteTable.reloadData()
                    }
                    
                }
                
            }
            
            
            
        })
        
        
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    
}
