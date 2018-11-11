//
//  UserProfileOverviewViewController.swift
//  TripKey2
//
//  Created by Peter on 9/2/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import Parse

class UserProfileOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users = [String]()
    var imageFiles = [PFFile]()
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var tableView: UITableView!
     var vaccineDictionaryArray = [Dictionary<String,String>!]()
    
    @IBAction func logOut(_ sender: Any) {
        
        if PFUser.current() != nil {
            
            DispatchQueue.main.async {
                PFUser.logOut()
                if UserDefaults.standard.object(forKey: "followedUsernames") != nil {
                    UserDefaults.standard.removeObject(forKey: "followedUsernames")
                }
                self.performSegue(withIdentifier: "goToNearMe", sender: self)
            }
        }
    }
    
    
    var sectionHeaders = ["Personal Details", "Travel Vaccinations", "Emergency Contacts", "Frequent Flyer Accounts"]
    
    @IBAction func goHome(_ sender: AnyObject) {
        
        print("CreateProfile")
        
        let alertcontroller = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .actionSheet)
        
        alertcontroller.addAction(UIAlertAction(title: "Change Profile Picture", style: .default, handler: { (action) in
            
            self.performSegue(withIdentifier: "changeProfilePic", sender: self)
            
        }))
        
        alertcontroller.addAction(UIAlertAction(title: "Edit Personal Details", style: .default, handler: { (action) in
            
            self.performSegue(withIdentifier: "editDetails", sender: self)
            
        }))
        
        alertcontroller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alertcontroller, animated: true, completion: nil)
        
        
    }
    
    
    
   
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //var sectionsContent = [userDetailsArray, vaccinesList, emergencyContactsNamesArray, frequentFlyerList]
    
    var sectionsContent = [[Any]]()
    
    var descriptionLabelCell1 = ["Email:", "First Name:", "Surname:", "Passport #:", "DOB:", "Gender:", "House #:", "Street 1:", "Street 2:", "City:", "State:", "Postcode:", "Country:", "Passport Country:", "Passport Exp:"]
    
    var descriptionLabelCell2 = ["First Name:", "Surname:", "Mobile Phone:", "Home Phone:", "Work Phone:", "Email:", "Whatsapp:", "Facebook Name:", "Facetime:"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePic.image = UIImage(named: "default.icon.png")
        
        let query = PFUser.query()
        
        query?.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                
                self.users.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        self.users.append(user.objectId!)
                        self.userName.text = user.username!
                        
                        let pictureQuery = PFQuery(className: "Posts")
                        
                        pictureQuery.whereKey("userid", equalTo: self.users[0])
                        
                        pictureQuery.findObjectsInBackground(block: { (objects, error) in
                            
                            if let posts = objects {
                                
                                for object in posts {
                                    
                                    if let post = object as? PFObject {
                                        
                                        self.imageFiles.append(post["imageFile"] as! PFFile)
                                        
                                        self.imageFiles[0].getDataInBackground { (data, error) in
                                            
                                            if let imageData = data {
                                                
                                                if let downloadedImage = UIImage(data: imageData) {
                                                    
                                                    self.profilePic.image = downloadedImage
                                                    
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
            
        })

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (UserDefaults.standard.object(forKey: "vaccinesList") != nil) {
            
            vaccineDictionaryArray = UserDefaults.standard.object(forKey: "vaccinesList") as! [Dictionary<String,String>]
            
        }
        
        if (UserDefaults.standard.object(forKey: "userDetailsArray") != nil) {
            
            userDetailsArray = UserDefaults.standard.object(forKey: "userDetailsArray") as! [String]
        }
        
        if (UserDefaults.standard.object(forKey: "emergencyContactsNamesArray") != nil) {
            
            emergencyContactsNamesArray = UserDefaults.standard.object(forKey: "emergencyContactsNamesArray") as! [String]
        }
        
        if (UserDefaults.standard.object(forKey: "frequentFlyerList") != nil) {
            
            frequentFlyerList = UserDefaults.standard.object(forKey: "frequentFlyerList") as! [String]
        }
        
        sectionsContent = [userDetailsArray, vaccineDictionaryArray, emergencyContactsNamesArray, frequentFlyerList]
        
        print("This is the array.....\(userDetailsArray) and \(vaccineDictionaryArray) and\(emergencyContactsNamesArray) and \(frequentFlyerList)")
        
        self.profilePic.image = UIImage(named: "default.icon.png")
        
        let query = PFUser.query()
        
        query?.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                
                self.users.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        self.users.append(user.objectId!)
                        self.userName.text = user.username!
                        
                        let pictureQuery = PFQuery(className: "Posts")
                        
                        pictureQuery.whereKey("userid", equalTo: self.users[0])
                        
                        //print("\((PFUser.current()?.username)!)")
                        
                        pictureQuery.findObjectsInBackground(block: { (objects, error) in
                            
                            if let posts = objects {
                                
                                for object in posts {
                                    
                                    if let post = object as? PFObject {
                                        
                                        self.imageFiles.append(post["imageFile"] as! PFFile)
                                        
                                        self.imageFiles[0].getDataInBackground { (data, error) in
                                            
                                            if let imageData = data {
                                                
                                                if let downloadedImage = UIImage(data: imageData) {
                                                    
                                                    self.profilePic.image = downloadedImage
                                                    
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
            
        })
        
       tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sectionsContent[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let userDetailsCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! UserProfileTableViewCell
            
            userDetailsCell.descriptionLabel?.text = descriptionLabelCell1[indexPath.row]
            
            userDetailsCell.infoLabel?.text = userDetailsArray[indexPath.row]
            
            return userDetailsCell
        }
            
            if indexPath.section == 1 {
                
            let vaccineDetailCell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as! UserVaccineTableViewCell
                
                vaccineDetailCell.vaccineCell?.text = "\(String(describing: self.vaccineDictionaryArray[indexPath.row]?["Vaccine Type"]!) + ": Expiring " + String(describing: self.vaccineDictionaryArray[indexPath.row]?["Vaccine Expiry Date"]!))"
                
            return vaccineDetailCell
                
            }
       
        if indexPath.section == 2 {
            let vaccineDetailCell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as! UserVaccineTableViewCell
            vaccineDetailCell.vaccineCell?.text = emergencyContactsNamesArray[indexPath.row]
            return vaccineDetailCell
        }
       
        
        if indexPath.section == 3 {
            
            let vaccineDetailCell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as! UserVaccineTableViewCell
            
            vaccineDetailCell.vaccineCell?.text = frequentFlyerList[indexPath.row]
            
            return vaccineDetailCell
            
        } else {
            
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as! DefaultTableViewCell
            
        return defaultCell
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionsContent.count
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < sectionHeaders.count {
            
            return sectionHeaders[section]
            
        }
        
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
}
