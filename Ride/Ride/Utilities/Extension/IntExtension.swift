//
//  IntExtension.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

extension Int {
    func secondsToHoursMinutesSeconds() -> (String, String, String) {
        let hour = self / 3600
        let minute = (self % 3600) / 60
        let second = (self % 3600) % 60
        return (String(format: "%02d", hour), String(format: "%02d", minute), String(format: "%02d", second))
    }
    
    func times(f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
    func times( f: @autoclosure () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
}

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}


