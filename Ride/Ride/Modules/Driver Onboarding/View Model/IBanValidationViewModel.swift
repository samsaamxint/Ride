//
//  IBanValidationViewModel.swift
//  Ride
//
//  Created by Ali Zaib on 28/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol IbanValidationProtocol {
    func validateIban(Iban : String)
}

class IbanValidationViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<iBanValidateResponse> = Combine(iBanValidateResponse())
}


extension IbanValidationViewModel: IbanValidationProtocol {
    func validateIban(Iban : String) {
        IbanValidationAPI.shared.validateIban(Iban : Iban)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.apiResponseData.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
                    
                }
            }
            .catch { [weak self] (error) in
                let myError = error as? RideError
                switch myError {
                case .errorWithCode(let message, let code):
                    self?.messageWithCode.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.messageWithCode.value = ErrorResponseWithCode(message: error.localizedDescription)
                }
            }
            .finally { [weak self] in
            }
    }
}



class IbanValidationAPI {
    static let shared = IbanValidationAPI()

    func validateIban(Iban : String) -> Promise<iBanValidateResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.validateIban + Iban, requestParams: request, method: "GET") { (response: Swift.Result<iBanValidateResponse, RideError>) in
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
