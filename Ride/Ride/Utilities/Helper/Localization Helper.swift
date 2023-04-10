//
//  Localization Helper.swift
//  Ride
//
//  Created by Ali Zaib on 02/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

protocol Localizable {
    var localized: String { get }
}
//extension String: Localizable {
//    var localized: String {
//        return NSLocalizedString(self, comment: "")
//    }
//}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localizedString()
        }
    }
}
extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localizedString(), for: .normal)
        }
   }
}
