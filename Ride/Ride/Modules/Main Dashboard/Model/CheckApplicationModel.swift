//
//  CheckApplicationModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

//response
struct CheckApplicationResponse : Codable{
    var code : Int?
    var message : String?
    var data : CheckApplicationData?
}

struct CheckApplicationData : Codable{
    var isApproved : Bool?
}
