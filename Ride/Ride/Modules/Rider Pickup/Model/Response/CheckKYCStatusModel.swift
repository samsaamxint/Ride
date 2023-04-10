//
//  CheckKYCStatusModel.swift
//  Ride
//
//  Created by Ali Zaib on 29/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct CheckKYCStatusResponse : Codable{
   var statusCode : Int?
   var data : CheckKYCStatusData?
}

struct CheckKYCStatusData : Codable{
    var isKycRequired : Bool?
}
