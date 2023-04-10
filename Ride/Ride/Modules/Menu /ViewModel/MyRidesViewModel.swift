//
//  MyRidesViewModel.swift
//  Ride
//
//  Created by Mac on 10/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
final class MyRidesViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    
    final var getRiderRides: Combine<TripsResponse> = Combine(TripsResponse())
    final var getDriverRides: Combine<TripsResponse> = Combine(TripsResponse())
    final var getTripDetail: Combine<TripDetailData> = Combine(TripDetailData())
}

extension MyRidesViewModel {
    final func getRiderTrip() {
        isLoading.value = true
        MainDashbaordAPI.shared.getRiderTrips()
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.getRiderRides.value = res
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
    
    final func getDriverTrip() {
        isLoading.value = true
        MainDashbaordAPI.shared.getDriverTrips()
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 200  {
                    self?.getDriverRides.value = res
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
    
    final func getTripDetail(tripid: String) {
        MainDashbaordAPI.shared.request(tripid: tripid)
            .done { [weak self] (res) in
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.getTripDetail.value = res
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
}
