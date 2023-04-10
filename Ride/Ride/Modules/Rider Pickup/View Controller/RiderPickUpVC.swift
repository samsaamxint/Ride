//
//  RiderPickUpVC.swift
//  Ride
//
//  Created by XintMac on 07/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class RiderPickUpVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var locationTV: UITableView!
    @IBOutlet weak var deliverToTF: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var setLocationBtn: UIButton!
    
    //MARK: - Constants and Variables
    private let riderPickupVM = RiderDropOffViewModel()
    private var workItemReference: DispatchWorkItem? = nil

    var destinationLocationAdd: String?
    var destLocation: CLLocation?
        
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLanguage()

        deliverToTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        pickUpLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        setLocationBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        riderPickupVM.autocompleteResults.removeAll()
        addCurrentLoc()
        locationTV.reloadData()
                
        deliverToTF.text = ""
        deliverToTF.placeholder = "Enter Here".localizedString()
        
        addObservers()
        SocketIOHelper.shared.subscribeUser()
        NotificationCenter.default.post(name: .toggleUserSwitchView, object: "", userInfo: [:])
        (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 400
        (parent?.parent as? MainDashboardViewController)?.mapView?.clear()
        (parent?.parent as? MainDashboardViewController)?.addCurrentLocationMarker()
        
        
        let parent = self.parent?.parent as? MainDashboardViewController
        
        let marker = GMSMarker()
        marker.icon = UIImage(named: "BlackMarker")
        marker.position = destLocation?.coordinate ?? CLLocationCoordinate2D()
        marker.map = parent?.mapView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 400
    }
    
    private func addCurrentLoc(){
        let currentAddress = GApiResponse.Autocomplete()
        currentAddress.formattedAddress = ""
        currentAddress.placeId = ""
        currentAddress.mainText = "Use Current Location".localizedString()
        currentAddress.subText = (parent?.parent as? MainDashboardViewController)?.currentAddress ?? ""
        riderPickupVM.autocompleteResults.insert(currentAddress, at: 0)
    }
    
    private func setupLanguage() {
        deliverToTF.delegate = self
        deliverToTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    //MARK: - Observers
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = keyboardSize.height + (400)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        (parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 400
    }
    
    private func setupViews() {
        setupTableView()
        
        view.layoutIfNeeded()
    }
    
    private func setupTableView() {
        locationTV.register(UINib(nibName: GoogleLocationSuggestionTableViewCell.className, bundle: nil), forCellReuseIdentifier: GoogleLocationSuggestionTableViewCell.className)
    }
    
    @IBAction func setLocationPressed(_ sender: Any) {
        if let vc : MapViewVC = UIStoryboard.instantiate(with: .riderPickup) {
            (self.parent?.parent as? MainDashboardViewController)?.navigationController?.pushViewController(vc, animated: true)
            vc.locationSelected = { [weak self]  (location,main,sub, zoomLevel) in
                guard let self = self else {return}
                self.goToPickupLocation(mainAdd: main,
                                        secAdd: sub,
                                        pickupLocation: location)
                (self.parent?.parent as? MainDashboardViewController)?.mapView?.animate(toLocation: location.coordinate)
                
                let selectedMarker = GMSMarker(position: location.coordinate)
                selectedMarker.icon = UIImage(named: "BlackMarker")
                selectedMarker.map = (self.parent?.parent as? MainDashboardViewController)?.mapView
                selectedMarker.userData = main
                if let level = zoomLevel {
                    (self.parent?.parent as? MainDashboardViewController)?.mapView?.animate(toZoom: level)
                }
            }
        }
    }
}

//MARK: - Tableview delegate and datasource
extension RiderPickUpVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        riderPickupVM.autocompleteResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GoogleLocationSuggestionTableViewCell.className, for: indexPath) as? GoogleLocationSuggestionTableViewCell else { return GoogleLocationSuggestionTableViewCell() }
        
        cell.item = riderPickupVM.autocompleteResults[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            goToPickupLocation(mainAdd: riderPickupVM.autocompleteResults.first?.mainText ?? DefaultValue.string,
                               secAdd: riderPickupVM.autocompleteResults.first?.subText ?? DefaultValue.string,
                               pickupLocation: LocationManager.shared.locationManager?.location)
        } else {
            riderPickupVM.getAPIDetail(index: indexPath.row) { [weak self] index, placeDetail in
                guard let `self` = self else { return }
                
                let location = CLLocation(latitude: placeDetail.latitude ?? DefaultValue.double,
                                          longitude: placeDetail.longitude ?? DefaultValue.double)
                let mainText = self.riderPickupVM.autocompleteResults[index].mainText
                let subText = self.riderPickupVM.autocompleteResults[index].subText
                
                self.goToPickupLocation(mainAdd: mainText,
                                        secAdd: subText.isEmpty ? mainText : subText,
                                        pickupLocation: location)
            }
        }
    }
    
    private func goToPickupLocation(mainAdd: String, secAdd: String, pickupLocation: CLLocation?) {
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 220
        if let vc: RiderPickUpLocationVC = UIStoryboard.instantiate(with: .riderPickup) {
            vc.primaryAddress = mainAdd
            vc.secondaryAddress = secAdd
            vc.dropOffLocationString = destinationLocationAdd
            
            vc.destinationLocation = destLocation
            vc.pickupLocation = pickupLocation
            
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

// MARK: - UITextfiled Delegate Method's
extension RiderPickUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let fullText = text.replacingCharacters(in: range, with: string)
        if fullText.count == 0 {
            riderPickupVM.autocompleteResults.removeAll()
            self.addCurrentLoc()
            locationTV.reloadData()
            workItemReference?.cancel()
            return true
        }
        workItemReference?.cancel()
        let searchWorkItem = DispatchWorkItem {
            self.riderPickupVM.showResults(string: fullText) { [weak self] in
                self?.addCurrentLoc()
                self?.locationTV.reloadData()
            }
        }
        workItemReference = searchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500), execute: searchWorkItem)
        
        return true
    }
}
