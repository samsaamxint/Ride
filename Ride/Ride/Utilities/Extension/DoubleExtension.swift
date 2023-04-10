//
//  DoubleExtension.swift
//  Ride
//
//  Created by Ali Zaib on 18/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//
import Foundation

extension Double {
    func getCorrectTime() -> String{
        let myTimeStamp = Int((self) / 1000)
        let dateFromServer = Date(timeIntervalSince1970:  Double(myTimeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        let timeString = dateFormatter.string(from: dateFromServer)
        return timeString
    }
}
