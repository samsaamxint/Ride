//
//  CarSequenceResponse.swift
//  Ride
//
//  Created by XintMac on 27/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import  UIKit

class CarSequenceResponse : Codable{
    var statusCode : Int?
    var message : String?
    var data : CarSequenceData?
}

class CarSequenceData : Codable{
//    var carSequenceNo : String?
//    var majorColor : String?
//    var modelYear : Int?
//    var ownerName : String?
//    var plateNumber : Int?
//    var plateText1 : String?
//    var plateText2 : String?
//    var plateText3 : String?
//    var plateTypeCode : Int?
//    var vehicleMaker : String?
//    var vehicleModel : String?
    var id : String?
    var createdAt : String?
    var updatedAt : String?
    var carSequenceNo : String?
    var chassisNumber : String?
    var cylinders : String?
    var licenseExpiryDate : String?
    var licenseExpiryDateEnglish : String?
    var lkVehicleClass : String?
    var bodyType : String?
    var bodyTypeEnglish : String?
    var majorColor : String?
    var majorColorEnglish : String?
    var modelYear : Int?
    var ownerName : String?
    var ownerNameEnglish : String?
    var plateNumber : Int?
    var plateText1 : String?
    var plateText1English : String?
    var plateText2 : String?
    var plateText2English : String?
    var plateText3 : String?
    var plateText3English : String?
    var plateTypeCode : Int?
    var regplace : String?
    var regplaceEnglish : String?
    var vehicleCapacity : String?
    var vehicleMaker : String?
    var vehicleMakerEnglish : String?
    var vehicleModel : String?
    var vehicleModelEnglish : String?
    var createdBy : String?
    var modifiedBy : String?
    var makerIcon : String?
}

