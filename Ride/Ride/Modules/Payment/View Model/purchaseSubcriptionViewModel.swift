//
//  purchaseSubcriptionViewModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class PurchaseSubcriptionViewmodel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<purchaseSubcriptionResponse> = Combine(purchaseSubcriptionResponse())
}

extension PurchaseSubcriptionViewmodel{
    final func purchaseSubcription(amount: Int,card_id: Int,payment_method: String){
        self.isLoading.value = true
        PurchaseSubcriptionAPI.shared.purchaseSubcription(amount: amount, card_id: card_id, payment_method: payment_method)
            .done { [weak self] (res) in
                if res.code == 201 || res.code == 200 {
                    self?.apiResponseData.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.code)
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
                self?.isLoading.value = false
            }
    }
}

struct PurchaseSubcriptionAPI{
    static let shared = PurchaseSubcriptionAPI()
    
    func purchaseSubcription(amount: Int,card_id: Int,payment_method: String) -> Promise<purchaseSubcriptionResponse> {
        return Promise { seal in
            
            let request = purchaseSubcriptionRequest.init(amount: amount, card_id: card_id, payment_method: payment_method)
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.purchaseSubscription, requestParams: request, method: "POST") { (response: Swift.Result<purchaseSubcriptionResponse, RideError>) in
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
    
