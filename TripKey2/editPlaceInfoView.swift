//
//  editPlaceInfoView.swift
//  TripKey
//
//  Created by Peter on 7/16/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class editPlaceInfoView: UIView {
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var editPlaceInfo: UILabel!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    

    @IBOutlet var placeAddress: UITextView!
    
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placePhoneNumber: UITextField!
    @IBOutlet var placeWebsite: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet var placeCountry: UITextField!
    @IBOutlet var placeState: UITextField!
    @IBOutlet var placeCity: UITextField!
    @IBOutlet var placeLatitude: UITextField!
    @IBOutlet var placeLongitude: UITextField!
    @IBOutlet var placeNotes: UITextView!
    
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var save: UIButton!
    
    
    

}
