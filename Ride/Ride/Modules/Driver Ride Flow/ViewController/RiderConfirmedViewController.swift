//
//  RiderConfirmedViewController.swift
//  Ride
//
//  Created by Mac on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps

class RiderConfirmedViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var topDistanceGuideView: UIView!
    @IBOutlet weak var intructionLabel: UILabel!
    @IBOutlet weak var navigateToRiderBtn: UIButton!
    @IBOutlet weak var raechedBtn: UIButton!
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet weak var riderRating: UILabel!
    @IBOutlet weak var timeToReach: UILabel!
    @IBOutlet weak var distanceAndTime: UILabel!
    
    //MARK: - Constants and Variables
    weak var delegate: DashboardChildDelegates?
    var driverReachedVM = DriverReachedViewModel()

    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        topDistanceGuideView.isHidden = true
        bindViewToViewModel()
        (self.parent?.parent as? MainDashboardViewController)?.goToGM.isHidden = false
        if let location = LocationManager.shared.locationManager?.location {
            self.setUI(fromLocation : location)
        }
        setLocationUpdateObserver()
        
        intructionLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        navigateToRiderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        raechedBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        riderName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        timeToReach.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        distanceAndTime.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        riderRating.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        timeToReach.textAlignment = Commons.isArabicLanguage() ? .right : .left
        distanceAndTime.textAlignment = timeToReach.textAlignment
    }
    
    func setLocationUpdateObserver(){
        if let preveLoc = LocationManager.shared.locationManager?.location {
            let tripObj = RideSingleton.shared.tripDetailObject
            let loc = CLLocation(latitude: tripObj?.data?.source?.latitude ?? DefaultValue.double,
                                 longitude: tripObj?.data?.source?.longitude ?? DefaultValue.double)
            
            let distanceInMeters = preveLoc.distance(from: loc)

            if distanceInMeters < 50 && UserDefaultsConfig.isDriver {
                let parent = self.parent?.parent as? MainDashboardViewController
                parent?.checkIfDriverReachedToPickup(location: preveLoc)
            }
        }
    }
    
    func setUI(fromLocation : CLLocation, isDrawPolyLine: Bool = false){
        let tripObj = RideSingleton.shared.tripDetailObject
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.distanceUpdate(fromLoc: fromLocation, toLoc: CLLocation.init(latitude: tripObj?.data?.source?.latitude  ?? DefaultValue.double, longitude: tripObj?.data?.source?.longitude  ?? DefaultValue.double), isDrawPolyLine: isDrawPolyLine){ calculatedTime in
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                var fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.name
                if Commons.isArabicLanguage(){
                    fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.arabicName
                }
                self.riderName.text = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.rating
                let firstName = fullName?.components(separatedBy: " ")
                self.riderName.text = firstName?[0]
                let timeDuration = Commons.getAddedTime(time: parent?.route.travelDuration ?? 0).split(separator: " ")
                self.distanceAndTime.text = "\(parent?.route.routeDistance ?? "") • \(timeDuration.first ?? "") \((timeDuration.last ?? "").contains("PM") ? "PM".localizedString() : "AM".localizedString())"
                self.timeToReach.text = calculatedTime
                //self.topDistanceGuideView.isHidden = false
//                let desc = String(format: "Go straight".localizedString(), parent?.route.travelInstruction ?? "0.1 m")
//                self.intructionLabel.text = desc
                self.intructionLabel.text = "Go straight".localizedString() + (parent?.route.travelInstruction ?? "0.1 m")
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .switchLeftBarItem, object: "", userInfo: [:])
        if let location = LocationManager.shared.locationManager?.location {
            self.setUI(fromLocation : location, isDrawPolyLine: true)
            let tripObj = RideSingleton.shared.tripDetailObject
            let parent = self.parent?.parent as? MainDashboardViewController
            parent?.updateMarker(from: location.coordinate , to: CLLocationCoordinate2D(latitude: tripObj?.data?.source?.latitude  ?? DefaultValue.double, longitude: tripObj?.data?.source?.longitude  ?? DefaultValue.double))
        }
    }
    
    func updateViewWhenCaptainReachedAtPickup() {
        navigateToRiderBtn.isHidden = true
        raechedBtn.isHidden = false
        topDistanceGuideView.isHidden = true
        let parent = parent?.parent as? MainDashboardViewController
        parent?.containerViewHeight.constant = 270
    }
    
    func updateViewForOnTheWay() {
        navigateToRiderBtn.isHidden = false
        raechedBtn.isHidden = true
        topDistanceGuideView.isHidden = false
        let parent = parent?.parent as? MainDashboardViewController
        parent?.containerViewHeight.constant = 320
    }
    
    private func openDirections() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            openGoogleMap()
        }else{
            openAppleMap()
        }
//        let actionSheet = UIAlertController(title: "Open Location".localizedString(), message: "Choose an app to open direction".localizedString(), preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Google Maps".localizedString(), style: .default, handler: { _ in
//            // Pass the coordinate inside this URL
//            self.openGoogleMap()
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Apple Maps".localizedString(), style: .default, handler: { _ in
//            // Pass the coordinate that you want here
//            self.openAppleMap()
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func openAppleMap(){
        let destinationCord = CLLocationCoordinate2D(latitude: RideSingleton.shared.tripDetailObject?.data?.source?.latitude ?? 0, longitude: RideSingleton.shared.tripDetailObject?.data?.source?.longitude ?? 0)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationCord, addressDictionary: nil))
        mapItem.name = "Destination"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func openGoogleMap() {
        let lat = RideSingleton.shared.tripDetailObject?.data?.source?.latitude ?? 0
        let lng = RideSingleton.shared.tripDetailObject?.data?.source?.longitude ?? 0
        
        if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(lat),\(lng)&directionsmode=driving") {
            UIApplication.shared.open(url, options: [:])
        }
    }
        
    
    //MARK: - UIACTIONS
    @IBAction func navigateToRiderBtnClicked(_ sender: Any) {
        //openDirections()
        if let location = LocationManager.shared.locationManager?.location {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude:location.coordinate.longitude, zoom: 20)
            let parent = self.parent?.parent as? MainDashboardViewController
            parent?.mapView?.camera = camera
        }
        
    }
    
    @IBAction func reachedBtnClicked(_ sender: Any) {
        //delegate?.driverReachedAtRiderAddress()
        driverReachedVM.reachedByDriver(id: UserDefaultsConfig.tripId ?? "")

    }
    
    @IBAction func didTapCallACaptain(_ sender: Any) {
        let number = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.mobile ?? ""
        guard let number = URL(string: "tel://+\(number)") else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func didTapMessageRideBtn(_ sender: Any) {
        if let vc: MainChatVC = UIStoryboard.instantiate(with: .chat) {
            vc.receiverChatId = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.id
            var image = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.profileImage
            var fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.name
            if Commons.isArabicLanguage(){
                fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.arabicName
            }
            let firstName = fullName?.components(separatedBy: " ")
            vc.chatName = firstName?[0]
            vc.chatImage = image
            parent?.parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}


extension RiderConfirmedViewController{
    func bindViewToViewModel() {
        self.driverReachedVM.reachedResponse.bind { [weak self] response in
            guard let `self` = self else { return }
            if response.statusCode == 200 {
                if let vc : EnterPINToStartRideViewController = UIStoryboard.instantiate(with: .driverToRider){
                    let parent = self.parent?.parent as? MainDashboardViewController
                    parent?.containerViewHeight.constant = 340
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
        
        driverReachedVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }

        driverReachedVM.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
        }
    }
    
    
}

