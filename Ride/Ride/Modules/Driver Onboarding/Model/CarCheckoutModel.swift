//
//  CarCheckoutModel.swift
//  Ride
//
//  Created by XintMac on 06/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//


import Foundation

//request
struct CarCheckoutRequest : Codable {
    var car_id: String?
    var pkg_id: Int?
    var preference: String?
    var preference_lat: String?
    var preference_lng: String?
}

//response
struct CarCheckoutResponse: Codable {
    var message: String?
    var statusCode: Int?
    var data: CarCheckoutData?
}

struct CarCheckoutData: Codable {
    var tId: String?
}

