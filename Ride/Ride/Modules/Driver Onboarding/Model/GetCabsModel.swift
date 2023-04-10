//
//  GetCabsModel.swift
//  Ride
//
//  Created by XintMac on 04/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct GetCabsResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: [GetCabsData]?
}

struct GetCabsData: Codable {
    var id: String?
    var createdAt: String?
    var updatedAt: String?
    var name: String?
    var nameArabic: String?
    var description: String?
    var descriptionArabic: String?
    var categoryIcon: String?
}

