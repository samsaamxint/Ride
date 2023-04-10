//
//  NSNotificationExtension.swift
//  Ride
//
//  Created by Mac on 08/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let toggleUserSwitchView = NSNotification.Name("com.xint.ride.toggleUserSwitchView")
    public static let showNearByCars = NSNotification.Name("com.xint.ride.showNearByCars")
    public static let tripNavigation = NSNotification.Name("com.xint.ride.tripNavigation")
    public static let switchLeftBarItem = NSNotification.Name("com.xint.ride.switchLeftBarItem")
    public static let rideCanceled = NSNotification.Name("com.xint.ride.rideCanceled")
    public static let updateLocationForDriver = NSNotification.Name("com.xint.ride.updateLocationForDriver")
    public static let updateDriverIcon = NSNotification.Name("com.xint.ride.updateDriverIcon")
}
