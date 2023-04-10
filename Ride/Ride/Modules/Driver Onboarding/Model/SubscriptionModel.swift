//
//  SubscriptionModel.swift
//  Ride
//
//  Created by Mac on 01/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct PurchaseSubscriptionResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: PurchaseSubscriptionData?
}

struct PurchaseSubscriptionData: Codable {
    var id: String?
}

struct PurchaseSubscriptionRes: Codable {
    var statusCode: Int?
    var message: String?
    var data: SubscriptionPurchaseData?
}

struct SubscriptionPurchaseData: Codable {
    var redirect_url: String?
}

struct PurchaseSubscriptionRequest: Codable {
    var promoCode: String?
    var method: String?
}

struct UpdateSubscriptionReq: Codable {
    var subscriptionId: String
}
