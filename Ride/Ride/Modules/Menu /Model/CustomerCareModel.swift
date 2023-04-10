//
//  CustomerCareModel.swift
//  Ride
//
//  Created by Mac on 06/02/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import Foundation

struct GetCustomerCareResponse : Codable {
    var statusCode : Int?
   var message : String?
    var data : CustomerCareData?
}
struct customerData : Codable{
    var data : CustomerCareData?
}
struct CustomerCareData : Codable {
    var id : String?
    var name : String?
    var value : String?
    var subCategory : Int?
    var description : String?
}
