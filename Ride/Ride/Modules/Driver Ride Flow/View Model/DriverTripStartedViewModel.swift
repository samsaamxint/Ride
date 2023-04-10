//
//  DriverTripStartedViewModel.swift
//  Ride
//
//  Created by XintMac on 13/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class DriverTripStartedViewModel{
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var tripStartedResponse: Combine<CommonResponse> = Combine(CommonResponse())
}

extension DriverTripStartedViewModel {
    final func tripStarted(id : String , OTP : String) {
        isLoading.value = true
        
        DriverTripStartedResponseAPI.shared.tripStarted(id: id, tripOTP: OTP)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.tripStartedResponse.value = res
                } else {
                    self?.apiResponseMessage.value = AlertMessages.somethingwrong
                }
            }
            .catch { [weak self] (error) in
                let myError = error as? RideError
                switch myError {
                case .otherError(let message):
                    self?.apiResponseMessage.value = message
                case .errorWithCode(let message, _):
                    self?.apiResponseMessage.value = message
                default:
                    self?.apiResponseMessage.value = error.localizedDescription
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
    
    
    
}

struct DriverTripStartedResponseAPI {
    
    static let shared = DriverTripStartedResponseAPI()
    
    func tripStarted(id : String , tripOTP : String) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = DriverTripStartedRequest(tripOtp: Int(tripOTP))
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.driver_trip_started + "\(id)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>) in
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
