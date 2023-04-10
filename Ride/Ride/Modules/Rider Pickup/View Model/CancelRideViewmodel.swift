//
//  CancelRideViewmodel.swift
//  Ride
//
//  Created by XintMac on 09/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import PromiseKit

final class CancelTripViewmodel{
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var cancelTripResponse: Combine<TripResponse> = Combine(TripResponse())
}

extension CancelTripViewmodel{
    final func cancelTrip(id : String) {
        isLoading.value = true
        
        CancelTripAPI.shared.cancelTrip(id : id)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.cancelTripResponse.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message)
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
                let myError = error as? RideError
                switch myError {
                case .errorWithCode(let message, let code):
                    self?.messageWithCode.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.messageWithCode.value = ErrorResponseWithCode(message: error.localizedDescription)
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
}

struct CancelTripAPI{
    
    static let shared = CancelTripAPI()
    
    func cancelTrip(id : String) -> Promise<TripResponse> {
        return Promise { seal in
            
            let request = CancelTripRequest.init(tripId: id)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.cancelTrip + "\(id)", requestParams: request, method: "PUT") { (response: Swift.Result<TripResponse, RideError>) in
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
