//
//  AppVersionResponse.swift
//  Ride
//
//  Created by Ali Zaib on 14/03/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct AppVersionResponse: Codable {
    let statusCode: Int?
    let data: AppDetails?
}

// MARK: - DataClass
struct AppDetails: Codable {
    let id, name, value: String?
    let subCategory: Int?
    let description: String?
}
