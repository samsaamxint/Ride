//
//  RiderRideSelection.swift
//  Ride
//
//  Created by XintMac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import PassKit

class RiderRideSelection: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var pickupLocationLbl: UILabel!
    @IBOutlet weak var destinationLocation: UILabel!
    @IBOutlet weak var recommendedRideTV: UITableView!
    @IBOutlet weak var moreRidesBtn: UIButton!
    @IBOutlet weak var userBalance: UILabel!
    @IBOutlet weak var promoBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var ridesTVheight: NSLayoutConstraint!
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var promoText: UILabel!
    @IBOutlet weak var crossBtn: UIImageView!
    @IBOutlet weak var recommendedRides: UILabel!
    
    @IBOutlet weak var balanceTitleLbl: UILabel!
    
    @IBOutlet weak var addBalanceBtn: UIButton!
    @IBOutlet weak var topUpAppleBtn: UIButton!
    
    
    //MARK: - Constants and Variables
    private var countryName: String?
    private var cityName: String?
    private var selectedIndex: Int = 0
    private var discountAmount = ""
    private var promoCode = ""
    private let riderSelectionVM = RideSelectionViewModel()
    private let promocodeVM = PromocodeViewModel()
    private let balanceVM = BalanceViewModel()
    var selectedCarIndex = 0
    var applePaymentRequest = AddBalanceRequestNew()
    private let addBalanceVM = BalanceViewModel()
    
    private var carList = [CarItem]() {
        didSet {
            topUpAppleBtn.isEnabled = true
            recommendedRideTV.reloadData()
        }
    }
    
    private var contentViewHeightConst: CGFloat = 600
    
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
        setupTableView()
        self.topUpAppleBtn.isEnabled = false
        self.confirmBtn.enableButton(false)
        riderSelectionVM.requestCabs(originAddressLng: String( pickupLocation?.coordinate.longitude ?? CLLocationCoordinate2D().longitude),
                                     originAddressLat: String( pickupLocation?.coordinate.latitude ?? CLLocationCoordinate2D().latitude),
                                     destinationAddressLat: String( destLocation?.coordinate.latitude ?? CLLocationCoordinate2D().latitude),
                                     destinationAddressLng: String( destLocation?.coordinate.longitude ?? CLLocationCoordinate2D().longitude))
        
        let pickupTap = UITapGestureRecognizer(target: self, action: #selector(pickUpTapped))
        pickupLocationLbl.addGestureRecognizer(pickupTap)
        
        let destinationTap = UITapGestureRecognizer(target: self, action: #selector(destinationTapped))
        destinationLocation.addGestureRecognizer(destinationTap)
        
        crossBtn.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(removePromo)))
        
        getAddresses()
        
        bindViewToViewModel()
        
        promoBtn.titleLabel?.textAlignment = Commons.isArabicLanguage() ? .left : .right
        promoBtn.contentHorizontalAlignment =  Commons.isArabicLanguage() ? .left : .right
        
        //self.promoBtn.enableButton(true)
    }
    
    override func viewDidLayoutSubviews() {
        recommendedRides.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        pickupLocationLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        destinationLocation.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
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
        (self.parent?.parent as? MainDashboardViewController)?.drawPolyLine(startingLoc: pickupLocation?.coordinate ?? CLLocationCoordinate2D(), endingLocation: destLocation?.coordinate ?? CLLocationCoordinate2D(),showCarMarker: false, isDrawPolyLine: true)
        self.confirmBtn.enableButton(true)
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = contentViewHeightConst
        balanceVM.getBalance()
        SocketIOHelper.shared.subscribeUser()
    }
    
    private func updateViewIfInsufficientBalance() {
        userBalance.text = String(balanceVM.apiResponseData.value.data?.balance ?? 0.0) + " SAR"
        
        let currentBlnc = balanceVM.apiResponseData.value.data?.balance ?? 0.0
        var newAmount = carList[selectedIndex].estimateCost ?? 0.0
        if let discountAmount = carList[selectedIndex].discountCost{
            newAmount = newAmount - discountAmount
        }
        if currentBlnc < newAmount{
            balanceTitleLbl.text = "Insufficient balance".localizedString()
            balanceTitleLbl.textColor = .errorRed
            confirmBtn.isHidden = true
            addBalanceBtn.isHidden = false
            //            topUpAppleBtn.isHidden = false
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 600
        } else {
            balanceTitleLbl.text = "Balance".localizedString()
            balanceTitleLbl.textColor = .primaryDarkBG
            confirmBtn.isHidden = false
            addBalanceBtn.isHidden = true
            // topUpAppleBtn.isHidden = false
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 580
        }
    }
    
    private func setupData() {
        pickupLocationLbl.text = pickupLocationString
        destinationLocation.text = dropOffLocationString
    }
    
    private func setupTableView() {
        recommendedRideTV.register(UINib(nibName: RecommendedRideTVCell.className, bundle: nil), forCellReuseIdentifier: RecommendedRideTVCell.className)
    }
    
    private func bookRide() {
        if self.carList.count > 0 {
            let fromObj = CreateTripAddress(address: pickupLocationString,
                                            cityNameInArabic: fromAddressArabic,
                                            addressType: 1,
                                            latitude: pickupLocation?.coordinate.latitude,
                                            longitude: pickupLocation?.coordinate.longitude)
            
            let toObj = CreateTripAddress(address: dropOffLocationString,
                                          cityNameInArabic: toAddressArabic,
                                          addressType: 2,
                                          latitude: destLocation?.coordinate.latitude,
                                          longitude: destLocation?.coordinate.longitude)
            
            var addressArr = [CreateTripAddress]()
            
            addressArr.append(fromObj)
            addressArr.append(toObj)
            
            riderSelectionVM.bookCabs(with: carList[selectedIndex].id,
                                      promoCode: self.promoCode ,
                                      country: self.countryName,
                                      city: self.cityName,
                                      addresses: addressArr, tokenApplePay: applePaymentRequest.amount == nil ? nil : applePaymentRequest,
                                      amount: (carList[selectedIndex].estimateCost ?? 0.0) + Double(Constants.estimationAmount)
            )
        }
    }
    
    //MARK: - IBActions
    @IBAction func moreRidesPressed(_ sender: Any) {
    }
    @IBAction func applePayTpd(_ sender: Any) {
        let price = String((carList[selectedIndex].estimateCost ?? 0.0) + Double(Constants.estimationAmount))
        let wallet = PKPaymentPassActivationState.activated
        let paymentItem = PKPaymentSummaryItem.init(label: AppName, amount: NSDecimalNumber.init(string:  price))
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa ,.mada]
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            request.currencyCode = "SAR" // 1
            request.countryCode = "SA" // 2
            request.merchantIdentifier = "merchant.com.Ride.RideCompany" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
            request.paymentSummaryItems = [paymentItem] // 6
            request.requiredShippingContactFields = [.name, .phoneNumber, .postalAddress]
            
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                //displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Unable to present Apple Pay authorization".localizedString())
                return
            }
            
            paymentVC.delegate = self
            self.present(paymentVC, animated: true, completion: nil)
        } else {
            // displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Please add your card in Apple Wallet then you'll be able to pay.".localizedString())
        }
    }
    
    @IBAction func promoPressed(_ sender: Any) {
        if self.carList.count > 1{
            if let vc: AddPromoCodeVC = UIStoryboard.instantiate(with: .promoCode) {
                (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 210
                self.navigationController?.pushViewController(vc, animated: false)
                vc.selectedAmount = self.carList[selectedIndex].estimateCost
                vc.applyingTo = 1
                vc.promoReturn = {[weak self] (code,discount,Status) in
                    guard let self = self else {return}
                    self.promoBtn.isHidden = true
                    self.promoView.isHidden = false
                    self.promoText.text = code
                    self.promoCode = code
                    self.discountAmount = discount
                    self.carList[self.selectedIndex].discountCost = Double(discount)
                    self.recommendedRideTV.reloadData()
                    self.updateViewIfInsufficientBalance()
                }
            }
        }
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        confirmBtn.enableButton(false)
        riderSelectionVM.checkKYC()
        //        if SocketIOHelper.shared.socket?.status == .connected {
        //            bookRide()
        //        } else {
        //            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Internet connection is unstable".localizedString())
        //            SocketIOHelper.shared.establishConnection()
        //        }
    }
    private func showErrorPopup(message: String = "Please try again after some time we are facing some server issues".localizedString()) {
        let vc = StatusAlertVC.instantiate(title: "Topup Failed".localizedString(), message: message, image: UIImage.init(named: "FailedImage") ?? UIImage())
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.alertAction = { (isDone) in
            if isDone{
                //if done/yes is pressed
            }else{
                //if no/tryagain is pressed
            }
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func addBalancePressed(_ sender: Any) {
        if let vc: AddBalanceVC = UIStoryboard.instantiate(with: .paymentMethods) {
            vc.shouldShowCard = balanceVM.apiResponseData.value.data?.card == 1
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @objc private func pickUpTapped() {
        let controllers = self.navigationController?.viewControllers ?? []
        for vc in controllers{
            if vc.isKind(of: RiderPickUpVC.self){
                self.navigationController?.popToViewController(vc, animated: false)
                return
            }
        }
    }
    
    @objc private func destinationTapped() {
        let controllers = self.navigationController?.viewControllers ?? []
        for vc in controllers{
            if vc.isKind(of: RiderDropOffVC.self){
                self.navigationController?.popToViewController(vc, animated: false)
                return
            }
        }
    }
    
    @objc private func removePromo(){
        self.promoBtn.isHidden = false
        self.promoView.isHidden = true
        self.promoText.text = ""
        self.promoCode = ""
        for (index,_) in self.carList.enumerated(){
            self.carList[index].discountCost = nil
        }
    }
}

//MARK: - Tableview delegate and datasource
extension RiderRideSelection: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        carList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecommendedRideTVCell.className, for: indexPath) as? RecommendedRideTVCell else { return RecommendedRideTVCell() }
        
        
        cell.item = carList[indexPath.row]
        cell.mainView.backgroundColor = selectedIndex == indexPath.row ? .lightGrayBG : .systemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            for (index,_) in self.carList.enumerated(){
                self.carList[index].discountCost = nil
            }
            //self.removePromo()
            self.selectedIndex = indexPath.row
            if self.promoCode != ""{
                if let currentLocation = LocationManager.shared.locationManager?.location{
                    self.promocodeVM.validatePromocode(amount: self.carList[self.selectedIndex].estimateCost ?? 0.0, promoCode: self.promoCode, lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude, applyingTo: 1, tripId: nil)
                }
            }
            self.recommendedRideTV.reloadData()
            self.updateViewIfInsufficientBalance()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}

//MARK: - RiderRideSelection
extension RiderRideSelection {
    func bindViewToViewModel() {
        riderSelectionVM.getCarAPIResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                self.carList = res.data?.cabs ?? []
                self.topUpAppleBtn.isEnabled = true
                self.confirmBtn.enableButton(true)
                if self.carList.count == 0{
                    if let vc: RiderNoDriverVC = UIStoryboard.instantiate(with: .riderToDriver) {
                        
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
                if self.carList.count < 3{
                    self.ridesTVheight.constant  = CGFloat(self.carList.count * 70)
                    self.contentViewHeightConst = CGFloat((600 - 210) + self.carList.count * 70)
                    (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = self.contentViewHeightConst
                }
                // self.promoBtn.enableButton(true)600
                self.callSocketFunctionForFindDriver()
                self.updateViewIfInsufficientBalance()
            }
        }
        
        riderSelectionVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        riderSelectionVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
        }
        
        riderSelectionVM.checkKYCRes.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard value.statusCode.isSome else { return }
            if value.data?.isKycRequired ?? false{
                
                (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 400
                if let vc: RiderKYCVC = UIStoryboard.instantiate(with: .riderToDriver) {
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }else{
                if SocketIOHelper.shared.socket?.status == .connected {
                    //                    confirm ride
                    Commons.adjustEventTracker(eventId: AdjustEventId.ConfirmRide)
                    self.bookRide()
                } else {
                    Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "It Seems like your internet connection is unstable. Please try again")
                    self.confirmBtn.enableButton(true)
                    SocketIOHelper.shared.establishConnection()
                }
            }
        }
        
        riderSelectionVM.bookCarAPIResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode.isSome else { return }
            self.confirmBtn.enableButton(true)
            
            if SocketIOHelper.shared.socket?.status != .connected {
                SocketIOHelper.shared.establishConnection()
            }
            if !SocketIOHelper.shared.isUserSubscribe {
                SocketIOHelper.shared.subscribeUser()
            }
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 320
            if let vc: RiderWaitingVC = UIStoryboard.instantiate(with: .riderToDriver) {
                vc.tripId = res.data?.id ?? ""
                self.navigationController?.pushViewController(vc, animated: false)
            }
            
            print("msg : ",res.data?.message as Any)
            let response :[String: TripResponse] = ["data": res]
            NotificationCenter.default.post(name: .tripNavigation, object: "", userInfo: response)
        }
        
        balanceVM.apiResponseData.bind {[weak self] (value) in
            guard let `self` = self else { return }
            
            if value.statusCode == 200 {
                if !self.carList.isEmpty{
                    self.updateViewIfInsufficientBalance()
                }
            }
        }
        
        balanceVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        promocodeVM.validateSubscriptionRes.bind {[weak self] (value) in
            guard let `self` = self else { return }
            if value.statusCode == 200 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.discountAmount = String(value.data?.amount ?? 0.0)
                    self.carList[self.selectedIndex].discountCost = Double(String(value.data?.amount ?? 0.0))
                    self.recommendedRideTV.reloadData()
                    self.updateViewIfInsufficientBalance()
                })
                
            }
        }
        
        promocodeVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        promocodeVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        addBalanceVM.addBalanceResponse.bind {[weak self] (value) in
            guard let `self` = self else { return }
            guard value.statusCode.isSome else {return}
            
            if value.statusCode == 200{
                Commons.adjustEventTracker(eventId: AdjustEventId.BankTransactionSuccess)
                //               do success thing here
                self.balanceTitleLbl.text = "Balance".localizedString()
                self.balanceTitleLbl.textColor = .primaryDarkBG
                self.confirmBtn.isHidden = false
                self.addBalanceBtn.isHidden = true
                self.topUpAppleBtn.isHidden = true
                (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 530
            } else {
                Commons.adjustEventTracker(eventId: AdjustEventId.BankTransactionFailure)
                self.showErrorPopup()
            }
        }
        
        addBalanceVM.topUpResponse.bind {[weak self] (value) in
            guard let `self` = self else { return }
            guard value.success != nil else {return}
            if value.success == true{
                if let urlString = value.data![0].data?.redirect_url, let url = URL(string: urlString){
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.open(url)
                    }
                }
            }else{
                self.showErrorPopup()
            }
        }
        
        addBalanceVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        
        addBalanceVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
    }
    
    private func callSocketFunctionForFindDriver() {
        let dict = NSMutableDictionary()
        dict.setValue(UserDefaultsConfig.user?.userId ?? "", forKey: "userID")
        let dataDict = NSMutableDictionary()
        dataDict.setValue(String( pickupLocation?.coordinate.latitude ?? CLLocationCoordinate2D().latitude), forKey: "latitude")
        dataDict.setValue(String( pickupLocation?.coordinate.longitude ?? CLLocationCoordinate2D().longitude), forKey: "longitude")
        dataDict.setValue(String( destLocation?.coordinate.latitude ?? CLLocationCoordinate2D().latitude), forKey: "destinationLatitude")
        dataDict.setValue(String( destLocation?.coordinate.longitude ?? CLLocationCoordinate2D().longitude), forKey: "destinationLongitude")
        dict.setValue(dataDict, forKey: "data")
        
        SocketIOHelper.shared.emitEvent(eventName: "find-drivers", dict: dict as! [String : Any])
        
        SocketIOHelper.shared.listenFindDriverEvent(eventName: "find-drivers") { [weak self] res in
            guard let self = self else { return }
            guard res.statusCode == 200 else { return }
            let driversData :[String: [Driver]] = ["drivers": res.drivers ?? []]
            NotificationCenter.default.post(name: .showNearByCars, object: "", userInfo: driversData)
            
        }
    }
}

extension RiderRideSelection: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        let network = "\(payment.token.paymentMethod.network?.rawValue ?? "")"
        let identifier = payment.token.transactionIdentifier
        let paymentMethod = PaymentMethod(network: network, type: "\(payment.token.paymentMethod.type.rawValue)", displayName: payment.token.paymentMethod.displayName)
        do {
            let price = Int(carList[selectedIndex].estimateCost ?? 0.0) + Constants.estimationAmount
            let value = try JSONDecoder().decode(PaymentData.self, from: payment.token.paymentData)
            
            let request = AddBalanceRequestNew.init(amount: price, applePayToken: ApplePayToken(paymentMethod: paymentMethod, transactionIdentifier: identifier , paymentData: value))
            self.applePaymentRequest.applePayToken?.paymentMethod = paymentMethod
            self.applePaymentRequest.applePayToken?.transactionIdentifier = payment.token.transactionIdentifier
            print(value)
            applePaymentRequest.applePayToken?.paymentData = value
            self.applePaymentRequest = request
            riderSelectionVM.checkKYC()
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            print(applePaymentRequest)
            //            print("Payment Data: \(jsonResponse)")
        } catch {
            print("Error: \(error.localizedDescription)")
            completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
        }
        //        addBalanceVM.addBalanceNew(tokenApplePay: applePaymentRequest)
    }
    
    
}

