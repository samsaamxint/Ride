//
//  TripResponse.swift
//  Ride
//
//  Created by Mac on 09/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

enum tripDetailsAction : String , Codable{
    case driverAccepted = "driver_accepted"
    case tripExpired = "trip_expired"
    case tripRequest = "trip_request"
    case trip_started = "trip_started"
    case trip_completed = "trip_completed"
    case rider_cancelled = "rider_cancelled"
    case driver_cancelled_before_arrived = "driver_cancelled_before_arrived"
    case driver_cancelled = "driver_cancelled"
    case no_drivers = "no_drivers"
    case rider_updated_destination = "rider_updated_destination"
}

enum TripStatus: Int, Codable {
    case PENDING = 1
    case ACCEPTED_BY_DRIVER = 2
    case REJECTED_BY_DRIVER = 3
    case CANCELLED_BY_DRIVER = 4
    case DRIVER_ARRIVED = 5
    case CANCELLED_BY_RIDER = 6
    case STARTED = 7
    case COMPLETED = 8
    case NO_DRIVER = 9
    case EXPIRED = 10
    case CANCELLED_BY_ADMIN = 11
    case BOOKING_CANCELLED = 12
    case STOP_AND_ASSIGNED = 13
    case STOP_AND_COMPLETED = 14
}

struct TripResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: TripData?
}

struct TripData: Codable {
    let id: String?
    let message: String?
}


struct TripDetailResponse : Codable {
    var data : TripDetail?
    let action : tripDetailsAction?
}

struct TimeEstimateResponse : Codable {
    var data : TimeEstimate?
}

struct TimeEstimate : Codable {
    
    var riderAmount : Double?
    var driverAmount : Double?
    var estimatedTripTime : Double?
}

struct TripDetail : Codable {
    var id : String?
    var driverId : String?
    var riderId : String?
    var tripType : Int?
    var cabType : String?
    var cabInfo : CabInfo?
    var driverInfo : DriverInfo?
    var riderInfo : RiderInfo?
    var source : TripLocationData?
    var destination : TripLocationData?
    var destinationNew : TripLocationData?
    //    let source : String?
    //    let destination : String?
    var tripDistance : Double?
    var tripDistanceCovered : Double?
    var estimatedTripTime : Double?
    var tripTime : Double?
    var tripBaseAmount : Double?
    var taxAmount : Double?
    var taxPercentage : Double?
    var waitingCharge : Double?
    var riderAmount : Double?
    var driverAmount : Double?
    var promoCode : String?
    var promoCodeAmount : Double?
    var status : TripStatus?
    var transactionStatus : Int?
    var riderScheduledAt : String?
    var driverAssignedAt : String?
    var driverReachedAt : String?
    var tripStartedAt : String?
    var tripFinishedAt : String?
    var tripOtp : Int?
    var tripExpireTime: String?
    var currentDistance : Double?
    var currentTime : Double?
}

struct TripLocationData : Codable {
    let address : String?
    let latitude : Double?
    let longitude : Double?
}


struct DriverInfo : Codable {
    let name : String?
    let arabicName : String?
    let mobile: String?
    @CovertedRating var rating : String?
    let id: String?
    let carPlateNo: String?
    let carSequenceNo: String?
    let profileImage: String?
    let totalTrips: Int?
    var latitude : Double?
    var longitude : Double?
}

struct CabInfo : Codable {    
    let noOfSeats : Int?
    let baseFare : Double?
    let costPerMin : Double?
    let costPerKm : Double?
    let name : String?
    let description : String?
    let nameArabic : String?
    let descriptionArabic : String?
    let categoryIcon : String?
}

struct CommonResponse: Codable {
    var message: String?
    var statusCode: Int?
}

struct RiderInfo : Codable {
    let name : String?
    let arabicName : String?
    let mobile : String?
    @CovertedRating var rating : String?
    let id: String?
    let totalRides: Int?
    let profileImage: String?
    let latitude : Double?
    let longitude : Double?
}
