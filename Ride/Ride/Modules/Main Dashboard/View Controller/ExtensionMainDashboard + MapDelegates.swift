//
//  ExtensionMainDashboard + MapDelegates.swift
//  Ride
//
//  Created by Mac on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GoogleMapsUtils

// MARK: - CLLocationManagerDelegate
extension MainDashboardViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Create a GMSCameraPosition that tells the map to display current location at zoom level 15.0
        guard let location = locations.last else { return }
        
        if let location = locations.last {
            
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            
            Commons.geocodeAddressFromGoogleMap(lat: myLocation.latitude, lng: myLocation.longitude) { address in
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.currentAddress = address
                }
            }
        }
        
        
        if !isOnCurrentLocation{
            let camera = GMSCameraPosition.camera(withLatitude:location.coordinate.latitude, longitude:location.coordinate.longitude, zoom: 16)
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                
                CATransaction.begin()
                CATransaction.setValue(0, forKey: kCATransactionAnimationDuration)
                self.mapView?.animate(to: camera)
                CATransaction.commit()
                
            }
            isOnCurrentLocation = true
        }
        
        addCurrentLocationMarker()
        
        if let location = locations.last {
            //print("BEARING ------- \(location.course)")
            updateCaptainLocationWhereNeeded(location: location)
            
        }
        NotificationCenter.default.post(name: .updateDriverIcon, object: nil, userInfo: ["location": location])
        checkIfDriverReachedToPickup(location: location)
    }
    
    func checkIfDriverReachedToPickup(location: CLLocation) {
        let tripData = RideSingleton.shared.tripDetailObject?.data
        let childNavigationController = (containerView.subviews.first?.getParentController() as? UINavigationController)
        guard let lastVC = childNavigationController?.viewControllers.last else { return }
        
        if let vc = lastVC as? RiderConfirmedViewController{
            vc.setUI(fromLocation: location)
        }else if let vc = lastVC as? RideInProgressViewController{
            vc.setUI(fromLocation: location)
        }
        
        if tripData?.status == .ACCEPTED_BY_DRIVER || tripData?.status == .PENDING {
            if let pickLat = tripData?.source?.latitude,
               let pickLong = tripData?.source?.longitude {
                let sourceLoc = CLLocation(latitude: pickLat, longitude: pickLong)
                let distanceInMeters = sourceLoc.distance(from: location)
                if distanceInMeters < 50 {
                    if let vc = lastVC as? RiderConfirmedViewController {
                        vc.updateViewWhenCaptainReachedAtPickup()
                    }
                }else{
                    if let vc = lastVC as? RiderConfirmedViewController {
                        vc.updateViewForOnTheWay()
                    }
                }
            }
        }
        
    }
    
    func updateCaptainLocationWhereNeeded(location: CLLocation) {
        if let preveLoc = LocationManager.shared.previousLocation {
            let distanceInMeters = preveLoc.distance(from: location)
            LocationManager.shared.previousLocation = location
            if distanceInMeters > 0.001 {
                LocationManager.shared.previousLocation = location
                SocketIOHelper.shared.updateCaptainLocation(location: location)
                
                didUpdateLocation = true
                
                NotificationCenter.default.post(name: .updateLocationForDriver, object: nil, userInfo: ["location": location])
            } else if !didUpdateLocation {
                
                LocationManager.shared.previousLocation = location
                SocketIOHelper.shared.updateCaptainLocation(location: location)
                didUpdateLocation = true
                
                NotificationCenter.default.post(name: .updateLocationForDriver, object: nil, userInfo: ["location": location])
            }
        }
    }
}

//MARK: - MapViewProtocol
extension MainDashboardViewController: MapViewProtocol {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            setDarkMap()
        } else {
            mapView?.mapStyle = nil
        }
    }
    
    private func setDarkMap() {
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "DarkGMSStyle", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    func setupMap() {
        mapView = GMSMapView(frame: view.frame)
        view.addSubview(mapView!)
        
        mapView?.delegate = self
        mapView?.isMyLocationEnabled = false
        view.sendSubviewToBack(mapView!)
        
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            setDarkMap()
        } else {
            mapView?.mapStyle = nil
        }
    }
    
    
    func addCurrentLocationMarker() {
        if let location = locationManager.location {
            guard RideSingleton.shared.tripDetailObject?.data?.status != .STARTED else { return }
            
            if let marker = markers.first(where: { $0.userData as? Int == 1 }) {
                markers[0] = marker
                currentLocationMarker?.position = location.coordinate
                currentLocationMarker?.rotation = location.course
                marker.map = mapView
            } else {
                currentLocationMarker = GMSMarker(position: location.coordinate)
                currentLocationMarker?.icon = UIImage(named: "MapCurrentMarker")
                currentLocationMarker?.map = mapView
                currentLocationMarker?.userData = 1
                currentLocationMarker?.rotation = locationManager.location?.course ?? DefaultValue.cgfloat
                //currentLocationMarker?.userData = "currentLoc"
                markers.append(currentLocationMarker!)
            }
        }
    }
}

//MARK: - GMSMapViewDelegate
extension MainDashboardViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker.userData as? Int == 1 {
            //            let markerView: CustomMarkerInfoView = .fromNib()
            //            markerView.locationName.text = "Current location"
            return nil
        } else if marker.position != nil {
            let childNavigationController = (containerView.subviews.first?.getParentController() as? UINavigationController)
            if childNavigationController?.viewControllers.count == 1 {
                if let lastVC = childNavigationController?.viewControllers.first as? UIViewController {
                    if lastVC.isKind(of: NoRidersViewController.self){
                        if let vc : NavigateToHeatmapVC = UIStoryboard.instantiate(with: .driverToRider){
                            self.containerViewHeight.constant = 230
                            vc.heatMaplocaion =  CLLocation.init(latitude: marker.position.latitude, longitude: marker.position.longitude)
                            RideSingleton.shared.heatMaplocaionPoints = vc.heatMaplocaion
                            (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                            self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                        }
                    }
                }
            }
            return nil
        } else{
            let markerView: CustomMarkerInfoView = .fromNib()
            if let location = marker.userData as? ActiveUserLocationItem{
                NSLog("coordinates tapped \(location.latitude) \(location.longitude)")
                if let vc : NavigateToHeatmapVC = UIStoryboard.instantiate(with: .driverToRider){
                    self.containerViewHeight.constant = 230
                    vc.heatMaplocaion =  CLLocation.init(latitude: location.latitude ?? 0.0 , longitude: location.longitude ?? 0.0)
                    (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                    self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                }
                return markerView
            }
            markerView.locationName.text = marker.userData as? String
            return markerView
        }
    }
    
    
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let lat = locationManager.location?.coordinate.latitude else { return false }
        guard let lng = locationManager.location?.coordinate.longitude else { return false }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng , zoom: self.mapView?.camera.zoom ?? 16)
        self.mapView?.animate(to: camera)
        return false //default move map to my location
    }
}

extension MainDashboardViewController {
    func drawCabMarkers(cords : [CLLocationCoordinate2D] ) {
        cords.forEach { cord in
            let marker = GMSMarker(position: cord)
            marker.isFlat = true
            marker.rotation = previousAngle
            marker.icon = UIImage(named: "CarMarker")
            marker.map = mapView
        }
    }
}

