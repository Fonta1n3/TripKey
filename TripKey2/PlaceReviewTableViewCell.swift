//
//  PlaceReviewTableViewCell.swift
//  TripKey2
//
//  Created by Peter on 2/4/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class PlaceReviewTableViewCell: UITableViewCell {

    @IBOutlet var placeReview: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        DispatchQueue.main.async {
            
            self.placeReview.setContentOffset(CGPoint.zero, animated: false)
            
        }
        
        
        
        
    }

}
