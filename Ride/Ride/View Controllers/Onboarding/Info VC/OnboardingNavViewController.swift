//
//  OnboardingNavViewController.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class OnboardingNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    override var childForStatusBarStyle: UIViewController? {
        self.topViewController
    }
}
