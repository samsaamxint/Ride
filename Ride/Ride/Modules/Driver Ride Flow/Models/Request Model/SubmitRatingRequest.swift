//
//  SubmitRatingRequest.swift
//  Ride
//
//  Created by Mac on 16/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct SubmitRatingRequest: Codable {
    var title: String?
    var description: String?
    var rating: Float?
    var tripId: String?
}
