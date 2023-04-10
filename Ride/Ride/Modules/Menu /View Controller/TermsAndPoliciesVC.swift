//
//  TermsAndPoliciesVC.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import WebKit

class TermsAndPoliciesVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var VCtitle: UILabel!
    var setTitle = ""
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var webVu: WKWebView!
    
    var url: URL?
    let TermsConditionVM = TermsConditionViewModel()
    var isPolicy = false
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        bindViewModel()
        loadLegals()
        
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
        self.VCtitle.text = setTitle.localizedString()
        self.TermsConditionVM.getTermsCondition(isPrivacyPolicy: self.isPolicy)
        VCtitle.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        
    }
    
    private func loadLegals() {
        let language: String = UserDefaults.standard.value(forKey: languageKey) as? String ?? ""
        if setTitle == "Privacy Policy" && language == "en"{
            url = URL(string: ServerUrls.legals + RequestType.PrivacyPolicy)
        } else if setTitle == "Terms & Condition" && language == "en" {
            url = URL(string: ServerUrls.legals + RequestType.TermsAndConditions)
        } else if setTitle == "Privacy Policy" && language == "ar" {
            url = URL(string: ServerUrls.legals + RequestType.PrivacyPolicyAR)
        } else if setTitle == "Terms & Condition" && language == "ar" {
            url = URL(string: ServerUrls.legals + RequestType.TermsAndConditionsAR)
        }
        if let url = url {
            webVu.load(URLRequest(url: url))
        }
    }
    
    // MARK: - Navigation
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension TermsAndPoliciesVC{
    func bindViewModel(){
        TermsConditionVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        TermsConditionVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
//        TermsConditionVM.apiResponseData.bind { [weak self] res in
//            guard let `self` = self else { return }
//            guard res.statusCode == 200 else { return }
//            var htmlString = ""
//            let language: String = UserDefaults.standard.value(forKey: languageKey) as? String ?? ""
//            for item in res.data!.data!{
//                //                let size = "<span style=\"font-family: \(UIFont.SFProDisplayRegular); font-size: \(item.order)\">%@</span>", text)
//                //                let size = "<span style=font-size: 26px>"
//                //                if item.code == "terms-and-conditions" && self.setTitle == "Terms & Condition".localizedString(){
//                var title = item.title ?? ""
//                title = "<h1>\(title)</h1>"
//                let styles = "<html><head>"
//                + "<style type=\"text/css\">body{font-size:20px;}" //font-family:\(UIFont.SFProDisplayRegular);
//                + "</style></head>"
//                + "<body \(language == "ar" ? "style='align:right;" : "style='text-align:left;") >" + "</body></html>"
//
////                var bodyStyle = ""
////                if language == "ar" {
////                    bodyStyle = "<div  style='text-align:right;'align:right; color:blue; >" + (item.description ?? "") + "</div>"
////                }
//                title = styles + title
//                let body = item.description //bodyStyle + (item.description  ?? "")
//                htmlString.append(title)
//                htmlString.append(body ?? "")
//
//
//            }
//            print(htmlString)
//            self.webVu.loadHTMLString(htmlString, baseURL: nil)
//
//            // let url = URL(string: "https://uat-dashboard.ride.sa/pages/terms-and-condition.html")
//            //webVu.load(URLRequest(url: url!))
//            // self.webVu.load(URLRequest(url: URL(string: "https://uat-dashboard.ride.sa/pages/terms-and-condition.html") ?? "))
//            //  loadHTMLString(htmlString, baseURL: nil)
//            //            self.desc.attributedText = htmlString.convertToAttributedFromHTML()
//            //            self.desc.textAlignment  = Commons.isArabicLanguage() ? .right : .left
//            //            self.desc.textColor = .primaryDarkBG
//            //            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
//            //                self.desc.textColor = .white
//            //            } else {
//            //                self.desc.textColor = .
//            //            }
//            //self.notificationTV.reloadData()
//        }
    }
}
