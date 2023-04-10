//
//  UpdateProfileViewModel.swift
//  Ride
//
//  Created by Mac on 11/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

//View Model
final class UpdateProfileViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var updateProfile: Combine<UploadProfileImageRes> = Combine(UploadProfileImageRes())
    final var userData: Combine<UpdateProfileResponse> = Combine(UpdateProfileResponse())
}

extension UpdateProfileViewModel {
    final func updloadProfileImage(file: AttachmentInfo) {
        isLoading.value = true
        UpdateProfileAPI.shared.uploadProfileImage(file: file)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.updateProfile.value = res
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
    
    final func updateCustomer(deviceId: String?, deviceToken: String?, deviceName: String?, latitude: Double?, longitude: Double? , email : String?,mobileNo : String?,profileImage : String?, prefferedLanguage: String?, isLanguageUpdate: Bool?) {
        isLoading.value = true
        UpdateProfileAPI.shared.updateCustomer(deviceId: deviceId,
                                               deviceToken: deviceToken,
                                               deviceName: deviceName,
                                               latitude: latitude,
                                               longitude: longitude,
                                               email: email,
                                               mobileNo : mobileNo,
                                               profileImage :profileImage,
                                               prefferedLanguage: prefferedLanguage, isLanguageUpdate: isLanguageUpdate)
        .done { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 201 || res.statusCode == 200 {
                self.userData.value = res
                UserDefaultsConfig.user = res.data
            } else {
                self.messageWithCode.value = ErrorResponseWithCode(message: "", code: res.statusCode)
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

//API
struct UpdateProfileAPI {
    static let shared = UpdateProfileAPI()
    
    func uploadProfileImage(file: AttachmentInfo) -> Promise<UploadProfileImageRes> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.sendUploadRequest(withURL: ServerUrls.RideBASE_URL + RequestType.update_profile, requestParams: request, method: "PUT", image: file.data, imageKey: file.apiKey, timeoutInterval: 120) { (response: Swift.Result<UploadProfileImageRes, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func updateCustomer(deviceId: String?, deviceToken: String?, deviceName: String?, latitude: Double?, longitude: Double? , email : String?,mobileNo : String?, profileImage : String?, prefferedLanguage: String?, isLanguageUpdate: Bool?) -> Promise<UpdateProfileResponse> {
        return Promise { seal in
            var request = UpdateCustomerRequest(deviceId: deviceId,
                                             deviceToken: deviceToken,
                                             deviceName: deviceName,
                                             latitude: latitude,
                                             longitude: longitude,
                                             email: email,
                                             mobileNo: mobileNo,
                                             profileImage: profileImage,
                                             prefferedLanguage: prefferedLanguage)
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.updateCustomer, requestParams: request, method: "POST") { (response: Swift.Result<UpdateProfileResponse, RideError>) in
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


