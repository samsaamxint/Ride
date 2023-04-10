//
//  TrackStatusDetailsViewController.swift
//  Ride
//
//  Created by Mac on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class TrackStatusDetailsViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var progressStatusTV: UITableView!
    
    //MARK: - Constants and Variables
    private var carStatuses = [
        CarStatus(title: "Order Placed", subTitle: "20 March 2022, 12:00pm", isCompleted: true),
        CarStatus(title: "Order Processing", subTitle: "20 March 2022, 12:00pm", isCompleted: true),
        CarStatus(title: "Pending Absher Authorization", subTitle: nil, isCompleted: false),
        CarStatus(title: "Out For Delivery", subTitle: nil, isCompleted: false),
        CarStatus(title: "Delivered", subTitle: nil, isCompleted: false),
    ]
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(didSelectBackButton))
        setupTableView()
    }
    
    private func setupTableView() {
        progressStatusTV.delegate = self
        progressStatusTV.dataSource = self
        
        progressStatusTV.register(UINib(nibName: TrackStatusTableViewCell.className, bundle: nil), forCellReuseIdentifier: TrackStatusTableViewCell.className)
    }
    
    @objc private func didSelectBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Tableview delegate and datasource
extension TrackStatusDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        carStatuses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackStatusTableViewCell.className, for: indexPath) as? TrackStatusTableViewCell else { return TrackStatusTableViewCell() }
        
        cell.isLastIndex = indexPath.row == carStatuses.count - 1
        cell.item = carStatuses[indexPath.row]
        
        return cell
    }
}
