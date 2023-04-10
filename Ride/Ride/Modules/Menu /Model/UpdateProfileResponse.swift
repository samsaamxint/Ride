//
//  UpdateProfileResponse.swift
//  Ride
//
//  Created by Ali Zaib on 07/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import Foundation

struct UpdateProfileResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : User?
}

struct UpdateProfileData : Codable{
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
    var totalEarned : Int?
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
}


//["data": {
//    activationDate = "<null>";
//    additionalInfo = "<null>";
//    address1 = "<null>";
//    address2 = "<null>";
//    arabicFirstName = "<null>";
//    arabicFullName = "";
//    arabicLastName = "<null>";
//    clientOs = "<null>";
//    createdAt = "2022-12-28T11:43:39.567Z";
//    creationDate = "<null>";
//    dateOfBirth = "<null>";
//    deviceToken = "cCwHIOwKjE4shIf5lQs77t:APA91bGDbQoSRpwwReO2C16SnIdeqSXUcfvtZs1s5OzqZiaRBJLEPjGMMDqVev4AoyjLSzjUZ1HLpUBorenzlTPcdQAJZp4gtT-FJWaHGwTWVvTGbnKiQAb2_gq-4UDxOOp3VvksYekW";
//    driverId = "<null>";
//    emailId = "test@Fmaul.com";
//    firstName = Guest;
//    fullName = "Guest User";
//    gender = U;
//    id = "a348b02a-d86b-4620-acc7-d0f0214b6950";
//    idNumber = 0;
//    isKycRequired = 0;
//    isRider = 1;
//    kycStatus = 0;
//    lastName = User;
//    latitude = "31.419304";
//    longitude = "74.21632200000001";
//    mobileNo = 966545557782;
//    modificationDate = "<null>";
//    prefferedLanguage = "<null>";
//    profileImage = "<null>";
//    ridesCancelled = 0;
//    totalEarned = 0;
//    totalRides = 0;
//    totalSpent = 0;
//    totalTrips = 0;
//    tripsCancelled = 0;
//    tripsDeclined = 0;
//    upcomingRides = 0;
//    updatedAt = "2023-01-07T14:13:56.000Z";
//    userId = 966113113965;
//    userStatus = A;
//    userType = 1;
//}, "statusCode": 200]
