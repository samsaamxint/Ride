//
//  DashboardProtocol.swift
//  Ride
//
//  Created by Mac on 04/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation

protocol MapViewProtocol: AnyObject {
    var currentLocationMarker: GMSMarker? { get set }
    var mapView: GMSMapView? { get set }
    
    func setupMap()
    func addCurrentLocationMarker()
}

extension MapViewProtocol where Self: UIViewController {
    func addCurrentLocationMarker(){ }
}



//MARK: - Main Dashboard Delegates
protocol DashboardChildDelegates: AnyObject {
    func didTapTrackYourCarStatus()
    func didAcceptRiderReqByDriver()
    func navigateToRider()
    func navigatingToRider()
    func driverReachedAtRiderAddress()
    func didStartRide()
    func finishRide()
    func didSubmitRating()
    func goToEmptyDashboard()
    func seeApplicationStatusDetails()
    func ownCarSubscribe()
    func addBalance()
}

