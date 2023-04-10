//
//  InvoiceModel.swift
//  Ride
//
//  Created by Mac on 28/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct invoiceResponse : Codable{
    var statusCode : Int?
    var data : invoiceData?
}

struct invoiceData : Codable{
    var id : String?
    var packageName : String?
    var packageDescription : String?
    var planType : Int?
    var basePrice : Double?
    var finalPrice : Double?
    var status : Bool?
    var taxPercentage : String?
    var cardFeePercentage : String?
    var cardFee : Double?
    var taxAmount : Double?
}
