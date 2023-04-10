//
//  LoginRes.swift
//  Ride
//
//  Created by Mac on 16/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct EnterNumberResp: Codable {
    var status: Int?
    var message: String?
    var data : EnterNumberData?

    enum CodingKeys: String, CodingKey {
        case status = "statusCode"
        case message = "message"
        case data = "data"
    }
}

struct EnterNumberData : Codable{
    var tId : String?
}

struct VerifyOTPResp: Codable {
    var statusCode: Int?
    var message : String?
    var data: VerifyOTPData?

    enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case data = "data"
        case message = "message"
    }
}

struct VerifyOTPData : Codable{
    var token: String?
    //var userID: String?
    var details : User?
}

struct RiderKYCResponse: Codable {
    var statusCode: Int?
    var message : String?
    var data: User?

    enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case data = "data"
        case message = "message"
    }
}

struct User : Codable{
    var userId : String?
    var idNumber: String?
    var firstName : String?
    var mobileNo : String?
    var dateOfBirth : String?
    var gender : String?
    var userStatus : String?
    var authStatus : String?
    var agentId : String?
    var lastName : String?
    var arabicFirstName : String?
    var arabicLastName : String?
    var emailId : String?
    var address1 : String?
    var address2 : String?
    var regionId : String?
    var pinCode : String?
    var addactivationDateress2 : String?
    var remarks : String?
    var rejectionReason : String?
    var subStatus : String?
    var creationDate : String?
    var modificationDate : String?
    var deviceId : String?
    var deviceToken : String?
    var clientOs : String?
    var prefferedLanguage : String?
    var socialId : String?
    var socialProfile : String?
    var appVersion : String?
    var deviceName : String?
    var smsEnable : String?
    var emailEnable : String?
    var notificationEnable : String?
    var nationality : String?
    var profileImage : String?
    var otherDetails : String?
    var additionalInfo : String?
    var totalRides : Int?
    var ridesCancelled : Int?
    var totalTrips : Int?
    var tripsDeclined : Int?
    var tripsCancelled : Int?
    var totalEarned : Double?
    var userType : Int?
    var driverId : String?
    var cabId : Int?
    var customerOtp : Int?
    var id : String?
    var createdAt : String?
    var updatedAt : String?
    var riderRating : Int?
    var riderReviews : Int?
    var driverRating : Int?
    var driverReviews : Int?
    var walletBalance: Double?
    var isWASLApproved: Int?
    var familyNameArabic : String?
    var lastNameEnglish : String?
}
struct UserProfile : Codable{
    var userId : String?
    var idNumber: String?
    var firstName : String?
    var mobileNo : String?
    var dateOfBirth : String?
    var gender : String?
    var userStatus : String?
    var authStatus : String?
    var agentId : String?
    var lastName : String?
    var arabicFirstName : String?
    var arabicLastName : String?
    var emailId : String?
    var address1 : String?
    var address2 : String?
    var regionId : String?
    var pinCode : String?
    var addactivationDateress2 : String?
    var remarks : String?
    var rejectionReason : String?
    var subStatus : String?
    var creationDate : String?
    var modificationDate : String?
    var deviceId : String?
    var deviceToken : String?
    var clientOs : String?
    var prefferedLanguage : String?
    var socialId : String?
    var socialProfile : String?
    var appVersion : String?
    var deviceName : String?
    var smsEnable : String?
    var emailEnable : String?
    var notificationEnable : String?
    var nationality : String?
    var profileImage : String?
    var otherDetails : String?
    var additionalInfo : String?
    var totalRides : Int?
    var ridesCancelled : Int?
    var totalTrips : Int?
    var tripsDeclined : Int?
    var tripsCancelled : Int?
    var totalEarned : Double?
    var userType : Int?
    var driverId : String?
    var cabId : Int?
    var customerOtp : Int?
    var id : idData?
    var createdAt : String?
    var updatedAt : String?
    var riderRating : Int?
    var riderReviews : Int?
    var driverRating : Int?
    var driverReviews : Int?
    var walletBalance: Double?
    var isWASLApproved: Int?
    var familyNameArabic : String?
    var lastNameEnglish : String?
}
