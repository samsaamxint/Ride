//
//  DropoffChangedVC.swift
//  Ride
//
//  Created by Ali Zaib on 02/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class DropoffChangedVC : UIViewController{
    //MARK: - Outlets
    @IBOutlet weak var newDestinationLabel: UILabel!
    @IBOutlet weak var navigateBtn: UIButton!
    @IBOutlet weak var destinationChangeLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    var destination : String?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        newDestinationLabel.text = destination ?? ""
        
        newDestinationLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        navigateBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        destinationChangeLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        descLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
    }
    
    @IBAction func NavigatePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
