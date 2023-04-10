//
//  ChoosePaymentMethodViewController.swift
//  Ride
//
//  Created by Mac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ChoosePaymentMethodViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    //MARK: - Constants and Variables
    private var choosePaymentVM = ChoosePaymentMethodViewModel()
    private var purchaseSubcriptionVM = PurchaseSubcriptionViewmodel()
    var driverKYCVM = DriverKYCViewModel()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewToViewModel()
        
        choosePaymentVM.getCardList(request: "1")
    }
    
    private func setupViews() {
        cardsCollectionView.register(UINib(nibName: SavedCardsCVCell.className, bundle: nil), forCellWithReuseIdentifier: SavedCardsCVCell.className)
        
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
    }
    
    //MARK: - UIACTIONS
    @IBAction func didTapAddNewBtn(_ sender: Any) {
        if let vc: SaveCardForPaymentViewController = UIStoryboard.instantiate(with: .paymentMethods) {
            parent?.parent?.navigationController?.pushViewController(vc, animated: true)
            (self.parent?.parent as? MainDashboardViewController)?.isFromSignup = false
        }
    }
    @IBAction func procceedPressed(_ sender: Any) {
        purchaseSubcriptionVM.purchaseSubcription(amount: 100, card_id: 1, payment_method: "card")
        //driverKYCVM.becomeCaption(driverName: "", driverNationalId: "", carPlateNo: "", carLicenceType: 1, carCategoryType: 1, cab: "", carSequenceNo: "", drivingModes: [], acceptTC: true, isShowLoader: false, isForWaslCheck: false, subscriptionId: "", autoRenewal: false, transactionId: "")
      
    }
    
    func GotoDriverScreen(){
        if let vc: WelcomeDriverVC = UIStoryboard.instantiate(with: .switchUser) {
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 330
            (self.parent?.parent as? MainDashboardViewController)?.isFromSignup = false
            UserDefaultsConfig.isDriver = true
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

//MARK: - CollectionView delegate and DataSource
extension ChoosePaymentMethodViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        choosePaymentVM.apiResponse.value.data?.count ?? DefaultValue.int
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedCardsCVCell.className, for: indexPath) as? SavedCardsCVCell else {
            return SavedCardsCVCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 250, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

//MARK: - Bind View Model
extension ChoosePaymentMethodViewController {
    private func bindViewToViewModel() {
        choosePaymentVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        choosePaymentVM.messageWithCode.bind { [weak self] errorWithCode in
            guard let `self` = self else { return }
            guard !(errorWithCode.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self,
                                     message: errorWithCode.message ?? DefaultValue.string)
        }
        
        choosePaymentVM.apiResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.code == 200 {
                self.cardsCollectionView.reloadData()
            }
        }
        
        purchaseSubcriptionVM.apiResponseData.bind { [weak self] res in
            guard let self = self else {return}
            guard let code = res.code else {return}
            if code == 200{
                let vc = StatusAlertVC.instantiate(title: "Topup Successful".localizedString(), message: "Payment of first month fees has been paid successfully".localizedString(), image: UIImage.init(named: "SuccessImage") ?? UIImage())
                vc.onlySuccess = true
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.alertAction = { (isDone) in
                    if isDone{
                        //if done/yes is pressed
                        self.GotoDriverScreen()
                    }else{
                        //if no/tryagain is pressed
                    }
                }
                self.present(vc, animated: true, completion: nil)
            }else{
                let vc = StatusAlertVC.instantiate(title: "Topup Failed".localizedString(), message: "Please try again after some time we are facing some server issues".localizedString(), image: UIImage.init(named: "FailedImage") ?? UIImage())
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.alertAction = { (isDone) in
                    if isDone{
                        //if done/yes is pressed
                    }else{
                        //if no/tryagain is pressed
                    }
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        purchaseSubcriptionVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        purchaseSubcriptionVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
        
        
        driverKYCVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        driverKYCVM.messageWithCode.bind { [weak self] errorWithCode in
            guard let `self` = self else { return }
            guard !(errorWithCode.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self,
                                     message: errorWithCode.message ?? DefaultValue.string)
        }
        
        driverKYCVM.apiResponsebecomeCap.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                (self.parent?.parent as? MainDashboardViewController)?.listenRequestForDriverAccept()
                SocketIOHelper.shared.establishConnection()
                self.GotoDriverScreen()
            }
        }
    }
}
