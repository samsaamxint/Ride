//
//  PaymentWebViewVC.swift
//  Ride
//
//  Created by Mac on 11/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import WebKit

protocol PaymentWebViewProtcol: AnyObject {
    func paymentSuccessfull()
    func paymentFailed(with error: String)
}

class PaymentWebViewVC: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var myWebView: WKWebView!
    
    //MARK: - Constants and Variables
    var urlStringToLoad: String?
    weak var delegate: PaymentWebViewProtcol?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlStringToLoad = urlStringToLoad, let url = URL(string: urlStringToLoad) {
            myWebView.load(URLRequest(url: url))
        }

        myWebView.navigationDelegate = self
        setLeftBackButton(selector: #selector(backButtonTapped))
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

extension PaymentWebViewVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView.url?.absoluteString == ServerUrls.PaymentCallBackURL else { return }
        webView.evaluateJavaScript("document.getElementsByTagName('pre')[0].innerHTML", completionHandler: { (res, error) in
             if let fingerprint = res as? String {
                 let data: Data = fingerprint.data(using: .utf8)!
                 do {
                     if let jsObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> {
                         if (jsObj["statusCode"] as? Int) == 200 {
                             self.delegate?.paymentSuccessfull()
                         } else {
                             let message = jsObj["message"] as? String
                             self.delegate?.paymentFailed(with: message ?? "Something went wrong".localizedString())
                         }
                         self.navigationController?.popViewController(animated: true)
                     }
                 } catch _ {
                     print("having trouble converting it to a dictionary")
                 }
             }
        })
    }
}
