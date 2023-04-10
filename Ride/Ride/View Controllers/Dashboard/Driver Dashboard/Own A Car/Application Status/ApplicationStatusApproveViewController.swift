//
//  ApplicationStatusApproveViewController.swift
//  Ride
//
//  Created by Mac on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ApplicationStatusApproveViewController: UIViewController {
    //MARK: - Constants and Variables
    weak var delegate: DashboardChildDelegates?
    private let selectedPlanVM = SelectedPlanSummaryViewModel()
    var hasSubscribedBefore : Bool = false
    var payableAmount: Double?
    
    //MARK: - Outlets
    @IBOutlet weak var approvedLabel: UILabel!
    @IBOutlet weak var subscribeBtn: UIButton!
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewToViewModel()
        
        approvedLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        subscribeBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.containerViewHeight.constant = 290
    }
    
    //MARK: - UIACTIONS
    @IBAction func subscribeBtnClicked(_ sender: Any) {
        let parent = self.parent?.parent as? MainDashboardViewController
        if let vc: VerifyDriverIBANViewController = UIStoryboard.instantiate(with: .driverRideARideDashboard) {
            parent?.containerViewHeight.constant = 400
            (parent?.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
            parent?.addChildWithNavViewController(childController: vc, contentView: parent?.containerView ?? UIView())
            //self.navigationController?.pushViewController(vc, animated: false)
        }
    }
        //selectedPlanVM.getPlanSummary(id: 1)
//        if hasSubscribedBefore{
//            if let vc: SubcriptionDetailVC = UIStoryboard.instantiate(with: .userProfile) {
//            vc.showAllSub = true
//                self.parent?.parent?.navigationController?.pushViewController(vc, animated: true)
//        }
//        }else{
//            let parent = self.parent?.parent as? MainDashboardViewController
//            let childNavigationController = parent?.containerView.subviews.first?.getParentController() as? UINavigationController
//            if let vc: OwnCarSubscriptionViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
//                parent?.containerViewHeight.constant = 440
//                childNavigationController?.pushViewController(vc, animated: false)
//            }
//        }
        
    }

extension ApplicationStatusApproveViewController{
    func bindViewToViewModel(){
        selectedPlanVM.apiResponseData.bind { res in
            if res.code == 200{
                let parent = self.parent?.parent as? MainDashboardViewController
                let childNavigationController = parent?.containerView.subviews.first?.getParentController() as? UINavigationController
                if let vc: OwnCarSubscriptionViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                    parent?.containerViewHeight.constant = 440
                    childNavigationController?.pushViewController(vc, animated: false)
                }
            }
        }
        
        selectedPlanVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        selectedPlanVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
    }
}
