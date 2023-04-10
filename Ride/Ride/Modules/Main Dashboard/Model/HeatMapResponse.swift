//
//  HeatMapResponse.swift
//  Ride
//
//  Created by Mac on 02/12/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct ActiveUserLocationResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: [ActiveUserLocationItem]?
}

struct ActiveUserLocationItem: Codable  {
    var latitude: Double?
    var longitude: Double?
}

struct HighDemandZoneResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: HighDemandZoneItem?
}

// MARK: - DataClass
struct HighDemandZoneItem: Codable {
    var user: ActiveUserLocationItem?
    var radius: Int?
    var coordinates, adminCoordinates: [Coordinate]?
}

// MARK: - Coordinate
struct Coordinate: Codable {
    var lat, lng: Double?
}
