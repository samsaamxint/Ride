//
//  NotificationViewModel.swift
//  Ride
//
//  Created by Ali Zaib on 07/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//


import Foundation
import PromiseKit

protocol NotificationProtocol {
    func getNotification(with page: Int, limit: Int)
}

extension NotificationProtocol {
    func getNotification(with page: Int, limit: Int) { }
}

class NotificationViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<GetNotificationResponse> = Combine(GetNotificationResponse())
    private(set) var notificationHistory = [GetNotificationData]()
    private(set) var canLoad = true
}


extension NotificationViewModel:NotificationProtocol{
    
    func getNotification(with page: Int, limit: Int, showLoader: Bool = true) {
        if showLoader {
            isLoading.value = true
        }
        NotificationAPI.shared.getNotification(with: page, limit: limit)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.notificationHistory.append(contentsOf: res.data ?? [])
                    self?.apiResponseData.value = res
                    if res.data?.count == 0 || res.data == nil {
                        self?.canLoad = false
                    }
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

class NotificationAPI {
    static let shared = NotificationAPI()

    func getNotification(with page: Int, limit: Int) -> Promise<GetNotificationResponse> {
        return Promise { seal in
            
            let request = GetNotification(page: String(page), limit: String(limit))
//let notificationUrl = RequestType.getNotification + "?page=\(page)" + "&limmit=\(limit)"
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getNotification, requestParams: request, method: "GET") { (response: Swift.Result<GetNotificationResponse, RideError>) in
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
