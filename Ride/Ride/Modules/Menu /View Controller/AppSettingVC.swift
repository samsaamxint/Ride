//
//  AppSettingVC.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class AppSettingVC: UIViewController {
    
    //MARK: -  IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var changeLangBtn: UILabel!
    @IBOutlet weak var notificationBtn: UILabel!
    @IBOutlet weak var changeLanguageView: UIStackView!
    @IBOutlet weak var notifcationSwitch: UISwitch!
    
     //MARK: - Life Cycle Methods
     override func viewDidLoad() {
         super.viewDidLoad()

         setupViews()
     }
     
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OpenChangeLanguage(gesture: )))
        changeLanguageView.addGestureRecognizer(tapGesture)
        changeLanguageView.isUserInteractionEnabled = true
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        changeLangBtn.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        notificationBtn.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        notifcationSwitch.semanticContentAttribute = Commons.isArabicLanguage() ? .forceRightToLeft : .forceLeftToRight
        
        if UserDefaultsConfig.notificationStatus{
            notifcationSwitch.setOn(true, animated: false)
        }else{
            notifcationSwitch.setOn(false, animated: false)
        }
        
    }
     
     
     // MARK: - Navigation
      
     @objc private func backButtonTapped() {
         navigationController?.popViewController(animated: true)
     }
    
    //MARK: - IBActions
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        if (sender.isOn == true){
            print("notification are on")
            UIApplication.shared.unregisterForRemoteNotifications()
            UserDefaultsConfig.notificationStatus = true
        }
        else{
            print("notification are Off")
            UIApplication.shared.registerForRemoteNotifications()
            UserDefaultsConfig.notificationStatus = false
        }
    }
    
    @objc func OpenChangeLanguage(gesture: UIGestureRecognizer) {
        if let vc: ChangeLanguageVC = UIStoryboard.instantiate(with: .userProfile) {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.view.backgroundColor = .lightGray.withAlphaComponent(0.5)
            present(vc, animated: true)
        }
    }
    
}
