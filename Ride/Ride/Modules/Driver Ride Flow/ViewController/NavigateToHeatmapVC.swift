//
//  NavigateToHeatmapVC.swift
//  Ride
//
//  Created by Ali Zaib on 04/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class NavigateToHeatmapVC: UIViewController {
    
    @IBOutlet weak var rideTimeRemaining: UILabel!
    @IBOutlet weak var rideDistance: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var endRideBtn: UIButton!
    @IBOutlet weak var navigateBtn: UIButton!
    
    var heatMaplocaion : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showLoader(startAnimate: true)
        updateMainMapView()
        if let location = LocationManager.shared.locationManager?.location {
            setUI(fromLocation: location)
        }
        (self.parent?.parent as? MainDashboardViewController)?.goToGM.isHidden = false
        
        rideTimeRemaining.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        rideDistance.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        instructionsLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        endRideBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        navigateBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(18) : UIFont.SFProDisplaySemiBold?.withSize(18)
        endRideBtn.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateDriversIcon), name: .updateDriverIcon, object: nil)
    }
    

    func setUI(fromLocation : CLLocation){
        let parent = self.parent?.parent as? MainDashboardViewController
        if let destination = heatMaplocaion{
        parent?.distanceUpdate(fromLoc: fromLocation, toLoc: destination, isDrawPolyLine: true){ calculatedTime in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.rideDistance.text = "\(parent?.route.routeDistance ?? "") • \(Commons.getAddedTime(time: parent?.route.travelDuration ?? 0))"
                self.rideTimeRemaining.text = calculatedTime
                //let desc = String(format: "Go straight".localizedString(), parent?.route.travelInstruction ?? "0.1 m")
                self.instructionsLabel.text = "Go straight".localizedString() + (parent?.route.travelInstruction ?? "0.1 m")
             
            }
        }
        }
    }
    
    @objc private func updateDriversIcon(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary?, let location = dict["location"] as? CLLocation {
            var distanceInMeters = location.distance(from: CLLocation(latitude: heatMaplocaion?.coordinate.latitude ?? 0, longitude: heatMaplocaion?.coordinate.longitude ?? 0))
            if distanceInMeters > 2 {
                let parent = self.parent?.parent as? MainDashboardViewController
                parent?.drawPolyLine(startingLoc: location.coordinate, endingLocation: CLLocationCoordinate2D.init(latitude: heatMaplocaion?.coordinate.latitude ?? 0.0 , longitude: heatMaplocaion?.coordinate.longitude ?? 0.0), shouldBound: false, showCarMarker: true, rotation: location.course){
                    parent?.heatmapLayer.map = parent?.mapView
                    parent?.heatmapGroupLayer.map = parent?.mapView
                    
                }
            }
        }
    }
    
//    private func updateUI() {
//        let tripObj = RideSingleton.shared.tripDetailObject
//        self.rideTimeRemaining.text = "\(tripObj?.data?.estimatedTripTime ?? 0.0) mins".replacingOccurrences(of: ".", with: ":")
//        rideDistance.text = "\(tripObj?.data?.tripDistance ?? 0.0) Km • 3:00 pm"
//        let desc = String(format: "Go straight".localizedString(), tripObj?.data?.tripDistance ?? "0.1 m")
//        self.instructionsLabel.text = desc
//    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.heatmapLayer.map = nil
        parent?.heatmapGroupLayer.map = nil
    }
    
    private func updateMainMapView() {
        let parent = self.parent?.parent as? MainDashboardViewController
        var source = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
        if let location = LocationManager.shared.locationManager?.location {
            source = CLLocationCoordinate2D.init(latitude: location.coordinate.latitude , longitude: location.coordinate.longitude)
        }
        
     //   parent?.drawPolyLine(startingLoc: source,
                            // endingLocation: CLLocationCoordinate2D.init(latitude: heatMaplocaion?.coordinate.latitude ?? 0.0 , longitude: heatMaplocaion?.coordinate.longitude ?? 0.0))
        parent?.drawPolyLine(startingLoc: source, endingLocation: CLLocationCoordinate2D.init(latitude: heatMaplocaion?.coordinate.latitude ?? 0.0 , longitude: heatMaplocaion?.coordinate.longitude ?? 0.0), shouldBound: true, showCarMarker: true){
            parent?.heatmapLayer.map = parent?.mapView
            parent?.heatmapGroupLayer.map = parent?.mapView
        }
        self.showLoader(startAnimate: false)
        
    }
    
    //MARK: - UIACTIONS
    @IBAction func endRideBtnClicked(_ sender: Any) {
        (self.parent?.parent as? MainDashboardViewController)?.goToGM.isHidden = true
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: NoRidersViewController.self) {
                self.navigationController!.popToViewController(controller, animated: false)
                return
            }
        }
        let parent = (self.parent?.parent as? MainDashboardViewController)
        if let vc: NoRidersViewController = UIStoryboard.instantiate(with: .driverToRider) {
            parent?.containerViewHeight.constant = 220
            (parent?.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
            parent?.addChildWithNavViewController(childController: vc, contentView: (parent?.containerView)!)
        }
    }
    
    @IBAction func navigateBtn(_ sender: Any) {
        let parent = (self.parent?.parent as? MainDashboardViewController)
        DispatchQueue.main.async() { () -> Void in
            guard let lat = parent?.locationManager.location?.coordinate.latitude else { return }
            guard let lng = parent?.locationManager.location?.coordinate.longitude else { return }
            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 16)
            parent?.mapView?.camera = camera
            self.endRideBtn.isHidden = false
            self.navigateBtn.isHidden = true
        }
    }
    

}
