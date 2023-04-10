//
//  AddBalanceModel.swift
//  Ride
//
//  Created by Ali Zaib on 25/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct AddBalanceRequest: Codable {
    var balance: Int?
}

struct AddBalanceHostedRequest: Codable {
    var amount: Int?
}

struct ChangeCardStatus: Codable {
    var customerId: String?
    var card: String?
}
struct AddBalanceRequestNew: Codable {
    var amount: Int?
    var name, email, country, street, city, ip, phone: String?
    var applePayToken : ApplePayToken?
    
}



struct ApplePayToken : Codable {
    var paymentMethod : PaymentMethod?
    var transactionIdentifier : String?
    var paymentData : PaymentData?
    
}

struct PaymentData : Codable {
    let data : String?
    let signature : String?
    let header : Header?
    let version : String?
}
struct Header : Codable {
    let publicKeyHash : String?
    let ephemeralPublicKey : String?
    let transactionId : String?
}
struct PaymentMethod : Codable {
    var network : String?
    var type : String?
    var displayName : String?
    
}
