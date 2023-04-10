//
//  RiderKYCViewModel.swift
//  Ride
//
//  Created by Ali Zaib on 28/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit


final class RiderKYCViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var kycResponse: Combine<RiderKYCResponse> = Combine(RiderKYCResponse())
}

// MARK: - API Call
extension RiderKYCViewModel {

    final func requestOTPValidate(userId : String?, dateOfBirth : String?) {
        isLoading.value = true

        RiderKYCAPI.shared.request(userId : userId, dateOfBirth : dateOfBirth)
            .done { [weak self] (res) in
                if res.statusCode == 200  {
                    self?.kycResponse.value = res
                    UserDefaultsConfig.user = res.data
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

struct RiderKYCAPI {
    static let shared = RiderKYCAPI()

    func request (userId : String?, dateOfBirth : String?) -> Promise<RiderKYCResponse> {
        return Promise { seal in
            
            
            let request = RiderKYCRequest.init(userId: userId, dateOfBirth: dateOfBirth)
            
            //let request = RiderKYCRequest.init(mobile_number: mobileNumber, otp: otp, tId : tId, reason: reason)
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.riderKYC, requestParams: request) { (response: Swift.Result<RiderKYCResponse, RideError>) in
                switch response {
                case .success(let verifyRes):
                    seal.fulfill(verifyRes)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

}

