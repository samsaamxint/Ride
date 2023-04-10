//
//  MainDashbaordViewModel.swift
//  Ride
//
//  Created by Mac on 16/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

enum CheckStatusAPITrack: Codable {
    case fromLanding, onTogglingInterface, toRefreshOnly
}

//View Model
final class MainDashbaordViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var getCaptainError: Combine<(ErrorResponseWithCode, CheckStatusAPITrack)> = Combine((ErrorResponseWithCode(), CheckStatusAPITrack.fromLanding))
    
    final var apiResponseData: Combine<TripDetailData> = Combine(TripDetailData())
    final var checkCaptainStatus: Combine<(DriverStatusResponse, CheckStatusAPITrack)> = Combine((DriverStatusResponse(), CheckStatusAPITrack.fromLanding))
    final var updateCaptainStatus: Combine<CommonResponse> = Combine(CommonResponse())
    final var getApplicationStatus: Combine<CheckApplicationResponse> = Combine(CheckApplicationResponse())
    final var uploadTripImage: Combine<CommonResponse> = Combine(CommonResponse())
    
    final var verifySubscriptionRes: Combine<PurchaseSubscriptionResponse> = Combine(PurchaseSubscriptionResponse())
    final var verifySubscriptionError: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    
    final var activeUserLocations: Combine<ActiveUserLocationResponse> = Combine(ActiveUserLocationResponse())
    final var highDemandZone: Combine<HighDemandZoneResponse> = Combine(HighDemandZoneResponse())
}

extension MainDashbaordViewModel {
    final func getTripDetail(tripid: String) {
        MainDashbaordAPI.shared.request(tripid: tripid)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.apiResponseData.value = res
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
    
    final func getCaptainStatus(check: CheckStatusAPITrack) {
        isLoading.value = true
        
        MainDashbaordAPI.shared.getCaptainStatus()
            .done { [weak self] (res) in
//                self?.isLoading.value = false
                if res.statusCode == 200  {
                    if check == .fromLanding || check == .toRefreshOnly{
                        self?.isLoading.value = false
                    }
                    self?.checkCaptainStatus.value = (res, check)
                } else {
                    self?.getCaptainError.value = (ErrorResponseWithCode(message: "", code: res.statusCode), check)
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
                let myError = error as? RideError
                switch myError {
                case .errorWithCode(let message, let code):
                    self?.getCaptainError.value = (ErrorResponseWithCode(message: message, code: code), check)
                default:
                    self?.getCaptainError.value = (ErrorResponseWithCode(message: error.localizedDescription), check)
                }
            }
            .finally { [weak self] in
                //                self?.isLoading.value = false
                print("")
            }
    }
    
    final func uploadMapImage(tripid : String , image : UIImage) {
        MainDashbaordAPI.shared.uploadTripImage(tripid: tripid, image : image)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    
                } else {
                    
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
                let myError = error as? RideError
                switch myError {
                case .errorWithCode(_, _): break
                    //                    self?.getCaptainError.value = ErrorResponseWithCode(message: message, code: code)
                default:
                   print("Error")
                }
            }
            .finally { [weak self] in
                //                self?.isLoading.value = false
            }
    }
    
    final func changeDriverMode() {
        isLoading.value = true
        MainDashbaordAPI.shared.changeDriverMode()
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.updateCaptainStatus.value = res
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
    
    final func checkApplication(reason: String) {
        isLoading.value = true
        
        MainDashbaordAPI.shared.checkApplication(reason : reason)
            .done { [weak self] (res) in
                if res.code == 200  {
                    self?.getApplicationStatus.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.code)
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
    
    final func getRiderTrip(shouldChangeMode: Bool) {
        isLoading.value = true
        MainDashbaordAPI.shared.getRiderTrips()
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    //self?.getApplicationStatus.value = res
                    if let latestTrip = res.data?.trips?.first{
                        if latestTrip.status == .ACCEPTED_BY_DRIVER || latestTrip.status == .DRIVER_ARRIVED || latestTrip.status == .STARTED{
                            UserDefaultsConfig.isDriver = false
                            self?.getTripDetail(tripid: latestTrip.id ?? "")
                        } else {
                            if shouldChangeMode {
                                UserDefaultsConfig.isDriver = false
                                self?.changeDriverMode()
                            }
                        }
                    } else {
                        if shouldChangeMode {
                            UserDefaultsConfig.isDriver = false
                            self?.changeDriverMode()
                        }
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
    
    final func getDriverTrip(shouldChangeMode: Bool) {
        isLoading.value = true
        MainDashbaordAPI.shared.getDriverTrips()
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    //self?.getApplicationStatus.value = res
                    if let latestTrip = res.data?.trips?.first{
                        if latestTrip.status == .ACCEPTED_BY_DRIVER || latestTrip.status == .DRIVER_ARRIVED || latestTrip.status == .STARTED{
                            UserDefaultsConfig.isDriver = true
                            self?.getTripDetail(tripid: latestTrip.id ?? "")
                        } else {
                            if shouldChangeMode {
                                UserDefaultsConfig.isDriver = true
                                self?.changeDriverMode()
                            }
                        }
                    } else {
                        if shouldChangeMode {
                            UserDefaultsConfig.isDriver = true
                            self?.changeDriverMode()
                        }
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
    
    final func getUsersLocation() {
        MainDashbaordAPI.shared.getUsersLocationForHeatMap()
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.activeUserLocations.value = res
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
                //                self?.isLoading.value = false
            }
    }
    
    final func getHighDemadZone() {
        MainDashbaordAPI.shared.getHighDemandZones()
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.highDemandZone.value = res
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
                //                self?.isLoading.value = false
            }
    }
}

extension MainDashbaordViewModel: SubscriptionProtocol {
    func verifySubscription() {
        isLoading.value = true
        
        SubscriptionAPI.shared.verifySubscription()
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.verifySubscriptionRes.value = res
                } else {
                    self?.verifySubscriptionError.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
                let myError = error as? RideError
                switch myError {
                case .errorWithCode(let message, let code):
                    self?.verifySubscriptionError.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.verifySubscriptionError.value = ErrorResponseWithCode(message: error.localizedDescription)
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
}

//API
struct MainDashbaordAPI {
    static let shared = MainDashbaordAPI()
    
    func request(tripid: String) -> Promise<TripDetailData> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getTripDetail + "\(tripid)", requestParams: request, method: "GET") { (response: Swift.Result<TripDetailData, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func getCaptainStatus() -> Promise<DriverStatusResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getCaptainStatus, requestParams: request, method: "GET") { (response: Swift.Result<DriverStatusResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func changeDriverMode() -> Promise<CommonResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.changeDriverMode, requestParams: request) { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func checkApplication(reason : String) -> Promise<CheckApplicationResponse> {
        return Promise { seal in
            
            let request = DummyRequest.init(request: reason)
            
            Service.shared.request(withURL: ServerUrls.mockBaseURL + RequestType.checkApplicationStatus, requestParams: request, method: "GET") { (response: Swift.Result<CheckApplicationResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getRiderTrips() -> Promise<TripsResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.riderTrips, requestParams: request, method: "GET") { (response: Swift.Result<TripsResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getDriverTrips() -> Promise<TripsResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.driverTrips, requestParams: request, method: "GET") { (response: Swift.Result<TripsResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func uploadTripImage(tripid : String, image : UIImage) -> Promise<CommonResponse> {
        return Promise { seal in
            
             let request = EmptyRequest()
            
            let key = UserDefaultsConfig.isDriver  ? "driverPhoto" : "riderPhoto"
            
            Service.shared.sendUploadRequest(withURL: ServerUrls.RideBASE_URL + RequestType.uploadMapPhoto + "\(tripid)", requestParams: request, method : "PATCH",paramters : ["type" : "\(RideSingleton.shared.tripDetailObject?.data?.status?.rawValue ?? 0)" ], image: image.pngData(), imageKey: key) { (response: Swift.Result<CommonResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getUsersLocationForHeatMap() -> Promise<ActiveUserLocationResponse> {
        return Promise { seal in
            
             let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getActiveUsersLocation, requestParams: request, method : "GET") { (response: Swift.Result<ActiveUserLocationResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getHighDemandZones() -> Promise<HighDemandZoneResponse> {
        return Promise { seal in
            
             let request = EmptyRequest()
            
            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getHighDemandZones, requestParams: request, method : "GET") { (response: Swift.Result<HighDemandZoneResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }//getHighDemandZones
}


