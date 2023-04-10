//
//  RiderCancelTrip.swift
//  Ride
//
//  Created by XintMac on 16/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct RiderCancelTrip: Codable {
    var declinedReason: String?
}

struct CancelReasonList: Codable {
    var statusCode: Int?
    var message: String?
    var errors: String?
    
    var data: [CancelReasonItem]?
}

struct CancelReasonItem: Codable {
    var id: String?
    var createdAt: String?
    var reason: String?
    var reasonArabic: String?
    var reasonType: Int?
    var status: Bool?
}
