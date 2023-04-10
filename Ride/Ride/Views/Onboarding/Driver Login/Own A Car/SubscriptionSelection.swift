//
//  SubscriptionSelection.swift
//  Ride
//
//  Created by XintMac on 23/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class SubscriptionSelection : UITableViewCell{
    @IBOutlet weak var salePercent: UILabel!
    @IBOutlet weak var subscriptionTypeLabel: UILabel!
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var innerStackView: UIStackView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var subscriptionPriceLabel: UILabel!
    @IBOutlet weak var popularLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var des1: UILabel!
    @IBOutlet weak var des2: UILabel!
    @IBOutlet weak var des3: UILabel!
    
    var subcriptionModel : GetSubcriptionsData?{
        didSet{
            subscriptionTypeLabel.text = subcriptionModel?.packageName
            subscriptionPriceLabel.text = "\(String(subcriptionModel?.finalPrice ?? 0)) SAR / Month"
            des1.text = subcriptionModel?.packageDescription
            des2.text = subcriptionModel?.packageDescription
            des3.text = subcriptionModel?.packageDescription
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.innerView.roundBottomCorners(radius: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected{
            self.contentView.backgroundColor = .black
            self.outerStackView.backgroundColor = .black
            self.subscriptionTypeLabel.textColor = .white
        } else {
            self.contentView.backgroundColor = .lightGrayBG
            self.outerStackView.backgroundColor = .lightGrayBG
            self.subscriptionTypeLabel.textColor = .black
        }
    }
}


