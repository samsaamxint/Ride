//
//  IBanValidateModel.swift
//  Ride
//
//  Created by Ali Zaib on 28/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation


struct iBanValidateRequest : Codable{
    var iban : String
}


struct iBanValidateResponse : Codable{
    var statusCode: Int?
    var message : String?
}
