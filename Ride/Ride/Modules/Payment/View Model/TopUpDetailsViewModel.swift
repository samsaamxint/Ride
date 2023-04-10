//
//  TopUpDetailsViewModel.swift
//  Ride
//
//  Created by Ali Zaib on 14/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//
import Foundation
import PromiseKit

protocol TopUpDetailsProtoc0l {
    func getTopUpDetails()
}

final class TopUpDetailsViewModel : TopUpDetailsProtoc0l {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<TopUpDetailsResponse> = Combine(TopUpDetailsResponse())
}

extension TopUpDetailsViewModel{
    
    func getTopUpDetails() {
        isLoading.value = true
        
        TopUpDetailsAPI.shared.getTopUpDetails()
            .done { [weak self] (res) in
                self?.apiResponseData.value = res
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

struct TopUpDetailsAPI {
    static let shared = TopUpDetailsAPI()

    func getTopUpDetails() -> Promise<TopUpDetailsResponse> {
        return Promise { seal in
            
            let request = TopupHistoryRequest(filters: TopupHistoryFilterReq(entityType: "3"))

            Service.shared.request(withURL:   ServerUrls.RideBASE_URL + RequestType.topUpHistory, requestParams: request, method: "POST") { (response: Swift.Result<TopUpDetailsResponse, RideError>) in
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
    
