//
//  addCardViewModel.swift
//  Ride
//
//  Created by XintMac on 28/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol CardManagmentProtocol {
    func addCard(name: String,company: String,card_number: Int,exp_date: String, cvv:Int)
    func changeCardStatus(status: String)
}

final class AddCardViewModel: CardManagmentProtocol {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<addCardResponse> = Combine(addCardResponse())
    
    final var changeCardStatus: Combine<ChangeCardStatusResp> = Combine(ChangeCardStatusResp())
}

extension AddCardViewModel{
    func addCard(name: String,company: String,card_number: Int,exp_date: String, cvv:Int){
        self.isLoading.value = true
        AddCardAPI.shared.addCart(name: name, company: company, card_number: card_number, exp_date: exp_date, cvv: cvv)
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
    
    func changeCardStatus(status: String) {
        isLoading.value = true
        
        AddCardAPI.shared.changeCardStatus(status: String(status))
            .done { [weak self] (res) in
                self?.changeCardStatus.value = res
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

struct AddCardAPI {
    static let shared = AddCardAPI()
    
    func addCart(name: String,company: String,card_number: Int,exp_date: String,cvv:Int) -> Promise<addCardResponse> {
        return Promise { seal in
            
            let request = addCardRequest.init(name: name, company: company, card_number: card_number, exp_date: exp_date, cvv: cvv)
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.addCard, requestParams: request, method: "POST") { (response: Swift.Result<addCardResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func changeCardStatus(status : String) -> Promise<ChangeCardStatusResp> {
        return Promise { seal in
            
            let request = ChangeCardStatus(customerId: UserDefaultsConfig.user?.userId, card: status)

            Service.shared.request(withURL: RequestType.changeCardStatus, requestParams: request, method: "GET") { (response: Swift.Result<ChangeCardStatusResp, RideError>) in
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
    
