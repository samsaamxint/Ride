//
//  DriverKYCViewController.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CountryPicker

class DriverKYCViewController: UIViewController {
    //MARK: - Outlets
   
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var phoneTFMainView: UIView!
    @IBOutlet weak var countryFlagLbl: UILabel!
    @IBOutlet weak var countryCodeLbl: UILabel!
    @IBOutlet weak var countryStackView: UIStackView!
    @IBOutlet weak var countryFlag: UILabel!
    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var titleStackView: UIStackView!
    
    
    @IBOutlet weak var enterDetailsLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var idNumberTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var licenceTF: UITextField!
    @IBOutlet weak var licenceLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var verifyBtn: UIButton!
    
    //MARK: - Constants and Variables
    private let driverKYCVM = DriverKYCViewModel()
    private let enterNumberVM = EnterRiderNumberViewModel()
    
    var isRideARideService = false
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
                
        verifyBtn.enableButton(false)
        setupTextFields()
        
        setupLanguage()
        
        bindViewToViewModel()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeCountry(gesture: )))
        countryStackView.addGestureRecognizer(tapGesture)
        countryStackView.isUserInteractionEnabled = true
        
        let identifier = Countries.getCountryPhonceCode()
        countryCodeLbl.text = "+\(identifier)"
        let flag = Countries.getFlag()
        countryFlagLbl.text = flag
        
        if globalMobileNumber.isSome {
            phoneNumberTF.text = globalMobileNumber
            phoneNumberTF.isUserInteractionEnabled = false
        }
        
        backBtn.rotateBtnIfNeeded()
        
        
        enterDetailsLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        idLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        idNumberTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        dobTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        licenceTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        licenceLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        mobileLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        verifyBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        phoneStackView.semanticContentAttribute = .forceLeftToRight
        phoneNumberTF.textAlignment = .left
    }
    
    @objc func changeCountry(gesture: UIGestureRecognizer) {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = "SA"
        countryPicker.delegate = self
        self.present(countryPicker, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dobTF.layoutIfNeeded()
        licenceTF.layoutIfNeeded()
        self.view?.endEditing(true)
    }
    
    private func setupLanguage() {
        idNumberTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        dobTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        phoneNumberTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        licenceTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    private func setupTextFields() {

        
        idNumberTF.setLeadingPadding(15)
        dobTF.setLeadingPadding(15)
        licenceTF.setLeadingPadding(15)
        
        idNumberTF.setRightPadding(15)
        dobTF.setRightPadding(15)
        licenceTF.setRightPadding(15)
        
        idNumberTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        dobTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        licenceTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        
        idNumberTF.delegate = self
        dobTF.delegate = self
        phoneNumberTF.delegate = self
        licenceTF.delegate = self
        
        idNumberTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        dobTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        licenceTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        licenceTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .allEditingEvents)
        phoneNumberTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        
       
    }
    
    override func viewDidLayoutSubviews() {
        //dobTF.addInputViewDatePicker(target: self, selector: #selector(didSelectDate), maxDate: Date())
        let minDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        let maxDate = Calendar.current.date(byAdding: .year, value: -65, to: Date())
        dobTF.addInputViewDatePicker(target: self, selector:  #selector(didSelectDate), minDate: maxDate, maxDate: minDate)
        licenceTF.addInputViewDatePicker(target: self, selector:  #selector(didSelectDateToHijri),minDate: Date(), calender: Calendar(identifier: .islamicUmmAlQura))
    }
   
    
    //MARK: - Observers
    @objc private func textFieldValueChangeListener() {

        if ((idNumberTF.text?.count ?? 0) < 10){
            verifyBtn.enableButton(false)
            return
        }

        if phoneNumberTF.text?.count ?? DefaultValue.int < 9 {
            verifyBtn.enableButton(false)
            return
        }
        
        if licenceTF.text?.isEmpty ?? true {
            verifyBtn.enableButton(false)
            return
        }
        
        verifyBtn.enableButton(true)
    }
    
    @objc private func didSelectDate() {
        if let datePicker = dobTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dobTF.text = dateFormatter.string(from: datePicker.date)
        }
        dobTF.resignFirstResponder()
        
    }
    
    @objc private func didSelectDateToHijri() {
        if let datePicker = licenceTF.inputView as? UIDatePicker {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
            datePicker.minimumDate = Date()
            let islamic = NSCalendar(identifier: .islamicUmmAlQura)!
            let components = islamic.components(NSCalendar.Unit(rawValue: UInt.max), from: datePicker.date)
        
            licenceTF.text = "\(self.getDoubleDigit(number: components.day ?? 1))-\(self.getDoubleDigit(number: components.month ?? 1) )-\(components.year ?? 2022)"
        }
        licenceTF.resignFirstResponder()
    }
    
    func getDoubleDigit(number : Int) -> String {
        if number < 10{
            //let str1 = String(format: "%02d", 1);
            let newNum = "0"+String(number)
            return newNum
        }
        return String(number)
    }
    
    
    private func moveToDestination(tId: String) {
        if let vc: VerifyOTPViewController = UIStoryboard.instantiate(with: .onboarding) {
            if let parent = parent?.parent as? GenericOnboardingViewController {
                parent.containerViewHeight.constant = 320
            } else {
                (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 320
            }
            vc.isDriver = true
            vc.onboardingType = .signup
            vc.isRideARideService = isRideARideService
            vc.mobileNumber = phoneNumberTF.text
            vc.userid = idNumberTF.text
            vc.licenceExpiry = licenceTF.text
            vc.tId = tId
            vc.countryCode = self.countryCode.text!.replacingOccurrences(of: "+", with: "")
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    //MARK: - UIACTIONS
    @IBAction func verifyBtnClicked(_ sender: Any) {

        if phoneNumberTF.text!.hasPrefix("5"){
            if idNumberTF.text?.hasPrefix("1") ?? DefaultValue.bool || idNumberTF.text?.hasPrefix("2") ?? DefaultValue.bool {
                enterNumberVM.requestLogin(mobileNumber: "\(countryCode.text!.replacingOccurrences(of: "+", with: ""))\(phoneNumberTF.text ?? DefaultValue.string)",reason: "2")
            } else {
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Entered Id Number is invalid")
                idNumberTF.addDoubleBorder(with: .clear, and: .red)
            }
        }else{
            Commons.showErrorMessage(controller: self.parent?.parent ?? self, message: "Number should start with 5")
            phoneTFMainView.addDoubleBorder(with: .clear, and: .red)
        }
        
        
    }
    
    @IBAction func backBtnDidClick(_ sender: Any) {
        if (parent?.parent as? GenericOnboardingViewController).isSome {
            (parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 220
        } else {
            (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 220
        }
        navigationController?.popViewController(animated: false)
    }
}

//MARK: - UITextFieldDelegate
extension DriverKYCViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == phoneNumberTF {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        if textField == idNumberTF{
            let maxLength = 10
               let currentString = (textField.text ?? "") as NSString
               let newString = currentString.replacingCharacters(in: range, with: string)

               return newString.count <= maxLength
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField  == phoneNumberTF {
            phoneTFMainView.addDoubleBorder(with: .primaryDarkBG, and: .primaryGreen)
        } else {
            textField .addDoubleBorder(cornerRadius: 12)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
          
            if textField == phoneNumberTF  {
                phoneTFMainView.addDoubleBorder(with: .sepratorColor, and: .clear, cornerRadius: 12)
            } else {
                textField  .addDoubleBorder(with: .sepratorColor, and: .clear, cornerRadius: 12)
            }
        } else if (textField == phoneNumberTF && textField.text?.count ?? DefaultValue.int < 9) {
            phoneTFMainView  .addDoubleBorder(with: .sepratorColor, and: .clear, cornerRadius: 12)
        } else {
            if textField == phoneNumberTF  {
                phoneTFMainView.addDoubleBorder(with: .sepratorColor, and: .clear, cornerRadius: 12)
            } else {
                textField.addDoubleBorder(with: .sepratorColor, and: .clear, cornerRadius: 12)
            }
        }
    }
}

extension DriverKYCViewController {
    func bindToDriverKYVViewModel() {
        driverKYCVM.apiResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            self.dismiss(animated: false)
        }
        
        driverKYCVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }

        driverKYCVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            if !value.isEmpty {
                Commons.showErrorMessage(controller: self, message: value)
            }
        }
    }
}

extension DriverKYCViewController {
    func bindViewToViewModel() {
        enterNumberVM.apiResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.status == 200 {
                self.moveToDestination(tId: res.data?.tId ?? "")
            }
            
        }
        
        enterNumberVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }

        enterNumberVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            if !value.isEmpty {
                Commons.showErrorMessage(controller: self.parent?.parent ?? self, message: value)
            }
        }
    }
}


extension DriverKYCViewController: CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        countryFlag.text = country.isoCode.getFlag()
        countryCode.text = "+"+country.phoneCode
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismissKeyboard()
        }
    }
}
