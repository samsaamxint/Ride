//
//  RiderKYCVC.swift
//  Ride
//
//  Created by XintMac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class RiderKYCVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var userIDView: UIView!
    @IBOutlet weak var userIdTF: UITextField!
    @IBOutlet weak var dateOfBirthView: UIView!
    @IBOutlet weak var dateOfBirthTF: UITextField!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var enterDetailLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var enterIdLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    
    private let riderKYCVM = RiderKYCViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        verifyBtn.enableButton(false)
        setupTextFields()
        bindViewToViewModel()
        
        userIdTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        dateOfBirthTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        verifyBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        enterDetailLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        descLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        enterIdLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        dobLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        
        userIdTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        dateOfBirthTF.textAlignment = userIdTF.textAlignment
        enterDetailLabel.textAlignment = userIdTF.textAlignment
        descLabel.textAlignment = userIdTF.textAlignment
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 400
    }
    
    private func setupTextFields() {
        userIdTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        dateOfBirthTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
       
        userIdTF.setLeadingPadding(15)
        dateOfBirthTF.setLeadingPadding(15)
        userIdTF.setRightPadding(15)
        dateOfBirthTF.setRightPadding(15)
        
        userIdTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        dateOfBirthTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        
        userIdTF.delegate = self
        dateOfBirthTF.delegate = self
        
        dateOfBirthTF.addInputViewDatePicker(target: self, selector: #selector(didSelectDate), maxDate: Date())
    }
    
    //MARK: - Observers
    @objc private func textFieldValueChangeListener() {
        
        if dateOfBirthTF.text?.isEmpty ?? true {
            verifyBtn.enableButton(false)
            return
        }
        
        if ((userIdTF.text?.count ?? 0) < 10){
            verifyBtn.enableButton(false)
            return
        }
        
        verifyBtn.enableButton(true)
    }
    
    @objc private func didSelectDate() {
        if let datePicker = dateOfBirthTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dateOfBirthTF.text = dateFormatter.string(from: datePicker.date)
        }
        dateOfBirthTF.resignFirstResponder()
        
        if (userIdTF.text?.count == 10){
            verifyBtn.enableButton(true)
        }
    }

    //MARK: - IBActions
    @IBAction func verifyPressed(_ sender: Any) {
        
        if userIdTF.text?.hasPrefix("1") ?? DefaultValue.bool || userIdTF.text?.hasPrefix("2") ?? DefaultValue.bool {
            riderKYCVM.requestOTPValidate(userId: userIdTF.text!, dateOfBirth: dateOfBirthTF.text!)
        } else {
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Entered Id Number is invalid")
        }
        
//        if userIdTF.text == "123" {
//            Commons.showErrorMessage(controller: self, message: "Entered ID is incorrect")
//        }
//        if dateOfBirthTF.text == "01-07-2022" {
//            Commons.showErrorMessage(controller: self, message: "Entered date of birth is incorrect")
//        }
        
        
    }
}

//MARK: - UITextFieldDelegate
extension RiderKYCVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.addDoubleBorder(with: .primaryDarkBG, and: .primaryGreen)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
                textField.addDoubleBorder(with: .sepratorColor, and: .clear)
        } else {
                textField.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
        }
    }
}



extension RiderKYCVC{
    func bindViewToViewModel(){
        riderKYCVM.kycResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
              //  Commons.goToMain(type: .rider)
                Commons.adjustEventTracker(eventId: AdjustEventId.KYCAttempts)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
        
        riderKYCVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }

        riderKYCVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            if !value.isEmpty {
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
            }
        }
    }
}
