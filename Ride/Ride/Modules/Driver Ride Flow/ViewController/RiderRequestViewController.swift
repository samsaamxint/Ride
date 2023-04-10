//
//  RiderRequestViewController.swift
//  Ride
//
//  Created by Mac on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import AVFoundation

class RiderRequestViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet weak var riderRating: UILabel!
    @IBOutlet weak var distanceAndTime: UILabel!
    @IBOutlet weak var estimatedEarning: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var estimateLbl: UILabel!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    
    //MARK: - Constants and Variables
    private var tripresponseViewModel = RiderRequestResponseViewModel()
    //private var acceptViewModel = RiderRequestResponseViewModel()
    var audioPlayer: AVAudioPlayer?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        PathSave.shared.removeValue()
        bindViewToViewModel()
        setUI()
        self.drawPolyLineToPickUp()
        
        riderName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        distanceAndTime.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        estimatedEarning.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        pickupLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        destinationLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        estimateLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        riderRating.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        declineBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        acceptBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        self.playNotificationSound(soundName: "New request for the driver")
    }
    
    func playNotificationSound(soundName : String){
       
        if let bundle = Bundle.main.path(forResource: soundName, ofType: "mp3") {
                   let backgroundMusic = NSURL(fileURLWithPath: bundle)
                   do {
                       audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                       guard let audioPlayer = audioPlayer else { return }
                       audioPlayer.prepareToPlay()
                       audioPlayer.play()
                   } catch {
                       print(error)
                   }
               }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent as? MainDashboardViewController)?.navigationItem.leftBarButtonItem = nil
    }
    
    private func setUI(){
        let tripObj = RideSingleton.shared.tripDetailObject
        let parent = self.parent?.parent as? MainDashboardViewController
//        guard let location = LocationManager.shared.locationManager?.location else { return }
        
        let riderLoc = CLLocationCoordinate2D.init(latitude: tripObj?.data?.source?.latitude ?? DefaultValue.double,
                                                   longitude: tripObj?.data?.source?.longitude ?? DefaultValue.double)
        
        let driverLoc =  CLLocationCoordinate2D.init(latitude: tripObj?.data?.destination?.latitude ?? DefaultValue.double,
                                                     longitude: tripObj?.data?.destination?.longitude ?? DefaultValue.double)
        
        Commons.getRouteSteps(from: riderLoc, to: driverLoc, needSnapShot: true) { [weak self] _ , _ , routeData in
            guard let self = self else {return}
            parent?.route.travelTime = routeData?.travelTime ?? ""
            parent?.route.travelDuration = routeData?.travelDuration ?? 0
            parent?.route.routeDistance = routeData?.routeDistance ?? ""
            parent?.route.travelInstruction = routeData?.travelInstruction ?? ""
            parent?.calculatedTime = parent?.calculateOngoingEstimatedTime(timeinSeconds: routeData?.travelDuration , travelTime: routeData?.travelTime ?? "", isDriver: false) ?? ""
           
            
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                self?.setupDetails()
                parent?.drawPolyLine(startingLoc: riderLoc, endingLocation: driverLoc, shouldBound: true, showCarMarker: false)
            }
        }
    }
    
    private func setupDetails() {
        let parent = self.parent?.parent as? MainDashboardViewController
        let tripObj = RideSingleton.shared.tripDetailObject?.data
        var fullName = tripObj?.riderInfo?.name
        if Commons.isArabicLanguage(){
            fullName = tripObj?.riderInfo?.arabicName
        }
        let firstName = fullName?.components(separatedBy: " ")
        self.riderName.text = firstName?[0]
        self.riderRating.text = RideSingleton.shared.tripDetailObject?.data?.riderInfo?.rating
        self.distanceAndTime.text = "\(parent?.route.routeDistance ?? "") • \(Commons.getAddedTime(time: parent?.route.travelDuration ?? 0))"
        self.distanceAndTime.textAlignment = Commons.isArabicLanguage() ? .right : .left
        self.distanceAndTime.text = "\(parent?.route.routeDistance ?? "") • \(Commons.getAddedTime(time: parent?.route.travelDuration ?? 0))"
        self.estimatedEarning.text = "SAR \(tripObj?.driverAmount ?? 0.0)"
        pickupLabel.text = tripObj?.source?.address
        destinationLabel.text = tripObj?.destination?.address
    }
    
    
    func reverseGeocode(location: CLLocation, completion: @escaping (String) -> Void){
        LocationManager.shared.getReverseGeoCodedLocation(location: location) { [weak self] (loc, place, error) in
            guard self != nil else {return}
            if let place = place {
                let addresss =  Commons.getAddressStrFromPlaceMark(place: place) // place.description
                if addresss.isEmpty {
                    completion("Unnamed Location".localizedString())
                }
                completion(addresss)
            }else{
                completion("Unnamed Location".localizedString())
            }
        }
    }
    
    
    
    //MARK: - UIACTIONS
    @IBAction func acceptBtnClicked(_ sender: Any) {
//        rider accepted ride
        tripresponseViewModel.driverAcceptRequest(tripId: RideSingleton.shared.tripDetailObject?.data?.id ?? DefaultValue.string)
    }
    
    @IBAction func declineBtnClicked(_ sender: Any) {
//        before accepting cancel
        tripresponseViewModel.cancelTripByDriver(with: RideSingleton.shared.tripDetailObject?.data?.id ?? DefaultValue.string)
    }
    
    private func drawPolyLineToPickUp() {
        let tripObj = RideSingleton.shared.tripDetailObject
        let riderLoc = CLLocationCoordinate2D.init(latitude: tripObj?.data?.source?.latitude ?? DefaultValue.double,
                                                   longitude: tripObj?.data?.source?.longitude ?? DefaultValue.double)
        
        //let driverLoc = LocationManager.shared.locationManager?.location?.coordinate
        let driverLoc =  CLLocationCoordinate2D.init(latitude: tripObj?.data?.destination?.latitude ?? DefaultValue.double,
                                                     longitude: tripObj?.data?.destination?.longitude ?? DefaultValue.double)
       // LocationManager.shared.locationManager?.location?.coordinate.latitude
//        (self.parent?.parent as? MainDashboardViewController)?.mapView?.clear()
        let marker = GMSMarker(position: riderLoc)
        marker.userData =  tripObj?.data?.source?.address ?? "Unnamed Location"
        marker.map = (self.parent?.parent as? MainDashboardViewController)?.mapView
        
        let Dmarker = GMSMarker(position: driverLoc )
        Dmarker.icon = UIImage(named: "CarMarker")
        Dmarker.userData = "Driver location"
        Dmarker.isFlat = true
        Dmarker.rotation = CLLocation(latitude: tripObj?.data?.destination?.latitude ?? DefaultValue.double, longitude: tripObj?.data?.destination?.longitude ?? DefaultValue.double).course
        Dmarker.rotation = (self.parent?.parent as? MainDashboardViewController)?.previousAngle ?? 0
        Dmarker.map = (self.parent?.parent as? MainDashboardViewController)?.mapView
        //(self.parent?.parent as? MainDashboardViewController)?.

        Commons.getRouteSteps(from: driverLoc, to: riderLoc , needSnapShot: false) { polyline, polylines, route in
            for polyline in polylines ?? [] {
                polyline.map = (self.parent?.parent as? MainDashboardViewController)?.mapView
                
                var bounds = GMSCoordinateBounds()
                if let plylines = route?.polyLine {
                    for route in plylines {
                        for index in 1...(route.path?.count())! {
                            bounds = bounds.includingCoordinate((route.path?.coordinate(at: index))!)
                        }
                    }
                }
                bounds = bounds.includingCoordinate(riderLoc)
                bounds = bounds.includingCoordinate(driverLoc)
//                let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(60))
//                (self.parent?.parent as? MainDashboardViewController)?.mapView?.animate(with: update)
            }
        }
    }
    
    private func resetRequestView() {
        showLoader(startAnimate: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let `self` = self else { return }
            RideSingleton.shared.tripDetailObject = nil
            UserDefaultsConfig.tripId = nil
            
            let parent = self.parent?.parent as? MainDashboardViewController
            parent?.containerViewHeight.constant = 220
            
            parent?.mapView?.clear()
            parent?.addCurrentLocationMarker()
            parent?.setupSwitchUserModeView()
            
            let leftView = parent?.navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
            leftView?.selectCaptainView()
            
            self.showLoader(startAnimate: false)
            
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
}

//MARK: - Bind To View Model
extension RiderRequestViewController {
    func bindViewToViewModel() {
        tripresponseViewModel.cancelTripResponse.bind { [weak self] res in
            guard let `self` = self else { return }
//              before accepting cancel
            Commons.adjustEventTracker(eventId: AdjustEventId.RidecancelledBeforeconfirmation)

            if res.statusCode == 200 {
                self.resetRequestView()
            }
        }
        
        tripresponseViewModel.isLoading.bind { [weak self] (value) in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }

        tripresponseViewModel.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            if value.containsIgnoringCase("Trip Driver not found"){
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Trip Expired")
            }else{
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
            }
        }
        
        
        tripresponseViewModel.acceptTripResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                Commons.adjustEventTracker(eventId: AdjustEventId.RidesAccepted)
                //self.drawPolyLineToPickUp()
                
                if let vc : RiderConfirmedViewController = UIStoryboard.instantiate(with: .driverToRider){
                    let parent = self.parent?.parent as? MainDashboardViewController
                    parent?.containerViewHeight.constant = 270
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                
            }
        }
        
        tripresponseViewModel.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            
            if value.code == 400 {
                self.resetRequestView()
            }
        }
    }
}
