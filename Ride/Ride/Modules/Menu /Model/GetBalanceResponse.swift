//
//  GetBalanceResponse.swift
//  Ride
//
//  Created by Mac on 24/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct GetBalanceResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: GetBalanceData?
}

struct GetBalanceData: Codable {
    var id: String?
    var status: String?
    var accountid: String?
    var balance: Double?
    var created_at: String?
    var updated_at: String?
    var card:  Int?
}

struct AddBalanceByClickPayRes: Codable {
    var statusCode: Int?
    var message: String?
    var data: AddBalanceByClickPayData?
}

struct AddBalanceByClickPayData: Codable {
    var redirect_url: String?
}
