//
//  userPlace.swift
//  TripKey2
//
//  Created by Peter on 2/20/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class userPlace: UITableViewCell {
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var distanceFromYouLabel: UILabel!
    
    @IBOutlet var coordinatesLabel: UILabel!
    
    var tapCallAction: ((UITableViewCell) -> Void)?
    var tapDirectionsAction: ((UITableViewCell) -> Void)?
    var tapWebsiteAction: ((UITableViewCell) -> Void)?
    var tapMapAction: ((UITableViewCell) -> Void)?
    var tapShareAction: ((UITableViewCell) -> Void)?
    var tapPhotoAction: ((UITableViewCell) -> Void)?
    var tapAddCategoryAction: ((UITableViewCell) -> Void)?
    var tapEditAction: ((UITableViewCell) -> Void)?
    var tapNotesAction: ((UITableViewCell) -> Void)?
    var phoneNumber:String!
    var latitude:Double!
    var longitude:Double!
    var website:String!
    
    @IBOutlet var address: UITextView!
    @IBOutlet var distance: UILabel!
    @IBOutlet var placeName: UILabel!
    
    @IBOutlet var callPlace: UIButton!
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var photos: UIButton!
    @IBOutlet var addTypeButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var notesButton: UIButton!
    
    
    
    
    
    @IBOutlet var coordinates: UITextField!
    
    @IBAction func notes(_ sender: Any) {
        
        tapNotesAction?(self)
    }
    @IBAction func edit(_ sender: Any) {
        
        tapEditAction?(self)
    }
    
    @IBAction func addCategory(_ sender: Any) {
        
        tapAddCategoryAction?(self)
    }
    
    @IBAction func call(_ sender: Any) {
        
        tapCallAction?(self)
        
    }
    
    @IBAction func directions(_ sender: Any) {
        
        tapDirectionsAction?(self)
        
    }
    
    @IBAction func photos(_ sender: Any) {
        
     tapPhotoAction?(self)
        
    }
    
    @IBAction func website(_ sender: Any) {
        
        tapWebsiteAction?(self)
        
    }
    
    @IBAction func map(_ sender: Any) {
        
        tapMapAction?(self)
        
    }
    
    @IBAction func share(_ sender: Any) {
        
        tapShareAction?(self)
        
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }

}
