//
//  GetCabDetailsModel.swift
//  Ride
//
//  Created by XintMac on 05/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct GetCabDetailResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: GetCabDetailData?
}

struct GetCabDetailData: Codable {
    var id: String?
    var createdAt: String?
    var updatedAt: String?
    var name: String?
    var fuel_type: String?
    var seating_capacity: Int?
    var cylinder: Int?
    var displacement: String?
    var nameArabic: String?
    var description: String?
    var descriptionArabic: String?
    var categoryIcon: String?
   // var details: String?
}

