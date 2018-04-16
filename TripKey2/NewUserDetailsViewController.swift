//
//  NewUserDetailsViewController.swift
//  TripKey2
//
//  Created by Peter on 8/21/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
//import CoreData

var userDetailsArray = [String]()

class NewUserDetailsViewController: UIViewController, UITextFieldDelegate {
    
    let birthdayDatePickerView = Bundle.main.loadNibNamed("Date Picker", owner: self, options: nil)?[0] as! DatePickerView
    let passportExpiryDatePickerView = Bundle.main.loadNibNamed("Date Picker", owner: self, options: nil)?[0] as! DatePickerView
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    
    var DOB:String!
    var passExpory:String!
    
    //var createArray = [String]()
    @IBOutlet var username: UITextField!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var surname: UITextField!
    @IBOutlet var passportNumber: UITextField!
    @IBOutlet var dateOfBirth: UITextField!
    @IBOutlet var gender: UITextField!
    @IBOutlet var houseAptNumber: UITextField!
    @IBOutlet var street1: UITextField!
    @IBOutlet var street2: UITextField!
    @IBOutlet var city: UITextField!
    @IBOutlet var state: UITextField!
    @IBOutlet var postcode: UITextField!
    @IBOutlet var country: UITextField!
    @IBOutlet var passportCountry: UITextField!
    @IBOutlet var passportExpiry: UITextField!
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == country || textField == postcode || textField == state || textField == city || textField == street2 || textField == street1 || textField == houseAptNumber {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        
        if textField == passportExpiry {
            
            
            //self.dismissKeyboard()
            
            DispatchQueue.main.async {
                self.passportExpiry.resignFirstResponder()
            }
            
            
            self.passportExpiryDatePickerView.save.addTarget(self, action: #selector(self.savePassportExpiry), for: .touchUpInside)
            self.passportExpiryDatePickerView.exit.addTarget(self, action: #selector(self.closePassportDatePicker), for: .touchUpInside)
            self.passportExpiryDatePickerView.center = self.view.center
            self.passportExpiryDatePickerView.alpha = 0
            self.passportExpiryDatePickerView.title.text = "Select your passport expiry"
            
            self.blurEffectView.frame = view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurEffectView.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.view.addSubview(self.blurEffectView)
                self.view.addSubview(self.passportExpiryDatePickerView)
                self.blurEffectView.alpha = 1
                self.passportExpiryDatePickerView.alpha = 1
                
            }) { _ in
                
            }
            
        } else if textField == self.dateOfBirth {
            
            //self.dismissKeyboard()
            
            DispatchQueue.main.async {
                self.dateOfBirth.resignFirstResponder()
            }
            
            
            
            
            self.birthdayDatePickerView.save.addTarget(self, action: #selector(self.saveBirthDate), for: .touchUpInside)
            self.birthdayDatePickerView.exit.addTarget(self, action: #selector(self.closeBirthdayDatePicker), for: .touchUpInside)
            self.birthdayDatePickerView.center = self.view.center
            self.birthdayDatePickerView.alpha = 0
            self.birthdayDatePickerView.title.text = "Select your birth date"
            
            self.blurEffectView.frame = view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurEffectView.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.view.addSubview(self.blurEffectView)
                self.view.addSubview(self.birthdayDatePickerView)
                self.blurEffectView.alpha = 1
                self.birthdayDatePickerView.alpha = 1
                
            }) { _ in
                
            }
            
        }
        
    }
    
    func savePassportExpiry() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.passportExpiryDatePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            let passportDateFormatter = DateFormatter()
            passportDateFormatter.dateFormat = "E, MMM d, yyyy"
            //UserDefaults.standard.set(passportDateFormatter.string(from: self.passportExpiryDatePickerView.datePicker.date), forKey: "passportExpiry")
            
            //print("self.passportExpiryDatePickerView.datePicker.date = \(self.passportExpiryDatePickerView.datePicker.date)")
            
            let date = self.passportExpiryDatePickerView.datePicker.date
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            delegate?.schedulePassportExpiryNotification(expiryDate: date)
            
            DispatchQueue.main.async {
                
                self.passportExpiry.text = "\(passportDateFormatter.string(from: self.passportExpiryDatePickerView.datePicker.date))"
                
            }
            
            self.passportExpiryDatePickerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
            
        }
        
    }
    
    func saveBirthDate() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.birthdayDatePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            let birthDateFormatter = DateFormatter()
            birthDateFormatter.dateFormat = "E, MMM d, yyyy"
            
            DispatchQueue.main.async {
                
                self.dateOfBirth.text = "\(birthDateFormatter.string(from: self.birthdayDatePickerView.datePicker.date))"
                
            }
            
            self.birthdayDatePickerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
            
        }
        
    }
    
    func closeBirthdayDatePicker() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.birthdayDatePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            self.birthdayDatePickerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
        }
        
    }
    
    func closePassportDatePicker() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.passportExpiryDatePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            self.passportExpiryDatePickerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Save(_ sender: AnyObject) {
        
        if username.text == "" {
            
            let alert = UIAlertController(title: "Error in form", message: "Please enter an email.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            saveUserDetails()
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        view.endEditing(true)
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        //#selector(self.keyboardWillShow(notification:))
        //#selector(self.keyboardWillHide(notification:))
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        blurEffectView.addGestureRecognizer(tap)
        
        if (UserDefaults.standard.object(forKey: "userDetailsArray") != nil) {
            userDetailsArray = UserDefaults.standard.object(forKey: "userDetailsArray") as! [String]
            print("This is userDetailsArray\n \(userDetailsArray)")
            
            username.text = userDetailsArray[0]
            firstName.text = userDetailsArray[1]
            surname.text = userDetailsArray[2]
            passportNumber.text = userDetailsArray[3]
            dateOfBirth.text = userDetailsArray[4]
            gender.text = userDetailsArray[5]
            houseAptNumber.text = userDetailsArray[6]
            street1.text = userDetailsArray[7]
            street2.text = userDetailsArray[8]
            city.text = userDetailsArray[9]
            state.text = userDetailsArray[10]
            postcode.text = userDetailsArray[11]
            country.text = userDetailsArray[12]
            passportCountry.text = userDetailsArray[13]
            passportExpiry.text = userDetailsArray[14]
        }
        
        self.username.delegate = self
        self.firstName.delegate = self
        self.surname.delegate = self
        self.passportNumber.delegate = self
        self.dateOfBirth.delegate = self
        self.gender.delegate = self
        self.houseAptNumber.delegate = self
        self.street1.delegate = self
        self.street2.delegate = self
        self.city.delegate = self
        self.state.delegate = self
        self.postcode.delegate = self
        self.country.delegate = self
        self.passportCountry.delegate = self
        self.passportExpiry.delegate = self
    }
    
    func saveUserDetails() {
        
        print("saveUserDetails")
        
        userDetailsArray = []
      
        userDetailsArray.append(username.text!)
        userDetailsArray.append(firstName.text!)
        userDetailsArray.append(surname.text!)
        userDetailsArray.append(passportNumber.text!)
        userDetailsArray.append(dateOfBirth.text!)
        userDetailsArray.append(gender.text!)
        userDetailsArray.append(houseAptNumber.text!)
        userDetailsArray.append(street1.text!)
        userDetailsArray.append(street2.text!)
        userDetailsArray.append(city.text!)
        userDetailsArray.append(state.text!)
        userDetailsArray.append(postcode.text!)
        userDetailsArray.append(country.text!)
        userDetailsArray.append(passportCountry.text!)
        userDetailsArray.append(passportExpiry.text!)
        
        
        
        UserDefaults.standard.set(userDetailsArray, forKey: "userDetailsArray")
        
        print("This is userDetailsArray after clicking save\n\(userDetailsArray)")
        
        performSegue(withIdentifier: "save", sender: self)
        
        //let viewController = self.storyboard! .instantiateViewController(withIdentifier: "AddVaccines") as UIViewController; self.present(viewController, animated: true, completion: nil)

        
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
    
}
