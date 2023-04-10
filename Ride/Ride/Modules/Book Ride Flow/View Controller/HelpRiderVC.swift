//
//  HelpRiderVC.swift
//  Ride
//
//  Created by Samsaam Zohaib on 23/02/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import UIKit

class HelpRiderVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var lblEmergency: UILabel!
    @IBOutlet weak var btnSharedRide: UIButton!
    @IBOutlet weak var btnCallPolice: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var lblCallCenter: UILabel!
    @IBOutlet weak var lblShareRide: UILabel!
    
    //MARK: - Variables
    let CustomerCareVM = CustomerCareViewModel()
    var number = "966544555527"
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindViewModel()
        CustomerCareVM.getCustomerCareCondition()
    }
    
    //MARK: - Private Function
    private func setupViews() {
        lblEmergency.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        btnSharedRide.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        btnCallPolice.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        btnCall.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        lblHelp?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        lblCallCenter?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        lblShareRide?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
    }
    
    //MARK: - IBAction
    @IBAction func btnCallThePolicePressed(_ sender: UIButton) {
        guard let number = URL(string: "tel://\(911)") else { return }
        UIApplication.shared.open(number)
    }
    @IBAction func btnShareDetailsPressed(_ sender: UIButton) {
        let language = (UserDefaults.standard.value(forKey: languageKey) as? String) ?? "en"
        let url = URL(string: "https://apps.apple.com/pk/app/ride-%D8%B1%D8%A7%D9%8A%D8%AF/id6443488537")!
        var message: String = ""
        if language == "ar" {
            message = "مرحبا، اود دعوتك لتحميل تطبيق رايد لتجربة رحلات سعيدة. حمل التطبيق الآن"
        } else {
            message = "Hi! I'd like to invite you to RiDE to experience good RiDE services. Download the app now."
        }
        let vc = UIActivityViewController(activityItems: [url, message], applicationActivities: nil)
        self.present(vc, animated: true)
    }
    @IBAction func btnCallPressed(_ sender: UIButton) {
        guard let number = URL(string: "tel://\(number)") else { return }
        UIApplication.shared.open(number)
    }
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

}


//MARK: - Extension
extension HelpRiderVC{
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
            if let data = res.data{
                self.number = data.value ?? ""
                
            }
        }
    }
}
