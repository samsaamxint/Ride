//
//  RiderDropOffVC.swift
//  Ride
//
//  Created by XintMac on 17/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import GoogleMaps
import UIKit

class RiderDropOffVC: UIViewController {
    
     //MARK: - IBOutlets
    @IBOutlet weak var locationTV: UITableView!
    @IBOutlet weak var deliverToTF: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var setLocationLabel: UIButton!
    
    //MARK: - Constants and Variables
    private let riderDropOffVM = RiderDropOffViewModel()
    
//    private var mapView: GMSMapView!
    private var workItemReference: DispatchWorkItem? = nil
    private var keyboardHeight : CGFloat = 0
    
    var toChangeDestination = false
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupViews()
        
        setupLanguage()
                
        LocationManager.shared.locationManager?.startUpdatingLocation()
        SocketIOHelper.shared.subscribeUser()
      
    }
    
    
    private func setupLanguage() {
        deliverToTF.delegate = self
        deliverToTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObservers()
        self.locationTV.isHidden = true
        self.deliverToTF.text = ""
        deliverToTF.placeholder = "Where to".localizedString()
        let backbutton = self.getAppNavBackButton()
        backbutton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        (parent?.parent as? MainDashboardViewController)?.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: backbutton)
        self.getAppNavBackButton()
        riderDropOffVM.autocompleteResults.removeAll()
        locationTV.reloadData()
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant =  150

        if !toChangeDestination {
            (parent?.parent as? MainDashboardViewController)?.mapView?.clear()
            (parent?.parent as? MainDashboardViewController)?.addCurrentLocationMarker()
            (parent?.parent as? MainDashboardViewController)?.setupSwitchUserModeView()
        }else{
            self.deliverToTF.placeholder = "Change drop-off".localizedString()
        }
        
//        DispatchQueue.main.async {
            self.deliverToTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
            self.setLocationLabel.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
           
//        }
         print("this is our font \(self.deliverToTF.font)")
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Observers
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
            
            moveScreen()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        DispatchQueue.main.async { [weak self] in
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: { [weak self] in
            guard let `self` = self else { return }
            print("keyboardshoudhide")
//            if self.view.frame.origin.y != 0 {
//                    self.view.frame.origin.y = 0
//                }
//            self.view.frame.origin.y = 0
            if self.riderDropOffVM.autocompleteResults.count != 0 {
                self.locationTV.isHidden = false
                print("keyboardshoudhidenewcontentsize")
//                containerViewheight = 340
                ( self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 280
//                ( self.parent?.parent as? MainDashboardViewController)?.containerView.frame.origin.y = 0
                ( self.parent?.parent as? MainDashboardViewController)?.containerView.layoutIfNeeded()
                
               
               
              
            }else{
                self.locationTV.isHidden = true
                print("keyboardshoudhidenewcontentsize")
                ( self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant =  150
//                ( self.parent?.parent as? MainDashboardViewController)?.containerView.frame.origin.y = 0
//                ( self.parent?.parent as? MainDashboardViewController)?.containerView.layoutIfNeeded()
               
               
               
               
            }
        })
    }
    
    private func setupViews() {
        setupTableView()
        
        view.layoutIfNeeded()
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: false)
    }
    
    private func setupTableView() {
        locationTV.register(UINib(nibName: GoogleLocationSuggestionTableViewCell.className, bundle: nil), forCellReuseIdentifier: GoogleLocationSuggestionTableViewCell.className)
    }
    
    private func moveScreen(){
        if self.riderDropOffVM.autocompleteResults.count != 0{
            self.locationTV.isHidden = false
            ( self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = CGFloat(keyboardHeight + (keyboardHeight == 0 ? 240 : 230))
            
        } else {
            self.locationTV.isHidden = true
            ( self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = CGFloat(keyboardHeight + 100)
        }
    }
    @IBAction func setLocationPressed(_ sender: Any) {
        if let vc : MapViewVC = UIStoryboard.instantiate(with: .riderPickup) {
            (self.parent?.parent as? MainDashboardViewController)?.navigationController?.pushViewController(vc, animated: true)
            vc.locationSelected = { [weak self] (location,main,sub, zoomLevel) in
                guard let self = self else {return}
                //(self.parent?.parent as? MainDashboardViewController)?.mapView?.animate(toLocation: location.coordinate)
                if !self.toChangeDestination{
                (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 400
                if let vc: RiderPickUpVC = UIStoryboard.instantiate(with: .riderPickup) {
                    vc.destinationLocationAdd = main
                    vc.destLocation = location
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                }else{
                    (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 440
                    if let vc: ConfirmChangeDestination = UIStoryboard.instantiate(with: .riderToDriver) {
                        
                        vc.destLocation = location
                        
                        vc.pickupLocationString = RideSingleton.shared.tripDetailObject?.data?.source?.address
                        vc.dropOffLocationString = sub.isEmpty ? main : sub
                        
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
                
                if let level = zoomLevel {
                    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                          longitude: location.coordinate.longitude,
                                                          zoom: level)
                    (self.parent?.parent as? MainDashboardViewController)?.mapView?.animate(to: camera)
                }
            }
        }
    }
}

//MARK: - Tableview delegate and datasource
extension RiderDropOffVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        riderDropOffVM.autocompleteResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GoogleLocationSuggestionTableViewCell.className, for: indexPath) as? GoogleLocationSuggestionTableViewCell else { return GoogleLocationSuggestionTableViewCell() }
        
        cell.item = riderDropOffVM.autocompleteResults[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        riderDropOffVM.getAPIDetail(index: indexPath.row) { [weak self] index, placeDetail in
            guard let `self` = self else { return }
            
            if !self.toChangeDestination{
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 400
            if let vc: RiderPickUpVC = UIStoryboard.instantiate(with: .riderPickup) {
                
                let mainText = self.riderDropOffVM.autocompleteResults[index].mainText
                let subText = self.riderDropOffVM.autocompleteResults[index].subText
                
                vc.destinationLocationAdd = subText.isEmpty ? mainText : subText
                
                let location = CLLocation(latitude: placeDetail.latitude ?? DefaultValue.double,
                                          longitude: placeDetail.longitude ?? DefaultValue.double)
                
                vc.destLocation = location
                self.navigationController?.pushViewController(vc, animated: false)
            }
            }else{
                (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 440
                if let vc: ConfirmChangeDestination = UIStoryboard.instantiate(with: .riderToDriver) {
                    
                    let mainText = self.riderDropOffVM.autocompleteResults[index].mainText
                    let subText = self.riderDropOffVM.autocompleteResults[index].subText
                    
                    let location = CLLocation(latitude: placeDetail.latitude ?? DefaultValue.double,
                                              longitude: placeDetail.longitude ?? DefaultValue.double)
                    
                    vc.destLocation = location
                    
                    vc.pickupLocationString = RideSingleton.shared.tripDetailObject?.data?.source?.address
                    vc.dropOffLocationString = subText.isEmpty ? mainText : subText
                    
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
    }
}

// MARK: - UITextfiled Delegate Method's
extension RiderDropOffVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let fullText = text.replacingCharacters(in: range, with: string)
        if fullText.count == 0 {
            riderDropOffVM.autocompleteResults.removeAll()
            self.locationTV.isHidden = true
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = keyboardHeight + 100
            locationTV.reloadData()
        }
        workItemReference?.cancel()
        let searchWorkItem = DispatchWorkItem {
            self.riderDropOffVM.showResults(string: fullText) { [weak self] in
                guard let `self` = self else { return }
                
                self.moveScreen()
                self.locationTV.reloadData()
            }
        }
        workItemReference = searchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500), execute: searchWorkItem)
        
        return true
    }
}
