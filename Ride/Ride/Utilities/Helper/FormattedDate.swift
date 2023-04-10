//
//  FormattedDate.swift
//  Ride
//
//  Created by Mac on 10/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

@propertyWrapper
struct FormattedDate: Equatable, Codable {
        
    var tempDate: String
    var wrappedValue: String? {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = dateFormatter.date(from: tempDate) {
                dateFormatter.dateFormat = "dd-MM-YYYY, hh:mm a"
                return dateFormatter.string(from: date)
            }
            return tempDate
        }
    }
    
    init(from decoder: Decoder) throws {
        let contaner = try decoder.singleValueContainer()
        
        tempDate = try contaner.decode(String.self)
    }
    
    init(string: String) {
        tempDate = string
    }
}
