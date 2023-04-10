//
//  Debug.swift
//  Ride
//
//  Created by Mac on 07/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

let debug = true

public func DLog(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    if debug {
        let className = (fileName as NSString).lastPathComponent
        print("<\(className)> \(functionName) [#\(lineNumber)]| \(Date().timeIntervalSince1970) | 🍀🍀🍀🍀🍀:- \(message)\n")
    }
}

let isResponseLogEnable = true

public func RLog(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    if isResponseLogEnable {
        let className = (fileName as NSString).lastPathComponent
        print("<\(className)> \(functionName) [#\(lineNumber)]| \(Date().timeIntervalSince1970) | 🍀🍀🍀🍀:- \(message)\n")
    }
}

let isSocketLogEnable = true

public func SLog(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    if isSocketLogEnable {
        let className = (fileName as NSString).lastPathComponent
        print("<\(className)> \(functionName) [#\(lineNumber)]| \(Date().timeIntervalSince1970) | 🍀🍀🍀:- \(message)\n")
    }
}

