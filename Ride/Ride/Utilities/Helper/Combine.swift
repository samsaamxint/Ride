//
//  Box.swift
//  Ride
//
//  Created by Nabeel Nazir on 22/08/22.

import Foundation
// Dynamic type box to set observer on variables
final class Combine<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    func forceUpdate(){
         listener?(value)
    }
    func unBind(){
        listener = nil
    }
}

// Dynamic type box to set observer on variables
final class CombineOptional<T> {
    typealias Listener = (T?) -> Void
    var listener: Listener?
    
    var value: T? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.listener?(self.value)
            }
        }
    }
    
    init(_ value: T?) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    func unBind(){
        listener = nil
    }
}
