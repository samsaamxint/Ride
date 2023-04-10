//
//  purchaseSubscriptionModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
//request
struct purchaseSubcriptionRequest : Codable{
    var amount : Int?
    var card_id : Int?
    var payment_method : String?
}

//response

struct purchaseSubcriptionResponse : Codable{
    var code : Int?
    var message : String?
    var data : addCardData?
}

struct purchaseSubcriptionData : Codable{
    var Summary : String?
}
