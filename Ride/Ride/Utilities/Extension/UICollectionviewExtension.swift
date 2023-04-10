//
//  UICollectionviewExtension.swift
//  Ride
//
//  Created by PSE on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {

    func setEmptyMessage(_ message: String, font:UIFont?=UIFont(name: "SF Pro Display", size: 15)) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = font
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    func restore() {
        self.backgroundView = nil
    }
    func showErrorIfZero(count:Int, message: String ){
        if count == 0 {
            setEmptyMessage(message)
        }else{
            restore()
        }
    }
}
