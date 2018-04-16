//
//  placeInfoWindow.swift
//  TripKey2
//
//  Created by Peter on 1/25/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class placeInfoWindow: UIView {
    
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var reviewsButton: UIButton!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var goToPhotos: UIButton!
    
    var tapGoToPhotos: ((Void) -> Void)?
    var tapCall: ((Void) -> Void)?
    var tapDirections: ((Void) -> Void)?
    var tapPhotos: ((Void) -> Void)?
    var tapReviews: ((Void) -> Void)?
    var tapShare: ((Void) -> Void)?
    var tapWebsite: ((Void) -> Void)?
    
    @IBOutlet var midView: UIView!
    @IBOutlet var topView: UIView!
    @IBOutlet var pictureView: UIView!
    @IBOutlet var openOrClosed: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var distanceFromUser: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var priceRange: UILabel!
    @IBOutlet var icon: UIImageView!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var phoneNumber: UILabel!
    @IBOutlet var website: UILabel!
    @IBOutlet var address: UILabel!
    
    @IBOutlet var copyright: UILabel!
    @IBAction func goToPhotosAction(_ sender: Any) {
        
        tapGoToPhotos?()
    }
    @IBAction func call(_ sender: Any) {
        
        tapCall?()
    }
    
    @IBAction func directions(_ sender: Any) {
        
        tapDirections?()
    }
    @IBAction func photos(_ sender: Any) {
        
        tapPhotos?()
    }
    @IBAction func reviews(_ sender: Any) {
        
        tapReviews?()
    }
    @IBAction func share(_ sender: Any) {
        
        tapShare?()
    }
    @IBAction func website(_ sender: Any) {
        
        tapWebsite?()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
