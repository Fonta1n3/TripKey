//
//  ActivityView.swift
//  TripKey
//
//  Created by Peter on 17/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import UIKit

class CenterActivityView: UIView {
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let activityLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView()
    var activityDescription = String()
    
    func add(viewController: UIViewController) {
        
        DispatchQueue.main.async {
            
            self.blurView.frame = CGRect(x: viewController.view.center.x - 75,
                                         y: viewController.view.center.y - 60,
                                         width: 150,
                                         height: 120)
            
            self.blurView.alpha = 0
            self.blurView.layer.cornerRadius = 30
            self.blurView.clipsToBounds = true
            
            viewController.view.addSubview(self.blurView)
            
            self.activityLabel.frame = CGRect(x: 0,
                                              y: self.blurView.contentView.frame.maxY - 40,
                                              width: 150,
                                              height: 20)
            
            self.activityLabel.font = UIFont(name: "HelveticaNeue-Light",
                                             size: 15.0)
            
            self.activityLabel.textColor = UIColor.white
            self.activityLabel.text = self.activityDescription
            self.activityLabel.textAlignment = .center
            self.activityLabel.alpha = 0
            self.activityLabel.adjustsFontSizeToFitWidth = true
            
            self.activityIndicator.frame = CGRect(x: self.blurView.contentView.center.x - 25,
                                                  y: self.blurView.contentView.frame.minY + 25,
                                                  width: 50,
                                                  height: 50)
            
             self.activityIndicator.hidesWhenStopped = true
             self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
             self.activityIndicator.alpha = 0
             self.activityIndicator.startAnimating()
            
            
            
            self.blurView.contentView.addSubview(self.activityLabel)
            self.blurView.contentView.addSubview( self.activityIndicator)
            
            
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.blurView.alpha = 1
                self.activityIndicator.alpha = 1
                self.activityLabel.alpha = 1
                
            })
            
        }
    }
    
    func remove() {
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.activityLabel.alpha = 0
                self.blurView.alpha = 0
                
            }) { _ in
                
                self.activityIndicator.stopAnimating()
                self.activityLabel.removeFromSuperview()
                self.blurView.removeFromSuperview()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
            
        }
        
    }
    
}
