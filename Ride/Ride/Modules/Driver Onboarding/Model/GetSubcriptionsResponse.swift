//
//  SubcriptionsRepose.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
//
struct GetSubcriptionsResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : [GetSubcriptionsData]?
}

struct GetSubcriptionsData : Codable{
    var id : String?
    var createdAt : String?
    var updatedAt : String?
    var packageName : String?
    var packageDescription : String?
    var planType : Int?
    var basePrice : Int?
    var discountType : String?
    var discountValue : String?
    var finalPrice : Int?
    var createdBy : String?
    var isStandard : Int?
    var modifiedBy : String?
    var isDeleted : Bool?
    var status : SubscriptionStatus?
    var activeSubscribers : Int?
    var totalSubscribers : Int?
}
