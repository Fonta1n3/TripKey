//
//  BlurAlert.swift
//  TripKey
//
//  Created by Peter on 17/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import UIKit

class SuccessAlertView: UIView {
    
    let checkmarkview = UIImageView()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    let label = UILabel()
    var labelText = String()
    
    func addSuccessView(viewController: UIViewController) {
        
        checkmarkview.alpha = 0
        blurView.alpha = 0
        label.alpha = 0
        
        blurView.frame = viewController.view.frame
        viewController.view.addSubview(blurView)
        
        checkmarkview.frame = CGRect(x: blurView.center.x - 95,
                                     y: (blurView.center.y - 95) - (blurView.frame.height / 5),
                                     width: 190,
                                     height: 190)
        
        checkmarkview.image = UIImage(named: "whiteCheck.png")
        checkmarkview.alpha = 0
        addShadow(view: checkmarkview)
        blurView.contentView.addSubview(checkmarkview)
        
        label.frame = CGRect(x: 0,
                                y: checkmarkview.frame.maxY + 10,
                                width: blurView.frame.width,
                                height: 30)
        
        label.font = UIFont.init(name: "HelveticaNeue", size: 20)
        label.text = labelText
        addShadow(view: label)
        label.textColor = UIColor.white
        label.textAlignment = .center
        blurView.contentView.addSubview(label)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.blurView.alpha = 1
            self.label.alpha = 1
            
        }) { _ in
            
            self.checkmarkview.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            
            UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIViewAnimationOptions.allowUserInteraction, animations: {
                
                self.checkmarkview.alpha = 1
                self.checkmarkview.transform = CGAffineTransform.identity
                
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                self.removeSuccessView()
                
            }
            
        }
        
    }
    
    func removeSuccessView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.checkmarkview.alpha = 0
            self.blurView.alpha = 0
        }) { _ in
            self.checkmarkview.removeFromSuperview()
            self.blurView.removeFromSuperview()
        }
        
    }
    
}
