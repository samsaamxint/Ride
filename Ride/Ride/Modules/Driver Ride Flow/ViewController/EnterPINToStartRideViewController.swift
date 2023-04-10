//
//  EnterPINToStartRideViewController.swift
//  Ride
//
//  Created by Mac on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps

class EnterPINToStartRideViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var pinCodeTF: PinCodeTextField!
    @IBOutlet weak var startRideBtn: UIButton!
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet weak var riderImage: UIImageView!
    @IBOutlet weak var riderRATING: UILabel!
    @IBOutlet weak var enterPInLbl: UILabel!
    
    //MARK: - Constants and Variables
    weak var delegate: DashboardChildDelegates?
    var tripstartedViewmodel = DriverTripStartedViewModel()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        pinCodeTF.alpha = 0
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.setupViews()
            self.view.layoutIfNeeded()
        }
        (self.parent?.parent as? MainDashboardViewController)?.goToGM.isHidden = false
        bindViewToViewModel()
        
        startRideBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        riderName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        riderRATING.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        enterPInLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        enterPInLbl.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .switchLeftBarItem, object: "", userInfo: [:])
        addObservers()
        pinCodeTF.keyboardType = .numberPad
    }
    
    
    //MARK: - Observers
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 340 + 100
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 340
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    private func setupViews() {
        pinCodeTF.delegate = self
        pinCodeTF.underlineWidth = (pinCodeTF.frame.width - 45) / 4
        startRideBtn.enableButton(false)
        pinCodeTF.alpha = 1
        pinCodeTF.layoutIfNeeded()
        pinCodeTF.setNeedsLayout()
        view.setNeedsLayout()
        
        var fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.name
        if Commons.isArabicLanguage(){
            fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.arabicName
        }
        let firstName = fullName?.components(separatedBy: " ")
        self.riderName.text = firstName?[0]
        self.riderName.text = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.rating
        riderRATING.text =  String(RideSingleton.shared.tripDetailObject?.data?.riderInfo?.rating ?? DefaultValue.string)
       
    }
    
    //MARK: - UIACTIONS
    @IBAction func startRideBtnClicked(_ sender: Any) {
        tripstartedViewmodel.tripStarted(id: UserDefaultsConfig.tripId ?? "", OTP: pinCodeTF.text ?? "0000")
    }
  
}

//MARK: - PinCodeTextFieldDelegate
extension EnterPINToStartRideViewController: PinCodeTextFieldDelegate {
    func textFieldValueChanged(_ textField: PinCodeTextField) {
      
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            // light mode detected
            startRideBtn.enableButton(textField.text?.count == 4)
        case .dark:
            // dark mode detected
            startRideBtn.enableButton(textField.text?.count == 4)
            startRideBtn.backgroundColor = .primaryGreen
        }
    }
}


extension EnterPINToStartRideViewController{
    func bindViewToViewModel() {
        tripstartedViewmodel.tripStartedResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                if let vc : RideInProgressViewController = UIStoryboard.instantiate(with: .driverToRider){
                    let parent = self.parent?.parent as? MainDashboardViewController
                    parent?.containerViewHeight.constant = 280
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
        
        tripstartedViewmodel.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        tripstartedViewmodel.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
        }
    }
}
