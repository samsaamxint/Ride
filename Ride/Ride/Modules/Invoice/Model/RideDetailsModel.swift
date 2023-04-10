//
//  RideDetailsModel.swift
//  Ride
//
//  Created by Ali Zaib on 01/12/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation


struct RideDetailResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : RideDetailData?
}

struct RideDetailData : Codable{
    var trip : tripData?
}

struct tripData : Codable{
    var id : String?
    var createdAt : String?
    var tripNo : String?
    var riderId : String?
    var driverId : String?
    var tripOtp : Int?
    var tripDistance : Double?
    var tripDistanceCovered : Double?
    var cabId : String?
    var tripType : Int?
    var status : Int?
    var transactionStatus : Int?
    var zatcaQR : String?
    var promoCode : String?
    var estimatedBaseAmount : Double?
    var estimatedTripTime : Double?
    var tripTime : Double?
    var promoCodeAmount : Double?
    var riderAmount : Double?
    var driverAmount : Double?
    var baseFare : Double?
    var costPerMin : Double?
    var costPerKm : Double?
    var tripBaseAmount : Double?
    var taxAmount : Double?
    var taxPercentage : Double?
    var motAmount : Double?
    var waslFee : Double?
    var processingFee : Double?
    var waitingCharge : Double?
    var driverReachedAt : String?
    var tripStartedAt : String?
    var tripFinishedAt : String?
    var driverAssignedAt : String?
    var earningPercentage : Double?
    var totalTripDistanceAmt : Double?
    var totalTripTimeAmt : Double?
    var rider : riderData?
}

struct riderData : Codable{
    var id : String?
    var userId : String?
    var firstName : String?
    var lastName : String?
    var arabicFirstName : String?
    var arabicLastName : String?
    var mobileNo : String?
    var dateOfBirth : String?
    var profileImage : String?
    var fullName : String?
    var arabicFullName : String?
    var overallRating : Double?
    var overallReviews : Double?
}

struct RideInvoiceModel : Codable{
    var statusCode : Int?
    var message : String?
    var data : InvoicelDetailData?
}
struct InvoicelDetailData : Codable{
    var invoiceNo : String?
}


