//
//  ApplicationStatusViewController.swift
//  Ride
//
//  Created by Mac on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ApplicationStatusViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var underProcessLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var seeDetailsBtn: UIButton!
    @IBOutlet weak var statusImgVu: UIImageView!
    
    var isRejected = false
    var rejectionReason = ""
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        underProcessLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        descLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(18) : UIFont.SFProDisplayRegular?.withSize(18)
        seeDetailsBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        if isRejected {
            underProcessLabel.text = "Your Application Is Rejected".localizedString()
            descLabel.text = rejectionReason
            statusImgVu.image = UIImage(named: "RedCross")
            seeDetailsBtn.isHidden = true
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        isRejected = false
    }
    
    //MARK: - UIACTIONS
    @IBAction func seeDetailsClicked(_ sender: Any) {
        if let vc: ApplicationStatusDetailViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
            parent?.parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
