//
//  RideInProgressViewController.swift
//  Ride
//
//  Created by Mac on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CoreLocation

class RideInProgressViewController: UIViewController {

    //MARK: - Constants and Variables
    weak var delegate: DashboardChildDelegates?
    @IBOutlet weak var rideTimeRemaining: UILabel!
    @IBOutlet weak var rideDistance: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var endRideBtn: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    var tripCompletedViewModel = DriverTripCompletedViewModel()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewToViewModel()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//            guard let `self` = self else { return }
//            self.showLoader(startAnimate: false)
//        }
        var fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.name
        if Commons.isArabicLanguage(){
            fullName = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.arabicName
        }
        let firstName = fullName?.components(separatedBy: " ").first ?? ""
        statusLabel.text = "Dropping".localizedString() + " \(firstName)" 
        
        updateMainMapView()
        updateUI()
        
        if let location = LocationManager.shared.locationManager?.location {
            setUI(fromLocation: location)
        }
        
        rideTimeRemaining.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        rideDistance.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        instructionsLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        endRideBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        statusLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .switchLeftBarItem, object: "", userInfo: [:])
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 280
        (self.parent?.parent as? MainDashboardViewController)?.goToGM.isHidden = false
        if let location = LocationManager.shared.locationManager?.location {
            setUI(fromLocation: location, isDrawPolyLine: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//       (self.parent?.parent as? MainDashboardViewController)?.goToGM.isHidden = true
    }
    
    func setUI(fromLocation : CLLocation, isDrawPolyLine: Bool = false){
        let tripObj = RideSingleton.shared.tripDetailObject
        let parent = self.parent?.parent as? MainDashboardViewController
        var destination = CLLocation.init(latitude: 0.0, longitude:0.0)
        if let newDestination = tripObj?.data?.destinationNew?.address{
            if newDestination.isEmpty{
                destination = CLLocation.init(latitude:  tripObj?.data?.destination?.latitude ?? DefaultValue.double,
                                              longitude:  tripObj?.data?.destination?.longitude ?? DefaultValue.double)
            }else{
                destination = CLLocation.init(latitude:  tripObj?.data?.destinationNew?.latitude ?? DefaultValue.double,
                                              longitude:  tripObj?.data?.destinationNew?.longitude ?? DefaultValue.double)
            }
        }
        parent?.distanceUpdate(fromLoc: fromLocation, toLoc: destination, isDrawPolyLine: isDrawPolyLine){ calculatedTime in
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.rideDistance.text = "\(parent?.route.routeDistance ?? "") • \(Commons.getAddedTime(time: parent?.route.travelDuration ?? 0))"
                self.rideTimeRemaining.text = calculatedTime
//                let desc = String(format: "Go straight".localizedString(), parent?.route.travelInstruction ?? "0.1 m")
//                self.instructionsLabel.text = desc
                self.instructionsLabel.text = "Go straight".localizedString() + (parent?.route.travelInstruction ?? "0.1 m")
            }
        }
    }
    
    private func updateUI() {
        let tripObj = RideSingleton.shared.tripDetailObject
        self.rideTimeRemaining.text = "\(tripObj?.data?.estimatedTripTime ?? 0.0) mins".replacingOccurrences(of: ".", with: ":")
        rideDistance.text = "\(tripObj?.data?.tripDistance ?? 0.0) Km • 3:00 pm"
//        let desc = String(format: "Go straight".localizedString(), tripObj?.data?.tripDistance ?? "0.1 m")
//        self.instructionsLabel.text = desc|
        self.instructionsLabel.text = "Go straight".localizedString() + (String(tripObj?.data?.tripDistance ?? 0.0) ?? "0.1 m")
    }
    
    private func updateMainMapView() {
        let tripObj = RideSingleton.shared.tripDetailObject
        let parent = self.parent?.parent as? MainDashboardViewController

        let source = CLLocationCoordinate2D.init(latitude: tripObj?.data?.source?.latitude ?? DefaultValue.double,
                                                   longitude: tripObj?.data?.source?.longitude ?? DefaultValue.double)

        var destination = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
        if let newDestination = tripObj?.data?.destinationNew?.address{
            if newDestination.isEmpty{
                destination = CLLocationCoordinate2D.init(latitude:  tripObj?.data?.destination?.latitude ?? DefaultValue.double,
                                              longitude:  tripObj?.data?.destination?.longitude ?? DefaultValue.double)
            }else{
                destination = CLLocationCoordinate2D.init(latitude:  tripObj?.data?.destinationNew?.latitude ?? DefaultValue.double,
                                              longitude:  tripObj?.data?.destinationNew?.longitude ?? DefaultValue.double)
            }
        }
        
        parent?.drawPolyLine(startingLoc: source,
                             endingLocation: destination)
    }
    
    //MARK: - UIACTIONS
    @IBAction func endRideBtnClicked(_ sender: Any) {
        //delegate?.finishRide()
        
        let trip = RideSingleton.shared.tripDetailObject?.data
        let fromLoc = CLLocationCoordinate2D(latitude: trip?.source?.latitude ?? DefaultValue.double,
                                             longitude: trip?.source?.longitude ?? DefaultValue.double)
        
        let toLoc = CLLocationCoordinate2D(latitude: trip?.destination?.latitude ?? DefaultValue.double,
                                             longitude: trip?.destination?.longitude ?? DefaultValue.double)
        Commons.getRouteSteps(from: fromLoc, to: toLoc, needSnapShot: true) { _, _, _ in
            
        }
        
        tripCompletedViewModel.tripCompleted(id: UserDefaultsConfig.tripId ?? "", address: RideSingleton.shared.tripDetailObject?.data?.destination?.address ?? "", latitude: RideSingleton.shared.tripDetailObject?.data?.destination?.latitude ?? 0.0, longitude: RideSingleton.shared.tripDetailObject?.data?.destination?.longitude ?? 0.0)
    }
}

extension RideInProgressViewController{
    func bindViewToViewModel() {
        tripCompletedViewModel.tripCompletedResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                if let vc : CompleteRideViewController = UIStoryboard.instantiate(with: .driverToRider){
                    let parent = self.parent?.parent as? MainDashboardViewController
                    parent?.containerViewHeight.constant = 370
                    parent?.navigationItem.leftBarButtonItem = nil
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
        
        tripCompletedViewModel.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        tripCompletedViewModel.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
        }
    }
}
