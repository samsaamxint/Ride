//
//  SelectRideViewController.swift
//  Ride
//
//  Created by Mac on 03/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class SelectRideViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var ridesTV: UITableView!
    var getCabsVM = GetCabsViewModel()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setLeftBackButton(selector: #selector(backButtonTapped))

        setupTableView()
        bindViewToViewModel()
        
        DispatchQueue.main.async {
            self.getCabsVM.getCabs()
        }
      
      
    }
    
    private func setupTableView() {
        ridesTV.delegate = self
        ridesTV.dataSource = self
        
        ridesTV.register(UINib(nibName: SelectRideTableViewCell.className, bundle: nil), forCellReuseIdentifier: SelectRideTableViewCell.className)
        
        ridesTV.contentInset.bottom = Commons.getSafeAreaInset().bottom + 10
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
}

//MARK: - Tableview delegate and datasource
extension SelectRideViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getCabsVM.apiResponse.value.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectRideTableViewCell.className, for: indexPath) as? SelectRideTableViewCell else { return SelectRideTableViewCell() }
        
        cell.chevronIcon.rotateImageIfNeeded()
        cell.Cabdata = self.getCabsVM.apiResponse.value.data?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc: CarDetailViewController = UIStoryboard.instantiate(with: .rideARide) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension SelectRideViewController{
    func bindViewToViewModel(){
        getCabsVM.apiResponse.bind { [weak self] res in
            guard let self = self else {return}
            if res.statusCode == 200{
                self.ridesTV.reloadData()
            }
        }
        
        getCabsVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        getCabsVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
    }
}
