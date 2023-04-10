//
//  ChatAttachmentViewController.swift
//  Ride
//
//  Created by Mac on 23/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ChatAttachmentViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var attchmentIV: UIImageView!
    @IBOutlet weak var messageTF: UITextField!
    
    //MARK: - Constants and Variables
    var image: UIImage?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    private func setupViews() {
        attchmentIV.image = image
        
        messageTF.addDoubleBorder(with: .sepratorColor, and: .primaryGreen,cornerRadius: messageTF.frame.height/2)
        messageTF.setLeadingPadding(15)
        messageTF.setRightPadding(15)
    }
    
    //MARK: - UIACTIONS
    @IBAction func didTapCloseBtn(_ sender: Any) {
        dismiss(animated: false)
    }
}
