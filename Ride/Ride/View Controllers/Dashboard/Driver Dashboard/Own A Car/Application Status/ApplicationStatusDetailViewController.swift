//
//  ApplicationStatusDetailViewController.swift
//  Ride
//
//  Created by Mac on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ApplicationStatusDetailViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var underReviewLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var whatsAppBtn: UIButton!
    @IBOutlet weak var callCareBtn: UIButton!
    @IBOutlet weak var liveChatBtn: UIButton!
    @IBOutlet weak var reportAProblemBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    let CustomerCareVM = CustomerCareViewModel()
    var number = ""
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
       CustomerCareVM.getCustomerCareCondition()

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
        
        underReviewLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        descLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(18) : UIFont.SFProDisplayRegular?.withSize(18)
        callCareBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        liveChatBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        reportAProblemBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        doneBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        whatsAppBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
    }
    
    //MARK: - UIACTIONS
    @IBAction func doneBtnClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reportAproblem(_ sender: Any) {
        if let vc: ReportaProblemVC = UIStoryboard.instantiate(with: .userProfile) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func callCustomerCare(_ sender: Any) {
      
        guard let number = URL(string: "tel://\(number)") else { return }
        UIApplication.shared.open(number)
    }
}

extension ApplicationStatusDetailViewController{
    func bindViewModel(){
        CustomerCareVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        CustomerCareVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        CustomerCareVM.apiResponseData.bind { [weak self] res in
            guard let `self` = self else { return }
            guard res.statusCode == 200 else { return }
            var htmlString = ""
            if let data = res.data{
                self.number = data.value ?? ""
                
            }

        }
    }
}


