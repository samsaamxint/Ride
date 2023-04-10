//
//  RiderNoDriverVC.swift
//  Ride
//
//  Created by XintMac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class RiderNoDriverVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tryagainBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
     //MARK: - Variables and Constant
    private let cancelTripVM = CancelTripViewmodel()
     var tripId : String = ""
    
     //MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        Commons.adjustEventTracker(eventId: AdjustEventId.CarNotFound)
        titleLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        tryagainBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        cancelBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 380
        ( self.parent?.parent as? MainDashboardViewController)?.navigationItem.leftBarButtonItem = nil
       // bindViewToViewModel()
    }


    // MARK: - IBActions

    @IBAction func tryAgainPressed(_ sender: Any) {
        //self.navigationController?.popViewController(animated: false)
        let controllers = self.navigationController?.viewControllers ?? []
        if controllers.isEmpty{
            self.navigationController?.popViewController(animated: true)
            return
        }
        for vc in controllers{
            if vc.isKind(of: RiderRideSelection.self){
                ( self.parent?.parent as? MainDashboardViewController)?.handleSwitchUserView()
                self.navigationController?.popToViewController(vc, animated: false)
                return
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        //cancelTripVM.cancelTrip(id: self.tripId)
        
        ( self.parent?.parent as? MainDashboardViewController)?.setupSwitchUserModeView()
        let controllers = self.navigationController?.viewControllers ?? []
        for vc in controllers{
            if vc.isKind(of: RiderDropOffVC.self){
              
                self.navigationController?.popToViewController(vc, animated: false)
                return
            }
        }
    }
    
}

extension RiderNoDriverVC {
    func bindViewToViewModel() {
        cancelTripVM.cancelTripResponse.bind { [weak self] res in
            guard let self = self else { return }
            if res.statusCode == 200{
                print("msg : ",res.message as Any)
                ( self.parent?.parent as? MainDashboardViewController)?.setupSwitchUserModeView()
                let controllers = self.navigationController?.viewControllers ?? []
                for vc in controllers{
                    if vc.isKind(of: RiderDropOffVC.self){
                        self.navigationController?.popToViewController(vc, animated: false)
                        return
                    }
                }
            }else{
                print("res : ",res.data as Any)
            }
        }
        
        
        cancelTripVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
    }
}
