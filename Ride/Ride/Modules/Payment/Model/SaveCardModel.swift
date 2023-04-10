//
//  SaveCardModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

//request
struct addCardRequest : Codable{
    var name : String?
    var company : String?
    var card_number : Int?
    var exp_date : String?
    var cvv : Int?
}

//response

struct addCardResponse : Codable{
    var code : Int?
    var message : String?
    var data : addCardData?
}

struct addCardData : Codable{
    var Summary : String?
}


struct ChangeCardStatusResp: Codable {
    var status: String?
}
