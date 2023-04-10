//
//  MyReportTableViewCell.swift
//  Ride
//
//  Created by Mac on 24/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class MyReportTableViewCell: UITableViewCell {
    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    var item: IssueTicket? {
        didSet {
            titleLbl.text = item?.category?.title ?? "Report".localizedString()
            statusLbl.text = "Pending".localizedString()
            descriptionLbl.text = item?.description
            
            titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(20) : UIFont.SFProDisplayMedium?.withSize(20)
            statusLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
            descriptionLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        }
    }
}
