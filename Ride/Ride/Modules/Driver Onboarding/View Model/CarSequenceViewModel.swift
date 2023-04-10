//
//  CarSequenceViewModel.swift
//  Ride
//
//  Created by XintMac on 27/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//
import Foundation
import PromiseKit

final class CarSequenceViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponse: Combine<CarSequenceResponse> = Combine(CarSequenceResponse())
}

// MARK: - API Call
extension CarSequenceViewModel {

    final func getCarDetails(carSequence : String, onwerId: String) {
        isLoading.value = true
        
        CarSequenceAPI.shared.getCarDetails(carSequence : carSequence, onwerId: onwerId)
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

struct CarSequenceAPI {
    static let shared = CarSequenceAPI()

    func getCarDetails(carSequence : String, onwerId: String) -> Promise<CarSequenceResponse> {
        return Promise { seal in
            let request = CarSequenceRequest.init(userid :  onwerId == "" ? (UserDefaultsConfig.user?.idNumber ?? DefaultValue.string) : onwerId , sequenceNumber : String(carSequence))
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getCarDetails, requestParams: request) { (response: Swift.Result<CarSequenceResponse, RideError>) in
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

