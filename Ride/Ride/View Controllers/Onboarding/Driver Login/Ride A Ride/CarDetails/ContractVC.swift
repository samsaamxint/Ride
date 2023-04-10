//
//  ContractVC.swift
//  Ride
//
//  Created by XintMac on 01/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ContractVC: UIViewController {
    
    var callback:(() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            guard let `self` = self else { return }
            self.callback?()
            self.dismiss(animated: true)
        })
    }
    
}
