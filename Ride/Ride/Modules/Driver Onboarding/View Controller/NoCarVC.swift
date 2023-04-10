//
//  NoCarVC.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class NoCarVC: UIViewController {
    
    //MARK: - variables
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        descLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        
        cancelButton.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    //MARK: - IBoutlets
    @IBAction func useRideARidePressed(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
