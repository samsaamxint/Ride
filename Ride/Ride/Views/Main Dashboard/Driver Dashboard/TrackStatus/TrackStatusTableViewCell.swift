//
//  TrackStatusTableViewCell.swift
//  Ride
//
//  Created by Mac on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class TrackStatusTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var tailView: UIView!
    
    @IBOutlet weak var mapView: UIView!
    
    //MARK: - Constants and Variables
    var isLastIndex = false
    var item: CarStatus? {
        didSet {
            titleLbl.text = item?.title
            subTitleLbl.text = item?.subTitle
            titleLbl.textColor = (item?.isCompleted ?? DefaultValue.bool) ? .primaryDarkBG : .secondaryGrayTextColor
            
            tailView.isHidden = isLastIndex
            
            let isCompleted = item?.isCompleted ?? DefaultValue.bool
            
            checkmarkImage.image = isCompleted ? UIImage(named: "CheckmarkRound") : nil
            checkmarkImage.borderWidth = isCompleted ? 0 : 5
            tailView.borderWidth = isCompleted ? 0 : 1
            tailView.backgroundColor = isCompleted ? .primaryDarkBG : .sepratorColor
            titleLbl.font = isCompleted ? UIFont.SFProDisplayBold?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
            
            mapView.isHidden = !isLastIndex
        }
    }
}
