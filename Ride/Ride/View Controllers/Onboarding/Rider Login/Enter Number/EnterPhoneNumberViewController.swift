//
//  EnterPhoneNumberViewController.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CountryPicker

class EnterPhoneNumberViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var TFMainBGView: UIView!
    @IBOutlet weak var countryStackVIew: UIStackView!
    @IBOutlet weak var countryCodeLbl: UILabel!
    @IBOutlet weak var countryFlagLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var phoneStackView: UIStackView!
    
    @IBOutlet weak var enterYoursDetailsLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var verifyBtn: UIButton!
    
    
    //MARK: - Constants and Variables
    private let enterNumberVM = EnterRiderNumberViewModel()
    
    var onboardingType: OnboardingType = .signup
    var isDriver: Bool = false
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configurePhoneTF()
        prepareVerifyBtn()
        setupLanguage()
        bindViewToViewModel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeCountry(gesture: )))
        countryStackVIew.addGestureRecognizer(tapGesture)
        countryStackVIew.isUserInteractionEnabled = true
        
        let identifier = Countries.getCountryPhonceCode()
        countryCodeLbl.text = "+\(identifier)"
        let flag = Countries.getFlag()
        countryFlagLbl.text = flag
        
        backButton.rotateBtnIfNeeded()
        
        enterYoursDetailsLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        mobileNumberLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        phoneNumberTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        verifyBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        phoneStackView.semanticContentAttribute = .forceLeftToRight
        phoneNumberTF.textAlignment = .left
        verifyBtn.enableButton(false)
        //        if globalMobileNumber.isSome {
        //            phoneNumberTF.text = globalMobileNumber
        //            phoneNumberTF.isUserInteractionEnabled = false
        //        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 250
    }
    
    private func setupLanguage() {
        phoneNumberTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    //MARK: - Observers
    @objc private func phoneNoTFValueChanged() {
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            // light mode detected
            verifyBtn.enableButton(phoneNumberTF.text?.count ?? DefaultValue.int >= 9)
        case .dark:
            // dark mode detected
            verifyBtn.enableButton(phoneNumberTF.text?.count ?? DefaultValue.int >= 9)
            if phoneNumberTF.text?.count ?? DefaultValue.int >= 9{
                verifyBtn.backgroundColor = .primaryGreen
            }else{
                verifyBtn.backgroundColor = .primaryDarkBG.withAlphaComponent(0.12)
            }
        }
        
    }
    
    @objc func changeCountry(gesture: UIGestureRecognizer) {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = "SA"
        countryPicker.delegate = self
        self.present(countryPicker, animated: true)
    }
    
    private func configurePhoneTF() {
        phoneNumberTF.delegate = self
        phoneNumberTF.addTarget(self, action: #selector(phoneNoTFValueChanged), for: .editingChanged)
    }
    
    private func prepareVerifyBtn() {
        verifyBtn.enableButton(false)
    }
    
    //MARK: - UIACTIONS
    @IBAction func verifyBtnClicked(_ sender: Any) {
        if phoneNumberTF.text!.hasPrefix("5"){
        enterNumberVM.requestLogin(mobileNumber: "\(countryCodeLbl.text!.replacingOccurrences(of: "+", with: ""))\(phoneNumberTF.text ?? DefaultValue.string)", reason: isDriver ? (onboardingType == .signup ? "2" : "1") : (onboardingType == .signup ? "4" : "3"))
        }else{
            Commons.showErrorMessage(controller: self.parent?.parent ?? self, message: "Number should start with 5")
        }
    }
    
    @IBAction func didTapBackBtn(_ sender: Any) {
        (parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 300
        navigationController?.popViewController(animated: false)
    }
}

//MARK: - UITextFieldDelegate
extension EnterPhoneNumberViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        TFMainBGView.addDoubleBorder(cornerRadius: 12)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count ?? DefaultValue.int >= 9 {
            TFMainBGView.addDoubleBorder(with: .sepratorColor, and: .primaryGreen, cornerRadius: 12)
        } else {
            TFMainBGView.addDoubleBorder(with: .sepratorColor, and: .clear, cornerRadius: 12)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == phoneNumberTF {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}

extension EnterPhoneNumberViewController {
    func bindViewToViewModel() {
        enterNumberVM.apiResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.status == 200 {
                if let vc: VerifyOTPViewController = UIStoryboard.instantiate(with: .onboarding) {
                    (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 320
                    vc.isDriver = self.isDriver
                    vc.onboardingType = self.onboardingType
                    vc.countryCode = self.countryCodeLbl.text!.replacingOccurrences(of: "+", with: "")
                    vc.mobileNumber = self.phoneNumberTF.text
                    vc.tId = res.data?.tId ?? ""
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
            
        }
        
        enterNumberVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        enterNumberVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            if !value.isEmpty {
                self.TFMainBGView.addDoubleBorder(with: .separator, and: .errorRed)
                Commons.showErrorMessage(controller: self.parent?.parent ?? self, message: value)
            }
        }
    }
}

extension EnterPhoneNumberViewController: CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        countryFlagLbl.text = country.isoCode.getFlag()
        countryCodeLbl.text = "+"+country.phoneCode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.view.layoutIfNeeded()
            self.dismissKeyboard()
        }
        
    }
}
