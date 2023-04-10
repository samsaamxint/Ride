//
//  ChangeLanguageVC.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ChangeLanguageVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var englishView: UIView!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var arabicView: UIView!
    @IBOutlet weak var arabicButton: UIButton!
    
    private let updateVM = UpdateProfileViewModel()
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
    }
    
    //MARK: - UIACTIONS
    @IBAction func englishPressed(_ sender: Any) {
        englishView.addDoubleBorder()
        arabicView.removeAllSublayers()
        if UserDefaults.standard.value(forKey: languageKey) as? String == "ar"{
            UserDefaults.standard.set("en", forKey: languageKey)
            UserDefaults.standard.synchronize()
            LocalizationHelper.setCurrentLanguage("en")
            if UserDefaultsConfig.isDriver ?? DefaultValue.bool {
                Commons.goToMain(type: .driver)
            } else {
                Commons.goToMain(type: .rider)
            }
            updateCustomerLanguage()
        }else{
        }
    }
    
    @IBAction func arabicPressed(_ sender: Any) {
        englishView.removeAllSublayers()
        arabicView.addDoubleBorder()
        if UserDefaults.standard.value(forKey: languageKey) as? String == "en"{
            UserDefaults.standard.set("ar", forKey: languageKey)
            UserDefaults.standard.synchronize()
            LocalizationHelper.setCurrentLanguage("ar")
            if UserDefaultsConfig.isDriver ?? DefaultValue.bool {
                Commons.goToMain(type: .driver)
            } else {
                Commons.goToMain(type: .rider)
            }
            updateCustomerLanguage()
        }else{
            
        }
    }
    
    @IBAction func didTapBackBtn(_ sender: Any) {
        dismiss(animated: false)
    }
    
    
    func updateCustomerLanguage() {
        updateVM.updateCustomer(deviceId: nil,
                                deviceToken: nil,
                                deviceName: "iOS",
                                latitude: LocationManager.shared.lastLocation?.coordinate.latitude ,
                                longitude: LocationManager.shared.lastLocation?.coordinate.longitude, email: nil, mobileNo: nil, profileImage: nil, prefferedLanguage: UserDefaults.standard.value(forKey: languageKey) as? String, isLanguageUpdate: true)
        
    }
}
