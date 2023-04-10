//
//  ReportProblemViewModel.swift
//  Ride
//
//  Created by Mac on 24/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol ReportProblemProtocol {
    func saveTicket(number: String, name: String, description: String , id : Int)
    func getTickets(with number: String)
    func getComplaintsType()
}

class ReportProblemViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var reportProblem: Combine<AddTicketRespose> = Combine(AddTicketRespose())
    final var getIssuesList: Combine<GetIssuesResponse> = Combine(GetIssuesResponse())
    final var getComplaintTypes: Combine<GetComplaintTypesResponse> = Combine(GetComplaintTypesResponse())
}

extension ReportProblemViewModel: ReportProblemProtocol {
    func saveTicket(number: String, name: String, description: String , id : Int) {
        isLoading.value = true
        
        ReportProblemAPIs.shared.saveTicket(number: number, name: name, description: description , id : id)
            .done { [weak self] (res) in
                if res.success == true {
                    self?.reportProblem.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: 401)
                    
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
    
    func getComplaintsType() {
        isLoading.value = true
        
        ReportProblemAPIs.shared.getComplaintsType()
            .done { [weak self] (res) in
                if res.success == true {
                    self?.getComplaintTypes.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: 0)

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
    
    func getTickets(with number: String) {
        isLoading.value = true
        
        ReportProblemAPIs.shared.getTickets(with: number)
            .done { [weak self] (res) in
                if res.success == true {
                    self?.getIssuesList.value = res
                } else {
                    if res.message == "Customer not found"{
                        self?.messageWithCode.value = ErrorResponseWithCode(message: "No Report Founds", code: 0)
                    }else{
                        self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: 0)
                    }
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

//API
struct ReportProblemAPIs {
    static let shared = ReportProblemAPIs()

    func saveTicket(number: String, name: String, description: String, id : Int) -> Promise<AddTicketRespose> {
        return Promise { seal in
            
            let request = ReportProblemReq(contact_no: number, name: name, description: description, category_id : id,type: UserDefaultsConfig.isDriver ? 2 : 1, secret_key: APIKeys.CMS_SECRET_KEY)

            Service.shared.request(withURL: ServerUrls.CMS_BASE_URL + RequestType.addTicket, requestParams: request, method: "POST") { (response: Swift.Result<AddTicketRespose, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getTickets(with number: String) -> Promise<GetIssuesResponse> {
        return Promise { seal in
            
            let request = GetIssuesListReq(contact_no: number, secret_key: APIKeys.CMS_SECRET_KEY)

            Service.shared.request(withURL: ServerUrls.CMS_BASE_URL + RequestType.tickerPerCustomer, requestParams: request, method: "POST") { (response: Swift.Result<GetIssuesResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getComplaintsType() -> Promise<GetComplaintTypesResponse> {
        return Promise { seal in
            
            let request = getComplaintTypes.init(secret_key: APIKeys.CMS_SECRET_KEY)

            Service.shared.request(withURL: ServerUrls.CMS_BASE_URL + RequestType.getComplaintType, requestParams: request, method: "GET") { (response: Swift.Result<GetComplaintTypesResponse, RideError>) in
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


