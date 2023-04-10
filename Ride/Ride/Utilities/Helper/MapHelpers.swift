//
//  MapHelpers.swift
//  Ride
//
//  Created by XintMac on 12/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class RouteData: NSObject {
    var routeDistance = ""
    var routeDistanceValue = 0
    var travelTime = ""
    var travelDuration = 0
    var travelInstruction = ""
    var staticImageURL = ""
    var points = ""
    var polyLinee: GMSPolyline?
    var polyLine = [GMSPolyline]()
    var path: GMSMutablePath?
    var staticDriverImageURL = ""
    var staticRiderImageURL = ""
    
}
