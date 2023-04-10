//
//  ReportProblem.swift
//  Ride
//
//  Created by Mac on 24/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct ReportProblemReq: Codable {
    var contact_no: String?
    var name: String?
    var description: String?
    var category_id: Int?
    var type : Int?
    var secret_key: String?
}

struct GetIssuesListReq: Codable {
    var contact_no: String?
    var secret_key: String?
}

struct GetIssuesResponse: Codable {
    var success: Bool?
    var message: String?
    var data: [GetIssuesData]?
}

struct GetIssuesData: Codable {
    var tickets: [IssueTicket]?
}

struct IssueTicket: Codable {
    var id: Int?
    var description: String?
    var status_id: Int?
    var category : TicketCategory?
}

struct TicketCategory: Codable {
    var company_id: Int?
    var id: Int?
    var title : String?
}

struct AddTicketRespose: Codable {
    var success: Bool?
    var message: String?
}

struct getComplaintTypes: Codable {
    var secret_key: String?
}

struct GetComplaintTypesResponse: Codable {
    var success: Bool?
    var message: String?
    var data: [ComplaintTypes]?
}

struct ComplaintTypes : Codable{
    var id : Int?
    var title : String?
    var company_id : Int?
}
