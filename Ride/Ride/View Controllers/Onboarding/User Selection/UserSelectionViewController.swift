//
//  UserSelectionViewController.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

var isPickup: Bool?

class UserSelectionViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var captainLabel: UILabel!
    @IBOutlet weak var alreadyAccountLbl: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var riderMainBG: UIView!
    @IBOutlet weak var driverMainBG: UIView!
    @IBOutlet weak var pickupMainBG: UIView!
    
    
    //MARK: - Constants and Variables
    private var onboardingType: OnboardingType = .signup {
        didSet {
            setupView(for: onboardingType)
        }
    }
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView(for: .signup)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
            self.riderLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
            self.captainLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
            self.alreadyAccountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
            self.loginBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 250
    }
    
    private func setupView(for type: OnboardingType) {
        titleLbl.text = type == .signup ? "Signup as".localizedString() : "Login as".localizedString()
        alreadyAccountLbl.text = type == .signup ? "AlreadyUser".localizedString() : "Dont have an account".localizedString()
        loginBtn.setTitle(type == .signup ? "Login".localizedString() : "Sign Up".localizedString(), for: .normal)
    }
    
    //MARK: - UIACTIONS
    @IBAction func didClickOnRiderView(_ sender: Any) {
        isPickup = nil
        riderMainBG.addDoubleBorder()
        driverMainBG.removeAllSublayers()
        pickupMainBG.removeAllSublayers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else { return }
            if let vc: EnterPhoneNumberViewController = UIStoryboard.instantiate(with: .onboarding) {
                (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 250
                vc.onboardingType = self.onboardingType
                vc.isDriver = false
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    @IBAction func didClickOnDriverView(_ sender: Any) {
        driverMainBG.addDoubleBorder()
        riderMainBG.removeAllSublayers()
        pickupMainBG.removeAllSublayers()
        
        isPickup = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else { return }
            
            if self.onboardingType == .login {
                if let vc: EnterPhoneNumberViewController = UIStoryboard.instantiate(with: .onboarding) {
                    vc.onboardingType = .login
                    vc.isDriver = true
                    (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 250
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } else {
                if let vc: SelectRideOptionViewController = UIStoryboard.instantiate(with: .driverOnboarding) {
                    vc.isDriver = true
                    (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 220
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
    }
    
    @IBAction func didClickPickupView(_ sender: Any) {
        pickupMainBG.addDoubleBorder()
        driverMainBG.removeAllSublayers()
        riderMainBG.removeAllSublayers()
        
        isPickup = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else { return }
            if self.onboardingType == .login {
                if let vc: EnterPhoneNumberViewController = UIStoryboard.instantiate(with: .onboarding) {
                    vc.onboardingType = .login
                    vc.isDriver = false
                    (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 250
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                //self.delegate?.goToEnterRiderMobileNumber(for: .login, isDriver: false)
            } else {
                if let vc: SelectRideOptionViewController = UIStoryboard.instantiate(with: .driverOnboarding) {
                    vc.isDriver = false
                    (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 220
                    self.navigationController?.pushViewController(vc, animated: false)
                }
//                self.delegate?.goToSelectDriverRide(isDriver: false, mobileNumber: "")
            }
        }
    }
    
    @IBAction func didTapLoginBtn(_ sender: Any) {
        onboardingType = onboardingType == .signup ? .login : .signup
    }
}
