//
//  BecomeCaptainRequest.swift
//  Ride
//
//  Created by Mac on 20/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct BecomeCaptainRequest: Codable {
    
    let acceptTC: Bool?
    let cab: String?
    let carLicenceType: Int?
    let carPlateNo: String?
    let carSequenceNo: String?
    let driverNationalId: String?
    let drivingModes: [DrivingMode]?
    let subscriptionId: String?
    let autoRenewal: Bool?
}

struct DrivingMode: Codable {
    let drivingMode: Int?

}
