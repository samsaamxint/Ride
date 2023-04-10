//
//  GenericEnums.swift
//  Ride
//
//  Created by Mac on 04/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

enum OnboardingType {
    case signup, login
}

enum MainDashboardState: Equatable {
    case trackStatus(CGFloat), statusApproved(CGFloat), trackStatusDetails, noRidersAround(CGFloat), none, enterIBAN(CGFloat), highDemandNavigation(CGFloat), rideRequest(CGFloat), rideReqAccepted(CGFloat), enterPin(CGFloat), startRideByDriver(CGFloat), completeRide(CGFloat), driverPaymentDetails(CGFloat), cancelRide(CGFloat), applicationStatus(CGFloat), applicationStatusDetail, applicationStatusApprove(CGFloat), ownCarSubscription(CGFloat), addBalance, notDriver(CGFloat), riderDropOff
}

enum DashboardType {
    case rider, driver
}
