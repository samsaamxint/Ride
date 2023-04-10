//
//  ConfirmChangeDestination.swift
//  Ride
//
//  Created by Ali Zaib on 31/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps


class ConfirmChangeDestination: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var pickupLocationLbl: UILabel!
    @IBOutlet weak var destinationLocation: UILabel!
    @IBOutlet weak var moreRidesBtn: UIButton!
    @IBOutlet weak var userBalance: UILabel!
    @IBOutlet weak var promoBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var promoText: UILabel!
    @IBOutlet weak var crossBtn: UIImageView!
    @IBOutlet weak var balanceTitleLbl: UILabel!
    @IBOutlet weak var addBalanceBtn: UIButton!
    @IBOutlet weak var topUpAppleBtn: UIButton!
    @IBOutlet weak var rideImageView: UIImageView!
    @IBOutlet weak var rideTypeLabel: UILabel!
    @IBOutlet weak var rideTimeLabel: UILabel!
    @IBOutlet weak var fareAmountLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    
    
    //MARK: - Constants and Variables
    private var countryName: String?
    private var cityName: String?
    
    private let balanceVM = BalanceViewModel()
    private let changeDestination = ChangeDestinationViewModel()
    
    private var contentViewHeightConst: CGFloat = 440
    
    var pickupLocationString: String?
    var dropOffLocationString: String?
    
    var destLocation: CLLocation?
    var pickupLocation: CLLocation?
    
    private var toAddressArabic: String?
    
    private var fromAddressArabic: String?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        let pickupTap = UITapGestureRecognizer(target: self, action: #selector(pickUpTapped))
        pickupLocationLbl.addGestureRecognizer(pickupTap)
        
        let destinationTap = UITapGestureRecognizer(target: self, action: #selector(destinationTapped))
        destinationLocation.addGestureRecognizer(destinationTap)
        
        crossBtn.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(removePromo)))
        
        getAddresses()
        
        bindViewToViewModel()
        
       
        
        let parent = self.parent?.parent as? MainDashboardViewController
        
        let tripData = RideSingleton.shared.tripDetailObject
        
        parent?.drawPolyLine(startingLoc: CLLocationCoordinate2D.init(latitude: tripData?.data?.source?.latitude ?? 0.0, longitude: tripData?.data?.source?.longitude ?? 0.0), endingLocation: destLocation?.coordinate ?? CLLocationCoordinate2D(),showCarMarker: false, isDrawPolyLine: true)
    
        parent?.distanceUpdate(fromLoc: CLLocation.init(latitude: tripData?.data?.source?.latitude ?? 0.0, longitude: tripData?.data?.source?.longitude ?? 0.0), toLoc: destLocation ?? CLLocation.init(latitude: 0.0, longitude: 0.0)){ calculatedTime in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.arrivalLabel.text = "Arrival \(Commons.getAddedTime(time: parent?.route.travelDuration ?? 0))"
            }
        }
        
        
        pickupLocationLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        destinationLocation.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        rideTypeLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        rideTimeLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        fareAmountLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        arrivalLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        moreRidesBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        userBalance.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(12) : UIFont.SFProDisplayBold?.withSize(12)
        promoBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        confirmBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        promoText.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(12) : UIFont.SFProDisplaySemiBold?.withSize(12)
        balanceTitleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        addBalanceBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        topUpAppleBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        
    }
    
    
    
    
    private func getAddresses() {
        if let pickupLocation = pickupLocation {
            Commons.getAddressFrom(location: pickupLocation, identifier: "ar") { [weak self] address in
                guard let `self` = self else { return }
                self.fromAddressArabic = address
            }
            
            Commons.geocode(latitude: pickupLocation.coordinate.latitude, longitude: pickupLocation.coordinate.longitude) { [weak self] placemark, error in
                guard let `self` = self else { return }
                
                self.countryName = placemark?.country
                self.cityName = placemark?.locality
            }
        }
        
        
        
        if let destLocation = destLocation {
            Commons.getAddressFrom(location: destLocation, identifier: "ar") { [weak self] address in
                guard let `self` = self else { return }
                self.toAddressArabic = address
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent as? MainDashboardViewController)?.drawPolyLine(startingLoc: pickupLocation?.coordinate ?? CLLocationCoordinate2D(), endingLocation: destLocation?.coordinate ?? CLLocationCoordinate2D(),showCarMarker: false)
        
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = contentViewHeightConst
        balanceVM.getBalance()
    }
    
    private func updateViewIfInsufficientBalance() {
        userBalance.text = String(balanceVM.apiResponseData.value.data?.balance ?? 0.0) + " SAR"
        
        let currentBlnc = balanceVM.apiResponseData.value.data?.balance ?? 0.0
//        if currentBlnc < carList[selectedIndex].estimateCost ?? DefaultValue.double {
//            balanceTitleLbl.text = "Insufficient balance"
//            balanceTitleLbl.textColor = .errorRed
//            confirmBtn.isHidden = true
//            addBalanceBtn.isHidden = false
//            topUpAppleBtn.isHidden = true
//           // (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 600
//        } else {
//            balanceTitleLbl.text = "Balance"
//            balanceTitleLbl.textColor = .primaryDarkBG
//            confirmBtn.isHidden = false
//            addBalanceBtn.isHidden = true
//            topUpAppleBtn.isHidden = true
//           // (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 530
//        }
    }
    
    private func setupData() {
        pickupLocationLbl.text = pickupLocationString
        destinationLocation.text = dropOffLocationString
        fareAmountLabel.textAlignment =  Commons.isArabicLanguage() ? .left : .right
        promoBtn.contentHorizontalAlignment =  Commons.isArabicLanguage() ? .left : .right
    }
    
    
    private func bookRide() {
        if let dest = destLocation{
            changeDestination.changeDestination(tripId: RideSingleton.shared.tripDetailObject?.data?.id ?? "", address: dropOffLocationString ?? "", cityNameInArabic:  self.fromAddressArabic ?? "", latitude: dest.coordinate.latitude, longitude: dest.coordinate.longitude)
        }
    }
    
    //MARK: - IBActions
    @IBAction func moreRidesPressed(_ sender: Any) {
    }
    
    @IBAction func promoPressed(_ sender: Any) {
        if let vc: AddPromoCodeVC = UIStoryboard.instantiate(with: .promoCode) {
            vc.applyingTo = 1
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 210
            self.navigationController?.pushViewController(vc, animated: false)
            vc.promoReturn = {[weak self] (code,discount,Status) in
                guard let self = self else {return}
                self.promoBtn.isHidden = true
                self.promoView.isHidden = false
                self.promoText.text = code
            }
        }
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        
        if SocketIOHelper.shared.socket?.status == .connected {
            bookRide()
        } else {
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "It Seems like your internet connection is unstable. Please try again")
            SocketIOHelper.shared.establishConnection()
        }
    }
    
    @IBAction func addBalancePressed(_ sender: Any) {
        if let vc: AddBalanceVC = UIStoryboard.instantiate(with: .paymentMethods) {
            vc.shouldShowCard = balanceVM.apiResponseData.value.data?.card == 1
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @objc private func pickUpTapped() {
//        let controllers = self.navigationController?.viewControllers ?? []
//        for vc in controllers{
//            if vc.isKind(of: RiderPickUpVC.self){
//                self.navigationController?.popToViewController(vc, animated: false)
//                return
//            }
//        }
    }
    
    @objc private func destinationTapped() {
//        let controllers = self.navigationController?.viewControllers ?? []
//        for vc in controllers{
//            if vc.isKind(of: RiderDropOffVC.self){
//                self.navigationController?.popToViewController(vc, animated: false)
//                return
//            }
//        }
    }
    
    @objc private func removePromo(){
        self.promoBtn.isHidden = false
        self.promoView.isHidden = true
        self.promoText.text = ""
    }
}


//MARK: - RiderRideSelection
extension ConfirmChangeDestination {
    func bindViewToViewModel() {
        balanceVM.apiResponseData.bind {[weak self] (value) in
            guard let `self` = self else { return }
            
            if value.statusCode == 200 {
                self.updateViewIfInsufficientBalance()
            }
        }
        
        balanceVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        changeDestination.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        changeDestination.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
        }
        
        changeDestination.changeDestinationResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode.isSome else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if res.statusCode == 200{
                    let controllers = self.navigationController?.viewControllers ?? []
                    for vc in controllers{
                        if vc.isKind(of: RiderDuringRide.self){
                            (vc as! RiderDuringRide).isChangeDestination = true
                            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, backgroundColor: .lightGreen, textColor: .greenTextColor, message: "New drop-off location changed successfully.", timerInterval: 3)
                            self.navigationController?.popToViewController(vc, animated: false)
                            break
                        }
                    }
                }
            }
        }
    }
}
