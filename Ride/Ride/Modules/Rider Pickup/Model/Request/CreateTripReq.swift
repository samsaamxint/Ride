//
//  CreateTripReq.swift
//  Ride
//
//  Created by Mac on 08/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
struct CreateTripAddress: Codable {
    var address, cityNameInArabic: String?
    var addressType: Int?
    var latitude, longitude: Double?
}
