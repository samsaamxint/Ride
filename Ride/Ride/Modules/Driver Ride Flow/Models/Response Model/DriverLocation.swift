//
//  DriverLocation.swift
//  Ride
//
//  Created by Mac on 14/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct DriverLocationDetailResponse : Codable {
    let lat : Double?
    let lon : Double?
    let driverId : String?
}
