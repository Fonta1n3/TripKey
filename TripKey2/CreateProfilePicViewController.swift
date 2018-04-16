//
//  CreateProfilePicViewController.swift
//  TripKey2
//
//  Created by Peter on 8/21/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import CoreData

var profilePic = UIImage()
var profilePicPath = String()

func getDocumentsURL() -> NSURL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsURL as NSURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL!.path
}

class CreateProfilePicViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBAction func home(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripConsole") as UIViewController; self.present(viewController, animated: true, completion: nil)
        
    }
    
    @IBOutlet var profilePicView: UIImageView!
    var imagePath = fileInDocumentsDirectory(filename: "profilePic.png")
    
    func saveImage (image: UIImage, path: String ){
        
        let pngImageData = UIImagePNGRepresentation(profilePicView.image!)
        
        do {
            
            let result = try pngImageData?.write(to: URL(fileURLWithPath: imagePath), options: .atomic)
            
            print(result)
            
        } catch {
            
            print("There was an error getting the URL path of the photo")
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            profilePicView.image = image
            
        } else {
            
            print("There was a problem getting the image")
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadProfilePic(_ sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveProfilePic(_ sender: AnyObject) {
        self.saveImage(image: profilePic, path: imagePath)
        print("Imgage URL is \(imagePath)")
        profilePicPath = imagePath
         let viewController = self.storyboard! .instantiateViewController(withIdentifier: "profileInfo") as UIViewController; self.present(viewController, animated: true, completion: nil)
    }
   
    @IBAction func GoToProfileWithNextButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "GoToProfileWithoutFB", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profilePic = loadImageFromPath(path: profilePicPath){
            
            profilePicView.image = profilePic
            
            
        } else {
            
            print("error displaying profile pic")
        }
        
        if let loadedImage = loadImageFromPath(path: profilePicPath) {
            print(" Loaded Image: \(loadedImage)")
        } else {
            print("Error loading the image.") }
        print("This is the image URL in the home view controller \(profilePicPath)")
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        print("Loading image from path: \(path)")
        return image
    }
    
    
}
