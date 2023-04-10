//
//  SubscriptionRespose.swift
//  Ride
//
//  Created by Mac on 03/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

// Request Model
struct GetSubscrption: Codable {
    var page: Int
    var limit: Int
}
struct GetNotification: Codable {
    var page: String
    var limit: String
}


// Response Model
enum SubscriptionStatus: Int, Codable {
    case INACTIVE = 0
    case ACTIVE = 1
    case OVERDUE = 2
    case EXPIRED = 3
    case CANCEL = 4
    case unknown
}

struct SubscriptionResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: [SubscriptionItem]?
}

struct SubscriptionItem: Codable {
    var id: String?
    var createdAt: String?
    var updatedAt: String?
    var userId: String?
    var userType: Int?
    var subscriptionId: String?
    var subscriptionType: Int?
    var subscriptionAmount: Double?
    var autoRenewal: Bool?
    var paidAmount: Double?
    var dueAmount: Double?
    var startDate: String?
    var endDate: String?
    var dueDate: String?
    var status: SubscriptionStatus?
}
