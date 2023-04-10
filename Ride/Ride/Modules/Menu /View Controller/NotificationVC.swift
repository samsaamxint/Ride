//
//  NotificationVC.swift
//  Ride
//
//  Created by PSE on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var notificationTV: UITableView!
    private var currentPage = 1
    private let notificationVM = NotificationViewModel()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindToViewModel()
        notificationVM.getNotification(with: 1, limit: 20)
        currentPage += 1
    }
    override func viewDidLayoutSubviews() {
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
    }
    // MARK: - Navigation
     
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

//MARK: - Tableview delegate and datasource
extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationVM.notificationHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTVCell.className, for: indexPath) as? NotificationTVCell else { return NotificationTVCell() }
        let notification = notificationVM.notificationHistory[indexPath.row]
        cell.notificationData = notification
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (notificationVM.notificationHistory.count - 1) {
            if notificationVM.canLoad{
                notificationVM.getNotification(with: currentPage, limit: 20, showLoader: false)
                currentPage += 1
            }
        }
    }
    
}

extension NotificationVC {
    private func bindToViewModel() {
        notificationVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        notificationVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        notificationVM.apiResponseData.bind { [weak self] res in
            guard let `self` = self else { return }
            guard res.statusCode == 200 else { return }
            self.notificationTV.reloadData()
        }

        
    }
}
