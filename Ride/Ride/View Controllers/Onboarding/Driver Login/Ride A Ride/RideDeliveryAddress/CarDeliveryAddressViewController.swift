//
//  CarDeliveryAddressViewController.swift
//  Ride
//
//  Created by Mac on 03/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps

class CarDeliveryAddressViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var suggestionsTV: UITableView!
    
    @IBOutlet weak var deliverToTF: UITextField!
    
    //MARK: - Constants and Variables
    private var mapView: GMSMapView!
    weak var delegate: CarDeliveryAddressViewControllerProtocol?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupViews()
        addObservers()
        
        setupLanguage()
    }
    
    private func setupLanguage() {
        deliverToTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    //MARK: - Observers
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.suggestionsTV.isHidden = false
                self.suggestionsTV.reloadData()
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height - 140)
            
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.suggestionsTV.isHidden = true
            self.bottomView.transform = .identity
        }
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped))

        setupMap()
        setupTableView()
        
        view.layoutIfNeeded()
    }
    
    private func setupMap() {
        mapView = GMSMapView(frame: view.frame)
        view.addSubview(mapView)
        
        mapView.isMyLocationEnabled = true
        mapView.tintColor = .primaryGreen
        
        view.sendSubviewToBack(mapView)
    }
    
    private func setupTableView() {
        suggestionsTV.delegate = self
        suggestionsTV.dataSource = self
        
        suggestionsTV.register(UINib(nibName: GoogleLocationSuggestionTableViewCell.className, bundle: nil), forCellReuseIdentifier: GoogleLocationSuggestionTableViewCell.className)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Tableview delegate and datasource
extension CarDeliveryAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GoogleLocationSuggestionTableViewCell.className, for: indexPath) as? GoogleLocationSuggestionTableViewCell else { return GoogleLocationSuggestionTableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectAddress(address: "McDonald's")
        navigationController?.popViewController(animated: true)
    }
}
