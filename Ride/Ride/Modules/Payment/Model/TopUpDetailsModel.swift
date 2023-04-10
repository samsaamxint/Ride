//
//  TopUpDetailsModel.swift
//  Ride
//
//  Created by Ali Zaib on 14/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct TopUpDetailsResponse : Codable{
    var statusCode : Int?
    var data :  TopUpDetailsTransaction?
}

struct TopUpDetailsTransaction: Codable {
    var transactions: [TopUpDetailsData]?
}

struct TopUpDetailsData : Codable{
    var id : String?
    var createdAt : String?
    var updatedAt : String?
    var receiverId : String?
    var creditAmount : Double?
    var receiverTax : Double?
    var receiverFee : Double?
    var transactionId : String?
    var status : PaymentStatus?
    var transactionAmount: Double?
    var eWalletAPIResponse: String?
}

enum PaymentStatus: Int, Codable {
    case PENDING = 1
    case COMPLETED = 2
    case CANCELLED = 3
    case REFUNDED = 4
    case FAILED = 5
}

struct TopupHistoryRequest: Codable {
    var filters: TopupHistoryFilterReq?
}

struct TopupHistoryFilterReq: Codable {
    var entityType: String?
}



// MARK: - Welcome
struct eWalletAPI: Codable {
    let tranRef, tranType, cartID, cartDescription: String
    let cartCurrency, cartAmount, tranCurrency, tranTotal: String
    let customerDetails: CustomerDetails
    let paymentResult: PaymentResult
    let paymentInfo: PaymentInfo
    let serviceID, profileID, merchantID: Int
    let trace: String

    enum CodingKeys: String, CodingKey {
        case tranRef = "tran_ref"
        case tranType = "tran_type"
        case cartID = "cart_id"
        case cartDescription = "cart_description"
        case cartCurrency = "cart_currency"
        case cartAmount = "cart_amount"
        case tranCurrency = "tran_currency"
        case tranTotal = "tran_total"
        case customerDetails = "customer_details"
        case paymentResult = "payment_result"
        case paymentInfo = "payment_info"
        case serviceID = "serviceId"
        case profileID = "profileId"
        case merchantID = "merchantId"
        case trace
    }
}

// MARK: - CustomerDetails
struct CustomerDetails: Codable {
    let name, email, phone, street1: String
    let city, state, country, zip: String
    let ip: String
}

// MARK: - PaymentInfo
struct PaymentInfo: Codable {
    let paymentMethod, cardScheme, paymentDescription: String
    let expiryMonth, expiryYear: Int

    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
        case cardScheme = "card_scheme"
        case paymentDescription = "payment_description"
        case expiryMonth, expiryYear
    }
}

// MARK: - PaymentResult
struct PaymentResult: Codable {
    let responseStatus, responseCode, responseMessage, acquirerMessage: String
    let acquirerRrn: String
    let transactionTime: Date

    enum CodingKeys: String, CodingKey {
        case responseStatus = "response_status"
        case responseCode = "response_code"
        case responseMessage = "response_message"
        case acquirerMessage = "acquirer_message"
        case acquirerRrn = "acquirer_rrn"
        case transactionTime = "transaction_time"
    }
}
