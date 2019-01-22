//
//  ViewController.swift
//  TripKey2
//
//  Created by Peter on 8/21/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import Parse
import SystemConfiguration

//var userLoginArray = [String]()

class ViewController: UIViewController, UITextFieldDelegate {
    
    var connected:Bool!
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    @IBOutlet var logInView: UIView!
    var signupMode = Bool()
    var loginMode = Bool()
    var activityIndicator = UIActivityIndicatorView()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    
    @IBOutlet var changeSignupModeButton: UIButton!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signupOrLoginButton: UIButton!
    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        self.connected = isReachable
        return (isReachable && !needsConnection)
    }
    
    @IBAction func changeSignupMode(_ sender: AnyObject) {
        if signupMode {
            // Change to login mode
            
            DispatchQueue.main.async {
                self.signupOrLoginButton.setTitle(NSLocalizedString("Log In", comment: ""), for: [])
                self.changeSignupModeButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: [])
                self.messageLabel.text = NSLocalizedString("Don't have an account?", comment: "")
                self.signupMode = false
            }
            
            
        } else {
            // Change to signup mode
            DispatchQueue.main.async {
                self.signupOrLoginButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: [])
                self.changeSignupModeButton.setTitle(NSLocalizedString("Log In", comment: ""), for: [])
                self.messageLabel.text = NSLocalizedString("Already have an account?", comment: "")
                self.signupMode = true
            }
            
        }
    }
    
    @IBAction func signupOrLogin(_ sender: AnyObject) {
        
        if signupMode {
            
            if emailTextField.text == "" || passwordTextField.text == "" {
                
                let alert = UIAlertController(title: NSLocalizedString("Error in form", comment: ""), message: NSLocalizedString("Please enter an username and password", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in self.dismiss(animated: true, completion: nil) }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
            self.signUpNewUser()
                
            }
        }
    }
    
    @IBAction func logIn(_ sender: AnyObject) {
        
        
        
        if signupMode == false {
            
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            let alert = UIAlertController(title: NSLocalizedString("Error in form", comment: ""), message: NSLocalizedString("Please enter an username and password", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in self.dismiss(animated: true, completion: nil) }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {

            //checkPasswordAndEmailBeforeLogin()
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                
               
                
                if error != nil {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    var displayErrorMessage = NSLocalizedString("Please try again later", comment: "")
                    
                    let error = error as NSError?
                    
                    if let errorMessage = error?.userInfo["error"] as? String {
                        
                        displayErrorMessage = errorMessage
                        
                    }
                    
                    print(error as Any)
                    
                    let alert = UIAlertController(title: NSLocalizedString("Login Error", comment: ""), message: displayErrorMessage, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    print("Logged In")
                    
                    self.performSegue(withIdentifier: "goToNearMe", sender: self)
                }
                
            })
            
            }
        }
    }
    
       func signUpNewUser() {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let user = PFUser()
            
            user.username = emailTextField.text!
            user.password = passwordTextField.text!
            
            user.signUpInBackground(block: { (success, error) in
                
                
                
                if error != nil {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    var displayErrorMessage = NSLocalizedString("Please try again later", comment: "")
                    
                    let error = error as NSError?
                    
                    if let errorMessage = error?.userInfo["error"] as? String {
                        
                        displayErrorMessage = errorMessage
                        
                    }
                    
                    print(error as Any)
                    
                    let alert = UIAlertController(title: NSLocalizedString("SignUp Error", comment: ""), message: displayErrorMessage, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    let query = PFQuery(className: "Posts")
                    
                    query.whereKey("userid", equalTo: (PFUser.current()?.objectId!)!)
                    
                    query.findObjectsInBackground(block: { (objects, error) in
                        
                        if let posts = objects {
                            
                            for post in posts {
                                
                                post.deleteInBackground(block: { (success, error) in
                                    
                                    if error != nil {
                                        
                                        print("post can not be deleted")
                                        
                                        
                                    } else {
                                        
                                        print("post deleted")
                                        
                                    }
                                })
                            }
                            
                            
                        }
                    })
                    
                    let post = PFObject(className: "Posts")
                    
                    post["userid"] = PFUser.current()?.objectId!
                    
                    let imageData = UIImagePNGRepresentation(UIImage(named: "default.icon.png")!)
                    
                    let imageFile = PFFile(name: "image.png", data: imageData!)
                    
                    post["imageFile"] = imageFile
                    post["username"] = PFUser.current()?.username
                    
                    post.saveInBackground { (success, error) in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        if error != nil {
                            
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            print("User signed up with Parse")
                            
                            self.performSegue(withIdentifier: "goToNearMe", sender: self)
                            
                            
                       }
                    }
                    
                    
                    
                    
                    
                    
                    //self.performSegue(withIdentifier: "postProfilePic", sender: self)
                }
                
            })
                
                
            
                self.deleteAllUserDefaultData()
            
            
    }
    

    func deleteAllUserDefaultData() {
        
        if (UserDefaults.standard.object(forKey: "frequentFlyerList") != nil) {
            UserDefaults.standard.removeObject(forKey: "frequentFlyerList")
        }
        
        if (UserDefaults.standard.object(forKey: "vaccinesList") != nil) {
            UserDefaults.standard.removeObject(forKey: "vaccinesList")
        }
        
        if (UserDefaults.standard.object(forKey: "emergencyContacts") != nil) {
            UserDefaults.standard.removeObject(forKey: "emergencyContacts")
        }
        
        if (UserDefaults.standard.object(forKey: "userDetailsArray") != nil) {
            UserDefaults.standard.removeObject(forKey: "userDetailsArray")
        }
        
        /*if (UserDefaults.standard.object(forKey: "flights") != nil) {
            UserDefaults.standard.removeObject(forKey: "flights")
        }*/
        
        if (UserDefaults.standard.object(forKey: "tripDictionaries") != nil) {
            UserDefaults.standard.removeObject(forKey: "tripDictionaries")
            
        }
        
        if (UserDefaults.standard.object(forKey: "placeDictionaries") != nil) {
            UserDefaults.standard.removeObject(forKey: "placeDictionaries")
            
        }
        
        if (UserDefaults.standard.object(forKey: "cityDictionaries") != nil) {
            UserDefaults.standard.removeObject(forKey: "cityDictionaries")
            
        }
        
        if (UserDefaults.standard.object(forKey: "countryDictionaries") != nil) {
            UserDefaults.standard.removeObject(forKey: "countryDictionaries")
            
        }
    

        print("All user defaults data deleted for new user sign up.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload viwcontroller")
        
        if launchedBefore == true {
            print("Not first launch.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(false, forKey: "launchedBefore")
        }
        
       signupMode = true
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.alpha = 0
        
        self.changeSignupModeButton.alpha = 0
        self.messageLabel.alpha = 0
        self.logInView.alpha = 0
        self.emailTextField.alpha = 0
        self.passwordTextField.alpha = 0
        self.signupOrLoginButton.alpha = 0
        
        emailTextField.placeholder = NSLocalizedString("Username", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        signupOrLoginButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: [])
        changeSignupModeButton.setTitle(NSLocalizedString("Log In", comment: ""), for: [])
        messageLabel.text = NSLocalizedString("Already have an account?", comment: "")
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
     isInternetAvailable()
        
        
        
        if self.connected == true {
            
            if PFUser.current() != nil {
                
                self.performSegue(withIdentifier: "goToNearMe", sender: self)
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.blurEffectView.frame = self.view.bounds
                    self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.blurEffectView.alpha = 1
                    
                    
                    self.changeSignupModeButton.alpha = 1
                    self.messageLabel.alpha = 1
                    self.logInView.alpha = 1
                    self.emailTextField.alpha = 1
                    self.passwordTextField.alpha = 1
                    self.signupOrLoginButton.alpha = 1
                    
                }) { _ in
                    
                    self.view.addSubview(self.blurEffectView)
                    self.view.addSubview(self.logInView)
                    
                }
            }

        } else {
            
            self.displayAlert(title: NSLocalizedString("No internet connection.", comment: ""), message: "Offline use for TripKey is coming soon, in the meantime please check your signal.")
        }
        
        
        
 
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
    
    func addActivityIndicatorCenter() {
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
}
    


