//
//  CancelRideByDriverViewController.swift
//  Ride
//
//  Created by Mac on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class CancelRideByDriverViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var cancelReasonsTableview: UITableView!
    @IBOutlet weak var reasonTVheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelRideBtn: UIButton!
    @IBOutlet weak var cancelRideLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    
    //MARK: - Constants and Variables
    weak var delegate: DashboardChildDelegates?
    private var riderCancelViewModel = RiderCancelViewModel()
    var previousContainerHeight : CGFloat = 0
    var callback : ((CGFloat) -> ())? = nil
    var type: CancelReasonType?
    var selectedReason : String?
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        bindViewToViewModel()
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.handleSwitchUserView()
        
        riderCancelViewModel.getReasons(with: type ?? .CANCEL_BY_RIDER)
        cancelRideBtn.enableButton(false)
        
        cancelRideBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        cancelRideLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        descLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
    }
    
    
    private func setupTableView() {
        cancelReasonsTableview.delegate = self
        cancelReasonsTableview.dataSource = self
        
        cancelReasonsTableview.register(UINib(nibName: CancelReasonTableViewCell.className, bundle: nil), forCellReuseIdentifier: CancelReasonTableViewCell.className)
    }
    
    //MARK: - UIACTIONS
    @IBAction func cancelRideClicked(_ sender: Any) {
//        cancel ride by driver
        if UserDefaultsConfig.isDriver{
            self.riderCancelViewModel.cancelTripByDriver(id:  RideSingleton.shared.tripDetailObject?.data?.id ?? DefaultValue.string, reason: selectedReason ?? "")
        } else {
            self.riderCancelViewModel.cancelTripByRider(id:  RideSingleton.shared.tripDetailObject?.data?.id ?? DefaultValue.string, reason: selectedReason ?? "")
            
            if let vc : RiderCancelingVC = UIStoryboard.instantiate(with: .riderToDriver){
                let parent = self.parent?.parent as? MainDashboardViewController
                parent?.containerViewHeight.constant = 250
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
}

//MARK: - Tableview delegate and datasource
extension CancelRideByDriverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.riderCancelViewModel.getReasons.value.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CancelReasonTableViewCell.className, for: indexPath) as? CancelReasonTableViewCell else { return CancelReasonTableViewCell() }
        cell.reasonData =  self.riderCancelViewModel.getReasons.value.data?[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReason = self.riderCancelViewModel.getReasons.value.data?[indexPath.section].id
        cancelRideBtn.enableButton(true)
    }
}


extension CancelRideByDriverViewController{
    func bindViewToViewModel(){
        self.riderCancelViewModel.riderCancelResponse.bind  { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                print("res : ",res)
//                rider cancel ride
                Commons.adjustEventTracker(eventId: AdjustEventId.RideCancelledAfterconfirmation)
                NotificationCenter.default.post(name: .rideCanceled, object: "", userInfo: [:])
            }
        }
        
        self.riderCancelViewModel.driverCancelResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                print("res : ",res)
//                driver cancel ride
                Commons.adjustEventTracker(eventId: AdjustEventId.RideCancelledAfterconfirmation)
                let parent = self.parent?.parent as? MainDashboardViewController
                parent?.containerViewHeight.constant = 220
                parent?.setupSwitchUserModeView()
                parent?.mapView?.clear()
                RideSingleton.shared.tripDetailObject = nil
                UserDefaultsConfig.tripId = nil
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
        
        if UserDefaultsConfig.isDriver{
            self.riderCancelViewModel.isLoading.bind {  [weak self] value in
                guard let self = self else {return}
                self.showLoader(startAnimate: value)
            }
        }
            
        
        self.riderCancelViewModel.apiResponseMessage.bind {  [weak self] err in
            guard let self = self else {return}
            if !err.isEmpty{
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err)
            }
        }
        
        self.riderCancelViewModel.getReasons.bind {  [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                self.cancelReasonsTableview.reloadData()
                self.reasonTVheightConstraint.constant = CGFloat(((self.riderCancelViewModel.getReasons.value.data?.count ?? 0) * 50))
                let parent = self.parent?.parent as? MainDashboardViewController
                parent?.containerViewHeight.constant = 200 +  self.reasonTVheightConstraint.constant
                
            }
        }
    }
}
