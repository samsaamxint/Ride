//
//  RideLoginRequest.swift
//  Ride
//
//  Created by Mac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct EnterMobileRequest: Codable {
    var mobileNo: String?
    //let test: String?
    var reason : String?
    
//    enum CodingKeys: String, CodingKey {
//        case mobileNo = "mobileNo"
//        //case test = "test"
//        case reason = "reason"
//    }
//    
//    init(mobileNumber: String , reason : String) {
//        self.mobileNo = mobileNumber
//        self.reason = reason
////#if Dev
////        self.test = "1"
////#else
////        self.test = "0"
////#endif
//    }
}

struct VerifyOTPRequest: Codable {
    var mobile_number : String?
    var otp : String?
    var tId : String?
    var reason : String?
    var userId : String?
    var licExpiry : String?

    enum CodingKeys: String, CodingKey {
        case mobile_number = "mobileNo"
        case otp = "otp"
        case reason = "reason"
        case tId = "tId"
        case userId = "userId"
        case licExpiry = "licExpiry"
    }
}
