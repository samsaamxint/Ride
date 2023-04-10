//
//  GetSubcriptionViewModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class GetSubcriptionViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponse: Combine<GetSubcriptionsResponse> = Combine(GetSubcriptionsResponse())
    
    private(set) var activeSubscription = [GetSubcriptionsData]()
    var selectedId: String = ""
}

// MARK: - API Call
extension GetSubcriptionViewModel {

    final func getSubcription() {
        isLoading.value = true
        
        GetSubcriptionAPI.shared.getSubcription()
            .done { [weak self] (res) in
                if res.statusCode == 200  {
                    self?.activeSubscription = res.data?.filter({ $0.status == .ACTIVE }) ?? []
                    self?.selectedId = self?.activeSubscription.first?.id ?? DefaultValue.string
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

struct GetSubcriptionAPI {
    static let shared = GetSubcriptionAPI()

    func getSubcription() -> Promise<GetSubcriptionsResponse> {
        return Promise { seal in

            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getSubscriptionPlan, requestParams: request, method: "GET") { (response: Swift.Result<GetSubcriptionsResponse, RideError>) in
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
