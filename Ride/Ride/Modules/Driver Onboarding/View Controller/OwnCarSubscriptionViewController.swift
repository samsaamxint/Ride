//
//  OwnCarSubscriptionViewController.swift
//  Ride
//
//  Created by Mac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class OwnCarSubscriptionViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var firstMonthFeeLbl: UILabel!
    @IBOutlet weak var payableAmountLbl: UILabel!
    @IBOutlet weak var currentBalanceLbl: UILabel!
    @IBOutlet weak var balanceTitleLbl: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var addBalanceBtn: UIButton!
    @IBOutlet weak var transactionFeesLbl: UILabel!
    @IBOutlet weak var VATAmountLbl: UILabel!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var promocodeDiscountLbl: UILabel!
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var firstMonthLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var vatlLabel: UIStackView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var promoCodeLabel: UIStackView!
    @IBOutlet weak var payableAmountLabel: UILabel!
    
    @IBOutlet weak var promoCodeStackView: UIStackView!
    @IBOutlet weak var promocodeBtn: UIButton!
    @IBOutlet weak var promocodeView: UIView!
    @IBOutlet weak var promocodeTextLbl: UILabel!
    @IBOutlet weak var removePromocodeBtn: UIImageView!
    
    
    
    //MARK: - Constants and Variables
//    var payableAmount: Double?
    private let subscriptionVM = SubscriptionViewModel()
    private var discountedPrice: Double = 0.0
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        bindViewToViewModel()
        subscriptionVM.getInvoice()
        
        promocodeView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(removePromo)))
        
        firstMonthFeeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        payableAmountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        currentBalanceLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(12) : UIFont.SFProDisplayBold?.withSize(12)
        balanceTitleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        confirmBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        addBalanceBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        transactionFeesLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        VATAmountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        totalAmountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        promocodeDiscountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        registrationLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        descLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        firstMonthLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        transactionLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        totalAmountLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        payableAmountLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscriptionVM.getBalance()
        
        if let parent = parent?.parent as? MainDashboardViewController {
            parent.containerViewHeight.constant = discountedPrice == 0 ? 440 : 520
        } else if let parent = parent?.parent as? EmptyTopupViewController {
            parent.containerViewHConstraint.constant = discountedPrice == 0 ? 440 : 520
        }
    }
    
    @objc private func removePromo(){
        promocodeBtn.isHidden = false
        promocodeView.isHidden = true
        promocodeTextLbl.text = ""
        discountedPrice = 0.0
                
        setupView()
        
        if let parent = parent?.parent as? MainDashboardViewController {
            parent.containerViewHeight.constant = 440
        } else if let parent = parent?.parent as? EmptyTopupViewController {
            parent.containerViewHConstraint.constant = 440
        }
    }
    
    private func setupView() {
        let data = subscriptionVM.getInvoiceResponse.value.data
        
        let finalPrice = data?.finalPrice ?? DefaultValue.double
        let totalPayable = finalPrice - discountedPrice
        
        firstMonthFeeLbl.text = "SAR " + (NSString(format: "%.2f",data?.basePrice ?? DefaultValue.double) as String)
        totalAmountLbl.text = "SAR " + (NSString(format: "%.2f",finalPrice) as String)
        promocodeDiscountLbl.text = "SAR -" + (NSString(format: "%.2f",discountedPrice) as String)
        payableAmountLbl.text = "SAR " + (NSString(format: "%.2f",totalPayable) as String)
        
        transactionFeesLbl.text = "SAR " + (NSString(format: "%.2f",data?.cardFee ?? DefaultValue.double) as String)
        VATAmountLbl.text = "SAR " + (NSString(format: "%.2f",data?.taxAmount ?? DefaultValue.double) as String)
        
        currentBalanceLbl.text = "SAR " + (NSString(format: "%.2f",RideSingleton.shared.userBalance ?? DefaultValue.double) as String)
        
        promoCodeStackView.isHidden = discountedPrice == 0.0
        
        balanceTitleLbl.text = "Balance"
        balanceTitleLbl.textColor = .primaryDarkBG
        confirmBtn.isHidden = false
        addBalanceBtn.isHidden = true
    }
    
    //MARK: - UIACTIONS
    @IBAction func addSARBtnClicked(_ sender: Any) {
        subscriptionVM.purchaseSubscription(promocode: promocodeTextLbl.text)
    }
    
    @IBAction func addBalancePressed(_ sender: Any) {
        if let vc: AddBalanceVC = UIStoryboard.instantiate(with: .paymentMethods) {
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 560
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func promoBtnPressed(_ sender: Any) {
        if let vc: AddPromoCodeVC = UIStoryboard.instantiate(with: .promoCode) {
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 210
            self.navigationController?.pushViewController(vc, animated: false)
            vc.applyingTo = 2
            vc.selectedAmount = subscriptionVM.getInvoiceResponse.value.data?.finalPrice
            vc.promoReturn = {[weak self] (code,discount,Status) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    
                    guard let self = self else {return}

                    self.promocodeBtn.isHidden = true
                    self.promocodeView.isHidden = false
                    self.promocodeTextLbl.text = code
                    self.discountedPrice = Double(discount) ?? 0.0
                  
                                    
                    if let parent = self.parent?.parent as? MainDashboardViewController {
                        parent.containerViewHeight.constant = 520
                    } else if let parent = self.parent?.parent as? EmptyTopupViewController {
                        parent.containerViewHConstraint.constant = 520
                    }
                    
                    self.setupView()
                }
            }
        }
    }
}

//MARK: - Bind View Model
extension OwnCarSubscriptionViewController {
    private func bindViewToViewModel() {
        subscriptionVM.apiResponseData.bind { [weak self] value in
            guard let `self` = self else { return }
            
            guard value.statusCode == 200 else { return }
            
            RideSingleton.shared.userBalance = value.data?.balance
            self.setupView()
        }
        
        subscriptionVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        subscriptionVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        subscriptionVM.verifySubscriptionRes.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            let parent = self.parent?.parent as? MainDashboardViewController
            parent?.mainDashboardVM.getCaptainStatus(check: .fromLanding)
        }
        
        subscriptionVM.getInvoiceResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            self.setupView()
        }
        
        subscriptionVM.purchaseSubscriptionData.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            
            if let vc: PaymentWebViewVC = UIStoryboard.instantiate(with: .paymentMethods) {
                vc.urlStringToLoad = res.data?.redirect_url
                vc.delegate = self
                self.parent?.parent?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension OwnCarSubscriptionViewController: PaymentWebViewProtcol {
    func paymentSuccessfull() {
        if let parent = self.parent?.parent as? MainDashboardViewController {
        parent.mainDashboardVM.getCaptainStatus(check: .fromLanding)
        } else if let parent = parent?.parent as? EmptyTopupViewController {
            parent.dismiss(animated: false) {
                parent.delegate?.subscriptionPurchased()
            }
        }
    }
    
    func paymentFailed(with error: String) {
        Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: error)
    }
}
