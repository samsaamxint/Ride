//
//  RenewalHistoryTVCell.swift
//  Ride
//
//  Created by XintMac on 10/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class RenewalHistoryTVCell : UITableViewCell{
    
    //MARK: - IBOutlets
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var renewalPrice: UILabel!
    
    var cellData : SubscriptionItem?{
        didSet{
            endDate.text = cellData?.dueDate
            renewalPrice.text = "Renewal of SAR \(String(cellData?.subscriptionAmount ?? 0.0)) Successful"
            if #available(iOS 15.0, *) {
                endTime.text = cellData?.createdAt?.toDate(.isoDateTimeMilliSec)?.formatted(date: .omitted, time: .shortened)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    endDateLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
    endTimeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
    endDate.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
    endTime.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
    renewalPrice.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
            
    }
}
