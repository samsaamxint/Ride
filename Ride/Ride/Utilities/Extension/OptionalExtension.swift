//
//  OptionalExtension.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

extension Optional {
    var isSome: Bool {
        self != nil
    }
    
    var isNone: Bool {
        self == nil
    }
}
