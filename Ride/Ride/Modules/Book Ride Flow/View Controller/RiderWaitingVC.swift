//
//  RiderWaitingVC.swift
//  Ride
//
//  Created by XintMac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class RiderWaitingVC: UIViewController {
    
     //MARK: - IBOutlets
    @IBOutlet weak var loaderView: ViewWithPersistentAnimations!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var tripId : String = ""
    
    private let cancelTripVM = CancelTripViewmodel()
    
     //MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewToViewModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterBackground(_:)), name: UIApplication.willResignActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        descLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        cancelBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        if !SocketIOHelper.shared.isUserSubscribe {
            SocketIOHelper.shared.subscribeUser()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationWillEnterBackground(_ notification: Notification) {
        
        self.loaderView.layer.removeAllAnimations()
       
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        UIView.animate(withDuration: 3, delay: 0, options: [ .curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            self.loaderView.transform = .init(translationX: -(self.view.frame.width - 220), y: 0)
        }, completion: { [weak self] _ in
            // Once that's done, begin a repeating animation between -250 and 250
            UIView.animate(withDuration: 3, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: { [weak self] in
                guard let `self` = self else { return }
                self.loaderView.transform = .init(translationX: self.view.frame.width - 220, y: 0)
            }, completion: nil)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .tripNavigation, object: nil)
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 3, delay: 0, options: [ .curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            self.loaderView.transform = .init(translationX: -(self.view.frame.width - 220), y: 0)
        }, completion: { [weak self] _ in
            // Once that's done, begin a repeating animation between -250 and 250
            UIView.animate(withDuration: 3, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: { [weak self] in
                guard let `self` = self else { return }
                self.loaderView.transform = .init(translationX: self.view.frame.width - 220, y: 0)
            }, completion: nil)
        })
    }
    
    private func resetView() {
        (self.parent?.parent as? MainDashboardViewController)?.setupSwitchUserModeView()
        let controllers = self.navigationController?.viewControllers ?? []
        for vc in controllers{
            if vc.isKind(of: RiderDropOffVC.self){
                self.navigationController?.popToViewController(vc, animated: false)
                return
            }
        }
    }
  
     //MARK: - IBActions
    @IBAction func cancelPressed(_ sender: Any) {
        cancelTripVM.cancelTrip(id: self.tripId)
    }
}

extension RiderWaitingVC {
    func bindViewToViewModel() {
        cancelTripVM.cancelTripResponse.bind { [weak self] res in
            guard let self = self else { return }
            if res.statusCode == 200{
                print("msg : ",res.message as Any)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let `self` = self else { return }
                    self.resetView()
                }
            }else{
                print("res : ",res.data as Any)
            }
        }
        
        
        cancelTripVM.isLoading.bind { [weak self] value in
            self?.showLoader(startAnimate: value)
        }
        
        cancelTripVM.messageWithCode.bind { [weak self] error in
            guard let `self` = self else { return }
            
            if !(error.message?.isEmpty ?? true) {
                if error.code == 400 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        guard let `self` = self else { return }
                        self.resetView()
                    }
                    return
                }
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: error.message ?? DefaultValue.string)
            }
        }
    }
}
    
