//
//  RideSelectionViewModel.swift
//  Ride
//
//  Created by Mac on 07/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

//View Model
final class RideSelectionViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var getCarAPIResponse: Combine<CarListResponse> = Combine(CarListResponse())
    final var bookCarAPIResponse: Combine<TripResponse> = Combine(TripResponse())
    final var checkKYCRes: Combine<CheckKYCStatusResponse> = Combine(CheckKYCStatusResponse())
}

extension RideSelectionViewModel {
    final func requestCabs(originAddressLng: String, originAddressLat: String, destinationAddressLat: String, destinationAddressLng: String) {
        isLoading.value = true

        RideSelectionAPI.shared.request(originAddressLng: originAddressLng,
                                        originAddressLat: originAddressLat,
                                        destinationAddressLat: destinationAddressLat,
                                        destinationAddressLng: destinationAddressLng)
            .done { [weak self] (res) in
                if res.statusCode == 200  {
                    self?.getCarAPIResponse.value = res
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

    
    final func bookCabs(with cabId: String?, promoCode: String?, country: String?, city: String?, addresses: [CreateTripAddress], tokenApplePay: AddBalanceRequestNew?, amount: Double) {
        isLoading.value = true
        
        RideSelectionAPI.shared.bookRide(cabId: cabId, promoCode: promoCode, country: country, city: city, addresses: addresses, tokenApplePay: tokenApplePay, tripAmount: amount)
            .done { [weak self] res in
                guard let `self` = self else { return }
                
                if res.statusCode == 201 {
                    self.bookCarAPIResponse.value = res
                } else {
                    self.apiResponseMessage.value = AlertMessages.somethingwrong
                }
            }
            .catch { [weak self] error in
                guard let `self` = self else { return }
                
                let myError = error as? RideError
                switch myError {
                case .otherError(let message):
                    self.apiResponseMessage.value = message
                case .errorWithCode(let message, _):
                    self.apiResponseMessage.value = message
                default:
                    self.apiResponseMessage.value = error.localizedDescription
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
    
    final func checkKYC() {
        isLoading.value = true
        
        RideSelectionAPI.shared.checkKYC()
            .done { [weak self] res in
                guard let `self` = self else { return }
                self.isLoading.value = false
                if res.statusCode == 200 {
                    self.checkKYCRes.value = res
                } else {
                    self.apiResponseMessage.value = AlertMessages.somethingwrong
                }
            }
            .catch { [weak self] error in
                guard let `self` = self else { return }
                self.isLoading.value = false
//                let myError = error as? RideError
//                switch myError {
//                case .otherError(let message):
//                    self.apiResponseMessage.value = message
//                case .errorWithCode(let message, _):
//                    self.apiResponseMessage.value = message
//                default:
//                    self.apiResponseMessage.value = error.localizedDescription
//                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
}

//API
struct RideSelectionAPI {
    static let shared = RideSelectionAPI()

    func request(originAddressLng: String, originAddressLat: String, destinationAddressLat: String, destinationAddressLng: String) -> Promise<CarListResponse> {
        return Promise { seal in

            let request = GetCarRequest(originAddressLng: originAddressLng,
                                        originAddressLat: originAddressLat,
                                        destinationAddressLat: destinationAddressLat,
                                        destinationAddressLng: destinationAddressLng)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getCars, requestParams: request, method: "GET") { (response: Swift.Result<CarListResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func bookRide(cabId: String?, promoCode: String?, country: String?, city: String?, addresses: [CreateTripAddress], tokenApplePay: AddBalanceRequestNew?, tripAmount: Double) -> Promise<TripResponse> {
        
        return Promise { seal in
            var request = TripRequestDetails()
            if tokenApplePay == nil {
              request = TripRequestDetails(cabId: cabId, promoCode: promoCode, country: country, city: city, addresses: addresses)
            } else {
                request = TripRequestDetails(cabId: cabId, promoCode: promoCode, country: country, city: city, addresses: addresses, applePayToken: tokenApplePay?.applePayToken, amount: tripAmount)
            }
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getTrip, requestParams: request) { (response: Swift.Result<TripResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    func checkKYC() -> Promise<CheckKYCStatusResponse> {
        return Promise { seal in
            let request = EmptyRequest()
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.checkKYCStatus, requestParams: request, method: "GET") { (response: Swift.Result<CheckKYCStatusResponse, RideError>) in
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

