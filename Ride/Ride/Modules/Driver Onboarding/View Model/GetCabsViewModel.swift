//
//  GetCabsViewModel.swift
//  Ride
//
//  Created by XintMac on 04/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class GetCabsViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponse: Combine<GetCabsResponse> = Combine(GetCabsResponse())
}

// MARK: - API Call
extension GetCabsViewModel {

    final func getCabs(){
        isLoading.value = true
        
        GetCabsAPI.shared.getCabs()
            .done { [weak self] (res) in
                if res.statusCode == 200  {
                    self?.apiResponse.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
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

struct GetCabsAPI {
    static let shared = GetCabsAPI()

    func getCabs() -> Promise<GetCabsResponse> {
        return Promise { seal in

            let request = DummyRequest(request: "1")
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.getCabs, requestParams: request, method: "GET") { (response: Swift.Result<GetCabsResponse, RideError>) in
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
