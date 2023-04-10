//
//  DriverTripCompleted.swift
//  Ride
//
//  Created by XintMac on 13/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class DriverTripCompletedViewModel{
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var tripCompletedResponse: Combine<CommonResponse> = Combine(CommonResponse())
}

extension DriverTripCompletedViewModel {
    final func tripCompleted(id : String , address : String , latitude : Double , longitude : Double) {
        isLoading.value = true
        
        DriverTripCompletedResponseAPI.shared.tripCompleted(id : id , address: address, latitude: latitude, longitude: longitude)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.tripCompletedResponse.value = res
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

struct DriverTripCompletedResponseAPI {
    
    static let shared = DriverTripCompletedResponseAPI()
    
    func tripCompleted(id : String , address : String , latitude : Double , longitude : Double)-> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = TripLocationData.init(address: address, latitude: latitude, longitude: longitude)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.driver_completed + "\(id)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>) in
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
