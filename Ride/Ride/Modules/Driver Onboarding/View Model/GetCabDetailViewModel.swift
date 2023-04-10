//
//  GetCabDetailViewModel.swift
//  Ride
//
//  Created by XintMac on 05/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class GetCabDetailViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponse: Combine<GetCabDetailResponse> = Combine(GetCabDetailResponse())
    final var checkOutApiResponse: Combine<CarCheckoutResponse> = Combine(CarCheckoutResponse())
}

// MARK: - API Call
extension GetCabDetailViewModel {

    final func getCabDetail(){
        isLoading.value = true
        
        GetCabDetailAPI.shared.getCabDetail()
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
    
    final func cabCheckOut(){
        isLoading.value = true
        
        GetCabDetailAPI.shared.cabCheckOut()
            .done { [weak self] (res) in
                if res.statusCode == 200  {
                    self?.checkOutApiResponse.value = res
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

struct GetCabDetailAPI{
    static let shared = GetCabDetailAPI()

    func getCabDetail() -> Promise<GetCabDetailResponse> {
        return Promise { seal in

            let request = DummyRequest(request: "1")
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.getCabDetail, requestParams: request, method: "GET") { (response: Swift.Result<GetCabDetailResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func cabCheckOut() -> Promise<CarCheckoutResponse> {
        return Promise { seal in

            let request = CarCheckoutRequest.init(car_id: "1064419037", pkg_id: 1, preference: "pickup", preference_lat: "1", preference_lng: "1")
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.carCheckout, requestParams: request) { (response: Swift.Result<CarCheckoutResponse, RideError>) in
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
