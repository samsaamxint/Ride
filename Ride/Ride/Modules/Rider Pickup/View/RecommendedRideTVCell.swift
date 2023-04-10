//
//  RecommendedRideTVCell.swift
//  Ride
//
//  Created by XintMac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class RecommendedRideTVCell : UITableViewCell{
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var carPersonBtn: UIButton!
    
    @IBOutlet weak var distanceAwayLbl: UILabel!
    @IBOutlet weak var estimateArrivalTimeLbl: UILabel!
    
    @IBOutlet weak var estimateFareLbl: UILabel!
    @IBOutlet weak var previousFareLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var item: CarItem? {
        didSet {
            carNameLbl.text = item?.name
            if Commons.isArabicLanguage(){
                carNameLbl.text = item?.nameArabic
            } 
            carPersonBtn.setTitle("\(item?.noOfSeats ?? DefaultValue.int)", for: .normal)
            if item?.discountCost == nil{
                estimateFareLbl.text = "\(String(format: "%.2f", item?.estimateCost ?? DefaultValue.double)) SAR"
                previousFareLbl.isHidden = true
            }else{
                let newAmount = (item?.estimateCost ?? 0.0) - (item?.discountCost ?? 0.0)
                estimateFareLbl.text = "\(String(format: "%.2f", newAmount)) SAR"
                previousFareLbl.text = "\(item?.estimateCost ?? DefaultValue.double) SAR"
                previousFareLbl.isHidden = false
            }
            distanceAwayLbl.text = "\(item?.shareEstimatedTimeArrival ?? DefaultValue.int) " + "min away".localizedString()
            estimateArrivalTimeLbl.text = String( Commons.getAddedTime(time: item?.shareEstimatedTimeArrival ?? DefaultValue.int))
            
            if let url = URL(string: item?.categoryIcon ?? DefaultValue.string) {
                carImageView.kf.setImage(with: url)
            }
            
            carNameLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(15) : UIFont.SFProDisplaySemiBold?.withSize(15)
            distanceAwayLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        }
    }
}

