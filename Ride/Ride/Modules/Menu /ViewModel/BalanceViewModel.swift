//
//  BalanceViewModel.swift
//  Ride
//
//  Created by Mac on 24/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol BalanceProtocol {
    func getBalance()
    func addBalance(balance: Int)
    func topUp(accountid : String, amount : String)
}

extension BalanceProtocol {
    func addBalance(balance: Int) { }
    func topUp(accountid : String ,amount : String) { }
}

//View Model
final class BalanceViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<GetBalanceResponse> = Combine(GetBalanceResponse())
    final var addBalanceResponse: Combine<AddBalanceByClickPayRes> = Combine(AddBalanceByClickPayRes())
    final var topUpResponse: Combine<TopUpResponse> = Combine(TopUpResponse())
}

extension BalanceViewModel: BalanceProtocol {
   
    
    final func getBalance() {
        isLoading.value = true
        
        BalanceAPI.shared.request()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.apiResponseData.value = res
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
    
    final func topUp(accountid : String ,amount : String) {
        isLoading.value = true
        BalanceAPI.shared.topUp(accountid : accountid ,amount : amount)
            .done { [weak self] (res) in
                    self?.topUpResponse.value = res
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
    
    final func addBalance(balance: Int) {
        isLoading.value = true
        
        BalanceAPI.shared.addBalance(balance: balance)
            .done { [weak self] (res) in
                //if res.statusCode == 201 || res.statusCode == 200 {
                    self?.addBalanceResponse.value = res
//                } else {
//                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
//
//                }
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
    final func addBalanceNew(tokenApplePay: AddBalanceRequestNew) {
        isLoading.value = true
        
        BalanceAPI.shared.addBalanceNew(Appletoken: tokenApplePay)
            .done { [weak self] (res) in
                //if res.statusCode == 201 || res.statusCode == 200 {
                    self?.addBalanceResponse.value = res
//                } else {
//                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
//
//                }
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

//API
struct BalanceAPI {
    static let shared = BalanceAPI()

    func request() -> Promise<GetBalanceResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()
            print("base url is thisss \(ServerUrls.RideBASE_URL)")
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getBalance, requestParams: request, method: "GET") { (response: Swift.Result<GetBalanceResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func topUp(accountid : String ,amount : String) -> Promise<TopUpResponse> {
        return Promise { seal in
            
            let request = TopUpRequest.init(name: "name", email: "email@email.com", accountid: accountid, street1: "address street", city: "riaydh", state: "01", country:  "SA", zip:  "12345", amount: amount, fee: "1", tax: "1", cart_id: randomString(length: 15), callbackurl: "https://dev-panel.ride.sa/api/topup-callback")

            Service.shared.request(withURL: RequestType.topUp, requestParams: request, method: "POST") { (response: Swift.Result<TopUpResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func addBalance(balance : Int) -> Promise<AddBalanceByClickPayRes> {
        return Promise { seal in
            
            let request = AddBalanceHostedRequest(amount: balance)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.addBalance, requestParams: request, method: "POST") { (response: Swift.Result<AddBalanceByClickPayRes, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    func addBalanceNew(Appletoken : AddBalanceRequestNew) -> Promise<AddBalanceByClickPayRes> {
        return Promise { seal in
            
//            let request = AddBalanceRequestNew(amount: token)

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.addBalance, requestParams: Appletoken, method: "POST") { (response: Swift.Result<AddBalanceByClickPayRes, RideError>) in
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


