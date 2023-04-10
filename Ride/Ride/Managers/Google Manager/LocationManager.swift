//
//  LocationManager.swift
//  Ride
//
//  Created by Mac on 07/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import MapKit

protocol LocationManagerDelegate: AnyObject {
    func currentLocation(location: CLLocation)
}

final class LocationManager: NSObject {
    
    enum LocationErrors: String {
        case denied = "Locations are turned off. Please turn it on in Settings"
        case restricted = "Locations are restricted"
        case notDetermined = "Locations are not determined yet"
        case notFetched = "Unable to fetch location"
        case invalidLocation = "Invalid Location"
        case reverseGeocodingFailed = "Reverse Geocoding Failed"
        case unknown = "Some Unknown Error occurred"
    }
    
    weak var delegate: LocationManagerDelegate?
    
    typealias LocationClosure = ((_ location:CLLocation?,_ error: NSError?)->Void)
    private var locationCompletionHandler: LocationClosure?
    
    typealias ReverseGeoLocationClosure = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: NSError?)->Void)
    typealias ReverseGeoLocationClosureAr = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: NSError?)->Void)
    private var geoLocationCompletionHandler: ReverseGeoLocationClosure?
    private var geoLocationCompletionHandlerAr: ReverseGeoLocationClosureAr?
    
    var locationManager:CLLocationManager?
    var locationAccuracy = kCLLocationAccuracyBest
    
    var lastLocation:CLLocation?
    var previousLocation:CLLocation?
    private var reverseGeocoding = false
    private var reverseGeocodingAr = false
    
    //Singleton Instance
    static let shared: LocationManager = {
        let instance = LocationManager()
        // setup code
        instance.setupLocationManager()
        return instance
    }()
    
    private override init() {}
    
    //MARK:- Destroy the LocationManager
    deinit {
        destroyLocationManager()
    }
    
    //MARK:- Private Methods
    private func setupLocationManager() {
        //Setting of location manager
        locationManager = nil
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = locationAccuracy
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.delegate = self
        locationManager?.activityType = .automotiveNavigation
        locationManager?.requestAlwaysAuthorization()
    }
    
    private func destroyLocationManager() {
        locationManager?.delegate = nil
        locationManager = nil
        lastLocation = nil
    }
    
    @objc private func sendPlacemark() {
        guard let _ = lastLocation else {
            
            self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            
            //            lastLocation = nil
            return
        }
        
        self.reverseGeoCoding(location: lastLocation)
        //        lastLocation = nil
    }
    
    @objc private func sendLocation() {
        guard let _ = lastLocation else {
            self.didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            return
        }
        self.didComplete(location: lastLocation,error: nil)
        //        lastLocation = nil
    }
    
    //MARK:- Public Methods
    
    /// Check if location is enabled on device or not
    ///
    /// - Parameter completionHandler: nil
    /// - Returns: Bool
    func isLocationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    /// Get current location
    ///
    /// - Parameter completionHandler: will return CLLocation object which is the current location of the user and NSError in case of error
    func getLocation(completionHandler:@escaping LocationClosure) {
        
        //Resetting last location
        lastLocation = nil
        
        self.locationCompletionHandler = completionHandler
        
        setupLocationManager()
    }
    
    
    /// Get Reverse Geocoded Placemark address by passing CLLocation
    ///
    /// - Parameters:
    ///   - location: location Passed which is a CLLocation object
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the CLLocation and NSError in case of error
    func getReverseGeoCodedLocation(location:CLLocation,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(location: location)
        }
        
    }
    
    func getReverseGeoCodedLocationArabic(location:CLLocation,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandlerAr = nil
        self.geoLocationCompletionHandlerAr = completionHandler
        if !reverseGeocodingAr {
            reverseGeocodingAr = true
            self.reverseGeoCodingArabic(location: location)
        }
        
    }
    
    /// Get Latitude and Longitude of the address as CLLocation object
    ///
    /// - Parameters:
    ///   - address: address given by the user in String
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the address entered and NSError in case of error
    func getReverseGeoCodedLocation(address:String,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(address: address)
        }
    }
    
    
    /// Get current location with placemark
    ///
    /// - Parameter completionHandler: will return Location,Placemark and error
    func getCurrentReverseGeoCodedLocation(completionHandler:@escaping ReverseGeoLocationClosure) {
        
        if !reverseGeocoding  {
            
            reverseGeocoding = true
            
            //Resetting last location
            lastLocation = nil
            
            self.geoLocationCompletionHandler = completionHandler
            
            setupLocationManager()
        }
    }
    
    //MARK:- Reverse GeoCoding
    private func reverseGeoCoding(location:CLLocation?) {
        CLGeocoder().reverseGeocodeLocation(location!,preferredLocale: Locale(identifier: "en"), completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                  NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
             NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                if let _ = location {
                    self.didCompleteGeocoding(location: location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                            [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                      NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                DLog("Problem with the data received from geocoder")
            }
        })
    }
    
    private func reverseGeoCodingArabic(location:CLLocation?) {
        CLGeocoder().reverseGeocodeLocation(location!, preferredLocale: Locale(identifier: "ar")) {(placemarks, error)->Void in
            
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocodingAR(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                  NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
             NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                if let _ = location {
                    self.didCompleteGeocodingAR(location: location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocodingAR(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                            [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                      NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                DLog("Problem with the data received from geocoder")
            }
        }
        
    }
    
    private func reverseGeoCoding(address:String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                  NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
             NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                if let placemark = placemarks?[0] {
                    self.didCompleteGeocoding(location: placemark.location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                            [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                      NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                DLog("Problem with the data received from geocoder")
            }
        })
    }
    
    //MARK:- Final closure/callback
    private func didComplete(location: CLLocation?,error: NSError?) {
        //        locationManager?.stopUpdatingLocation()
        locationCompletionHandler?(location,error)
        //        locationManager?.delegate = nil
        //        locationManager = nil
    }
    
    private func didCompleteGeocoding(location:CLLocation?,placemark: CLPlacemark?,error: NSError?) {
        //        locationManager?.stopUpdatingLocation()
        geoLocationCompletionHandler?(location,placemark,error)
        //        locationManager?.delegate = nil
        //        locationManager = nil
        reverseGeocoding = false
    }
    
    private func didCompleteGeocodingAR(location:CLLocation?,placemark: CLPlacemark?,error: NSError?) {
        //        locationManager?.stopUpdatingLocation()
        geoLocationCompletionHandlerAr?(location,placemark,error)
        //        locationManager?.delegate = nil
        //        locationManager = nil
        reverseGeocodingAr = false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    //MARK:- CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        DLog("\(Date())")
        locationManager?.startUpdatingHeading()
        if let location = locations.last {
            //if self.previousLocation == nil {
            if UserDefaultsConfig.isDriver {
                //                    SocketIOHelper.shared.updateCaptainLocation(location: location)
            }
            if previousLocation.isNone {
                self.previousLocation = self.lastLocation ?? location
            }
            //}
            self.lastLocation = location
        }
        lastLocation = locations.last
        if let location = locations.last {
            if location.horizontalAccuracy < 0 {
                self.locationManager?.stopUpdatingLocation()
                self.locationManager?.startUpdatingLocation()
                return
            }
            self.sendLocation()
                
            let tripData = RideSingleton.shared.tripDetailObject?.data
            if let tripId = UserDefaultsConfig.tripId, let tripStatus = tripData?.status {
                
                if tripStatus == .ACCEPTED_BY_DRIVER {
                    if let pickLat = tripData?.source?.latitude,
                       let pickLong = tripData?.source?.longitude {
                        let sourceLoc = CLLocation(latitude: pickLat, longitude: pickLong)
                        let distanceInMeters = sourceLoc.distance(from: location)
                        if distanceInMeters == 30 {
                            //                            APPDELEGATE.setLocalNotification(tripId: tripId, type: PushNotificationType.kDriverReachedOnPickup)
                        }
                    }
                } else if tripStatus == .STARTED {
                    if let destLat = tripData?.destinationNew?.latitude,
                       let destLong = tripData?.destinationNew?.longitude {
                        let destLoc = CLLocation(latitude: destLat, longitude: destLong)
                        let distanceInMeters = destLoc.distance(from: location)
                        if distanceInMeters == 30 {
                            //                            APPDELEGATE.setLocalNotification(tripId: tripId, type: PushNotificationType.kDriverReachedOnDestination)
                        }
                    } else if let destLat = tripData?.destination?.latitude,
                              let destLong = tripData?.destination?.longitude {
                        let destLoc = CLLocation(latitude: destLat, longitude: destLong)
                        let distanceInMeters = destLoc.distance(from: location)
                        if distanceInMeters == 30 {
                            //                            APPDELEGATE.setLocalNotification(tripId: tripId, type: PushNotificationType.kDriverReachedOnDestination)
                        }
                    }
                }
            }
            
            if let preveLoc = self.previousLocation {
                let distanceInMeters = preveLoc.distance(from: location)
                
                if let delegateObj = self.delegate, let tripId = UserDefaultsConfig.tripId, tripId.count > 0, distanceInMeters > 10 {
                    delegateObj.currentLocation(location: location)
                }
            }
        }
        if let tripID = UserDefaultsConfig.tripId, tripID.count > 0 {
            locationManager?.allowsBackgroundLocationUpdates = true
        } else if UserDefaultsConfig.isDriver {
            locationManager?.allowsBackgroundLocationUpdates = true
        } else {
            self.locationManager?.stopUpdatingLocation()
            locationManager?.allowsBackgroundLocationUpdates = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status { 
            
        case .authorizedWhenInUse:
            if UserDefaultsConfig.isDriver {
                showPermissionAlert()
            } else {
                self.locationManager?.startUpdatingLocation()
            }
           
        case .authorizedAlways:
            self.locationManager?.startUpdatingLocation()
            
        case .denied:
            let deniedError = NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.denied.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.denied.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.denied.rawValue])
            
            if reverseGeocoding {
                didCompleteGeocoding(location: nil, placemark: nil, error: deniedError)
            } else {
                didComplete(location: nil,error: deniedError)
            }
            //            locationManager?.requestWhenInUseAuthorization()
            showPermissionAlert()
        case .restricted:
            if reverseGeocoding {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            } else {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            }
            //            locationManager?.requestWhenInUseAuthorization()
            showPermissionAlert()
            
        case .notDetermined:
            self.locationManager?.requestLocation()
            showPermissionAlert()
            
        @unknown default:
            showPermissionAlert()
            didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.unknown.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.unknown.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.unknown.rawValue]))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DLog("\(error.localizedDescription)")
        self.didComplete(location: nil, error: error as NSError?)
    }
    
    func showPermissionAlert() {
        var alertController: UIAlertController?
        if UserDefaultsConfig.isDriver {
            alertController = UIAlertController(title: "location Permission title".localizedString(), message: "location permission desc".localizedString(), preferredStyle: UIAlertController.Style.alert)
        } else {
            alertController = UIAlertController(title: "location Permission title".localizedString(), message: "location permission desc rider".localizedString(), preferredStyle: UIAlertController.Style.alert)
        }
         
        let okAction = UIAlertAction(title: "Settings".localizedString(), style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        alertController?.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController!, animated: true)
    }
}

