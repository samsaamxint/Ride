//
//  termsConditionVM.swift
//  Ride
//
//  Created by Ali Zaib on 07/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//
import Foundation
import PromiseKit

protocol TermsConditionProtocol {
    func getTermsCondition(isPrivacyPolicy: Bool)
}

extension TermsConditionProtocol {
    func getTermsCondition(isPrivacyPolicy: Bool) { }
}

class TermsConditionViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<GetTermsConditionResponse> = Combine(GetTermsConditionResponse())
}


extension TermsConditionViewModel:TermsConditionProtocol{
    
    func getTermsCondition(isPrivacyPolicy: Bool = false) {
        isLoading.value = true
        TermsConditionAPI.shared.getTermsCondition(isPrivacypolicy: isPrivacyPolicy)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.apiResponseData.value = res
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

class TermsConditionAPI {
    static let shared = TermsConditionAPI()

    func getTermsCondition(isPrivacypolicy: Bool) -> Promise<GetTermsConditionResponse> {
        return Promise { seal in
            let language = UserDefaults.standard.value(forKey: languageKey) as! String
            let request = EmptyRequest()
            var endPoint = ""
            if isPrivacypolicy{
                endPoint = RequestType.PrivacyPolicy+"/"+language
            }else{
                endPoint = RequestType.TermsAndConditions+"/"+language
            }
            let baseURl = "https://pre-prod-apis.ride.sa/master/pages/"
//        privacy-policy/en
            print(baseURl+endPoint)
//
            Service.shared.request(withURL:  baseURl + endPoint , requestParams: request, method: "GET") { (response: Swift.Result<GetTermsConditionResponse, RideError>) in
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
