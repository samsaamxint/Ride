//
//  LogOutPopUpVC.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class LogOutPopUpVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        descLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        dismissBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        logoutBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(18)
    }

    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        Commons.goToOnboarding(isLogout: true)
    }
}
