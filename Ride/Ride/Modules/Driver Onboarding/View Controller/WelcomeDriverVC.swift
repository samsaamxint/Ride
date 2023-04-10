//
//  WelcomeDriverVC.swift
//  Ride
//
//  Created by XintMac on 01/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class WelcomeDriverVC: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    
    var welcomeDriverVM = WelcomeDriverViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

       bindViewToViewModel()
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        descriptionLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(18) : UIFont.SFProDisplayRegular?.withSize(18)
        doneBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        welcomeDriverVM.welcomeDriver()
        if let vc: NoRidersViewController = UIStoryboard.instantiate(with: .driverToRider) {
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 220
            (self.parent?.parent as? MainDashboardViewController)?.navigationItem.leftBarButtonItem?.isEnabled = true
            (self.parent?.parent as? MainDashboardViewController)?.navigationItem.rightBarButtonItem?.isEnabled = true
            (self.parent?.parent as? MainDashboardViewController)?.showDriverMainScreen()
            UserDefaultsConfig.isDriver = true
            //self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    

}
 

extension WelcomeDriverVC{
    func bindViewToViewModel() {
        
        welcomeDriverVM.apiResponse.bind {  [weak self] res in
            guard let self = self else {return}
            
        }
        
        welcomeDriverVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: false)
        }
        
        welcomeDriverVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
        }
    }
}
