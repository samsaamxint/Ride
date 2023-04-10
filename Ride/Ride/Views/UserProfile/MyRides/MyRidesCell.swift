//
//  MyRidesCell.swift
//  Ride
//
//  Created by PSE on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class MyRidesCell : UITableViewCell{
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapSnapShotIV: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var fareLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var ratingMainView: UIStackView!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var type: MyRidesType?
    var item: TripsDetails? {
        didSet {
            mapSnapShotIV.kf.indicatorType = .activity
            mapSnapShotIV.kf.setImage(with: URL(string: item?.images?.first?.url ?? "" ))
            timeLbl.text = item?.createdAt
            fareLbl.text = (type == .RidesGiven ? "\(item?.driverAmount ?? DefaultValue.double)" : "\(item?.riderAmount ?? DefaultValue.double)") + " SAR"
            if item?.riderReview != nil{
                ratingLbl.text = item?.riderReview!.rating
            }else{
                ratingMainView.superview?.isHidden = true
            }
            ratingMainView.isHidden = item?.riderReview.isNone ?? true
            
            statusLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(15) : UIFont.SFProDisplayRegular?.withSize(15)
            let status = item?.status
            
            if status == .PENDING {
                statusLbl.text = "Pending".localizedString()
            } else if status == .ACCEPTED_BY_DRIVER {
                statusLbl.text = "Trip Accepted".localizedString()
            } else if status == .REJECTED_BY_DRIVER {
                statusLbl.text = "Trip Rejected".localizedString()
            } else if status == .CANCELLED_BY_RIDER || status == .CANCELLED_BY_DRIVER || status == .CANCELLED_BY_ADMIN || status == .BOOKING_CANCELLED {
                statusLbl.text = "Trip Cancelled".localizedString()
            } else if status == .DRIVER_ARRIVED {
                statusLbl.text = "Driver Arrived".localizedString()
            } else if status == .STARTED {
                statusLbl.text = "Trip Started".localizedString()
            } else if status == .COMPLETED {
                statusLbl.text = "Trip Completed".localizedString()
            } else if status == .EXPIRED {
                statusLbl.text = "Trip Expired".localizedString()
            }
        }
    }
}

