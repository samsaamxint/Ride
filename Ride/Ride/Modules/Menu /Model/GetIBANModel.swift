//
//  GetIBANModel.swift
//  Ride
//
//  Created by Ali Zaib on 30/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct GetIBANResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : GetIBANData?
}

struct GetIBANData : Codable{
    var bic : String?
    var fax : String?
    var zip : String?
    var bank : String?
    var city : String?
    var phone : String?
    var account : String?
    var address : String?
    var country : String?
    var bank_code : String?
    var branch_code : String?
    var country_iso : String?
    var iban : String?
}

