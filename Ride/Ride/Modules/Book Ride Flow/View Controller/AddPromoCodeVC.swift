//
//  AddPromoCodeVCViewController.swift
//  Ride
//
//  Created by XintMac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class AddPromoCodeVC : UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var promoCodeLbl: UILabel!
    @IBOutlet weak var promoCodeView: UIView!
    @IBOutlet weak var promoCodeTF: UITextField!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    //MARK: - Constants and Variables
    private let promocodeVM = PromocodeViewModel()
    var applyingTo = 1
    
    var selectedAmount : Double?
    var promoReturn : ((String,String,Bool) -> Void)? = nil
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.promoCodeTF.delegate = self
        promoCodeTF.placeholder = "Promo Code".localizedString()
        bindToViewModel()
        
        
       promoCodeTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        
        backBtn.rotateBtnIfNeeded()
    
    }
    
    override func viewDidLayoutSubviews() {
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        promoCodeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        promoCodeTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        applyBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: - IBActions
    @IBAction func applyPressed(_ sender: Any) {
        if (promoCodeTF.text?.isEmpty ?? true){
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Please Enter Promo Code".localizedString())
            promoCodeView.addDoubleBorder(with: .red, and: .clear)
            return
        }
        //promoReturn?(promoCodeTF.text!, true)
        //promocodeVM.validatePromocode(amount: selectedAmount ?? 0.0, promoCode: promoCodeTF.text!, tripId: nil)
        if let currentLocation = LocationManager.shared.locationManager?.location{
            self.promocodeVM.validatePromocode(amount: selectedAmount ?? 0.0, promoCode: promoCodeTF.text!, lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude, applyingTo: self.applyingTo, tripId: nil)
        }
    }
}

//MARK: - UITextFieldDelegate
extension AddPromoCodeVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        promoCodeView.addDoubleBorder(with: .primaryDarkBG, and: .primaryGreen)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            promoCodeView.addDoubleBorder(with: .sepratorColor, and: .clear)
        } else {
            promoCodeView.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
        }
    }
}


extension AddPromoCodeVC{
    func bindToViewModel(){
        promocodeVM.validateSubscriptionRes.bind {[weak self] (value) in
            guard let `self` = self else { return }
            if value.statusCode == 200 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.promoReturn?(self.promoCodeTF.text!,String(value.data?.amount ?? 0.0), true)
                    self.navigationController?.popViewController(animated: false)
                })
                
            }
        }
        
        promocodeVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
            self.promoCodeView.addDoubleBorder(with: .red, and: .clear)
        }
        
        promocodeVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
    }
}
