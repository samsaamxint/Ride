//
//  DriverStatus.swift
//  Ride
//
//  Created by Mac on 27/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct DriverStatusResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: DriverStatusData?
}


struct DriverStatusData: Codable {
    var WASLRejectionReasons : String?
    var id: String?
    var createdAt: String?
    var updatedAt: String?
    var driverName: String?
    var externalId: String?
    var driverNationalId: String?
    var carPlateNo: String?
    var carSequenceNo: String?
    var carLicenceType: Int?
    var drivingModes: [DrivingMode]?
    var blockedReason: String?
    var blockedDate: String?
    var acceptTC: Bool?
    var driverModeSwitch: Bool?
    var driverRideStatus: Bool?
    var driverSubStatus: Int?
    var driverSubscriptionId: String?
    var driverSubAmount: Double?
    var latitude: Double?
    var longitude: Double?
    var eligibilityExpiryDate: String?
    var isWASLApproved: Int?
    var cab: CarItem?
    var profileImage: String?
    var dateOfBirth: String?
    var mobileNo: String?
    var emailId: String?
    var address1: String?
    var address2: String?
    var totalRides: Int?
    var totalTrips: Int?
    var tripsCancelled: Int?
    var tripsDeclined: Int?
    var arabicFullName: String?
    var overallRating: Double?
    var overallReviews: Int?
    var latestTripId: String?
    var iban: String?
}
