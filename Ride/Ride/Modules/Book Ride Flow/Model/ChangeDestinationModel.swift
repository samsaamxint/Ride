//
//  ChangeDestinationModel.swift
//  Ride
//
//  Created by Ali Zaib on 31/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct ChangeDestinationRequest : Codable{
    var address : String?
    var cityNameInArabic : String?
    var latitude : Double?
    var longitude : Double?
}
