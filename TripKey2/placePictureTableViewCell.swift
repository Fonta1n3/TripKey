//
//  placePictureTableViewCell.swift
//  TripKey2
//
//  Created by Peter on 2/1/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit

class placePictureTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet var placePicture: UIImageView!
    
    @IBOutlet var attributionText: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.attributionText.delegate = self
        
        DispatchQueue.main.async {
            
            self.attributionText.setContentOffset(CGPoint.zero, animated: false)
            
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                  in characterRange: NSRange) -> Bool {
        // Make links clickable.
        return true
    }

}
