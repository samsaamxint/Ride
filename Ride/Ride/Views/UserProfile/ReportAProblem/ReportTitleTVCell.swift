//
//  ReportTitleTVCell.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class ReportTitleTVCell : UITableViewCell {
    
    @IBOutlet weak var Title: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected{
            self.Title.setImage(UIImage.init(named: "selectedWhite")?.withTintColor(UIColor.primaryGreen), for: .normal)
        } else {
            self.Title.setImage(UIImage.init(named: "deSelectedWhite")?.withTintColor(UIColor.sepratorColor), for: .normal)
        }
    }
}
