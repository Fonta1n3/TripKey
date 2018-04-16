//
//  placeOverviewViewController.swift
//  TripKey2
//
//  Created by Peter on 2/1/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
//import Parse
//import StoreKit

class placeOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var activityIndicator:UIActivityIndicatorView!
    let blurEffectViewActivity = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var activityLabel = UILabel()
    var placeDictionary:Dictionary<String,String>!
    var users = [String: String]()
    var userNames = [String]()
    var websiteString:String! = ""
    var address:String! = ""
    var types:NSArray! = []
    var userAddedPlaceDictionaryArray = [Dictionary<String,String>]()
    var userSwipedBack:Bool! = false
    var imageArrayStrings:[String]! = []
    var placeReviews:[String] = []
    var phoneNumberString:String!
    var imageArray:[UIImage]! = []
    var attributedTextArray:[NSAttributedString]! = []
    var roundedDistance:String!
    var placeId:String!
    var photoArray:[GMSPlacePhotoMetadata]! = []
    var tappedMarkerLatitude:Double!
    var tappedMarkerLongitude:Double!
    var placeType:String!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var distanceLabel: UIButton!
    @IBOutlet var phoneNumber: UIButton!
    @IBOutlet var website: UIButton!
    @IBOutlet var pictureTable: UITableView!
    @IBOutlet var reviewTable: UITableView!
    @IBOutlet var seeReviewsLabel: UIButton!
    var photosMode:Bool!
    var reviewsMode:Bool!
    
    @IBAction func seeReviews(_ sender: Any) {
        
        if self.reviewTable.isHidden == true {
            
          self.reviewTable.isHidden = false
            self.pictureTable.isHidden = true
            seeReviewsLabel.setTitle("See Photos", for: [])
            
        } else if self.pictureTable.isHidden == true {
            
            self.reviewTable.isHidden = true
            self.pictureTable.isHidden = false
            seeReviewsLabel.setTitle("See Reviews", for: [])
            
        }
        
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //googleBanner.adUnitID = "ca-app-pub-1006371177832056/4508293729"
        //googleBanner.rootViewController = self
        //googleBanner.load(GADRequest())
        
        
        
      }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.object(forKey: "placeDictionaryForOverview") != nil {
            
            placeDictionary = UserDefaults.standard.object(forKey: "placeDictionaryForOverview") as! Dictionary<String,String>
            //print("placeDictionary = \(placeDictionary)")
            
            placeId = placeDictionary["Place ID"]!
            UserDefaults.standard.removeObject(forKey: "placeDictionaryForOverview")
            
            parsePlaceId()
            
            pictureTable.reloadData()
            reviewTable.reloadData()
            
        }
        
        if UserDefaults.standard.object(forKey: "roundedDistance") != nil {
            
            roundedDistance = UserDefaults.standard.object(forKey: "roundedDistance") as! String
        }
        
        if UserDefaults.standard.object(forKey: "tappedMarkerLatitude") != nil {
            
            tappedMarkerLatitude = UserDefaults.standard.object(forKey: "tappedMarkerLatitude") as! Double
        }
        
        if UserDefaults.standard.object(forKey: "tappedMarkerLongitude") != nil {
            
            tappedMarkerLongitude = UserDefaults.standard.object(forKey: "tappedMarkerLongitude") as! Double
        }
        
        if photosMode == true {
            
            self.reviewTable.isHidden = true
            self.pictureTable.isHidden = false
            seeReviewsLabel.setTitle("See Reviews", for: [])
            
        } else if reviewsMode == true {
            
            self.reviewTable.isHidden = false
            self.pictureTable.isHidden = true
            seeReviewsLabel.setTitle("See Photos", for: [])
        }
        
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == pictureTable {
         
            let pictureCell = pictureTable.dequeueReusableCell(withIdentifier: "placePicture", for: indexPath) as! placePictureTableViewCell
            
            
            pictureCell.attributionText.attributedText = self.attributedTextArray[indexPath.row]
            
            DispatchQueue.main.async {
                
                pictureCell.attributionText.setContentOffset(CGPoint.zero, animated: false)
                
            }
            
            pictureCell.placePicture.image = self.imageArray[indexPath.row]
            
         
            return pictureCell
         
        } else if tableView == reviewTable {
         
            let reviewCell = reviewTable.dequeueReusableCell(withIdentifier: "placeReview", for: indexPath) as! PlaceReviewTableViewCell
         
            reviewCell.placeReview.text = self.placeReviews[indexPath.row]
         
            return reviewCell
         
        } else {
            
            let reviewCell = pictureTable.dequeueReusableCell(withIdentifier: "placeReview", for: indexPath) as! PlaceReviewTableViewCell
            
            reviewCell.placeReview.text = self.placeReviews[indexPath.row]
            
            return reviewCell
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == pictureTable {
            
            return self.imageArray.count
                
        } else if tableView == reviewTable {
            
            return self.placeReviews.count
            
        } else {
            
            return 1
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    
    func parsePlaceId() {
        
        addActivityIndicatorPhotos()
        activityLabel.text = "Loading"
        
        let url = NSURL(string:"https://maps.googleapis.com/maps/api/place/details/json?placeid=" + self.placeId! + "&key=AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw")
        
        var name:String! = ""
        var reviews:NSArray! = []
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityLabel.removeFromSuperview()
                        self.blurEffectViewActivity.removeFromSuperview()
                        self.displayAlert(title: "Error", message: "Please check your connection and try again")
                    }
                    
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonPlaceResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            //print("jsonPlaceResult = \(jsonPlaceResult)")
                            
                            if let placeDictionaryCheck = jsonPlaceResult["result"] as? NSDictionary {
                                
                                let place = placeDictionaryCheck
                                
                                if let nameCheck = place["name"] as? String {
                                    
                                    name = nameCheck
                                    
                                    DispatchQueue.main.async {
                                        
                                        //placeInfoWindow.name.text = name
                                        self.placeName.text = name
                                        
                                    }
                                }
                                
                                
                                //photos
                                DispatchQueue.main.async {
                                    
                                    GMSPlacesClient.shared().lookUpPhotos(forPlaceID: self.placeId) { (photos, error) -> Void in
                                        
                                        if let error = error {
                                            
                                            DispatchQueue.main.async {
                                                self.activityIndicator.stopAnimating()
                                                self.activityLabel.removeFromSuperview()
                                                self.blurEffectViewActivity.removeFromSuperview()
                                                self.displayAlert(title: "Error", message: "Unable to load photos.")
                                            }
                                            
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                
                                                if let photos = photos?.results {
                                                    
                                                    for picture in photos {
                                                        
                                                        //self.photoArray.append(picture)
                                                        DispatchQueue.main.async {
                                                            
                                                            GMSPlacesClient.shared().loadPlacePhoto(picture, callback: {
                                                                
                                                                (photo, error) -> Void in
                                                                
                                                                if let error = error {
                                                                    
                                                                    //print("Error: \(error.localizedDescription)")
                                                                    
                                                                } else {
                                                                    
                                                                    DispatchQueue.main.async {
                                                                        
                                                                        //pictureCell.placePicture.image = photo;
                                                                        //pictureCell.attributionText.attributedText = self.photoArray[indexPath.row].attributions;
                                                                        self.imageArray.append(photo!)
                                                                        self.imageArrayStrings.append("1 photo")
                                                                        self.attributedTextArray.append(picture.attributions!)
                                                                        //print("imageArray = \(self.imageArray)")
                                                                        //print("attributedTextArray = \(self.attributedTextArray)")
                                                                        DispatchQueue.main.async {
                                                                            self.activityIndicator.stopAnimating()
                                                                            self.activityLabel.removeFromSuperview()
                                                                            self.blurEffectViewActivity.removeFromSuperview()
                                                                        }
                                                                        self.pictureTable.reloadData()
                                                                        
                                                                    }
                                                                    
                                                                }
                                                                
                                                            })
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                if let reviewsCheck = place["reviews"] as? NSArray {
                                    
                                    reviews = reviewsCheck
                                    //print("reviews = \(reviews)")
                                    //print("reviews count = \(reviews.count)")
                                    
                                    
                                    if reviews.count > 0 {
                                        
                                        for item in reviews {
                                            
                                            DispatchQueue.main.async {
                                                
                                                let reviewDictionary:NSDictionary = item as! NSDictionary
                                                let placeReview = reviewDictionary["text"] as! String
                                                self.placeReviews.append(placeReview)
                                                self.reviewTable.reloadData()
                                                //print("placeReviews = \(self.placeReviews)")
                                                
                                            }
                                            
                                        }
                                        
                                        //print("placeReviews = \(self.placeReviews)")
                                        
                                    }
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
                            
                        } catch {
                            
                            print("JSon processing failed")
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.activityLabel.removeFromSuperview()
                                self.blurEffectViewActivity.removeFromSuperview()
                                self.displayAlert(title: "Error", message: "Unable to load photos.")
                            }
                            
                        }
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func addActivityIndicatorPhotos() {
        
        
        
        activityLabel.frame = CGRect(x: self.view.center.x, y: self.view.frame.maxY - 141, width: 150, height: 20)
        activityLabel.center.x = self.view.center.x
        activityLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        activityLabel.textColor = UIColor.white
        activityLabel.textAlignment = .center
        activityLabel.alpha = 0
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: (self.view.frame.maxY - 191), width: 50, height: 50))
        activityIndicator.center.x = self.view.center.x
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.isUserInteractionEnabled = true
        activityIndicator.startAnimating()
        activityIndicator.alpha = 0
        blurEffectViewActivity.frame = CGRect(x: self.view.center.x, y: self.view.frame.maxY - 201, width: 150, height: 90)
        blurEffectViewActivity.center.x = self.view.center.x
        blurEffectViewActivity.alpha = 0
        blurEffectViewActivity.layer.cornerRadius = 20
        blurEffectViewActivity.clipsToBounds = true
        view.addSubview(self.blurEffectViewActivity)
        view.addSubview(self.activityLabel)
        view.addSubview(activityIndicator)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blurEffectViewActivity.alpha = 1
            self.activityIndicator.alpha = 1
            self.activityLabel.alpha = 1
            
        }) { (true) in
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLongitude")
        UserDefaults.standard.removeObject(forKey: "selectedPlaceLatitude")
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.userSwipedBack = true
        
        UserDefaults.standard.set(userSwipedBack, forKey: "userSwipedBack")
        
        dismiss(animated: false, completion: nil)
        
        self.userSwipedBack = false
    }
    
   

}
