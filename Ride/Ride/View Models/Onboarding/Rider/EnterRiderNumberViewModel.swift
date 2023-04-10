//
//  EnterRiderNumberViewModel.swift
//  Ride
//
//  Created by Mac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

//View Model
final class EnterRiderNumberViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var apiResponse: Combine<EnterNumberResp> = Combine(EnterNumberResp())
}

extension EnterRiderNumberViewModel {
    final func requestLogin(mobileNumber: String,reason : String?) {
        isLoading.value = true

        EnterRiderNumberAPI.shared.request(mobileNumber: mobileNumber ,reason : reason)
            .done { [weak self] (res) in
                if res.status == 200  {
                    self?.apiResponse.value = res
                } else {
                    self?.apiResponseMessage.value = AlertMessages.somethingwrong

                }
        }
        .catch { [weak self] (error) in
            let myError = error as? RideError
            switch myError {
            case .otherError(let message):
                self?.apiResponseMessage.value = message
            case .errorWithCode(let message, _):
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

//API
struct EnterRiderNumberAPI {
    static let shared = EnterRiderNumberAPI()

    func request(mobileNumber: String,reason : String?) -> Promise<EnterNumberResp> {
        return Promise { seal in

            let request = EnterMobileRequest.init(mobileNo: mobileNumber, reason : reason)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.sendOTP, requestParams: request) { (response: Swift.Result<EnterNumberResp, RideError>) in
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
