//
//  NewUserEmergencyContactViewController.swift
//  TripKey2
//
//  Created by Peter on 8/21/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
//import CoreData



var emergencyContactsNamesArray = [String]()

class NewUserEmergencyContactViewController: UIViewController, UITextFieldDelegate {
    
    
    var emergencyContactsArray = [String]()
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var surname: UITextField!
    @IBOutlet var mobilePhone: UITextField!
    @IBOutlet var homePhone: UITextField!
    @IBOutlet var workPhone: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var whatsapp: UITextField!
    @IBOutlet var facebookName: UITextField!
    @IBOutlet var facetime: UITextField!
    @IBOutlet var addContactLabel: UIButton!
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight:CGFloat = keyboardSize.height
        
        var _:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        var _:CGFloat = keyboardSize.height
        
        var _:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform.identity
        }, completion: nil)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == facetime || textField == facebookName {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    @IBAction func addContact(_ sender: AnyObject) {
        
        saveEmergencyContact()
        
        firstName.text = ""
        surname.text = ""
        mobilePhone.text = ""
        homePhone.text = ""
        workPhone.text = ""
        email.text = ""
        whatsapp.text = ""
        facebookName.text = ""
        facetime.text = ""
        
        addContactLabel.setTitle("Add another emergency contact", for: [])
 
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.object(forKey: "emergencyContactsArray") != nil) {
            
            emergencyContactsArray = UserDefaults.standard.object(forKey: "emergencyContactsArray") as! [String]
        }
        
        if (UserDefaults.standard.object(forKey: "emergencyContactsNamesArray") != nil) {
            
            emergencyContactsNamesArray = UserDefaults.standard.object(forKey: "emergencyContactsNamesArray") as! [String]
        }
        
        self.firstName.delegate = self
        self.surname.delegate = self
        self.mobilePhone.delegate = self
        self.homePhone.delegate = self
        self.workPhone.delegate = self
        self.email.delegate = self
        self.whatsapp.delegate = self
        self.facebookName.delegate = self
        self.facetime.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)

        return false
    }
    
    func saveEmergencyContact() {
        
        emergencyContactsArray.append(firstName.text!)
        emergencyContactsArray.append(surname.text!)
        emergencyContactsArray.append(mobilePhone.text!)
        emergencyContactsArray.append(homePhone.text!)
        emergencyContactsArray.append(workPhone.text!)
        emergencyContactsArray.append(email.text!)
        emergencyContactsArray.append(whatsapp.text!)
        emergencyContactsArray.append(facebookName.text!)
        emergencyContactsArray.append(facetime.text!)
        
        emergencyContactsNamesArray.append(firstName.text! + " " + surname.text!)
        
        UserDefaults.standard.set(emergencyContactsNamesArray, forKey: "emergencyContactsNamesArray")
        
        UserDefaults.standard.set(emergencyContactsArray, forKey: "emergencyContactsArray")
        
        /*
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newContact = NSEntityDescription.insertNewObject(forEntityName: "EmergencyContact", into: context)
        
        newContact.setValue(firstName.text, forKey: "firstName")
        newContact.setValue(surname.text, forKey: "surname")
        newContact.setValue(mobilePhone.text, forKey: "mobilePhone")
        newContact.setValue(homePhone.text, forKey: "homePhone")
        newContact.setValue(workPhone.text, forKey: "workPhone")
        newContact.setValue(email.text, forKey: "email")
        newContact.setValue(whatsapp.text, forKey: "whatsapp")
        newContact.setValue(facebookName.text, forKey: "facebookName")
        newContact.setValue(facetime.text, forKey: "facetime")
        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("There was an error")
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EmergencyContact")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let firstName = result.value(forKey: "firstName") as? String {
                        self.createArray.append(firstName)
                    }
                    if let surname = result.value(forKey: "surname") as? String {
                        self.createArray.append(surname)
                    }
                    if let mobilePhone = result.value(forKey: "mobilePhone") as? String {
                        self.createArray.append(mobilePhone)
                    }
                    if let homePhone = result.value(forKey: "homePhone") as? String {
                        self.createArray.append(homePhone)
                    }
                    if let workPhone = result.value(forKey: "workPhone") as? String {
                        self.createArray.append(workPhone)
                    }
                    if let email = result.value(forKey: "email") as? String {
                        self.createArray.append(email)
                    }
                    if let whatsapp = result.value(forKey: "whatsapp") as? String {
                        self.createArray.append(whatsapp)
                    }
                    if let facebookName = result.value(forKey: "facebookName") as? String {
                        self.createArray.append(facebookName)
                    }
                    if let facetime = result.value(forKey: "facetime") as? String {
                        self.createArray.append(facetime)
                    }
                    emergencyContacts = self.createArray
                    UserDefaults.standard.set(emergencyContacts, forKey: "emergencyContacts")
                }
            } else {
                print("No results")
            }
        } catch {
            print("Couldn't fetch results")
        }*/
    }
}
