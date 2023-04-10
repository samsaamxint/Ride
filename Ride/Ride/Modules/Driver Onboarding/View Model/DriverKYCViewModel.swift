//
//  DriverKYCViewModel.swift
//  Ride
//
//  Created by Mac on 16/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

final class DriverKYCViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var apiResponseMessage: Combine<String> = Combine("")
    final var apiResponse: Combine<EnterNumberResp> = Combine(EnterNumberResp())
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var apiResponsebecomeCap: Combine<BecomeCaptainResponse> = Combine(BecomeCaptainResponse())
}

// MARK: - API Call
extension DriverKYCViewModel {

    final func updateUserInfo(with mobileNumber: String, full_name: String? = nil, id_number: String? = nil, dob: String? = nil, type: Int, driver_id: String? = nil, car_plate_number: String? = nil, car_sequence_number: String? = nil) {
        isLoading.value = true
        
        DriverKYCAPI.shared.request(with: mobileNumber, full_name: full_name, id_number: id_number, dob: dob, type: type, driver_id: driver_id, car_plate_number: car_plate_number, car_sequence_number: car_sequence_number)
            .done { [weak self] (res) in
                if res.status == 200  {
                    self?.apiResponse.value = res
                } else {
                    self?.apiResponseMessage.value = AlertMessages.somethingwrong
                }
            }
        .catch { [weak self] (error) in
            self?.apiResponseMessage.value = error.localizedDescription
        }
        .finally { [weak self] in
            self?.isLoading.value = false
        }
    }
    
    final func becomeCaption(driverName: String, driverNationalId: String, carPlateNo: String, carLicenceType: Int, carCategoryType: Int, cab: String, carSequenceNo: String, drivingModes: [DrivingMode], acceptTC: Bool, isShowLoader: Bool, isForWaslCheck: Bool,subscriptionId: String,autoRenewal: Bool, transactionId: String) {
        isLoading.value = true
        
        DriverKYCAPI.shared.addBecomeACaptain(driverName: driverName, driverNationalId: driverNationalId, carPlateNo: carPlateNo, carLicenceType: carLicenceType, carCategoryType: carCategoryType, cab: cab, carSequenceNo: carSequenceNo, drivingModes: drivingModes, acceptTC: acceptTC, isShowLoader: isShowLoader, isForWaslCheck: isForWaslCheck,subscriptionId: subscriptionId,autoRenewal: autoRenewal, transactionId: transactionId)
            .done { [weak self] (res) in
                if res.statusCode == 200  {
                    self?.apiResponsebecomeCap.value = res
                } else {
                    self?.apiResponseMessage.value = AlertMessages.somethingwrong
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

struct DriverKYCAPI {
    static let shared = DriverKYCAPI()

    func request(with mobileNumber: String, full_name: String?, id_number: String?, dob: String?, type: Int, driver_id: String?, car_plate_number: String?, car_sequence_number: String?) -> Promise<EnterNumberResp> {
        return Promise { seal in

            let request = DriverRequest(mobileNumber: mobileNumber, fullName: full_name, idNumber: id_number, dob: dob, driverID: driver_id, carPlateNumber: car_plate_number, carSequenceNumber: car_sequence_number, type: type)
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.driverSignup, requestParams: request) { (response: Swift.Result<EnterNumberResp, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func addBecomeACaptain(driverName: String, driverNationalId: String, carPlateNo: String, carLicenceType: Int, carCategoryType: Int, cab: String, carSequenceNo: String, drivingModes: [DrivingMode], acceptTC: Bool, isShowLoader: Bool, isForWaslCheck: Bool,subscriptionId: String,autoRenewal: Bool, transactionId: String) -> Promise<BecomeCaptainResponse>  {
        
        return Promise { seal in
            
            let drivingMode = [DrivingMode.init(drivingMode: 1)]
           //static
            //let request = BecomeCaptainRequest.init(acceptTC: true, cab:  "db8db63e-1501-44c2-ac1b-c4bc213e92dc", carLicenceType: 1, carPlateNo: "8310-UOS", carSequenceNo: "194052910", driverNationalId:  "1064419037", drivingModes: [drivingMode], subscriptionId: "101adefc-fca0-445b-99a9-b12065bf06d7", autoRenewal: false)
           
            //dynamic
            let request = BecomeCaptainRequest.init(acceptTC: acceptTC, cab: UserDefaultsConfig.cab, carLicenceType: carLicenceType, carPlateNo: UserDefaultsConfig.carPlateNo, carSequenceNo: UserDefaultsConfig.carSequenceNo, driverNationalId: UserDefaultsConfig.user?.idNumber ?? DefaultValue.string, drivingModes: drivingMode, subscriptionId: UserDefaultsConfig.subscriptionId, autoRenewal: autoRenewal)
            
            let url = ServerUrls.RideBASE_URL + RequestType.becomeCaptain
            
            print("URL:- \(url)")
            
            Service.shared.request(withURL: url, requestParams: request) { (response: Swift.Result<BecomeCaptainResponse, RideError>) in
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

