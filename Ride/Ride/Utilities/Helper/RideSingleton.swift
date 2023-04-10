//
//  RideSingleton.swift
//  Ride
//
//  Created by XintMac on 12/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class RideSingleton{
    static let shared = RideSingleton()
    var tripDetailObject : TripDetailResponse?
    var userBalance : Double?
    var subscriptionStatusChanged: Bool = false
    var heatMaplocaionPoints : CLLocation?
}
