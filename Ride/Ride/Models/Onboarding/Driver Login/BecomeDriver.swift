//
//  BecomeDriver.swift
//  Ride
//
//  Created by Mac on 20/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
struct BecomeCaptainResponse: Codable {
    var data: BecomeCaptainData?
    var message: String?
    var statusCode: Int?
}

struct BecomeCaptainData: Codable {
    var id: String?
    var isWASLApproved: Int?
}
