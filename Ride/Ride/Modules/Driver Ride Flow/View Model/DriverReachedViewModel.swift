//
//  DriverReachedViewModel.swift
//  Ride
//
//  Created by XintMac on 13/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class DriverReachedViewModel{
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var reachedResponse: Combine<CommonResponse> = Combine(CommonResponse())
}

extension DriverReachedViewModel {
    final func reachedByDriver(id : String) {
        isLoading.value = true
        
        DriverReachedResponseAPI.shared.reached(id:id)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.reachedResponse.value = res
                } else {
                    self?.apiResponseMessage.value = AlertMessages.somethingwrong
                }
            }
            .catch { [weak self] (error) in
                let myError = error as? RideError
                switch myError {
                case .otherError(let message):
                    self?.apiResponseMessage.value = message
                case .errorWithCode(let message, let code):
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

struct DriverReachedResponseAPI {
    
    static let shared = DriverReachedResponseAPI()
    
    func reached(id : String) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = DriverReachedRequest(id : id)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.driver_reached + "\(id)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>) in
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
