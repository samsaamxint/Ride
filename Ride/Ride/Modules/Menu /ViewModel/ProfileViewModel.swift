//
//  ProfileViewModel.swift
//  Ride
//
//  Created by XintMac on 22/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

//View Model
final class ProfileViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponseData: Combine<ProfileResponseModel> = Combine(ProfileResponseModel())
}

extension ProfileViewModel {
    final func getProfileDetail() {
        isLoading.value = true
        
        ProfileAPI.shared.request()
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
    
    final func updateProfileImage() {
        
    }
}

//API
struct ProfileAPI {
    static let shared = ProfileAPI()

    func request() -> Promise<ProfileResponseModel> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getUserDetail, requestParams: request, method: "GET") { (response: Swift.Result<ProfileResponseModel, RideError>) in
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


