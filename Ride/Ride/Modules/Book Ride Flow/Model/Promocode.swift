//
//  Promocode.swift
//  Ride
//
//  Created by Mac on 03/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

// Request Model
struct ValidatePromocodeRequest: Codable {
    var promoCode: String?
    var amount: Double?
    var userId: String?
    var lat:Double?
    var long : Double?
    var applyingTo : Int?
    var tripId: String?
}

struct ValidatePromocodeResponse: Codable {
    var statusCode: Int?
    var message : String?
    var data: PromocodeData?
}

struct PromocodeData : Codable{
    var amount : Double?
    var promoCodeId : String?
    var valid : Bool?
}
