//
//  VerifyOTPViewController.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import OTPFieldView

var globalMobileNumber: String?

class VerifyOTPViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerStackView: UIStackView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var editLbl: UILabel!
    @IBOutlet weak var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var didRecieveLabel: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var phoneStackView: UIStackView!
    
    //MARK: - Constants and Variables
    var userid : String?
    var licenceExpiry : String?
    var countryCode : String?
    private var timer: Timer?
    private var timerValue = 60 {
        didSet {
            timerLbl.isHidden = timerValue <= 0
            resendBtn.isHidden = !timerLbl.isHidden
            if timerValue == 0 {
                resetTimer()
            } else {
                updateTimerLbl()
            }
        }
    }
    private let verifyOTPVM = VerifyOTPViewModel()
    var is_TAMM_OTP = false
    var onboardingType: OnboardingType = .signup
    var isDriver: Bool?
    var isRideARideService = false
    var mobileNumber: String?
    var tId: String?
    var enteredOTP: String?
    
    private let enterNumberVM = EnterRiderNumberViewModel()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (parent?.parent as? MainDashboardViewController).isSome {
            view.backgroundColor = .clear
        }
         
        let number = "+\(countryCode ?? "966")\(mobileNumber ?? "")"
//        DispatchQueue.main.async {
//            self.descLbl.attributedText = NSMutableAttributedString()
//                .normal(text.localizedString() , color: .secondaryGrayTextColor)
//                .bold("Edit".localizedString() , color: .secondaryGrayTextColor)
//            self.descLbl.semanticContentAttribute = .forceLeftToRight
//        }
        descLbl.text = "Code sent to number".localizedString()
        numberLbl.text = number
        editLbl.text = "Edit".localizedString()
       // innerStackView.semanticContentAttribute = .forceLeftToRight
        
        setTimer()
        updateTimerLbl()
//        setPinTextField()
        setupOtpView()
        doneBtn.enableButton(false)
        
        if is_TAMM_OTP {
            titleLbl.text = "Enter TAMM OTP"
            topConstraint.isActive = false
        } else {
            titleLbl.text = "Enter OTP".localizedString()
        }
        
        bindVerifyOTPViewModel()
        bindToEnterNumberViewModel()
        hideKeyboardWhenTappedAround()

        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        descLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        editLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        numberLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        didRecieveLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        timerLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        doneBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        resendBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parent = parent?.parent as? GenericOnboardingViewController {
            parent.containerViewHeight.constant = 320
        } else {
            (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 320
        }
        addObservers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPhoneNumber))
        editLbl.isUserInteractionEnabled = true
        editLbl.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let gesture = descLbl.gestureRecognizers?.first {
            descLbl.removeGestureRecognizer(gesture)
        }
    }
    
    func setupOtpView(){
            self.otpTextFieldView.fieldsCount = 4
            self.otpTextFieldView.fieldBorderWidth = 2
            self.otpTextFieldView.defaultBorderColor = UIColor.lightGray
            self.otpTextFieldView.filledBorderColor = UIColor.green
            self.otpTextFieldView.cursorColor = UIColor.black
            self.otpTextFieldView.displayType = .roundedCorner
            self.otpTextFieldView.fieldSize = 50
            self.otpTextFieldView.separatorSpace = 10
            self.otpTextFieldView.shouldAllowIntermediateEditing = false
            self.otpTextFieldView.delegate = self
            self.otpTextFieldView.initializeUI()
        }
    
    @objc private func didTapPhoneNumber() {
        if is_TAMM_OTP || onboardingType == .login {
            if is_TAMM_OTP {
                dismiss(animated: false)
            } else {
                backToEnterNumber()
            }
        } else if isDriver == true {
            backToKYCScreen()
        } else {
            backToEnterNumber()
        }
    }
    
    private func backToEnterNumber() {
        if let parent = (self.parent?.parent as? GenericOnboardingViewController) {
            parent.containerViewHeight.constant = 250
        } else {
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 250
        }
        navigationController?.popViewController(animated: false)
    }
    
    private func backToKYCScreen() {
        if let parent = parent?.parent as? GenericOnboardingViewController {
            parent.containerViewHeight.constant = 425
        } else {
            (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 425
        }
        navigationController?.popViewController(animated: false)
    }
    
    //MARK: - Observers
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if is_TAMM_OTP {
            bottomConstraint.constant = 150 + 120
            return
        }
        guard ((parent as? UINavigationController)?.viewControllers.last as? VerifyOTPViewController).isSome else {
            return
        }
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant = 150 + 100
            if let parent = (self.parent?.parent as? GenericOnboardingViewController) {
                parent.containerViewHeight.constant = 430 + 100
            } else {
                (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 430 + 100
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if is_TAMM_OTP {
            bottomConstraint.constant = 24
            return
        }
        guard ((parent as? UINavigationController)?.viewControllers.last as? VerifyOTPViewController).isSome else {
            return
        }
        bottomConstraint.constant = 24
        if let parent = (self.parent?.parent as? GenericOnboardingViewController) {
            parent.containerViewHeight.constant = 300
        } else {
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 300
        }
    }
    
    //MARK: - Timer
    private func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let `self` = self else { return }
            
            self.timerValue -= 1
        })
    }
    
    private func updateTimerLbl() {
        let (_, m, s) = timerValue.secondsToHoursMinutesSeconds()
        timerLbl.text = "\(m):\(s)"
    }
    
    private func resetTimer() {        
        timer?.invalidate()
        timer = nil
    }
    
//    //MARK: - PIN CODE TEXT FIELD
//    private func setPinTextField() {
//        pincodeTF.keyboardType = .numberPad
//        pincodeTF.delegate = self
//
//        pincodeTF.becomeFirstResponder()
//    }
    
    private func moveToDestination() {
        globalMobileNumber = mobileNumber
        if is_TAMM_OTP || onboardingType == .login {
            if isDriver ?? DefaultValue.bool {
                Commons.goToMain(type: .driver)
            } else {
                Commons.goToMain(type: .rider)
            }
             //.goToMain(type: .driverRideARide)
        } else if isDriver == true {
            Commons.adjustEventTracker(eventId: AdjustEventId.KYCAttempts)
            if isRideARideService {
                if let vc: SelectRideViewController = UIStoryboard.instantiate(with: .rideARide) {
                    parent?.parent?.navigationController?.pushViewController(vc, animated: false)
                }
            } else {
                if let vc: AddSequenceNoVc = UIStoryboard.instantiate(with: .driverOnboarding) {
                    if let parent = (self.parent?.parent as? GenericOnboardingViewController) {
                        parent.containerViewHeight.constant = 500
                    } else {
                        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 440
                    }
                    navigationController?.pushViewController(vc, animated: false)
                }
            }
        } else {
//            commenting to skip payment screen temporarily
//            if let vc: SaveCardForPaymentViewController = UIStoryboard.instantiate(with: .paymentMethods) {
//                vc.comingFrom = .signup
//                parent?.parent?.navigationController?.pushViewController(vc, animated: false)
//            }
            
           Commons.goToMain(type: .rider)
        }
    }
    
    //MARK: - UIACTIONS
    @IBAction func resendBtnClicked(_ sender: UIButton) {
        if is_TAMM_OTP {
            self.timerValue = 60
            self.setTimer()
            return
        }
        enterNumberVM.requestLogin(mobileNumber: "\(countryCode ?? "966")\(mobileNumber ?? DefaultValue.string)", reason: isDriver == true ?  (onboardingType == .signup ? "2" : "1") : (onboardingType == .signup ? "4" : "3"))
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        if is_TAMM_OTP {
            moveToDestination()
            return
        }
        verifyOTPVM.requestOTPValidate(mobileNumber: "\(countryCode ?? "966")\(mobileNumber ?? DefaultValue.string)", otp: enteredOTP ?? DefaultValue.string, reason: isDriver == true ? (onboardingType == .signup ? "2" : "1") : (onboardingType == .signup ? "4" : "3"), tId: tId ?? "", userId: userid, licExpiry: licenceExpiry)
    }
}

//MARK: - PinCodeTextFieldDelegate
extension VerifyOTPViewController: PinCodeTextFieldDelegate {
    func textFieldValueChanged(_ textField: PinCodeTextField) {
       
        switch traitCollection.userInterfaceStyle {
               case .light, .unspecified:
                   // light mode detected
            doneBtn.enableButton(textField.text?.count == 4)
               case .dark:
                   // dark mode detected
            doneBtn.enableButton(textField.text?.count == 4)
            doneBtn.backgroundColor = .primaryGreen
           }
    }
}

//MARK: - Bind Views
extension VerifyOTPViewController {
    func bindVerifyOTPViewModel() {
        verifyOTPVM.verifyResponse.bind { [weak self] (flag) in
            guard let `self` = self else { return }
            if flag.statusCode == 200 {
//                otp success case
                self.moveToDestination()
                Commons.adjustEventTracker(eventId: AdjustEventId.OTPSuccess)
            }
        }

        verifyOTPVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }

        verifyOTPVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            if !value.isEmpty {
                self.otpTextFieldView.defaultBorderColor = UIColor.errorRed
//                otp error event
                Commons.adjustEventTracker(eventId: AdjustEventId.OTPFailure)
                if value.containsIgnoringCase("Nin format"){
                    Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self,backgroundColor: .skyBlue,textColor: .darkSkyBlue, message: "National ID is not in correct format.")
                }else if value.containsIgnoringCase("license"){
                    Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self,backgroundColor: .lightBrown,textColor: .darkBrown, message: "Incorrect expiry date.")
                }else{
                    Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
                }
            }
        }
    }
}

extension VerifyOTPViewController {
    func bindToEnterNumberViewModel() {
        enterNumberVM.apiResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.status == 200 {
                self.tId = res.data?.tId ?? ""
                self.timerValue = 60
                self.setTimer()
            }
        }
        
        enterNumberVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }

        enterNumberVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            if !value.isEmpty {
                Commons.showErrorMessage(controller: self.parent?.parent ?? self, message: value)
//                self.pincodeTF.setError()
//
            }
        }
    }
}

extension VerifyOTPViewController: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        print("OTPString: \(otpString)")
        enteredOTP = otpString
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            // light mode detected
            doneBtn.enableButton(otpString.count == 4)
        case .dark:
            // dark mode detected
            doneBtn.enableButton(otpString.count == 4)
            doneBtn.backgroundColor = .primaryGreen
        }
    }
}
