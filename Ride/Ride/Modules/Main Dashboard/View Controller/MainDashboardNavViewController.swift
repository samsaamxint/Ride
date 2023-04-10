//
//  MainDashboardNavViewController.swift
//  Ride
//
//  Created by Mac on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class MainDashboardNavViewController: UINavigationController {

    //MARK: - Constants and Variables
    var type: DashboardType?
    var isFromSignup = false
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = viewControllers.first as? MainDashboardViewController {
//            vc.type = type
            vc.isFromSignup = self.isFromSignup
        }
    }
}
