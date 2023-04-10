//
//  Cars.swift
//  Ride
//
//  Created by Mac on 07/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct CarListResponse: Codable {
    var statusCode: Int?
    var data: CarListData?
}

struct CarListData: Codable {
    var cabs: [CarItem]?
    var estimate: Estimate?
}

struct CarItem: Codable ,Equatable{
    var id: String?
    var createdAt: String?
    var updatedAt: String?
    var name: String?
    var nameArabic: String?
    var description: String?
    var descriptionArabic: String?
    var noOfSeats: Int?
    var order: Int?
    var passengerEstimatedTimeArrival: Int?
    var passengerDriverMatching: Int?
    var passengerBaseFare: Double?
    var passengerBaseDistance: Int?
    var passengerBaseTime: Int?
    var passengerCostPerMin: Double?
    var passengerCostPerKm: Double?
    var waitChargePerMin: Double?
    var passengerCancellationCharge: Int?
    var passengerDriverDistribution: Int?
    var shareEstimatedTimeArrival: Int?
    var shareDriverMatching: Int?
    var shareBaseFare: Int?
    var shareBaseDistance: Int?
    var shareBaseTime: Int?
    var shareCostPerMin: Int?
    var shareCancellationCharge: Int?
    var shareDriverDistribution: Int?
    var shareMaxThreshold: Int?
    var carpoolEstimatedTimeArrival: Int?
    var carpoolDriverMatching: Int?
    var carpoolCostPerKmMin: Int?
    var carpoolCostPerKmMax: Int?
    var carpoolUserCancellationCharge: Int?
    var carpoolDriverCancellationCharge: Int?
    var carpoolDriverDistribution: Int?
    var categoryIcon: String?
    var status: Bool?
    var estimateCost: Double?
    var discountCost : Double?
}

struct Estimate: Codable {
    var distance: Double?
    var time: Double?
    var formattedDistance: String?
    var formattedTime: String?
}
