//
//  OwnACarViewController.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class OwnACarViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var mainStackview: UIStackView!
    @IBOutlet weak var driverNameTF: UITextField!
    @IBOutlet weak var driverIDTF: UITextField!
    @IBOutlet weak var plateNumberTF: UITextField!
    @IBOutlet weak var sequenceNumberTF: UITextField!
    
    @IBOutlet weak var chooseCarView: UIStackView!
    @IBOutlet weak var acceptIcon: UIButton!
    @IBOutlet weak var chosenCarView: UIView!
    @IBOutlet weak var changeCarBtn: UIButton!
    
    @IBOutlet weak var verifyBtn: UIButton!
    
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var proceedSV: UIStackView!
    
    //MARK: - Constants and Variables
    private var isAccepted = false {
        didSet {
            acceptIcon.setImage(isAccepted ? UIImage(named: "CheckmarkIcon") : nil, for: .normal)
            textFieldValueChangeListener()
        }
    }
    private let driverKYCVM = DriverKYCViewModel()

    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLeftBackButton(selector: #selector(backButtonTapped))
        setupTextFields()
        
        proceedBtn.enableButton(false)
        
        chooseCarView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeCarPressed))
        chooseCarView.addGestureRecognizer(tap)
        
        setupLanguage()
        bindToDriverKYVViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let vc: CarSelectionVC = UIStoryboard.instantiate(with: .driverOnboarding) {
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
            vc.selectedIndex = { (index) in
//                self.chooseCarView.isHidden = true
//                self.chosenCarView.isHidden = false
//                self.mainStackview.setNeedsLayout()
//                self.mainStackview.sizeToFit()
            }
        }
    }
    
    private func setupLanguage() {
        driverNameTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        driverIDTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        plateNumberTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        sequenceNumberTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    private func setupTextFields() {
        driverNameTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        driverIDTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        plateNumberTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        sequenceNumberTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        
        driverNameTF.setLeadingPadding(15)
        driverIDTF.setLeadingPadding(15)
        plateNumberTF.setLeadingPadding(15)
        sequenceNumberTF.setLeadingPadding(15)
        
        driverNameTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        driverIDTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        plateNumberTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        sequenceNumberTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        
        driverNameTF.delegate = self
        driverIDTF.delegate = self
        plateNumberTF.delegate = self
        sequenceNumberTF.delegate = self
    }
    
    //MARK: - Observers
    @objc private func textFieldValueChangeListener() {
        if driverNameTF.text?.isEmpty ?? true {
            proceedBtn.enableButton(false)
            return
        }
        
        if driverIDTF.text?.isEmpty ?? true {
            proceedBtn.enableButton(false)
            return
        }
        
        if plateNumberTF.text?.isEmpty ?? true {
            proceedBtn.enableButton(false)
            return
        }
        
        if sequenceNumberTF.text?.isEmpty ?? true {
            proceedBtn.enableButton(false)
            return
        }
        
        if !isAccepted {
            proceedBtn.enableButton(false)
            return
        }
        
        proceedBtn.enableButton(true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    
    
    //MARK: - UIACTIONS
    @IBAction func acceptTermsClicked(_ sender: Any) {
        isAccepted.toggle()
    }
    
    @IBAction func changeCarPressed(_ sender: Any) {
        if let vc: CarSelectionVC = UIStoryboard.instantiate(with: .driverOnboarding) {
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
            vc.selectedIndex = { (index) in
                self.chooseCarView.isHidden = true
                self.chosenCarView.isHidden = false
                self.mainStackview.setNeedsLayout()
                self.mainStackview.sizeToFit()
            }
        }
    }
    
    @IBAction func verifyBtnClicked(_ sender: Any) {
//        driverKYCVM.updateUserInfo(with: mobileNumber ?? DefaultValue.string, full_name: driverNameTF.text, type: 2, driver_id: driverIDTF.text, car_plate_number: plateNumberTF.text, car_sequence_number: sequenceNumberTF.text)
        self.verifyBtn.isHidden = true
        self.proceedSV.isHidden = false
    }
    
    @IBAction func proceedBtnClicked(_ sender: Any) {
//        Commons.goToMain(type: .driverOwnCar)
        Commons.goToMain(type: .driver)
    }
}

//MARK: - UITextFieldDelegate
extension OwnACarViewController: UITextFieldDelegate {
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
}

extension OwnACarViewController {
    func bindToDriverKYVViewModel() {
        driverKYCVM.apiResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.status == 200 {
                self.verifyBtn.isHidden = true
                self.proceedSV.isHidden = false
            }
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
