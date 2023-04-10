//
//  MainDashboardSocketExtension.swift
//  Ride
//
//  Created by XintMac on 12/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

extension MainDashboardViewController {
    func listenRequestForDriverAccept() {
        SocketIOHelper.shared.listenDriverAcceptEvent(eventName: "trip-detail") { response in
            if response.data?.id.isSome ?? DefaultValue.bool {
                self.tripActionHandler(response: response)
            }
        }
    }
    
    func listenTimeEstimateEvent() {
        SocketIOHelper.shared.listenTimeEstimateEvent(eventName: "estimate-trip-details-update") { response in
            RideSingleton.shared.tripDetailObject?.data?.estimatedTripTime = response.data?.estimatedTripTime
            RideSingleton.shared.tripDetailObject?.data?.riderAmount = response.data?.riderAmount
            RideSingleton.shared.tripDetailObject?.data?.driverAmount = response.data?.driverAmount
        }
    }
    
    func tripActionHandler(response : TripDetailResponse) {
        RideSingleton.shared.tripDetailObject = response
        UserDefaultsConfig.tripId = response.data?.id
        let childNavigationController = (containerView.subviews.first?.getParentController() as? UINavigationController)
        
        if UserDefaultsConfig.isDriver {
            if response.action == .tripRequest {
                containerViewHeight.constant = 420
                if let vc: RiderRequestViewController = UIStoryboard.instantiate(with: .driverToRider) {
                    childNavigationController?.pushViewController(vc, animated: false)
                }
            } else if response.action == .rider_cancelled {
                containerViewHeight.constant = 220
                self.setupSwitchUserModeView()
                mapView?.clear()
                addCurrentLocationMarker()
                
                let leftView = self.navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
                leftView?.selectCaptainView()
                
                if navigationController?.viewControllers.last?.isKind(of: MainChatVC.self) ?? DefaultValue.bool {
                    navigationController?.popViewController(animated: false)
                }
                
                childNavigationController?.popToRootViewController(animated: false)
            } else if response.action == .rider_updated_destination {
                containerViewHeight.constant = 430
                if let vc: DropoffChangedVC = UIStoryboard.instantiate(with: .driverToRider) {
                    vc.destination = response.data?.destinationNew?.address ?? ""
                    childNavigationController?.pushViewController(vc, animated: false)
                }
            }
        } else {
            if response.action == .driverAccepted {
                UserDefaultsConfig.tripId = tripId
                containerViewHeight.constant = 360
                //Commons.playNotificationSound(soundName: "Request Accepted")
                if let vc: RiderEnterPinVC = UIStoryboard.instantiate(with: .riderToDriver) {
                    childNavigationController?.pushViewController(vc, animated: false)
                }
            } else if response.action == .tripExpired {
                RideSingleton.shared.tripDetailObject = nil
                UserDefaultsConfig.tripId = nil
                containerViewHeight.constant = 530
                for vc in childNavigationController?.viewControllers ?? []{
                    if vc.isKind(of: RiderRideSelection.self){
                        childNavigationController?.popToViewController(vc, animated: false)
                        return
                    }
                }
            } else if response.action == .trip_started {
                containerViewHeight.constant = 320
                //Commons.playNotificationSound(soundName: "Trip Started")
                if let vc: RiderDuringRide = UIStoryboard.instantiate(with: .riderToDriver) {
                    childNavigationController?.pushViewController(vc, animated: false)
                }
            } else if response.action == .trip_completed {
                //Commons.playNotificationSound(soundName: "Trip Ended")
                RideSingleton.shared.tripDetailObject = response
                if navigationController?.viewControllers.last?.isKind(of: MainChatVC.self) ?? DefaultValue.bool {
                    navigationController?.popViewController(animated: false)
                }
                
        
                let trip = RideSingleton.shared.tripDetailObject?.data
                
                let fromLoc = CLLocationCoordinate2D(latitude: trip?.source?.latitude ?? DefaultValue.double,
                                                     longitude: trip?.source?.longitude ?? DefaultValue.double)
                
                let toLoc = CLLocationCoordinate2D(latitude: trip?.destination?.latitude ?? DefaultValue.double,
                                                     longitude: trip?.destination?.longitude ?? DefaultValue.double)
                
                Commons.getRouteSteps(from: fromLoc, to: toLoc, needSnapShot: true) { _, _, _ in
                    
                }
                
                containerViewHeight.constant = 480
                if let vc: RiderCompletedRideVC = UIStoryboard.instantiate(with: .riderToDriver) {
                    childNavigationController?.pushViewController(vc, animated: false)
                }
                
                
                
            } else if response.action == .driver_cancelled_before_arrived || response.action == .driver_cancelled || response.action == .no_drivers {
                showLoader(startAnimate: false)
                RideSingleton.shared.tripDetailObject = nil
                UserDefaultsConfig.tripId = nil
                
                if navigationController?.viewControllers.last?.isKind(of: MainChatVC.self) ?? DefaultValue.bool {
                    navigationController?.popViewController(animated: false)
                }
                
                if response.action == .no_drivers {
                    //Commons.showErrorMessage(controller: self.navigationController ?? self, message: "No Nearby Drivers")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                        guard let `self` = self else { return }
                        if let vc: RiderNoDriverVC = UIStoryboard.instantiate(with: .riderToDriver) {
                            vc.tripId = response.data?.id ?? ""
                            childNavigationController?.pushViewController(vc, animated: false)
                        }
                    }
                    return
                }
                 
                containerViewHeight.constant = 140
                setupSwitchUserModeView()
                mapView?.clear()
                addCurrentLocationMarker()
                childNavigationController?.popToRootViewController(animated: false)
                
               
            }else if response.action == .rider_updated_destination{
                if let vc = childNavigationController?.navigationController?.viewControllers.last as? RiderDuringRide{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        vc.updateView()
                    }
                }
            }
        }
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    func getBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
    func listenCaptainLocationUpdate() {
        SocketIOHelper.shared.listenForCaptainLocationUpdate(eventName: "driver-location-updates") { [weak self] res in
            guard let `self` = self else { return }
            if let driverId = res.driverId, driverId.count > 0 {
                if let newLat = res.lat, let newLong = res.lon {
                    
                    let oldLat = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.latitude
                    let oldLng = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.longitude
                    
                    RideSingleton.shared.tripDetailObject?.data?.driverInfo?.latitude = newLat
                    RideSingleton.shared.tripDetailObject?.data?.driverInfo?.longitude = newLong
//                    self.changeTimeAndDistance(location: CLLocation(latitude: lat, longitude: long)) // TODO Nabeel
                                        
                    if RideSingleton.shared.tripDetailObject?.data?.status == .ACCEPTED_BY_DRIVER {
                        let currentLoc = CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
                        let destination = CLLocationCoordinate2D(latitude: RideSingleton.shared.tripDetailObject?.data?.source?.latitude ?? DefaultValue.double,
                                                                 longitude: RideSingleton.shared.tripDetailObject?.data?.source?.longitude ?? DefaultValue.double)
                       
                        let oldLoc = CLLocationCoordinate2D(latitude: oldLat ?? DefaultValue.double,
                                                            longitude: oldLng ?? DefaultValue.double)
                        var angle = self.getBearingBetweenTwoPoints(point1: oldLoc, point2: currentLoc)
                        if angle == 0 {
                            angle = self.previousAngle
                        } else {
                            self.previousAngle = angle
                        }
                        
                        self.drawPolyLine(startingLoc: currentLoc, endingLocation: destination, shouldBound: false, rotation: angle)
                    } else if RideSingleton.shared.tripDetailObject?.data?.status == .STARTED {
                        let currentLoc = CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
                        
                        let oldLoc = CLLocationCoordinate2D(latitude: oldLat ?? DefaultValue.double,
                                                            longitude: oldLng ?? DefaultValue.double)
                        
                        var angle = self.getBearingBetweenTwoPoints(point1: oldLoc, point2: currentLoc)
                        if angle == 0 {
                            angle = self.previousAngle
                        } else {
                            self.previousAngle = angle
                        }
                        
                        print("ANGLEEEE : \(angle) \n OLD LOC: \(oldLoc) \n NEW LOC: \(currentLoc)")
                        
                        
                        let tripData = RideSingleton.shared.tripDetailObject?.data
                        var destination = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
                        if let newDestination = tripData?.destinationNew?.address{
                            if newDestination.isEmpty{
                                destination = CLLocationCoordinate2D.init(latitude: tripData?.destination?.latitude ?? DefaultValue.double,
                                                                          longitude: tripData?.destination?.longitude ?? DefaultValue.double)
                            }else{
                                destination = CLLocationCoordinate2D.init(latitude: tripData?.destinationNew?.latitude ?? DefaultValue.double,
                                                                          longitude: tripData?.destinationNew?.longitude ?? DefaultValue.double)
                            }
                        }
                        
                        
                        self.drawPolyLine(startingLoc: currentLoc, endingLocation: destination, shouldBound: false, rotation: angle, isDrawPolyLine: false)
                    }
                }
            } else {
                print("driver-location-updates socket status data === \(res)")
            }
        }
    }
}
