//
//  FindDriverResponse.swift
//  Ride
//
//  Created by Mac on 08/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct FindDriversReponse: Codable {
    let statusCode: Int?
    let cartypes: [CarItem]?
    let drivers: [Driver]?
}

struct Driver: Codable {
    let acceptTC: Int?
    let approved: Int?
    let cabId: String?
    let carLicenceType: String?
    let carPlateNo: String?
    let carSequenceNo: String?
    let createdAt: String?
    let dbDistance: Double?
    let distance: Double?
    let driverModeSwitch: Int?
    let driverName: String?
    let driverNationalId: String?
    let driverSubAmount: Double?
    let externalId: String?
    let id: String?
    let latitude: Double?
    let longitude: Double?
    let updatedAt: String?
}

