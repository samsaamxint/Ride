//
//  RiderDropOffViewModel.swift
//  Ride
//
//  Created by Mac on 07/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

class RiderDropOffViewModel {
    
    var autocompleteResults: [GApiResponse.Autocomplete] = []
    
    final func showResults(string: String, completion: @escaping () -> Void) {
        var input = GInput()
        input.keyword = string
        GoogleApi.shared.callApi(input: input) { [weak self] (response) in
            if response.isValidFor(.autocomplete) {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.autocompleteResults.removeAll()
                    var autocompleteLocalResults: [GApiResponse.Autocomplete] = []
                    autocompleteLocalResults = response.data as? [GApiResponse.Autocomplete] ?? [GApiResponse.Autocomplete]()
                    
                    for item in autocompleteLocalResults {
                        self.autocompleteResults.append(item)
                    }
                    
                    completion()
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
    
    final func getAPIDetail(index: Int, completion: @escaping (Int, GApiResponse.PlaceInfo) -> Void) {
        if autocompleteResults.count > 0 {
            var input = GInput()
            input.keyword = autocompleteResults[index].placeId
            GoogleApi.shared.callApi(.placeInformation, input: input) { [weak self] (response) in
                if response.isValidFor(.placeInformation) {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if let responseData = response.data as? GApiResponse.PlaceInfo {
                            print("place information ===== \(responseData)")
                            completion(index, responseData)
                        }
                    }
                } else { print(response.error ?? "ERROR") }
            }
        }
    }
}


class MapViewModel {
    
    var autocompleteResults: [GApiResponse.Autocomplete] = []
    
    final func showResults(string: String, completion: @escaping () -> Void) {
        var input = GInput()
        input.keyword = string
        GoogleApi.shared.callApi(input: input) { [weak self] (response) in
            if response.isValidFor(.autocomplete) {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.autocompleteResults.removeAll()
                    var autocompleteLocalResults: [GApiResponse.Autocomplete] = []
                    autocompleteLocalResults = response.data as? [GApiResponse.Autocomplete] ?? [GApiResponse.Autocomplete]()
                    
                    for item in autocompleteLocalResults {
                        self.autocompleteResults.append(item)
                    }
                    
                    completion()
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
    
    final func getAPIDetail(index: Int, completion: @escaping (Int, GApiResponse.PlaceInfo) -> Void) {
        if autocompleteResults.count > 0 {
            var input = GInput()
            input.keyword = autocompleteResults[index].placeId
            GoogleApi.shared.callApi(.placeInformation, input: input) { [weak self] (response) in
                if response.isValidFor(.placeInformation) {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if let responseData = response.data as? GApiResponse.PlaceInfo {
                            print("place information ===== \(responseData)")
                            completion(index, responseData)
                        }
                    }
                } else { print(response.error ?? "ERROR") }
            }
        }
    }
}
