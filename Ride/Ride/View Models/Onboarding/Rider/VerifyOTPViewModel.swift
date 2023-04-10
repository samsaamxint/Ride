//
//  VerifyOTPViewModel.swift
//  Ride
//
//  Created by Mac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit


final class VerifyOTPViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var verifyResponse: Combine<VerifyOTPResp> = Combine(VerifyOTPResp())
}

// MARK: - API Call
extension VerifyOTPViewModel {

    final func requestOTPValidate(mobileNumber: String, otp: String, reason: String? , tId : String, userId : String?, licExpiry : String?) {
        isLoading.value = true

        VerifyOTPAPI.shared.request(mobileNumber: mobileNumber, otp: otp, reason: reason , tId : tId, userId : userId, licExpiry : licExpiry)
            .done { [weak self] (res) in
                if res.statusCode == 200  {
                    self?.verifyResponse.value = res
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

struct VerifyOTPAPI {
    static let shared = VerifyOTPAPI()

    func request(mobileNumber: String, otp: String, reason: String? , tId : String, userId : String?, licExpiry : String?) -> Promise<VerifyOTPResp> {
        return Promise { seal in
            
            
            let request = VerifyOTPRequest.init(mobile_number: mobileNumber, otp: otp, tId: tId, reason: reason, userId: userId, licExpiry: licExpiry)
            
            //let request = VerifyOTPRequest.init(mobile_number: mobileNumber, otp: otp, tId : tId, reason: reason)
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.otp_verification, requestParams: request) { (response: Swift.Result<VerifyOTPResp, RideError>) in
                switch response {
                case .success(let verifyRes):
                    if verifyRes.data?.details?.id.isSome ?? DefaultValue.bool {
                        UserDefaultsConfig.sessionID = verifyRes.data?.token ?? ""
                        UserDefaultsConfig.user = verifyRes.data?.details
                    } else {
                        seal.reject(RideError.errorWithCode(message: verifyRes.message ?? DefaultValue.string , code: 0))
                    }
                    seal.fulfill(verifyRes)
//                    getCaptainStatus { captainStatusValue in
//                        switch captainStatusValue {
//                        case .success(let captainStatusRes):
//                            guard captainStatusRes.statusCode == 200 else {
//                                seal.reject(RideError.errorWithCode(message: "Unable to Proceed, Please try later!", code: captainStatusRes.statusCode ?? 0))
//                                return
//                            }
//
//                            if reason.isNone {                          // RIDER
//                                if captainStatusRes.data?.driverModeSwitch == true {
//
//                                    changeDriverMode { changeStateValue in
//                                        switch captainStatusValue {
//                                        case .success(let captainStatusRes):
//                                            guard captainStatusRes.statusCode == 200 else {
//                                                seal.reject(RideError.errorWithCode(message: "Unable to Proceed, Please try later!", code: captainStatusRes.statusCode ?? 0))
//                                                return
//                                            }
//
//                                            seal.fulfill(verifyRes)
//                                        case .failure( _):
//                                            seal.reject(RideError.errorWithCode(message: "Unable to Proceed, Please try later!", code: 0))
//                                        }
//                                    }
//
//                                } else {
//                                    seal.fulfill(verifyRes)
//                                }
//                            } else {                                    // CAPTAIN
//
//                                if captainStatusRes.data?.driverModeSwitch == false {
//                                    changeDriverMode { changeStateValue in
//                                        switch captainStatusValue {
//                                        case .success(let captainStatusRes):
//                                            guard captainStatusRes.statusCode == 200 else {
//                                                seal.reject(RideError.errorWithCode(message: "Unable to Proceed, Please try later!", code: captainStatusRes.statusCode ?? 0))
//                                                return
//                                            }
//
//                                            seal.fulfill(verifyRes)
//                                        case .failure(_):
//                                            seal.reject(RideError.errorWithCode(message: "Unable to Proceed, Please try later!", code: 0))
//                                        }
//                                    }
//
//                                } else {
//                                    seal.fulfill(verifyRes)
//                                }
//                            }
//
//                        case .failure(_):
//                            seal.reject(RideError.errorWithCode(message: "Unable to Proceed, Please try later!", code: 0))
//                        }
//                    }
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    private func getCaptainStatus(completionHandler: @escaping (Swift.Result<DriverStatusResponse, RideError>) -> Void) {
        let request = EmptyRequest()

        Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getCaptainStatus, requestParams: request, method: "GET") { (response: Swift.Result<DriverStatusResponse, RideError>) in
            switch response {
            case .success(let response):
                completionHandler(.success(response))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func changeDriverMode(completionHandler: @escaping (Swift.Result<CommonResponse, RideError>) -> Void) {
            let request = EmptyRequest()
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.changeDriverMode, requestParams: request) { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    completionHandler(.success(response))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
}

