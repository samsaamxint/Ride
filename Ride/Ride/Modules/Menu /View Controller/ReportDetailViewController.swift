//
//  ReportDetailViewController.swift
//  Ride
//
//  Created by Mac on 24/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ReportDetailViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var descLBl: UILabel!
    
    //MARK: - Constants and Variables
    var ticketItem: IssueTicket?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped))
        
        titleLbl.text = ticketItem?.category?.title ?? "Report".localizedString()
        statusLbl.text = "Pending".localizedString()
        descLBl.text = ticketItem?.description
        
        detailLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(20) : UIFont.SFProDisplayMedium?.withSize(20)
        statusLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(20) : UIFont.SFProDisplayMedium?.withSize(20)
        descLBl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(20) : UIFont.SFProDisplayMedium?.withSize(20)
    }
    
    // MARK: - Navigation
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
