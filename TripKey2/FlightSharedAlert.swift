//
//  FlightSharedAlert.swift
//  TripKey
//
//  Created by Peter on 18/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation

import UIKit

class FlightSharedAlertView: UIView {
    
    let profileImageView = UIImageView()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let label = UILabel()
    var labelText = String()
    let nameLabel = UILabel()
    var nameLabelText = String()
    var profileImage = UIImage()
    var yesButtonAction = {}
    var noButtonAction = {}
    let yesButton = UIButton()
    let noButton = UIButton()
    
    func addSuccessView(viewController: UIViewController) {
        
        profileImageView.alpha = 0
        blurView.alpha = 0
        label.alpha = 0
        nameLabel.alpha = 0
        yesButton.alpha = 0
        noButton.alpha = 0
        
        
        blurView.frame = viewController.view.frame
        viewController.view.addSubview(blurView)
        
        profileImageView.frame = CGRect(x: blurView.center.x - 50,
                                     y: (blurView.center.y - 50) - (blurView.frame.height / 5),
                                     width: 100,
                                     height: 100)
        
        nameLabel.frame = CGRect(x: 0, y: profileImageView.frame.maxY + 5, width: blurView.frame.width, height: 30)
        nameLabel.font = UIFont.init(name: "HelveticaNeue", size: 20)
        nameLabel.textColor = UIColor.white
        nameLabel.text = nameLabelText
        nameLabel.textAlignment = .center
        addShadow(view: nameLabel)
        blurView.contentView.addSubview(nameLabel)
        
        profileImageView.image = profileImage
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.alpha = 0
        addShadow(view: profileImageView)
        blurView.contentView.addSubview(profileImageView)
        
        label.frame = CGRect(x: 0,
                             y: nameLabel.frame.maxY + 10,
                             width: blurView.frame.width,
                             height: 100)
        
        label.font = UIFont.init(name: "HelveticaNeue", size: 20)
        label.text = labelText
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        addShadow(view: label)
        label.numberOfLines = 0
        label.textAlignment = .center
        blurView.contentView.addSubview(label)
        
        yesButton.frame = CGRect(x: blurView.frame.maxX - 90, y: blurView.frame.maxY - 100, width: 80, height: 30)
        noButton.frame = CGRect(x: 10, y: blurView.frame.maxY - 100, width: 80, height: 30)
        
        yesButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noAction), for: .touchUpInside)
        
        yesButton.setTitle("Yes", for: .normal)
        noButton.setTitle("No", for: .normal)
        
        yesButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        noButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        
        yesButton.titleLabel?.textAlignment = .right
        noButton.titleLabel?.textAlignment = .left
        
        addShadow(view: yesButton)
        addShadow(view: noButton)
        
        yesButton.setTitleColor(UIColor.white, for: .normal)
        noButton.setTitleColor(UIColor.white, for: .normal)
        
        blurView.contentView.addSubview(yesButton)
        blurView.contentView.addSubview(noButton)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.blurView.alpha = 1
            self.label.alpha = 1
            self.profileImageView.alpha = 1
            self.nameLabel.alpha = 1
            self.yesButton.alpha = 1
            self.noButton.alpha = 1
            
        }) { _ in
            
            
            
        }
        
    }
    
    @objc func addAction() {
        
        yesButtonAction()
        removeSuccessView()
        
    }
    
    @objc func noAction() {
        
        noButtonAction()
        
    }
    
    func removeSuccessView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.profileImageView.alpha = 0
            self.blurView.alpha = 0
        }) { _ in
            self.profileImageView.removeFromSuperview()
            self.blurView.removeFromSuperview()
        }
        
    }
    
}

