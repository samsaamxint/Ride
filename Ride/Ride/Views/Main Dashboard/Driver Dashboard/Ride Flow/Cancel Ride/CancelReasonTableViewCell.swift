//
//  CancelReasonTableViewCell.swift
//  Ride
//
//  Created by Mac on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class CancelReasonTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var reasonTitleBtn: UIButton!
    
    var reasonData : CancelReasonItem? {
        didSet{
            reasonTitleBtn.setTitle(Commons.isArabicLanguage() ? reasonData?.reasonArabic : reasonData?.reason, for: .normal)
        }
    }

    //MARK: - Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected{
            reasonTitleBtn.setImage(UIImage.init(named: "SelectedCheckbox")?.withTintColor(.primaryGreen), for: .normal)
            reasonTitleBtn.setTitleColor(.primaryDarkBG, for: .normal)
        } else{
            reasonTitleBtn.setImage(UIImage.init(named: "DeselectedCheckbox")?.withTintColor(UIColor.sepratorColor), for: .normal)
            reasonTitleBtn.setTitleColor(.secondaryGrayTextColor, for: .normal)
        }
    }
    
    
}
