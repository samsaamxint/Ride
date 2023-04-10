//
//  TripsModel.swift
//  Ride
//
//  Created by XintMac on 07/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
struct TripsResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : Trips?
}

struct Trips : Codable{
    var trips : [TripsDetails]?
}

struct TripsDetails : Codable{
    var id : String?
    var status : TripStatus?
    var riderId: String?
    var driverId: String?
    var tripDistance: Double?
    var cabId: String?
    var tripType: Int?
    var riderReviewId: String?
    var driverReviewId: String?
    var transactionStatus: Int?
    var riderAmount: Double?
    var driverAmount: Double?
    var motAmount: Double?
    var tripStartedAt: String?
    var tripFinishedAt: String?
    var rider: CustomUser?
    var driver: CustomUser?
    var images: [TripImage]?
    var cab: CustomCabType?
    var riderReview: ReviewObject?
    @FormattedDate var createdAt: String?
}

struct CustomUser: Codable {
    var firstName: String?
    var lastName: String?
    var arabicFirstName: String?
    var arabicLastName: String?
    var mobileNo: String?
    var profileImage: String?
    var name: String?
    var arabicName: String?
}

struct TripImage: Codable {
    let url: String?
    let imageType: Int?
    let imageBy: Int?
}

struct CustomCabType: Codable {
    var costPerKm: Double?
    var name: String?
    var nameArabic: String?
    var imageUrl: String?
    var waitChargePerMin: Double?
}

struct ReviewObject: Codable {
    var id: String?
    var createdAt: String?
    var updatedAt: String?
    var externalIdFor: String?
    var externalIdBy: String?
    var externalType: Int?
    @CovertedRating var rating: String?
    var title: String?
    var description: String?
}
