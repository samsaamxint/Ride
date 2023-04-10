//
//  NotificationResponse.swift
//  Ride
//
//  Created by Ali Zaib on 07/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import Foundation

struct GetNotificationResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : [GetNotificationData]?
}

struct GetNotificationData : Codable{
    var id : String?
    var title : String?
    var message : String?
    var sentTime : String?
    var isRead : Int?
    var type : String?
}

