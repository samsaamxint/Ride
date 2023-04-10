//
//  SubscriptionMainView.swift
//  Ride
//
//  Created by Mac on 30/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class SubscriptionMainView: UIView {
    //MARK: - Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topMainView: UIView!
    @IBOutlet weak var topAmountLbl: UILabel!
    
    @IBOutlet weak var totalTripTitleLbl: UILabel!
    @IBOutlet weak var totalTripCountLbl: UILabel!
    
    @IBOutlet weak var totalKmTitleLbl: UILabel!
    @IBOutlet weak var totalKmLbl: UILabel!
    
    @IBOutlet weak var extraMoneyTitleLbl: UILabel!
    @IBOutlet weak var extraMoneyLbl: UILabel!
    
    @IBOutlet weak var carCatTitleLbl: UILabel!
    @IBOutlet weak var carCategoryLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configureView(with even : Bool , subcription : GetSubcriptionsData, selectedId: String){
        mainView.backgroundColor = even ? UIColor.darkGreenColor : .white
        topMainView.backgroundColor = even ? UIColor.whiteWith16Alpha : .white
        topAmountLbl.textColor = even ? .white : .darkGreenColor
        descriptionLabel.textColor = even ? UIColor.white.withAlphaComponent(0.7) : UIColor.black.withAlphaComponent(0.7)
        
        topMainView.borderWidth = 1
        topMainView.borderColor = .sepratorColor
    
        let titleTextColor = even ? UIColor.white.withAlphaComponent(0.7) : UIColor.black.withAlphaComponent(0.7)
        let valueTextColor = even ? UIColor.white : UIColor.black
        
        totalTripTitleLbl.textColor = titleTextColor
        totalTripCountLbl.textColor = valueTextColor
        
        totalKmTitleLbl.textColor = titleTextColor
        totalKmLbl.textColor = valueTextColor
        
        extraMoneyTitleLbl.textColor = titleTextColor
        extraMoneyLbl.textColor = valueTextColor
        
        carCatTitleLbl.textColor = titleTextColor
        carCategoryLbl.textColor = valueTextColor
        
        
        topAmountLbl.text = "\(subcription.finalPrice ?? 9) SAR"
       // totalTripCountLbl.text = "\(subcription.) SAR"
//        totalKmLbl.text = "\(subcription.finalPrice) SAR"
//        extraMoneyLbl.text = "\(subcription.finalPrice) SAR"
//        carCategoryLbl.text = "\(subcription.finalPrice) SAR"
        
        mainView.borderWidth = 2
        
        switch (even, selectedId == subcription.id) {
        case (true, false):
            mainView.borderColor = .clear
        case (true, true):
            mainView.borderColor = .primaryGreen
        case (false, true):
            mainView.borderColor = .primaryGreen
        case (false, false):
            mainView.borderColor = .separator
        }
    
    }

}
