//
//  SelectedPlanSummaryViewModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class SelectedPlanSummaryViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<SelectedPlanSummaryResponse> = Combine(SelectedPlanSummaryResponse())
}

extension SelectedPlanSummaryViewModel{
    final func getPlanSummary(id: Int) {
        SelectedPlanSummaryAPI.shared.getSummary(id: id)
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

struct SelectedPlanSummaryAPI {
    static let shared = SelectedPlanSummaryAPI()
    
    func getSummary(id: Int) -> Promise<SelectedPlanSummaryResponse> {
        return Promise { seal in
            
            let request = SelectedPlanSummaryRequest.init(id: id)
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.selectedPlanSummary, requestParams: request, method: "POST") { (response: Swift.Result<SelectedPlanSummaryResponse, RideError>) in
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
    
