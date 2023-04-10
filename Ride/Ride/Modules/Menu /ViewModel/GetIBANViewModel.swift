//
//  GetIBANViewModel.swift
//  Ride
//
//  Created by Ali Zaib on 30/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol GetIBANProtocol {
    func getIBAN()
}

class GetIBANViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var getIBANRes: Combine<GetIBANResponse> = Combine(GetIBANResponse())
}

extension GetIBANViewModel: GetIBANProtocol {
    
    func getIBAN() {
        isLoading.value = true
        GetIBANAPI.shared.getIBAN()
            .done { [weak self] (res) in
                if res.statusCode == 200 {
                    self?.getIBANRes.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: 0)
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

//API
struct GetIBANAPI {
    static let shared = GetIBANAPI()
    
    func getIBAN() -> Promise<GetIBANResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getIban, requestParams: request, method: "GET") { (response: Swift.Result<GetIBANResponse, RideError>) in
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


