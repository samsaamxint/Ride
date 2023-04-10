//
//  RideDetailViewModel.swift
//  Ride
//
//  Created by Ali Zaib on 01/12/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class RideDetailViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var getTripDetail: Combine<RideDetailResponse> = Combine(RideDetailResponse())
    final var getInvoiceDetail: Combine<RideInvoiceModel> = Combine(RideInvoiceModel())
}

extension RideDetailViewModel {
    
    final func getTripDetail(tripid: String) {
        RideDetailAPI.shared.getTripDetail(tripid: tripid)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.getTripDetail.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: "", code: res.statusCode)
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
    
    final func getInvoiceDetail(tripid: String) {
        RideDetailAPI.shared.getInvoiceDetail(tripid: tripid)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.getInvoiceDetail.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: "", code: res.statusCode)
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


struct RideDetailAPI{
    static let shared = RideDetailAPI()
    
    func getTripDetail(tripid: String) -> Promise<RideDetailResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getTripDetailsApi + "\(tripid)", requestParams: request, method: "GET") { (response: Swift.Result<RideDetailResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    func getInvoiceDetail(tripid: String) -> Promise<RideInvoiceModel> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getInvoiceDetailsApi + "\(tripid)", requestParams: request, method: "GET") { (response: Swift.Result<RideInvoiceModel, RideError>) in
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
