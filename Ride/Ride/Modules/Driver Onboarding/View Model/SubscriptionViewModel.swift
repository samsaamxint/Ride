//
//  SubscriptionViewModel.swift
//  Ride
//
//  Created by Mac on 01/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol SubscriptionProtocol {
    func purchaseSubscription(promocode: String?)
    func verifySubscription()
    func getSubscriptions(with page: Int, limit: Int)
    func cancelSubscription()
    func getInvoice()
    func updateSubscription(with id: String)
    func changeRenewalStatus()
}

extension SubscriptionProtocol {
    func purchaseSubscription(promocode: String?) { }
    func verifySubscription() { }
    func getSubscriptions(with page: Int, limit: Int) { }
    func cancelSubscription() { }
    func getInvoice(){ }
    func updateSubscription(with id: String) { }
    func changeRenewalStatus() { }
}

class SubscriptionViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<GetBalanceResponse> = Combine(GetBalanceResponse())
    
    final var verifySubscriptionRes: Combine<PurchaseSubscriptionResponse> = Combine(PurchaseSubscriptionResponse())
    
    final var getSubscriptionData: Combine<SubscriptionResponse> = Combine(SubscriptionResponse())
    private(set) var activeSubscription : SubscriptionItem?
    private(set) var subscriptionHistory = [SubscriptionItem]()
    private(set) var canLoad = true
    
    final var cancelSubscriptionRes: Combine<CommonResponse> = Combine(CommonResponse())
    final var activateSubscriptionRes: Combine<CommonResponse> = Combine(CommonResponse())
    final var getInvoiceResponse: Combine<invoiceResponse> = Combine(invoiceResponse())
    
    final var purchaseSubscriptionData: Combine<PurchaseSubscriptionRes> = Combine(PurchaseSubscriptionRes())
    
    final var updateSubscription: Combine<CommonResponse> = Combine(CommonResponse())
    
    final var changeRenewalStatusRes: Combine<CommonResponse> = Combine(CommonResponse())
    final var changeRenewalError: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
}


extension SubscriptionViewModel: SubscriptionProtocol, BalanceProtocol {
    func getBalance() {
        BalanceAPI.shared.request()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.apiResponseData.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
                    
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
            }
    }
    
    func purchaseSubscription(promocode: String?) {
        isLoading.value = true
        
        SubscriptionAPI.shared.purchaseSubscription(promocode: promocode)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.purchaseSubscriptionData.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
                    
                }            }
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
    
    func verifySubscription() {
        isLoading.value = true
        
        SubscriptionAPI.shared.verifySubscription()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.verifySubscriptionRes.value = res
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
    
    func getSubscriptions(with page: Int, limit: Int, showLoader: Bool = true) {
        if showLoader {
            isLoading.value = true
        }
        
        SubscriptionAPI.shared.getSubscription(with: page, limit: limit)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.filterSubscriptions(res: res)
                    self?.getSubscriptionData.value = res
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
    
    private func filterSubscriptions(res: SubscriptionResponse) {
        if res.data?.first?.status == .ACTIVE {
            activeSubscription = res.data?.first
        }
        
        subscriptionHistory.append(contentsOf: res.data?.filter({ $0.status != .ACTIVE }) ?? [])
        if  res.data?.filter({ $0.status != .ACTIVE }).count == 0{
            canLoad = false
        }
    }
    
    func cancelSubscription() {
        isLoading.value = true
        
        SubscriptionAPI.shared.cancelSubscription()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.cancelSubscriptionRes.value = res
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
    
    func activateSubscription() {
        isLoading.value = true
        
        SubscriptionAPI.shared.activateSubscription()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.activateSubscriptionRes.value = res
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
    
    func getInvoice() {
        isLoading.value = true
        
        SubscriptionAPI.shared.getInvoice()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.getInvoiceResponse.value = res
                } else {
                    //self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
                let myError = error as? RideError
                switch myError {
                //case .errorWithCode(let message, let code):
                    //self?.messageWithCode.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.messageWithCode.value = ErrorResponseWithCode(message: error.localizedDescription)
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
    
    func updateSubscription(with id: String) {
        isLoading.value = true
        
        SubscriptionAPI.shared.updateSubscription(with: id)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.updateSubscription.value = res
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
    
    func changeRenewalStatus() {
        isLoading.value = true
        
        SubscriptionAPI.shared.changeRenewalStatus()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.changeRenewalStatusRes.value = res
                } else {
                    self?.changeRenewalError.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
                let myError = error as? RideError
                switch myError {
                case .errorWithCode(let message, let code):
                    self?.changeRenewalError.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.changeRenewalError.value = ErrorResponseWithCode(message: error.localizedDescription)
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
    
}

class SubscriptionAPI {
    static let shared = SubscriptionAPI()

    func purchaseSubscription(promocode: String?) -> Promise<PurchaseSubscriptionRes> {
        return Promise { seal in
            
            let request = PurchaseSubscriptionRequest(promoCode: promocode, method: "1")

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.purchaseSubscription, requestParams: request, method: "POST") { (response: Swift.Result<PurchaseSubscriptionRes, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func verifySubscription() -> Promise<PurchaseSubscriptionResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.verifySubscription, requestParams: request, method: "POST") { (response: Swift.Result<PurchaseSubscriptionResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getSubscription(with page: Int, limit: Int) -> Promise<SubscriptionResponse> {
        return Promise { seal in
            
            let request = GetSubscrption(page: page, limit: limit)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getSubscriptions, requestParams: request, method: "POST") { (response: Swift.Result<SubscriptionResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func cancelSubscription() -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.cancelSubscription, requestParams: request, method: "PUT") { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func activateSubscription() -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.activateSubscription, requestParams: request, method: "PUT") { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getInvoice() -> Promise<invoiceResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.captainInvoice, requestParams: request, method: "GET") { (response: Swift.Result<invoiceResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func updateSubscription(with id: String) -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = UpdateSubscriptionReq(subscriptionId: id)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.updateSubscription, requestParams: request, method: "POST") { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func changeRenewalStatus() -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.changeRenewalStatus, requestParams: request, method: "POST") { (response: Swift.Result<CommonResponse, RideError>) in
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
