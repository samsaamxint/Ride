//
//  PromocodeViewModel.swift
//  Ride
//
//  Created by Mac on 03/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol PromocodeProtocol {
    func validatePromocode(amount: Double, promoCode: String,lat : Double, long :Double,applyingTo:Int, tripId: String?)
}

extension PromocodeProtocol {
    func validatePromocode(amount: Double, promoCode: String,lat : Double, long :Double,applyingTo:Int, tripId: String?) { }
}

class PromocodeViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var validateSubscriptionRes: Combine<ValidatePromocodeResponse> = Combine(ValidatePromocodeResponse())
}

extension PromocodeViewModel: PromocodeProtocol {
    func validatePromocode(amount: Double, promoCode: String,lat : Double, long :Double,applyingTo:Int, tripId: String?) {
        isLoading.value = true
        PromocodeAPI.shared.validatePromocode(amount: amount, promoCode: promoCode, lat: lat, long: long, applyingTo: applyingTo, tripId: tripId)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.validateSubscriptionRes.value = res
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
                self?.isLoading.value = false
            }
    }
}

class PromocodeAPI {
    static let shared = PromocodeAPI()

    func validatePromocode(amount: Double, promoCode: String,lat : Double, long :Double,applyingTo:Int, tripId: String?) -> Promise<ValidatePromocodeResponse> {
        return Promise { seal in
            
            let request = ValidatePromocodeRequest(promoCode: promoCode, amount: amount, userId: UserDefaultsConfig.user?.userId, lat: lat, long: long, applyingTo: applyingTo, tripId: tripId)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.validatePromocode, requestParams: request, method: "POST") { (response: Swift.Result<ValidatePromocodeResponse, RideError>) in
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
