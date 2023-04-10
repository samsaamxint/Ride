//
//  UIButtonExtension.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func enableButton(_ value: Bool) {
        isUserInteractionEnabled = value
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            backgroundColor = value ? UIColor.primaryBtnBg : .primaryDarkBG.withAlphaComponent(0.12)
        } else {
            backgroundColor = value ? UIColor.primaryDarkBG : .primaryDarkBG.withAlphaComponent(0.12)
        }
       
    }
    
    func rotateBtnIfNeeded() {
        if Commons.isArabicLanguage() {
            transform = CGAffineTransform(rotationAngle: .pi)
        }
    }
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}
