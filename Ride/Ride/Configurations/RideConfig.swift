//
//  RideConfig.swift
//  Ride
//
//  Created by Mac on 22/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

public let AppName = "RiDE"
public let AppVersion = "1.0.5"
public let AppLink = "https://apps.apple.com/pk/app/ride-%D8%B1%D8%A7%D9%8A%D8%AF/id6443488537"
class RideConfigSetup {
    
    
    var envType: environmentApp = environmentApp.UAT
    
    
    enum ConfigKeys: String {
        case BASEURL = "BASE_URL"
        case SERVERNAME = "SERVER_NAME"
    }
    
    init() {
        self.setUpBuildConfigurations()
        self.setUpBaseUrl()
    }
    final fileprivate func setUpBaseUrl() {
        switch envType {
        case .dev:
            ServerUrls.RideBASE_URL = "http://150.230.54.239:3000/" //dev
            ServerUrls.BaseUrlSocket = "http://150.230.54.239:8100/" //dev
            ServerUrls.PaymentCallBackURL = "https://dev-api.ride.sa/user/clickpay-callback"
            ServerUrls.download_pdf_invoice = "http://dev-dashboard.ride.sa/trip-invoice/"
            ServerUrls.legals = "https://uat-dashboard.ride.sa/pages/"
        case .preProduction:
            ServerUrls.RideBASE_URL = "https://pre-prod-apis.ride.sa/" //pre-prod
            ServerUrls.BaseUrlSocket = "https://pre-prod-socket.ride.sa/" //pre-prod
            ServerUrls.PaymentCallBackURL = "https://pre-prod-apis.ride.sa/user/clickpay-callback" //pre-prod
            ServerUrls.download_pdf_invoice = "https://pre-prod-dashboard.ride.sa/trip-invoice/" //pre-prod
            ServerUrls.legals = "https://pre-prod-dashboard.ride.sa/pages/"
        case .UAT:
            ServerUrls.RideBASE_URL = "http://144.24.208.108:3000/" //UAT
            ServerUrls.BaseUrlSocket = "http://144.24.208.108:8100/"//UAT
            ServerUrls.PaymentCallBackURL = "https://uat-api.ride.sa/user/clickpay-callback"
            ServerUrls.download_pdf_invoice = "http://uat-dashboard.ride.sa/trip-invoice/"
            ServerUrls.legals = "https://uat-dashboard.ride.sa/pages/"
        case .Production:
            ServerUrls.RideBASE_URL = "https://ride-api.mytmdev.com/" //Prod
            ServerUrls.BaseUrlSocket = "http://prodsocket.ride.sa/" //Prod
            ServerUrls.PaymentCallBackURL = "https://ride-api.mytmdev.com/user/clickpay-callback"
            ServerUrls.download_pdf_invoice = "https://ride-api.mytmdev.com/trip-invoice/"
            ServerUrls.legals = "https://pre-prod-dashboard.ride.sa/pages/"
        }
    }
    
    final fileprivate func setUpBuildConfigurations() {
        let targetName = getValue(forKey: ConfigKeys.SERVERNAME.rawValue)
        Global.targetServer = targetName ?? ""
        
        let baseURL = getValue(forKey: ConfigKeys.BASEURL.rawValue) ?? ""
        var plistFileName = Bundle.main.infoDictionary?["TargetName"] as? String
        
        print(plistFileName)
        // Movit Urls
        ServerUrls.baseURL = baseURL
    }
    
    final fileprivate func getValue(forKey key: String) -> String? {
        return Bundle.main.infoDictionary?[key] as? String
    }
}

enum ServerUrls {
    static var baseURL = ""
    
    static var mockBaseURL = "https://8fc41050-1f91-477d-bf56-ee95ca14a3a2.mock.pstmn.io/"
    static var RideBASE_URL = ""
    //    static var RideBASE_URL = "http://144.24.208.108:3000/" //UAT
    //    static let RideBASE_URL = "http://150.230.54.239:3000/" //dev
    //      static let RideBASE_URL = "https://pre-prod-apis.ride.sa/" //pre-prod
    
    static var BaseUrlSocket = ""
    //    static var BaseUrlSocket = "http://144.24.208.108:8100/"//UAT
    //    static let BaseUrlSocket = "http://150.230.54.239:8100/" //dev
    //     static let BaseUrlSocket = "https://pre-prod-socket.ride.sa/" //pre-prod
    static var PaymentCallBackURL = ""
    //    static let PaymentCallBackURL = "https://dev-api.ride.sa/user/clickpay-callback"
    //    static var PaymentCallBackURL = "https://uat-api.ride.sa/user/clickpay-callback"
    //        static let PaymentCallBackURL = "https://pre-prod-apis.ride.sa/user/clickpay-callback" //pre-prod
    static var download_pdf_invoice = ""
    //    static let download_pdf_invoice = "http://dev-dashboard.ride.sa/trip-invoice/"
    //    static var download_pdf_invoice = "http://uat-dashboard.ride.sa/trip-invoice/"
    //    static let download_pdf_invoice = "https://pre-prod-socket.ride.sa/trip-invoice/" //pre-prod
    //
    static let BaseUrl_V2_Biller = "\(RideBASE_URL)billers/rest/v2/"
    
    static let CMS_BASE_URL = "https://cmsride.xintdev.com/api/v1/"
    
    static var legals = ""
}

enum Global {
    static  var  targetServer = ""
}
enum environmentApp: String{
    case dev
    case preProduction
    case UAT
    case Production
}

