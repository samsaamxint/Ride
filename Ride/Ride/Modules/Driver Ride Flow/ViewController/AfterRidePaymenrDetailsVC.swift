//
//  AfterRidePaymenrDetailsVC.swift
//  Ride
//
//  Created by Ali Zaib on 05/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import UIKit

class AfterRidePaymentDetailsVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var totalEarningLbl: UILabel!
    @IBOutlet weak var transferFeeLbl: UILabel!
    @IBOutlet weak var netEarningLbl: UILabel!
    @IBOutlet weak var totalEarning: UILabel!
    @IBOutlet weak var transferFee: UILabel!
    @IBOutlet weak var netEarning: UILabel!
    @IBOutlet weak var takeNextRideBtn: UIButton!
    
    var driverAmount: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (self.parent?.parent as? MainDashboardViewController)?.goToGM.isHidden = true
    }
    
    func setupView() {
        let tripObj = RideSingleton.shared.tripDetailObject?.data
        pickupLabel.text = tripObj?.source?.address
        destinationLabel.text = tripObj?.destination?.address
        totalEarning.text = "SAR " + String(self.driverAmount)
        let netED = (self.driverAmount) - 0.5
        netEarning.text = "SAR " + (NSString(format: "%.2f",netED) as String)
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        pickupLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        destinationLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        totalEarningLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        transferFeeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        netEarningLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        totalEarning.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        transferFee.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        netEarning.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        takeNextRideBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        
        titleLbl.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    @IBAction func nextRidePressed(_ sender: Any) {
        UserDefaultsConfig.tripId = nil
        RideSingleton.shared.tripDetailObject = nil
        self.resetDriversMainView()
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
    
}
