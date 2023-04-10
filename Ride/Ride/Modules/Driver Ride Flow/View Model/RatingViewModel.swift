//
//  RatingViewModel.swift
//  Ride
//
//  Created by Mac on 16/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

//View Model
final class RatingViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var submitRatingResponse: Combine<CommonResponse> = Combine(CommonResponse())
}

extension RatingViewModel {
    final func reviewRider(title: String, desc: String, rating: Float, tripid: String) {
        isLoading.value = true
        
        SubmitRatingAPI.shared.reviewRider(title: title, desc: desc, rating: rating, tripid: tripid)
            .done { [weak self] (res) in
                if res.statusCode == 201  {
                    self?.submitRatingResponse.value = res
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

    
    final func reviewDriver(title: String, desc: String, rating: Float, tripid: String) {
        isLoading.value = true
        
        SubmitRatingAPI.shared.reviewDriver(title: title, desc: desc, rating: rating, tripid: tripid)
            .done { [weak self] (res) in
                if res.statusCode == 201  {
                    self?.submitRatingResponse.value = res
                } else {
                    self?.apiResponseMessage.value = AlertMessages.somethingwrong
                    
                }
            }
            .catch { [weak self] (error) in
                let myError = error as? RideError
                switch myError {
                case .otherError(let message):
                    self?.apiResponseMessage.value = message
                case .errorWithCode(let message, let code):
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
struct SubmitRatingAPI {
    static let shared = SubmitRatingAPI()

    func reviewRider(title: String, desc: String, rating: Float, tripid: String) -> Promise<CommonResponse> {
        return Promise { seal in

            let request = SubmitRatingRequest(title: title, description: desc, rating: rating, tripId: tripid)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.rateDriver, requestParams: request, method: "POST") { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func reviewDriver(title: String, desc: String, rating: Float, tripid: String) -> Promise<CommonResponse> {
        return Promise { seal in

            let request = SubmitRatingRequest(title: title, description: desc, rating: rating, tripId: tripid)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.rateRider, requestParams: request, method: "POST") { (response: Swift.Result<CommonResponse, RideError>) in
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

