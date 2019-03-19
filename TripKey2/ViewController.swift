//
//  ViewController.swift
//  TripKey2
//
//  Created by Peter on 8/21/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import Parse
import EFQRCode

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var backgroundImage: UIImageView!
    let shareButton = UIButton()
    let userid = UserDefaults.standard.object(forKey: "userId") as! String
    let qrView = UIImageView()
    let profileImage = UIImageView()
    let backButton = UIButton()
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var signupOrLoginButton: UIButton!
    let qrLabel = UILabel()
    let activityCenter = CenterActivityView()
    
    func addButtons() {
        
        DispatchQueue.main.async {
            
            self.backButton.removeFromSuperview()
            let device = UIDevice.modelName
            
            switch device {
                
            case "Simulator iPhone X",
                 "iPhone X",
                 "Simulator iPhone XS",
                 "Simulator iPhone XR",
                 "Simulator iPhone XS Max":
                
                self.backButton.frame = CGRect(x: 5, y: 40, width: 25, height: 25)
                
            default:
                
                self.backButton.frame = CGRect(x: 5, y: 20, width: 25, height: 25)
                
            }
            
            self.backButton.showsTouchWhenHighlighted = true
            let image = UIImage(imageLiteralResourceName: "backButton.png")
            self.backButton.setImage(image, for: .normal)
            self.backButton.addTarget(self, action: #selector(self.goBack), for: .allTouchEvents)
            self.view.addSubview(self.backButton)
            
            self.shareButton.showsTouchWhenHighlighted = true
            self.shareButton.setTitle("Share", for: .normal)
            self.shareButton.setTitleColor(UIColor.white, for: .normal)
            self.shareButton.backgroundColor = UIColor.clear
            self.shareButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.shareButton.addTarget(self, action: #selector(self.share), for: .allTouchEvents)
            self.view.addSubview(self.shareButton)
            
        }
        
    }
    
    @objc func share() {
        
        DispatchQueue.main.async {
            
            let imageToShare = self.qrView.image?.withBackground(color: .blue)
            
            if let data = UIImagePNGRepresentation(imageToShare!) {
                
                let fileName = self.getDocumentsDirectory().appendingPathComponent("tripkey.png")
                
                try? data.write(to: fileName)
                
                let objectsToShare = [fileName]
                
                DispatchQueue.main.async {
                    
                    let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    self.present(activityController, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateUsername(_ sender: Any) {
        
        addActivityIndicatorCenter(description: "Updating Username")
        
        let username = emailTextField.text
        
        if emailTextField.text != "" {
            
            let query = PFQuery(className: "Posts")
            query.whereKey("userid", equalTo: self.userid)
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let posts = objects {
                    
                    for post in posts {
                        
                        post.deleteInBackground{ (success, error) in
                            
                            if error != nil {
                                
                                print("error deleting previous posts")
                                
                            } else {
                                
                                print("deleted all previous posts")
                                
                            }
                            
                        }
                        
                    }
                    
                    let post = PFObject(className: "Posts")
                    post["userid"] = self.userid
                    post["username"] = username
                    post.saveInBackground { (success, error) in
                        
                        if error != nil {
                            
                            print("error adding userid and username to posts")
                            
                        } else {
                            
                            print("User updated username")
                            self.emailTextField.resignFirstResponder()
                            self.activityCenter.remove()
                            let successView = SuccessAlertView()
                            successView.labelText = "Username updated to \(String(describing: username!))"
                            successView.addSuccessView(viewController: self)
                            
                        }
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload viwcontroller")
        
        imagePicker.delegate = self
        addButtons()
        emailTextField.delegate = self
        emailTextField.alpha = 0
        signupOrLoginButton.alpha = 0
        profileImage.alpha = 0
        qrView.alpha = 0
        qrLabel.alpha = 0
        qrLabel.text = "Share your QR Code so others can share flights with you"
        qrLabel.adjustsFontSizeToFitWidth = true
        qrLabel.numberOfLines = 0
        qrLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
        qrLabel.textColor = UIColor.white
        qrLabel.textAlignment = .center
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        
        var username = ""
        
        let query = PFQuery(className: "Posts")
        query.whereKey("userid", equalTo: UserDefaults.standard.object(forKey: "userId") as! String)
        query.findObjectsInBackground(block: { (objects, error) in
            if let posts = objects {
                for post in posts {
                    print("post = \(post)")
                    DispatchQueue.main.async {
                        username = post["username"] as! String
                        self.emailTextField.text = username
                        
                        if let imagedata = post["userProfile"] as? PFFileObject {
                            
                            if let photo = imagedata as? PFFileObject {
                                photo.getDataInBackground(block: {
                                    PFDataResultBlock in
                                    if PFDataResultBlock.1 == nil {//PFDataResultBlock.1 is Error
                                        if let image = UIImage(data:PFDataResultBlock.0!){
                                            //PFDataResultBlock.0 is Data
                                            
                                            DispatchQueue.main.async {
                                                self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
                                                self.profileImage.clipsToBounds = true
                                                self.profileImage.image = image
                                                self.profileImage.contentMode = .scaleAspectFill
                                            }
                                            
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
        
        let qrImage = generateQrCode(key: userid)
        qrView.image = qrImage
        profileImage.image = UIImage(named: "icons8-male-user-filled-50.png")
        view.addSubview(profileImage)
        view.addSubview(qrView)
        view.addSubview(qrLabel)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.profileImage.alpha = 1
            self.emailTextField.alpha = 1
            self.signupOrLoginButton.alpha = 1
            self.qrView.alpha = 1
            self.qrLabel.alpha = 1
            
        })
       
    }
    
    override func viewWillLayoutSubviews() {
        qrView.frame = CGRect(x: 40, y: emailTextField.frame.maxY + 10, width: view.frame.width - 80, height: view.frame.width - 80)
        shareButton.frame = CGRect(x: view.frame.maxX - 90, y: view.frame.maxY - 60, width: 80, height: 55)
        qrLabel.frame = CGRect(x: 0, y: qrView.frame.maxY, width: view.frame.width, height: 18)
        profileImage.frame = CGRect(x: (view.frame.maxX / 2) - 45, y: 40, width: 80, height: 80)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
    func imageTapped() {
        
        print("imageTapped")
        
        chooseImageFromLibrary()
    }
    
    func generateQrCode(key: String) -> UIImage? {
        print("generateQrCode")
        
        let pic = UIImage(named: "Tripkey-logo-white.png")!
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(CIImage(image: pic), forKey: kCIInputImageKey)
        filter.setValue(1.0, forKey: kCIInputIntensityKey)
        let ctx = CIContext(options:nil)
        let watermark = ctx.createCGImage(filter.outputImage!, from:filter.outputImage!.extent)
        let cgImage = EFQRCode.generate(content: key,
                                        size: EFIntSize.init(width: 256, height: 256),
                                        backgroundColor: UIColor.clear.cgColor,
                                        foregroundColor: UIColor.white.cgColor,
                                        watermark: watermark,
                                        watermarkMode: EFWatermarkMode.center,
                                        inputCorrectionLevel: EFInputCorrectionLevel.h,
                                        icon: nil,
                                        iconSize: nil,
                                        allowTransparent: false,
                                        pointShape: EFPointShape.circle,
                                        mode: EFQRCodeMode.none,
                                        binarizationThreshold: 0,
                                        magnification: EFIntSize.init(width: 50, height: 50),
                                        foregroundPointOffset: 0)
        let qrImage = UIImage(cgImage: cgImage!)
        
        return qrImage
        
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
    
    func getDocumentsDirectory() -> URL {
        print("getDocumentsDirectory")
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
        
        addActivityIndicatorCenter(description: "Uploading Profile Photo")
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let imageData = UIImageJPEGRepresentation(pickedImage, 0.5)
            if let imageFile = PFFileObject(name:"avatar.jpg", data:imageData!) as? PFFileObject {
                
                imageFile.saveInBackground { (result, error) in
                    if let error = error{
                        print(error)
                    }else{
                        let query = PFQuery(className: "Posts")
                        query.whereKey("userid", equalTo: self.userid)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if let posts = objects {
                                
                                posts[0]["userProfile"] = imageFile
                                
                                //posts[0].saveInBackground()
                                
                                posts[0].saveInBackground(block: { (success, error) in
                                    
                                    if error != nil {
                                        
                                        print("error saving profile image")
                                        self.activityCenter.remove()
                                        displayAlert(viewController: self, title: "Error", message: "We had an issue uploading your profile photo")
                                        
                                    } else {
                                        
                                        print("success saving profile image")
                                        self.activityCenter.remove()
                                        let successView = SuccessAlertView()
                                        successView.labelText = "Profile photo uploaded!"
                                        successView.addSuccessView(viewController: self)
                                        
                                        DispatchQueue.main.async {
                                            self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
                                            self.profileImage.clipsToBounds = true
                                            self.profileImage.image = pickedImage
                                            self.profileImage.contentMode = .scaleAspectFill
                                        }
                                        
                                    }
                                    
                                })
                                
                            }
                        })
                        
                    }
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
    
extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(cgImage!, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
}


