//
//  UpcomingTVCell.swift
//  Ride
//
//  Created by XintMac on 10/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class UpcomingTVCell : UITableViewCell{
    
    //MARK: - IBOutlets
    @IBOutlet weak var scheduledonLbl: UILabel!
    @IBOutlet weak var subscriptionFeeLbl: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var subcriptionFee: UILabel!
    @IBOutlet weak var cancelSubcription: UIButton!
    

    var cellData : SubscriptionItem?{
        didSet{
            dueDate.text = cellData?.endDate
            subcriptionFee.text = "SAR \(String(cellData?.subscriptionAmount ?? 0.0))"
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        scheduledonLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        subscriptionFeeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        dueDate.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        subcriptionFee.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        cancelSubcription.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
    }
    
}
