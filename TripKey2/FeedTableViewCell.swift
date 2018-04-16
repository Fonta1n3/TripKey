//
//  FeedTableViewCell.swift
//  TripKey
//
//  Created by Peter on 5/15/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    
    @IBOutlet var shareMyLocationLabel: UIButton!
    @IBOutlet var seeLocationLabel: UIButton!
    @IBOutlet var shareFlightLabel: UIButton!
    @IBOutlet var sharePlaceLabel: UIButton!
    
    var tapShareLocationAction: ((UITableViewCell) -> Void)?
    var tapSeeLocationAction: ((UITableViewCell) -> Void)?
    var tapShareFlightAction: ((UITableViewCell) -> Void)?
    var tapSharePlaceAction: ((UITableViewCell) -> Void)?

    @IBOutlet var postedImage: UIImageView!
    
    @IBOutlet var userName: UILabel!
    
    @IBAction func shareLocation(_ sender: Any) {
        
        tapShareLocationAction?(self)
        
    }
    
    @IBAction func seeLocation(_ sender: Any) {
        
        tapSeeLocationAction?(self)
        
    }
    
    @IBAction func shareFlight(_ sender: Any) {
        
        tapShareFlightAction?(self)
        
    }
    
    @IBAction func sharePlace(_ sender: Any) {
        
        tapSharePlaceAction?(self)
        
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
