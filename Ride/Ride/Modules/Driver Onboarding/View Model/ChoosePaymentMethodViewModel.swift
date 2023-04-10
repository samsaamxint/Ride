//
//  ChoosePaymentMethodViewModel.swift
//  Ride
//
//  Created by Mac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class ChoosePaymentMethodViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponse: Combine<CardListResponse> = Combine(CardListResponse())
}

// MARK: - API Call
extension ChoosePaymentMethodViewModel {

    final func getCardList(request: String) {
        isLoading.value = true
        
        ChoosePaymentMethodAPI.shared.getCardList(request: request)
            .done { [weak self] (res) in
                if res.code == 200  {
                    self?.apiResponse.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.code)
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

struct ChoosePaymentMethodAPI {
    static let shared = ChoosePaymentMethodAPI()

    func getCardList(request: String) -> Promise<CardListResponse> {
        return Promise { seal in

            let request = DummyRequest(request: request)
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.getCardsList, requestParams: request, method: "GET") { (response: Swift.Result<CardListResponse, RideError>) in
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


