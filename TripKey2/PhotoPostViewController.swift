//
//  PhotoPostViewController.swift
//  TripKey
//
//  Created by Peter on 5/14/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import Parse

class PhotoPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet var deleteProfilePicLabel: UIButton!
    @IBOutlet var nextLabel: UIButton!
    @IBOutlet var uploadLabel: UIButton!
    @IBOutlet var chooseProfilePicLabel: UIButton!
    var activityIndicator = UIActivityIndicatorView()
    var users = [String]()
    var imageFiles = [PFFile]()

    @IBOutlet var photoToPost: UIImageView!
    
    @IBAction func deleteProfilePic(_ sender: Any) {
        
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
                            
                            let post = PFObject(className: "Posts")
                            
                            post["userid"] = PFUser.current()?.objectId!
                            
                            let imageData = UIImagePNGRepresentation(self.photoToPost.image!)
                            
                            let imageFile = PFFile(name: "image.png", data: imageData!)
                            
                            post["imageFile"] = imageFile
                            
                            post["username"] = PFUser.current()?.username
                            
                            post.saveInBackground { (success, error) in
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                
                                if error != nil {
                                    
                                    let alert = UIAlertController(title: NSLocalizedString("Could not save profile pic", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Please try again later", comment: ""), style: .default, handler: { (action) in
                                        
                                        //self.performSegue(withIdentifier: "skipProfilePic", sender: self)
                                        
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                } else {
                                    
                                    let alert = UIAlertController(title: NSLocalizedString("Profile Picture Deleted!", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        
                                        //self.performSegue(withIdentifier: "skipProfilePic", sender: self)
                                        
                                        
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    
                                    //self.photoToPost.image = UIImage(named: "default.icon.png")
                                    
                                    
                                }
                            }
                            
                        }
                    })
                }
                
                
            }
            
            self.photoToPost.image = UIImage(named: "default.icon.png")
        })
        
        
        
        
    }
    
    func sFunc_imageFixOrientation(img:UIImage) -> UIImage {
        
        
        // No-op if the orientation is already correct
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (img.imageOrientation == UIImageOrientation.down
            || img.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: img.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        }
        
        if (img.imageOrientation == UIImageOrientation.left
            || img.imageOrientation == UIImageOrientation.leftMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }
        
        if (img.imageOrientation == UIImageOrientation.right
            || img.imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: img.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
        }
        
        if (img.imageOrientation == UIImageOrientation.upMirrored
            || img.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (img.imageOrientation == UIImageOrientation.leftMirrored
            || img.imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: img.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(img.size.width), height: Int(img.size.height),
                                      bitsPerComponent: img.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: img.cgImage!.colorSpace!,
                                      bitmapInfo: img.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (img.imageOrientation == UIImageOrientation.left
            || img.imageOrientation == UIImageOrientation.leftMirrored
            || img.imageOrientation == UIImageOrientation.right
            || img.imageOrientation == UIImageOrientation.rightMirrored
            ) {
            
            
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.height,height:img.size.width))
            
        } else {
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.width,height:img.size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }
    
    
    @IBAction func chooseAnImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func skip(_ sender: Any) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
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
        
        let imageData = UIImagePNGRepresentation(photoToPost.image!)
        
        let imageFile = PFFile(name: "image.png", data: imageData!)
        
        post["imageFile"] = imageFile
        post["username"] = PFUser.current()?.username
        
        post.saveInBackground { (success, error) in
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil {
                
                let alert = UIAlertController(title: NSLocalizedString("Could not post image", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                    
                    //self.performSegue(withIdentifier: "skipProfilePic", sender: self)
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: NSLocalizedString("Profile Picture Posted!", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                    
                    //self.performSegue(withIdentifier: "skipProfilePic", sender: self)
                    
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
                //self.photoToPost.image = UIImage(named: "default.icon.png")
                
                
            }
        }
        
        performSegue(withIdentifier: "skipProfilePic", sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let fixedImage = sFunc_imageFixOrientation(img: image)
            
            photoToPost.image = fixedImage
            
        } else {
            
            print("There was an error getting the image")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func postImage(_ sender: Any) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
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
        
        let imageData = UIImageJPEGRepresentation(photoToPost.image!, 0.1)! as Data
        
        //let imageData = UIImagePNGRepresentation(photoToPost.image!)
        
        
        let imageFile = PFFile(name: "image.jpg", data: imageData)
        
        post["imageFile"] = imageFile
        post["username"] = PFUser.current()?.username!
        
        post.saveInBackground { (success, error) in
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil {
                
                let alert = UIAlertController(title: NSLocalizedString("Could not post image", comment: ""), message: NSLocalizedString("Please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                    //self.performSegue(withIdentifier: "skipProfilePic", sender: self)
                    
                
                }))
                
                self.present(alert, animated: true, completion: nil)
            
            } else {
                
                let alert = UIAlertController(title: NSLocalizedString("Profile Picture Posted!", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                    
                    self.performSegue(withIdentifier: "skipProfilePic", sender: self)
                    
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
                //self.photoToPost.image = UIImage(named: "default.icon.png")
                
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextLabel.titleLabel?.text = NSLocalizedString("Next", comment: "")
        deleteProfilePicLabel.titleLabel?.text = NSLocalizedString("Delete Profile Picture", comment: "")
        uploadLabel.titleLabel?.text = NSLocalizedString("Upload", comment: "")
        chooseProfilePicLabel.titleLabel?.text = NSLocalizedString("Choose a Profile Picture", comment: "")

        let query = PFUser.query()
        
        query?.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                
                self.users.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        self.users.append(user.objectId!)
                        
                        let pictureQuery = PFQuery(className: "Posts")
                        
                        pictureQuery.whereKey("userid", equalTo: self.users[0])
                        
                        print("\((PFUser.current()?.username)!)")
                        
                        pictureQuery.findObjectsInBackground(block: { (objects, error) in
                            
                            if let posts = objects {
                                
                                for object in posts {
                                    
                                    if let post = object as? PFObject {
                                        
                                        self.imageFiles.append(post["imageFile"] as! PFFile)
                                        
                                        self.imageFiles[0].getDataInBackground { (data, error) in
                                            
                                            if let imageData = data {
                                                
                                                if let downloadedImage = UIImage(data: imageData) {
                                                    
                                                    self.photoToPost.image = downloadedImage
                                                    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


