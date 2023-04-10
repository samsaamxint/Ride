//
//  TopUpModel.swift
//  Ride
//
//  Created by Ali Zaib on 28/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct TopUpRequest : Codable{
    var name : String?
    var email : String?
    var accountid : String?
    var street1 : String?
    var city : String?
    var state : String?
    var country : String?
    var zip : String?
    var amount : String?
    var fee : String?
    var tax : String?
    var cart_id : String?
    var callbackurl : String?
}

struct TopUpResponse : Codable{
    var success : Bool?
    var errors : [String]?
    var current_timestamp : String?
    var message : String?
    var data : [TopUpData]?
}

struct TopUpData : Codable{
    var status : Bool?
    var data : TopUpObject?
}

struct TopUpObject : Codable{
    var tran_ref : String?
    var tran_type : String?
    var cart_id : String?
    var cart_description : String?
    var cart_currency : String?
    var cart_amount : String?
    var callback : String?
    var `return` : String?
    var redirect_url : String?
    var customer_details : TopUpCustomerDetail?
    var shipping_details : TopUpShippingDetails?
    var serviceId : Int?
    var profileId : Int?
    var merchantId : Int?
    var trace : String?
}

struct TopUpCustomerDetail : Codable{
    var name : String
    var email : String
    var street1 : String
    var city : String
    var state : String
    var country : String
    var zip : String
    var ip : String
}

struct TopUpShippingDetails : Codable{
    var name : String
    var email : String
    var street1 : String
    var city : String
    var state : String
    var country : String
    var zip : String
}
