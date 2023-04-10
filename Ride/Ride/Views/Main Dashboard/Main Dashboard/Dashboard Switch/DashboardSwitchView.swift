//
//  DashboardSwitchView.swift
//  Ride
//
//  Created by Mac on 17/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class DashboardSwitchView: UIView {
    
    //MARK: - Outlets
    @IBOutlet weak var riderBtn: UIButton!
    @IBOutlet weak var driverBtn: UIButton!
    @IBOutlet weak var pickupBtn: UIButton!
    @IBOutlet weak var contendView: UIView!
    @IBOutlet weak var stackVIew: UIStackView!
    
    //MARK: - Constants and Variables
    var didTapRider: (() -> Void)?
    var didTapDriver: (() -> Void)?
    var didTapPickup: (() -> Void)?
    
    override func awakeFromNib() {
       super.awakeFromNib()
        riderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        
        driverBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        if UserDefaultsConfig.isDriver{
            selectCaptainView()
        }
        
//        self.contendView.semanticContentAttribute = .forceLeftToRight
//        stackVIew.semanticContentAttribute = .forceLeftToRight
     }
    
    //MARK: - UIACTIONS
    @IBAction func didTapRiderBtn(_ sender: Any) {
        endEditing(true)
        
        didTapRider?()
        riderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        
        driverBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
    }
    
    @IBAction func didTapDriverBtn(_ sender: Any) {
//        selectCaptainView()
        didTapDriver?()
        riderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        
        driverBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
    }
    
    @IBAction func didTapPickupBtn(_ sender: Any) {
        endEditing(true)
        riderBtn.borderWidth = 0
        driverBtn.borderWidth = 0
        pickupBtn.borderWidth = 2
        
        riderBtn.backgroundColor = .black
        driverBtn.backgroundColor = .black
        pickupBtn.backgroundColor = .lightGray//.primaryGreen
        
        riderBtn.setTitleColor(.white, for: .normal)
        driverBtn.setTitleColor(.white, for: .normal)
        pickupBtn.setTitleColor(.white, for: .normal)
        
        didTapPickup?()
        riderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        
        driverBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
    }
    
    func selectCaptainView() {
        endEditing(true)
        riderBtn.borderWidth = 0
        driverBtn.borderWidth = 2
        pickupBtn.borderWidth = 0
        
        riderBtn.backgroundColor = .black
        driverBtn.backgroundColor = .primaryGreen
        pickupBtn.backgroundColor = .lightGray//.primaryDarkBG
        
        riderBtn.setTitleColor(.white, for: .normal)
        driverBtn.setTitleColor(.black, for: .normal)
        pickupBtn.setTitleColor(.white, for: .normal)
        riderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        
        driverBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
    }
    
    func selectRiderView() {
        riderBtn.borderWidth = 2
        driverBtn.borderWidth = 0
        pickupBtn.borderWidth = 0
        
        riderBtn.backgroundColor = .black
        driverBtn.backgroundColor = .black
        pickupBtn.backgroundColor = .lightGray//.primaryDarkBG
        
        riderBtn.setTitleColor(.black, for: .normal)
        driverBtn.setTitleColor(.white, for: .normal)
        pickupBtn.setTitleColor(.white, for: .normal)
        riderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        
        driverBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
    }
}
