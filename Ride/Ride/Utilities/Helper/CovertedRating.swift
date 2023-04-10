//
//  CovertedRating.swift
//  Ride
//
//  Created by Mac on 12/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

@propertyWrapper
struct CovertedRating: Equatable, Codable {
        
    var tempRating: Float?
    var wrappedValue: String? {
        get {
            if let rating = tempRating{
                switch rating {
                case 1...1.9: return "Poor".localizedString()
                case 2...2.9: return "Bad".localizedString()
                case 3...3.9: return "Average".localizedString()
                case 4...4.9: return "Good".localizedString()
                case 5: return "Excellent".localizedString()
                default:
                    return ""
                }
            }
            return ""
        }
    }
    
    init(from decoder: Decoder) throws {
        let contaner = try decoder.singleValueContainer()
        
        tempRating = try contaner.decode(Float.self)
    }
}
