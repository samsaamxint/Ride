//
//  SelectRideOptionViewController.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class SelectRideOptionViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var ownACarBG: UIView!
    @IBOutlet weak var userOurServiceBG: UIView!
    
    @IBOutlet weak var selectOptionLabel: UILabel!
    @IBOutlet weak var IOwnACarLbl: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    
    //MARK: - Constants and Variables
    var isDriver = true
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        IOwnACarLbl.text = isDriver ? "I Own a Car".localizedString() : "I Own a Pickup".localizedString()
        
        backBtn.rotateBtnIfNeeded()
        
    selectOptionLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
    IOwnACarLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (parent?.parent as? GenericOnboardingViewController).isSome {
            (parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 170
        } else {
            (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 170
        }
    }
    
    //MARK: - UIACTIONS
    @IBAction func backBtnDidClick(_ sender: Any) {
        if (parent?.parent as? GenericOnboardingViewController).isSome {
            (parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 300
        } else {
            (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 330
        }
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func IOwnACarClicked(_ sender: Any) {
        ownACarBG.addDoubleBorder()
        userOurServiceBG.removeAllSublayers()
        
        if let vc: DriverKYCViewController = UIStoryboard.instantiate(with: .driverOnboarding) {
            vc.isRideARideService = false
            if let parent = parent?.parent as? GenericOnboardingViewController {
                parent.containerViewHeight.constant = 425
            } else {
                (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 425
            }
            navigationController?.pushViewController(vc, animated: false)
        }
    }

    @IBAction func ourRideARideServiceClicked(_ sender: Any) {
        userOurServiceBG.addDoubleBorder()
        ownACarBG.removeAllSublayers()
        
        if let vc: DriverKYCViewController = UIStoryboard.instantiate(with: .driverOnboarding) {
            vc.isRideARideService = true
            if let parent = parent?.parent as? GenericOnboardingViewController {
                parent.containerViewHeight.constant = 425
            } else {
                (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 425
            }
            navigationController?.pushViewController(vc, animated: false)
        }
    }
}
