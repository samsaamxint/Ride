//
//  CurrentLocationProtocol.swift
//  Ride
//
//  Created by Mac on 18/08/2022.
//

import Foundation
import CoreLocation
import UIKit

protocol CurrentLocationProtocol:CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager{ get set }
    
    func requestLocation()
}

extension CurrentLocationProtocol where Self:UIViewController{
    
    //MARK:- Map configuration
    func requestLocation() {
        //Location manager code to ferch current location
        self.locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.startUpdatingLocation()
    }
}
