//
//  GetCarRequest.swift
//  Ride
//
//  Created by Mac on 07/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct GetCarRequest: Codable {
    let originAddressLng, originAddressLat, destinationAddressLat, destinationAddressLng: String
   
    init(originAddressLng: String, originAddressLat: String, destinationAddressLat: String, destinationAddressLng: String) {
        self.originAddressLng = originAddressLng
        self.originAddressLat = originAddressLat
        self.destinationAddressLat = destinationAddressLat
        self.destinationAddressLng = destinationAddressLng
    }
}
