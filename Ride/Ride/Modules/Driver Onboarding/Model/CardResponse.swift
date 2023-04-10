//
//  CardResponse.swift
//  Ride
//
//  Created by Mac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct CardListResponse: Codable {
    var code: Int?
    var message: String?
    var data: [CardItem]?
}

struct CardItem: Codable {
    var card_id: Int?
    var name: String?
    var company: String?
    var card_number: String?
}
