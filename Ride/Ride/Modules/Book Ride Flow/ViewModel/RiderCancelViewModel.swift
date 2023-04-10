//
//  RiderCancelViewModel.swift
//  Ride
//
//  Created by XintMac on 16/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

enum CancelReasonType: String {
    case DECLINE_BY_DRIVER = "1"
    case CANCEL_BY_DRIVER = "2"
    case CANCEL_BY_RIDER = "3"
}

protocol RiderCancelProtocol {
    func getReasons(with type: CancelReasonType)
}

final class RiderCancelViewModel{
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var riderCancelResponse: Combine<CommonResponse> = Combine(CommonResponse())
    final var driverCancelResponse: Combine<CommonResponse> = Combine(CommonResponse())
    
    final var getReasons: Combine<CancelReasonList> = Combine(CancelReasonList())
}

extension RiderCancelViewModel: RiderCancelProtocol {
    final func cancelTripByRider(id : String ,reason : String ) {
//        isLoading.value = true
        
        RiderCancelResponseAPI.shared.cancelRide(id: id, reason: reason)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.riderCancelResponse.value = res
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
    
    final func cancelTripByDriver(id : String ,reason : String ) {
//        isLoading.value = true
        
        RiderCancelResponseAPI.shared.cancelRideByDriver(id: id, reason: reason)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.driverCancelResponse.value = res
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
//                self?.isLoading.value = false
            }
    }
    
    func getReasons(with type: CancelReasonType) {
        isLoading.value = true
        
        RiderCancelResponseAPI.shared.getReasons(with: type)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.getReasons.value = res
                } else {
                    self?.apiResponseMessage.value = AlertMessages.somethingwrong
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
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
//                self?.isLoading.value = false
            }
    }
    
}

struct RiderCancelResponseAPI {
    
    static let shared = RiderCancelResponseAPI()
    
    func cancelRide(id : String , reason : String) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = RiderCancelTrip(declinedReason: reason)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.riderCancel + "\(id)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>)  in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func cancelRideByDriver(id : String , reason : String) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = RiderCancelTrip(declinedReason: reason)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.tripCancelledByDriver + "\(id)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getReasons(with type: CancelReasonType) -> Promise<CancelReasonList> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.cancelReasons + "\(type.rawValue)", requestParams: request, method: "GET") { (response: Swift.Result<CancelReasonList, RideError>) in
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
