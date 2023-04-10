//
//  TermsResponse.swift
//  Ride
//
//  Created by Ali Zaib on 07/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import Foundation

struct GetTermsConditionResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : termsData?
}

struct termsData : Codable{
    var data : [termsArray]?
}

struct termsArray : Codable{
    var id : String?
    var language : String?
    var title : String?
    var order : Int?
    var description : String?
    var code : String?
}

