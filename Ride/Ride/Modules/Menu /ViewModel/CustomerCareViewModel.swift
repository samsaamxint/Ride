//
//  CustomerCareViewModel.swift
//  Ride
//
//  Created by Mac on 06/02/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol CustomerCareProtocol {
    func getCustomerCareData() 
}
extension CustomerCareProtocol {
    func getCustomerCareData() { }
}

class CustomerCareViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<GetCustomerCareResponse> = Combine(GetCustomerCareResponse())
}


extension CustomerCareViewModel: CustomerCareProtocol{
    
    func getCustomerCareCondition() {
        isLoading.value = true
        CustomerCareAPI.shared.getCustomerCare()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.apiResponseData.value = res
                } else {
//                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
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

class CustomerCareAPI {
    static let shared = CustomerCareAPI()

    func getCustomerCare() -> Promise<GetCustomerCareResponse> {
        return Promise { seal in
//            let language = UserDefaults.standard.value(forKey: languageKey) as! String
            let request = EmptyRequest()
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getCustomerCare, requestParams: request, method: "GET") { (response: Swift.Result<GetCustomerCareResponse, RideError>) in
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

