//
//  GoogleLocationSuggestionTableViewCell.swift
//  Ride
//
//  Created by Mac on 03/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class GoogleLocationSuggestionTableViewCell: UITableViewCell {
    //MARK: - Outlets
    @IBOutlet weak var primaryAddressLbl: UILabel!
    @IBOutlet weak var secondaryAddressLBl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var item: GApiResponse.Autocomplete? {
        didSet {
            primaryAddressLbl.text = item?.mainText
            secondaryAddressLBl.text = item?.subText
            primaryAddressLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold : UIFont.SFProDisplaySemiBold
        }
    }
}
