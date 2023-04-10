//
//  StoaryboardExtension.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    static func instantiate<T: UIViewController>(with storyboardName: StoryboardEnum) -> T? {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: T.className) as? T
    }
}

enum StoryboardEnum: String {
    case onboarding = "Onboarding"
    case paymentMethods = "PaymentMethods"
    case driverOnboarding = "DriverOnboarding"
    case rideARide = "RideARide"
    case mainDashboard = "MainDashboard"
    case userProfile = "UserProfile"
    case driverRideARideDashboard = "DriverRideARideDashboard"
    case driverToRider = "DriverToRider"
    case driverOwnCarDashboard = "DriverOwnCarDashboard"
    case commonAlerts = "CommonAlertsVCs"
    case promoCode = "PromoCode"
    case riderToDriver = "RiderToDriver"
    case switchUser = "SwitchUser"
    case riderPickup = "RiderPickup"
    case chat = "Chat"
    case invoice = "Invoice"
}
