//
//  StatusAlertVC.swift
//  Ride
//
//  Created by PSE on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class StatusAlertVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    
    var image : UIImage?
    var vcTitle : String?
    var messageText : String?
    var yesText : String?
    var noText : String?
    var onlySuccess = false
    var alertAction:((Bool) -> ())?
    
    //MARK: -  Custom Init
    /// LOGIC: Static function to instantiate this view controller with a message
    internal static func instantiate(title: String , message : String , image : UIImage , yesText : String = "Done".localizedString() , noText : String = "Try Again".localizedString())  -> StatusAlertVC {
        if let vc: StatusAlertVC = UIStoryboard.instantiate(with: .commonAlerts) {
            vc.vcTitle = title
            vc.messageText = message
            vc.image = image
            vc.yesText = yesText
            vc.noText = noText
        return vc
        }
        return StatusAlertVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parent = (self.parent?.parent as? MainDashboardViewController) {
            parent.containerViewHeight.constant = 490
        } else {
            (self.parent?.parent as? EmptyTopupViewController)?.containerViewHConstraint.constant = 490
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.alertTitle.text = vcTitle
        self.message.text = messageText
        self.yesBtn.setTitle(yesText, for: .normal)
        self.noBtn.setTitle(noText, for: .normal)
        self.statusImage.image = image
        
        alertTitle.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        message.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(18) : UIFont.SFProDisplayMedium?.withSize(18)
        yesBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        noBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        
        if onlySuccess{
            self.noBtn.isHidden  = true
        }
    }
    
    //MARK: - IBActions
    @IBAction func donePressed(_ sender: Any) {
        if let parent = parent?.parent as? EmptyTopupViewController {
            parent.delegate?.updateBalance()
            parent.dismiss(animated: true)
        } else {
            self.dismiss(animated: true){ [weak self] in
                self?.alertAction?(true)
            }
        }
    }
    
    
    @IBAction func tryAgainPressed(_ sender: Any) {
        if let parent = parent?.parent as? UserProfileMainVC {
            navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: true) { [weak self] in
                self?.alertAction?(false)
            }
        }
    }
}
