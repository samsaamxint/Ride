//
//  NotADriverViewController.swift
//  Ride
//
//  Created by Mac on 17/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class NotADriverViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var goBacktoRider: UIButton!
    
    //MARK: - Constants and Variables
    var isDriver = true
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
//        titleLbl.text = isDriver ? "You are not a Captain".localizedString() : "You are not a pickup Captain!".localizedString()
//        descriptionLbl.text = isDriver ? "Please register as captain to use Captain mode.".localizedString() : "Please register as captain to use pickup mode.".localizedString()
//        registerBtn.setTitle(isDriver ? "Register As Captain".localizedString() : "Register As Pickup".localizedString(), for: .normal)
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        descriptionLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(18) : UIFont.SFProDisplayRegular?.withSize(18)
        registerBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        let attributedTitle = NSMutableAttributedString()
            .bold("Go back to Rider".localizedString() , color: .primaryDarkBG)
        
        goBacktoRider.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    //MARK: - UIACTIONS
    @IBAction func registeAsDriverClicked(_ sender: Any) {
        if let vc: SelectRideOptionViewController = UIStoryboard.instantiate(with: .driverOnboarding) {
            vc.isDriver = isDriver
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 220
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    @IBAction func didTapGoBackToRider(_ sender: Any) {
        let parent = (self.parent?.parent as? MainDashboardViewController)
        parent?.showRiderMainScreen()
    }
}
