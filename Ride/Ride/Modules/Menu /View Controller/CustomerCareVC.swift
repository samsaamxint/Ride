//
//  CustomerCareVC.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class CustomerCareVC : UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var callCarebtn: UIButton!
    @IBOutlet weak var whatsAppBtn: UIButton!
    @IBOutlet weak var liveChatBtn: UIButton!
    @IBOutlet weak var reportAProblemBtn: UIButton!
    
    let CustomerCareVM = CustomerCareViewModel()
    var number = "966544555527"
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
       CustomerCareVM.getCustomerCareCondition()
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        callCarebtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        whatsAppBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        liveChatBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        reportAProblemBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
    }
    
    // MARK: - Navigation
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - IBActions
    @IBAction func callCustomerCarePressed(_ sender: Any) {
       
        guard let number = URL(string: "tel://\(number)") else { return }
        UIApplication.shared.open(number)
    }
    
    
    @IBAction func callWhatsAppPressed(_ sender: Any) {
        openWhatsapp()
    }
    
    @IBAction func liveChatPressed(_ sender: Any) {
        if let vc: MainChatVC = UIStoryboard.instantiate(with: .chat) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func reportAproblemPressed(_ sender: Any) {
        if let vc: ReportaProblemVC = UIStoryboard.instantiate(with: .userProfile) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func openWhatsapp(){
        let urlWhats = "whatsapp://send?phone=+966\(number)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(whatsappURL)
                    }
                }
                else {
                    print("Install Whatsapp")
                }
            }
        }
    }

}

extension CustomerCareVC{
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
//            self.webVu.loadHTMLString(htmlString, baseURL: nil)
//            self.desc.attributedText = htmlString.convertToAttributedFromHTML()
//            self.desc.textAlignment  = Commons.isArabicLanguage() ? .right : .left
//            self.desc.textColor = .primaryDarkBG
//            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
//                self.desc.textColor = .white
//            } else {
//                self.desc.textColor = .
//            }
            //self.notificationTV.reloadData()
        }
    }
}

