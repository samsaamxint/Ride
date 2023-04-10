//
//  CancelRideByDriverViewModel.swift
//  Ride
//
//  Created by Mac on 12/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class RiderRequestResponseViewModel{
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var cancelTripResponse: Combine<CommonResponse> = Combine(CommonResponse())
    final var acceptTripResponse: Combine<CommonResponse> = Combine(CommonResponse())
    
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
}

extension RiderRequestResponseViewModel {
    final func cancelTripByDriver(with id : String) {
        isLoading.value = true
        
        RiderRequestResponseAPI.shared.cancelTrip(id : id)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.cancelTripResponse.value = res
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
                case .errorWithCode(let message, let code):
                    self?.apiResponseMessage.value = message
                    self?.messageWithCode.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.apiResponseMessage.value = error.localizedDescription
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
    
    
    final func driverAcceptRequest(tripId : String){
        isLoading.value = true
        
        RiderRequestResponseAPI.shared.acceptRiderRequest(id: tripId)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.acceptTripResponse.value = res
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
                case .errorWithCode(let message, let code):
                    self?.apiResponseMessage.value = message
                    self?.messageWithCode.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.apiResponseMessage.value = error.localizedDescription
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
    
}

struct RiderRequestResponseAPI {
    
    static let shared = RiderRequestResponseAPI()
    
    func cancelTrip(id : String) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = DriverDeclineRequest(declinedReason: "Personal emergecny")
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.driver_rejected + "\(id)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func acceptRiderRequest(id : String) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = DriverAcceptedRequest(driverId: UserDefaultsConfig.user?.userId ?? "")
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.driver_accepted + "\(id)", requestParams: request, method: "PATCH") { (response: Swift.Result<CommonResponse, RideError>) in
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

struct ErrorResponseWithCode: Codable {
    var message: String?
    var code: Int?
}
