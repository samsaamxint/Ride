//
//  RideStatusViewController.swift
//  Ride
//
//  Created by Mac on 04/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class RideStatusViewController: UIViewController {
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - UIACTIONS
    @IBAction func trackYourStatusBtnClicked(_ sender: Any) {
        if let vc: TrackStatusDetailsViewController = UIStoryboard.instantiate(with: .driverRideARideDashboard) {
            parent?.parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
