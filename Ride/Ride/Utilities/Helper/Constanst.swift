//
//  Constanst.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

public func delay(_ delay:Double, closure : @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

class DefaultValue {
    static let string = ""
    static let int = 0
    static let bool = false
    static let cgfloat: CGFloat = 0
    static let double: Double = 0
}

class CustomTag {
    static let ErrorviewTag = 101
    static let MainDashboardCancelView = 102
    static let SwitchUserModeView = 103
}

enum AlertMessages {
    static let somethingwrong           = "Something went wrong. Please try again."
    static let forceUpdate              = "forceUpdate"
    static let noInternet               = "Please check your internet connectivity."
    static let decryptionError          = "Problem in Decrypting response"
    static let remittanceNotAvailable   = "Remittance service is currently not available. Please try again after sometime."
}

enum ErrorCode {
    static let userNotFoundErrorCode    = "114"
    static let forceUpdateErrorcode     = "302"
    static let invalidSeasion           = "014"
    static let NoBeneficiariesErrorCode = "080"
    static let remittanceNotAvailable = "623|624"
    static let wrongPin = "047|045"
}

enum APIKeys{
    static let GoogleMapsKey   = "AIzaSyD1ozwIZZJsqSjDAJD12Cze6ylxkPVkjYQ"
    static let GooglePlacesKey   = "AIzaSyD1ozwIZZJsqSjDAJD12Cze6ylxkPVkjYQ"
    
    static let CMS_SECRET_KEY = "xBJbW0S1OIFJl9bsjsdZ"
}

class Constants {
    static var estimationAmount: Int = 5
//    static var riderID = "1123982538"
//    static var riderSessionId = "test1123982538" // RIDER
//    
//    static var driverID = "1051453478"
//    static var driverSessionId = "test1051453478" // DRIVER
//    
//    static var userID = riderID
//    static var sessionID = riderSessionId
}

enum NotificationType: String {
    case kTripRequest = "trip_request"
    case kTripAccepted = "trip_accept"
    case kTripCancelledByRider = "rider_cancelled"
    case kTripExpired = "trip_expired"
    case kTripCompletedByRider = "trip_completed_by_rider"
    case kChangeDestinationByRider = "rider_updated_destination"
    case kDriverAccepted = "driver_accepted"
    case kTripCancelledByDriver = "driver_cancelled"
    case kTripCancelledByDriverBeforePick = "driver_cancelled_before_arrived"
    case kDriverReached = "driver_reached"
    case kRideCompletedBydriver = "trip_completed_by_driver"
    case kDriverReachedOnPickup = "driver_reached_on_pickup"
    case kDriverReachedOnDestination = "driver_reached_on_destination"
}
