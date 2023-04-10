//
//  BookRideRequest.swift
//  Ride
//
//  Created by Mac on 09/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct TripRequestDetails: Codable {
    var cabId, promoCode, country, city: String?
    var addresses = [CreateTripAddress]()
    var applePayToken: ApplePayToken?
    var amount: Double?
}
