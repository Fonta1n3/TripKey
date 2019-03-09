//
//  FeedTableViewCell.swift
//  TripKey
//
//  Created by Peter on 5/15/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet var shareFlightLabel: UIButton!
    var tapShareFlightAction: ((UITableViewCell) -> Void)?
    @IBOutlet var userName: UILabel!
    
    @IBAction func shareFlight(_ sender: Any) {
        
        tapShareFlightAction?(self)
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

   }

}
