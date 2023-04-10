//
//  SelectedPlanSummaryModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

//request
struct SelectedPlanSummaryRequest : Codable{
    var  id : Int?
    
    internal init( id : Int? = nil) {
        self.id = id
    }
}

//response
struct SelectedPlanSummaryResponse : Codable{
    var code : Int?
    var message : String?
    var data : [SelectedPlanSummaryData]?
}

struct SelectedPlanSummaryData : Codable{
    var key : String?
}

