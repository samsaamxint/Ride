//
//  ConfigurationRequest.swift
//  Ride
//
//  Created by Mac on 25/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct UpdateCustomerRequest: Codable {
    var deviceId: String?
    var deviceToken: String?
    var deviceName: String?
    var latitude: Double?
    var longitude: Double?
    var email: String?
    var mobileNo: String?
    var profileImage : String?
    var prefferedLanguage : String?
}
