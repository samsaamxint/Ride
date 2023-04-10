//
//  MyReportsViewController.swift
//  Ride
//
//  Created by Mac on 24/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class MyReportsViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var myReportsTV: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    
    //MARK: - Constants and Variables
    private let reportVM = ReportProblemViewModel()
    
    var tickets = [IssueTicket]()
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewToViewModel()
        
        reportVM.getTickets(with: "\(UserDefaultsConfig.user?.mobileNo ?? "")")
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
        setupTableView()
    }
    
    private func setupTableView() {
        myReportsTV.delegate = self
        myReportsTV.dataSource = self
        
        myReportsTV.register(UINib(nibName: MyReportTableViewCell.className, bundle: nil), forCellReuseIdentifier: MyReportTableViewCell.className)
    }
    
    // MARK: - Navigation
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

//MARK: - Tableview delegate and Datasource
extension MyReportsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reportVM.getIssuesList.value.data?.first?.tickets?.count ?? DefaultValue.int
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyReportTableViewCell.className, for: indexPath) as? MyReportTableViewCell else { return MyReportTableViewCell() }
        
        cell.item = tickets[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc: ReportDetailViewController = UIStoryboard.instantiate(with: .userProfile) {
            vc.ticketItem = reportVM.getIssuesList.value.data?.first?.tickets?[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MyReportsViewController {
    private func bindViewToViewModel() {
        reportVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        
        reportVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        reportVM.getIssuesList.bind { [weak self] value in
            guard let `self` = self else { return }
            if value.success == true {
                if let data = self.reportVM.getIssuesList.value.data?.first {
                    self.tickets = data.tickets!.reversed()
                    self.myReportsTV.reloadData()
                }
            }
        }
    }
}
