//
//  GenericOnboardingViewController.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import PromiseKit
class GenericOnboardingViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc: UserSelectionViewController = UIStoryboard.instantiate(with: .onboarding) {
            addChildWithNavViewController(childController: vc, contentView: containerView)
        }
        
        hideKeyboardWhenTappedAround()
        checkLatestVersionApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        if UserDefaultsConfig.appVersion.isSome {
            if AppVersion < UserDefaultsConfig.appVersion! {
                if let url = URL(string: "\(AppLink)") {
                    UIApplication.shared.open(url)
                }
            }
        } else {
            checkLatestVersionApp()
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    func checkLatestVersionApp() {
        showLoader(startAnimate: true)
        CheckLatestAppAPI.shared.request()
            .done { (res) in
                if res.statusCode == 200  {
                    if AppVersion < (res.data?.value)! {
                        UserDefaultsConfig.appVersion = res.data?.value
                        if let url = URL(string: "\(AppLink)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .catch { (error) in
                let myError = error as? RideError
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                var topVC: UIViewController!
                if var topController = keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topVC = topController
                }
                switch myError {
                case .otherError(let message):
                    Commons.showErrorMessage(controller: topVC, message: message)
                case .errorWithCode(let message, _):
                    
                    Commons.showErrorMessage(controller: topVC, message: message)
                default:
                    Commons.showErrorMessage(controller: topVC, message: error.localizedDescription)
                }
            }
            .finally { [weak self] in
                self?.showLoader(startAnimate: false)
            }
    }
    
    //    @IBAction func chnagelanguage(_ sender: Any) {
    //        if UserDefaults.standard.value(forKey: languageKey) as? String == "ar"{
    //            UserDefaults.standard.set("en", forKey: languageKey)
    //            UserDefaults.standard.synchronize()
    //            LocalizationHelper.setCurrentLanguage("en")
    //            if let vc: UserSelectionViewController = UIStoryboard.instantiate(with: .onboarding) {
    //                addChildWithNavViewController(childController: vc, contentView: containerView)
    //            }
    //        }else{
    //            UserDefaults.standard.set("ar", forKey: languageKey)
    //            UserDefaults.standard.synchronize()
    //            LocalizationHelper.setCurrentLanguage("ar")
    //            if let vc: UserSelectionViewController = UIStoryboard.instantiate(with: .onboarding) {
    //                addChildWithNavViewController(childController: vc, contentView: containerView)
    //            }
    //        }
    //
    //
    //    }
}

//API
struct CheckLatestAppAPI {
    static let shared = CheckLatestAppAPI()
    
    func request() -> Promise<AppVersionResponse> {
        return Promise { seal in
            
            //            let request = EnterMobileRequest.init(mobileNo: mobileNumber, reason : reason)
            let request = EmptyRequest()
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.latestVersionCheck, requestParams: request, method: "GET") { (response: Swift.Result<AppVersionResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
