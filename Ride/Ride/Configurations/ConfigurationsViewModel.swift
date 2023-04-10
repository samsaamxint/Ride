//
//  ConfigurationsViewModel.swift
//  Ride
//
//  Created by Mac on 25/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol FirebaseConfigurations {
    func updateCustomer(deviceId: String?,
                        deviceToken: String?,
                        deviceName: String?,
                        latitude: Double?,
                        longitude: Double?,
                        email : String?,
                        mobileNo : String?,
                        profileImage : String?,
                        prefferedLanguage: String?
    )
}

class ConfigurationsViewModel: FirebaseConfigurations {
        
    final func updateCustomer(deviceId: String?, deviceToken: String?, deviceName: String?, latitude: Double?, longitude: Double? , email : String?,mobileNo : String?,profileImage : String?, prefferedLanguage: String?) {
        ConfigurationsAPI.shared.updateCustomer(deviceId: deviceId,
                                                deviceToken: deviceToken,
                                                deviceName: deviceName,
                                                latitude: latitude,
                                                longitude: longitude, email: email, mobileNo : mobileNo,profileImage :profileImage, prefferedLanguage: prefferedLanguage)
        .done { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 {
                
            }
        }
        .catch { [weak self] (error) in
            
        }
    }
}

class ConfigurationsAPI {
    
    static let shared = ConfigurationsAPI()
    
    func updateCustomer(deviceId: String?, deviceToken: String?, deviceName: String?, latitude: Double?, longitude: Double? , email : String?,mobileNo : String?, profileImage : String?, prefferedLanguage: String?) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = UpdateCustomerRequest(deviceId: deviceId,
                                                deviceToken: deviceToken,
                                                deviceName: deviceName,
                                                latitude: latitude,
                                                longitude: longitude,
                                                email: email,
                                                mobileNo: mobileNo,
                                                profileImage: profileImage,
                                                prefferedLanguage: prefferedLanguage)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.updateCustomer, requestParams: request, method: "POST") { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
