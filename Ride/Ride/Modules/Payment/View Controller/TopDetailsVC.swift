//
//  TopDetailsVC.swift
//  Ride
//
//  Created by XintMac on 17/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class TopDetailsVC: UIViewController {

     //MARK: - IBOutlets
    @IBOutlet weak var topUpDetailsTV: UITableView!
    @IBOutlet weak var topUpTitle: UILabel!
    
    
    //MARK: - Constants and Variables
    private let topUpDetailsVM = TopUpDetailsViewModel()
    
     //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewToViewModel()
        topUpTitle.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topUpDetailsVM.getTopUpDetails()
    }
    

    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped),rotate: false)
        
        topUpDetailsTV.register(UINib(nibName: TopUpDetailTVCell.className, bundle: nil), forCellReuseIdentifier: TopUpDetailTVCell.className)
    }

    // MARK: - Navigation
     
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Tableview delegate and datasource
extension TopDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topUpDetailsVM.apiResponseData.value.data?.transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TopUpDetailTVCell.className, for: indexPath) as? TopUpDetailTVCell else { return TopUpDetailTVCell() }
        cell.details = topUpDetailsVM.apiResponseData.value.data?.transactions?[indexPath.row]
        return cell
    }
    
}


extension TopDetailsVC{
    func bindViewToViewModel() {
        topUpDetailsVM.apiResponseData.bind {[weak self] (value) in
            guard let `self` = self else { return }
            guard value.statusCode == 200 else {return}
            if value.statusCode == 200{
                self.topUpDetailsTV.reloadData()
            }
        }
        
        topUpDetailsVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        
        topUpDetailsVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
    }
}
