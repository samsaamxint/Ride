//
//  CompleteRideViewController.swift
//  Ride
//
//  Created by Mac on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class CompleteRideViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var submitRatingBtn: UIButton!
    @IBOutlet weak var totalEarningLabel: UILabel!
    @IBOutlet weak var totalearningLbl: UILabel!
    @IBOutlet weak var rateRiderLbl: UILabel!
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet var ratingViews: [UIButton]!
    @IBOutlet weak var loyalityPointsLbl: UILabel!
    @IBOutlet weak var loyalPoints: UILabel!
    
    //MARK: - Constants and Variables
    private let ratingVieWModel = RatingViewModel()
    private var selectedRatingIndex = 1
    private var tripId = ""
    var driverAmount: Double = 0.0
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewToViewModel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let `self` = self else { return }
            let newBalance = (RideSingleton.shared.userBalance ?? 0.0) + (RideSingleton.shared.tripDetailObject?.data?.riderAmount ?? 0.0)
            RideSingleton.shared.userBalance = newBalance
            
            self.tripId = UserDefaultsConfig.tripId ?? ""
            self.driverAmount = RideSingleton.shared.tripDetailObject?.data?.driverAmount ?? 0.0
            self.totalEarningLabel.text =  String(self.driverAmount) + " SAR"
        }
        
//        UserDefaultsConfig.tripId = nil
//        RideSingleton.shared.tripDetailObject = nil
        
        submitRatingBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        totalearningLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        totalEarningLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        rateRiderLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(15) : UIFont.SFProDisplayMedium?.withSize(15)
        riderName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        
        totalEarningLabel.textAlignment = Commons.isArabicLanguage() ? .right : .left
        totalearningLbl.textAlignment = totalEarningLabel.textAlignment
        loyalityPointsLbl.textAlignment = totalEarningLabel.textAlignment
        loyalPoints.textAlignment = totalEarningLabel.textAlignment
    }
    
    private func resetBorders() {
        ratingViews.forEach { button in
            button.borderWidth = 0
        }
    }
    
    private func setupViews() {
        resetBorders()
        submitRatingBtn.enableButton(false)
        var fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.name
        if Commons.isArabicLanguage(){
            fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.arabicName
        }
        let firstName = fullName?.components(separatedBy: " ")
        self.riderName.text = firstName?[0]
        
        
    }
    
    private func resetDriversMainView() {
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.containerViewHeight.constant = 220
        navigationController?.popToRootViewController(animated: false)
        parent?.mapView?.clear()
        parent?.setupSwitchUserModeView()
        
        let leftView = parent?.navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
        leftView?.selectCaptainView()
    }
    
    //MARK: - UIACTIONS
    @IBAction func ratingViewSelected(_ sender: UIButton) {
        resetBorders()
        ratingViews[sender.tag - 1].addDoubleBorder(cornerRadius: 22)
     
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            // light mode detected
            submitRatingBtn.enableButton(true)
        case .dark:
            // dark mode detected
            submitRatingBtn.enableButton(true)
            submitRatingBtn.backgroundColor = .primaryGreen
        }
        
        selectedRatingIndex = sender.tag
    }
    
    @IBAction func submitRatingClicked(_ sender: UIButton) {
        ratingVieWModel.reviewRider(title: "test", desc: "", rating: Float(selectedRatingIndex), tripid: tripId)
    }
}

//MARK: - API
extension CompleteRideViewController{
    func bindViewToViewModel() {
        ratingVieWModel.submitRatingResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 || res.statusCode == 201 {
                if let vc : AfterRidePaymentDetailsVC = UIStoryboard.instantiate(with: .driverToRider){
                    let parent = self.parent?.parent as? MainDashboardViewController
                    parent?.containerViewHeight.constant = 400
                    parent?.navigationItem.leftBarButtonItem = nil
                    vc.driverAmount = self.driverAmount
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
        
        ratingVieWModel.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        ratingVieWModel.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
        }
    }
}
