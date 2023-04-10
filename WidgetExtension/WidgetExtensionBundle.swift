//
//  WidgetExtensionBundle.swift
//  WidgetExtension
//
//  Created by Samsaam Zohaib on 17/02/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct PizzaDeliveryAttributes: ActivityAttributes {
    public typealias PizzaDeliveryStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var driverName: String
        var estimatedDeliveryTime: ClosedRange<Date>
    }

    var numberOfPizzas: Int
    var totalAmount: String
}

struct PizzaAdAttributes: ActivityAttributes {
    public typealias PizzaAdStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var adName: String
        var showTime: Date
    }
    var discount: String
}
