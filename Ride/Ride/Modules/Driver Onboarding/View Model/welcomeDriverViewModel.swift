//
//  welcomeDriverViewModel.swift
//  Ride
//
//  Created by XintMac on 01/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class WelcomeDriverViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponse: Combine<EmptyRequest> = Combine(EmptyRequest())
}

// MARK: - API Call
extension WelcomeDriverViewModel {

    final func welcomeDriver() {
        isLoading.value = true
        
        WelcomeDriverAPI.shared.welcomeDriver()
            .done { [weak self] (res) in
//                if res.statusCode == 200  {
//                    //self?.apiResponse.value = res
//                } else {
//                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
//                }
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

struct WelcomeDriverAPI {
    static let shared = WelcomeDriverAPI()

    func welcomeDriver() -> Promise<EmptyRequest> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.driverWelcome, requestParams: request, method: "GET") { (response: Swift.Result<EmptyRequest, RideError>) in
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

