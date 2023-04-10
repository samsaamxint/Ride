//
//  ChangeDestinationViewModel.swift
//  Ride
//
//  Created by Ali Zaib on 31/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit


protocol ChangeDestinationProtocol {
    func changeDestination(tripId : String ,address: String, cityNameInArabic: String, latitude: Double, longitude: Double)
}

final class ChangeDestinationViewModel{
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var changeDestinationResponse: Combine<CommonResponse> = Combine(CommonResponse())
}

extension ChangeDestinationViewModel: ChangeDestinationProtocol {
    
    final func changeDestination(tripId : String ,address: String, cityNameInArabic: String, latitude: Double, longitude: Double) {
        isLoading.value = true
        
        ChangeDestinationViewModelAPI.shared.changeDestination(tripId: tripId, address: address, cityNameInArabic: cityNameInArabic, latitude: latitude, longitude: longitude)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.changeDestinationResponse.value = res
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

struct ChangeDestinationViewModelAPI {
    
    static let shared = ChangeDestinationViewModelAPI()
    
    func changeDestination(tripId : String ,address: String, cityNameInArabic: String, latitude: Double, longitude: Double) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = ChangeDestinationRequest.init(address: address, cityNameInArabic: cityNameInArabic, latitude: latitude, longitude: longitude)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.changeDestination + "\(tripId)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>)  in
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
