//
//  DriverRequest.swift
//  Ride
//
//  Created by Mac on 16/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct DriverRequest: Codable {
    let mobileNumber, fullName, idNumber, dob, driverID, carPlateNumber, carSequenceNumber : String?
    let type: Int

    enum CodingKeys: String, CodingKey {
        case mobileNumber = "mobile_number"
        case fullName = "full_name"
        case idNumber = "id_number"
        case dob = "dob"
        case driverID = "driver_id"
        case carPlateNumber = "car_plate_number"
        case carSequenceNumber = "car_sequence_number"
        case type = "type"
    }
    
    
    init(mobileNumber: String?, fullName: String? = nil, idNumber: String? = nil, dob: String? = nil, driverID: String? = nil, carPlateNumber: String? = nil, carSequenceNumber: String? = nil, type: Int) {
        self.mobileNumber = mobileNumber
        self.fullName = fullName
        self.idNumber = idNumber
        self.dob = dob
        self.driverID = driverID
        self.carPlateNumber = carPlateNumber
        self.carSequenceNumber = carSequenceNumber
        self.type = type
    }

}
