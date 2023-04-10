//
//  RiderCancelingVC.swift
//  Ride
//
//  Created by XintMac on 16/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class RiderCancelingVC: UIViewController {
    
     //MARK: - IBoutlets
    @IBOutlet weak var cancelTextLabel: UILabel!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    
    
     //MARK: - Life Cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cancelTextLabel.text = "We are cancelling your ride"
        cancelTextLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        doneBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRideCancel), name: .rideCanceled, object: nil)
        
        
        UIView.animate(withDuration: 3, delay: 0, options: [ .curveEaseInOut], animations: {
            self.loader.transform = .init(translationX: -(self.view.frame.width - 220), y: 0)

        }, completion: { _ in
            // Once that's done, begin a repeating animation between -250 and 250
            UIView.animate(withDuration: 3, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
                self.loader.transform = .init(translationX: self.view.frame.width - 220, y: 0)
            }, completion: nil)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .rideCanceled, object: nil)
    }
    

     //MARK: - IBActions
    @IBAction func donePressed(_ sender: Any) {
        let controllers = self.navigationController?.viewControllers ?? []
        for vc in controllers{
            if vc.isKind(of: RiderDropOffVC.self){
                self.navigationController?.popToViewController(vc, animated: false)
                return
            }
        }
    }
    
    @objc func handleRideCancel(){
        self.loader.isHidden = true
        self.doneBtn.isHidden = false
        (parent?.parent as? MainDashboardViewController)?.mapView?.clear()
        (parent?.parent as? MainDashboardViewController)?.addCurrentLocationMarker()
        RideSingleton.shared.tripDetailObject = nil
        UserDefaultsConfig.tripId = nil
        
        cancelTextLabel.text = "Your ride is cancelled".localizedString()
    }
    
}
