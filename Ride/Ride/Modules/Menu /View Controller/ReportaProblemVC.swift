//
//  ReportaProblemVC.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class ReportaProblemVC: UIViewController {
    
    //MARK: -IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var problemDescription: UITextView!
    @IBOutlet weak var problemLbl: UILabel!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var titlesTV: UITableView!
    @IBOutlet weak var titlesTVHeight: NSLayoutConstraint!
    
    //MARK: - Constants and Variables
    private let reportProblemVM = ReportProblemViewModel()
    private var selectedCategoryId : Int?

     //MARK: - Life Cycle Methods
     override func viewDidLoad() {
         super.viewDidLoad()
         
         setupViews()
         bindToViewModel()
         reportProblemVM.getComplaintsType()
     }
     
     private func setupViews() {
         setLeftBackButton(selector: #selector(backButtonTapped),rotate: false)
         titlesTVHeight.constant = 200
         
         
         titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
         descLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
         problemDescription.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
         problemLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
         reportBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
            
     }

     // MARK: - Navigation
      
     @objc private func backButtonTapped() {
         navigationController?.popViewController(animated: true)
     }
    
    //MARK: - UIACTIONS
    @IBAction func didTapReportProblem(_ sender: Any) {
//        problemDescription.text.isEmpty ||
        if  !problemDescription.text.trimmingCharacters(in: .whitespaces).isEmpty == false{
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Please enter description".localizedString())
            return
        }
        
        guard let id = selectedCategoryId else {
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Select Report type".localizedString())
            return
        }
        reportProblemVM.saveTicket(number: UserDefaultsConfig.user?.mobileNo ?? "",
                                   name: UserDefaultsConfig.user?.firstName ?? "",
                                   description: problemDescription.text, id: id)
    }
 }

 //MARK: - Tableview delegate and datasource
 extension ReportaProblemVC: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return reportProblemVM.getComplaintTypes.value.data?.count ?? 0
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportTitleTVCell.className, for: indexPath) as? ReportTitleTVCell else { return ReportTitleTVCell() }
         let model = reportProblemVM.getComplaintTypes.value.data?[indexPath.row]
         cell.Title.setTitle(model?.title ?? "", for: .normal)
         //cell.tag = model?.id ?? 0
         return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.selectedCategoryId = reportProblemVM.getComplaintTypes.value.data?[indexPath.row].id
     }

 }

extension ReportaProblemVC {
    private func bindToViewModel() {
        
        reportProblemVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        
        reportProblemVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        reportProblemVM.reportProblem.bind { [weak self] value in
            guard let `self` = self else { return }
            if value.success == true {
                Commons.showErrorMessage(controller: self.navigationController ?? self, backgroundColor: .lightGreen, textColor: .greenTextColor, message: "Report submitted successfully", timerInterval: 2)

                self.navigationController?.popViewController(animated: true)
            }
        }
        
        
        reportProblemVM.getComplaintTypes.bind { [weak self] value in
            guard let `self` = self else { return }
            if value.success == true {
                self.titlesTVHeight.constant = CGFloat(50 * (self.reportProblemVM.getComplaintTypes.value.data?.count ?? 1) )
                self.titlesTV.reloadData()
            }
        }
    }
}
