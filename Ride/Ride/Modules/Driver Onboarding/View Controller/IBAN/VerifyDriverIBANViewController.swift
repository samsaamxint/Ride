//
//  VerifyDriverIBANViewController.swift
//  Ride
//
//  Created by Mac on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import TextFieldFormatter

class VerifyDriverIBANViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var IBANTF: TextFieldFormatter!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var ibanLabel: UILabel!
    @IBOutlet weak var enterIBANLabel: UILabel!
    @IBOutlet weak var bankNameLbl: UILabel!
    
    @IBOutlet weak var bankNameView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Constants and Variables
    private let ibanValidationVM = IbanValidationViewModel()
    var ibanData: GetIBANData?
    var comingFromUpdate = false
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewToViewModel()
        
        IBANTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        doneBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        descLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        ibanLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        enterIBANLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        bankNameLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(12) : UIFont.SFProDisplayMedium?.withSize(12)
        DispatchQueue.main.async {
            self.IBANTF.becomeFirstResponder()
        }
        if comingFromUpdate{
            descLabel.isHidden = true
            enterIBANLabel.text = "Update IBAN".localizedString()
        }
    }
    
    private func setupViews() {
        bankNameView.alpha = 0
        setupTextField()
        doneBtn.enableButton(false)
        
        activityIndicator.stopAnimating()
        
        setupDataIfNeeded()
    }
    
    private func setupTextField() {
        IBANTF.delegate = self
        IBANTF.setLeadingPadding(15)
        IBANTF.setRightPadding(30)
        
        IBANTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        
        IBANTF.addDoubleBorder(with: .sepratorColor, and: .clear)
    }
    
    private func setupDataIfNeeded() {
        guard let data = ibanData else { return }
        
        bankNameView.alpha = 1
        bankNameLbl.text = "Bank: " + (data.bank ?? DefaultValue.string)
        
        IBANTF.text = data.iban
        
        //doneBtn.enableButton(true)
        
        doneBtn.setTitle("Update".localizedString() , for: .normal)
        doneBtn.enableButton(false)
    }
    
  
    
    //MARK: - Observers
    @objc private func textFieldValueChangeListener() {
        if IBANTF.text?.isEmpty ?? true {
            doneBtn.enableButton(false)
            return
        }
        
        activityIndicator.startAnimating()
        
        if IBANTF.text!.passesMod97Check() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                self.activityIndicator.stopAnimating()
                self.bankNameView.alpha = 1
            }
        } else {
            bankNameView.alpha = 0
            self.activityIndicator.stopAnimating()
        }
//        Commenting this for new logic check
        if IBANTF.text?.count == 1 {
            if IBANTF.text?.prefix(1) == "S" {
                IBANTF.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
                doneBtn.enableButton(true)
            } else {
                IBANTF.addDoubleBorder(with: .sepratorColor, and: .errorRed)
                doneBtn.enableButton(false)
            }
        } else {
            if IBANTF.text?.prefix(2) == "SA" {
                IBANTF.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
                doneBtn.enableButton(true)
            } else {
                IBANTF.addDoubleBorder(with: .sepratorColor, and: .errorRed)
                doneBtn.enableButton(false)
            }
        }
//        if IBANTF.text?.count == 24 {
//            if IBANTF.text?.prefix(2) == "SA" {
//                IBANTF.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
//                doneBtn.enableButton(true)
//            } else {
//                IBANTF.addDoubleBorder(with: .sepratorColor, and: .errorRed)
//                doneBtn.enableButton(false)
//            }
//        }else{
//            IBANTF.addDoubleBorder(with: .sepratorColor, and: .errorRed)
//            doneBtn.enableButton(false)
//        }

    }
    
    //MARK: - UIACTIONS
    @IBAction func doneBtnClicked(_ sender: Any) {
        ibanValidationVM.validateIban(Iban: IBANTF.text!.replacingOccurrences(of: " ", with: ""))
    }
}

//MARK: - UITextFieldDelegate
extension VerifyDriverIBANViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addDoubleBorder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.addDoubleBorder(with: .sepratorColor, and: .clear)
        } else {
            textField.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        doneBtn.enableButton(true)
        return true
    }
}


extension VerifyDriverIBANViewController{
    func bindViewToViewModel() {
        ibanValidationVM.apiResponseData.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                Commons.adjustEventTracker(eventId: AdjustEventId.IBANAddedSuccess)
                Commons.adjustEventTracker(eventId: AdjustEventId.IBANAdded)
                if self.ibanData.isNone {
                    (self.parent?.parent as? MainDashboardViewController)?.mainDashboardVM.checkCaptainStatus.value.0.data?.iban = self.IBANTF.text!.replacingOccurrences(of: " ", with: "")
                    Commons.goToMain(type: .driver)
//                    (self.parent?.parent as? MainDashboardViewController)?.listenRequestForDriverAccept()
//                    SocketIOHelper.shared.establishConnection()
//                    //self.GotoDriverScreen()
//                    DispatchQueue.main.async {
//                        let parent = self.parent?.parent as? MainDashboardViewController
//                        if let vc: NoRidersViewController = UIStoryboard.instantiate(with: .driverToRider) {
//                            parent?.containerViewHeight.constant = 220
//                            UserDefaultsConfig.isDriver = true
//                            if let location = parent?.locationManager.location {
//                                SocketIOHelper.shared.updateCaptainLocation(location: location)
//                            }
//                            //self.navigationController?.pushViewController(vc, animated: false)
//                            (parent?.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
//                            parent?.addChildWithNavViewController(childController: vc, contentView: parent?.containerView ?? UIView())
//                        }
//                    }
                } else {
                    guard self.ibanData != nil else { return }
                    //
                    Commons.showErrorMessage(controller:  self.navigationController ?? self,backgroundColor: .lightGreen,textColor: .greenTextColor, message: "IBAN updated successfully")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let controllers = self.navigationController?.viewControllers ?? []
                        for vc in controllers{
                            if let subVC = vc as? EmptyTopupViewController {
                                subVC.dismissBalancePopup(0)
                                break
                            }
                        }
                    }
                }
            }
        }
        
        ibanValidationVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        ibanValidationVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.adjustEventTracker(eventId: AdjustEventId.IBANAddedFailed)
            Commons.showErrorMessage(controller: self.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
    }
}
