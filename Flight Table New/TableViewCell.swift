//
//  TableViewCell.swift
//  TripKey
//
//  Created by Peter on 12/11/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var aircraftType: UILabel!
    @IBOutlet weak var terminalLabel: UILabel!
    @IBOutlet weak var gateLabel: UILabel!
    @IBOutlet weak var arrivalGateLabel: UILabel!
    @IBOutlet weak var arrivalTerminalLabel: UILabel!
    @IBOutlet weak var arrivalBaggageLabel: UILabel!
    @IBOutlet weak var months: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var secsLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var landingOnTimeDelayed: UILabel!
    @IBOutlet weak var secs: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var monthsLabel: UILabel!
    @IBOutlet weak var airlineName: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var baggageClaim: UILabel!
    @IBOutlet weak var flightDuration: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var departureCity: UILabel!
    @IBOutlet weak var departureTerminal: UILabel!
    @IBOutlet weak var departureGate: UILabel!
    @IBOutlet weak var departureDate: UILabel!
    @IBOutlet weak var arrivalCity: UILabel!
    @IBOutlet weak var arrivalDate: UILabel!
    @IBOutlet weak var arrivalGate: UILabel!
    @IBOutlet weak var arrivalTerminal: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var mins: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    var tapShareAction: ((UITableViewCell) -> Void)?
    let gradientLayer = CAGradientLayer()
    
    
    @IBAction func shareFlight(_ sender: Any) {
        tapShareAction?(self)
    }
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        DispatchQueue.main.async {
            
         
         // Configure the view for the selected state
        self.gradientLayer.frame = self.background.frame
         
         // 3
         let color1 = UIColor.white.cgColor as CGColor
         let color2 = UIColor(white: 1.0, alpha: 0.1).cgColor as CGColor
         self.gradientLayer.colors = [color1, color2]
         
         // 4
         //self.gradientLayer.locations = [0.4, 0.8]
            //self.gradientLayer.locations = [0.2, 1.0]
            self.gradientLayer.locations = [0.0, 0.6]
         
         // 5
        self.background.layer.addSublayer(self.gradientLayer)
         
         }
    }

}
