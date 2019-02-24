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

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    let shareButton = UIButton()
    let userid = UserDefaults.standard.object(forKey: "userId") as! String
    let qrView = UIImageView()
    let backButton = UIButton()
    var activityIndicator = UIActivityIndicatorView()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var signupOrLoginButton: UIButton!
    let qrLabel = UILabel()
    
    func addButtons() {
        
        DispatchQueue.main.async {
            
            self.backButton.removeFromSuperview()
            self.backButton.frame = CGRect(x: 5, y: 20, width: 25, height: 25)
            self.backButton.showsTouchWhenHighlighted = true
            let image = UIImage(imageLiteralResourceName: "backButton.png")
            self.backButton.setImage(image, for: .normal)
            self.backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            
            
            self.shareButton.showsTouchWhenHighlighted = true
            self.shareButton.setTitle("Share", for: .normal)
            self.shareButton.setTitleColor(UIColor.white, for: .normal)
            self.shareButton.backgroundColor = UIColor.clear
            self.shareButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.shareButton.addTarget(self, action: #selector(self.share), for: .touchUpInside)
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
                            displayAlert(viewController: self, title: "Success", message: "You updated your username to \(String(describing: username!))")
                        }
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload viwcontroller")
        
        addButtons()
        emailTextField.delegate = self
        emailTextField.alpha = 0
        signupOrLoginButton.alpha = 0
        qrView.alpha = 0
        qrLabel.alpha = 0
        qrLabel.text = "Share your QR Code so others can share flights with you"
        qrLabel.numberOfLines = 0
        qrLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
        qrLabel.textColor = UIColor.white
        qrLabel.textAlignment = .center
        
        var username = ""
        
        let query = PFQuery(className: "Posts")
        query.whereKey("userid", equalTo: UserDefaults.standard.object(forKey: "userId") as! String)
        query.findObjectsInBackground(block: { (objects, error) in
            if let posts = objects {
                for post in posts {
                    DispatchQueue.main.async {
                        username = post["username"] as! String
                        self.emailTextField.text = username
                    }
                }
            }
        })
       
    }
    
    override func viewWillLayoutSubviews() {
        qrView.frame = CGRect(x: 40, y: (view.frame.maxY / 2) - ((view.frame.width - 80) / 2), width: view.frame.width - 80, height: view.frame.width - 80)
        shareButton.frame = CGRect(x: view.frame.maxX - 90, y: view.frame.maxY - 60, width: 80, height: 55)
        qrLabel.frame = CGRect(x: 0, y: qrView.frame.maxY, width: view.frame.width, height: 18)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let qrImage = generateQrCode(key: userid)
        qrView.image = qrImage
        view.addSubview(qrView)
        view.addSubview(qrLabel)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.emailTextField.alpha = 1
            self.signupOrLoginButton.alpha = 1
            self.qrView.alpha = 1
            self.qrLabel.alpha = 1
            
        })
        
    }
    
    func generateQrCode(key: String) -> UIImage? {
        print("generateQrCode")
        
        /*// Get define string to encode
        let myString = key
        // Get data from the string
        let data = myString.data(using: String.Encoding.ascii)
        // Get a QR CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        // Input the data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Get the output image
        guard let qrImage = qrFilter.outputImage else { return nil }
        // Scale the image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.applying(transform)
        // Invert the colors
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return nil }
        colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputInvertedImage = colorInvertFilter.outputImage else { return nil }
        // Replace the black with transparency
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return nil }
        // Do some processing to get the UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        let processedImage = UIImage(cgImage: cgImage)
        UIView.animate(withDuration: 0.3) {
            self.backgroundImage.alpha = 0
        }
        
        return processedImage*/
        
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
    
    func addActivityIndicatorCenter() {
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
    }
    
    func getDocumentsDirectory() -> URL {
        print("getDocumentsDirectory")
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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


