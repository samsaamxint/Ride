//
//  UserDefaults.swift
//  Ride
//
//  Created by XintMac on 12/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else{ return defaultValue}
            
            do{
                let value = try JSONDecoder().decode(T.self, from: data)
                return value
            }catch let error{
                print(error.localizedDescription)
                return defaultValue
            }
        }
        set {
            do{
                let encodedData = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encodedData, forKey: key)
                UserDefaults.standard.synchronize()
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
}

struct UserDefaultsConfig {
   // @UserDefault("isRider", defaultValue: false)
   // static var isRider: Bool
    @UserDefault("appVersion", defaultValue: nil)
    static var appVersion: String?
    
    @UserDefault("tripId", defaultValue: nil)
    static var tripId: String?
    @UserDefault("waslRejectionStatus", defaultValue: false)
    static var waslRejectionStatus: Bool?
    
    @UserDefault("isDriver", defaultValue: false)
    static var isDriver: Bool
    
    @UserDefault("isUserLoggedIn", defaultValue: false)
    static var isUserLoggedIn: Bool
    
    @UserDefault("rideCount", defaultValue: 0)
    static var rideCount: Int
    
    @UserDefault("isRiderKYCRequired", defaultValue: true)
    static var isRiderKYCRequired: Bool
    
    @UserDefault("sessionID", defaultValue: "")
    static var sessionID : String
    
    @UserDefault("subscriptionId", defaultValue: "")
    static var subscriptionId : String
    
    @UserDefault("carSequenceNo", defaultValue: "")
    static var carSequenceNo : String
    
    @UserDefault("carPlateNo", defaultValue: "")
    static var carPlateNo : String
    
    @UserDefault("cab", defaultValue: "")
    static var cab : String
    
    @UserDefault("carLicenceType", defaultValue: nil)
    static var carLicenceType : Int?
    
    @UserDefault("user", defaultValue: nil)
    static var user: User?
    
    @UserDefault("cards", defaultValue: [])
    static var cards: [CardItem]
    
    @UserDefault("userBalance", defaultValue: "")
    static var userBalance : String
    
    @UserDefault("notificationStatus", defaultValue: true)
    static var notificationStatus: Bool
}
