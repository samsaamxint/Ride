//
//  UIlabelExtension.swift
//  Ride
//
//  Created by XintMac on 18/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit


open class CustomSpacingLabel : UILabel {
    @IBInspectable open var characterSpacing:CGFloat = 1 {
        didSet {
            updateWithSpacing()
        }

    }

    open override var text: String? {
        set {
            super.text = newValue
            updateWithSpacing()
        }
        get {
            return super.text
        }
    }
    open override var attributedText: NSAttributedString? {
        set {
            super.attributedText = newValue
            updateWithSpacing()
        }
        get {
            return super.attributedText
        }
    }
    func updateWithSpacing() {
        let attributedString = self.attributedText == nil ? NSMutableAttributedString(string: self.text ?? "") : NSMutableAttributedString(attributedString: attributedText!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: self.characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        super.attributedText = attributedString
    }
}


@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
//
//extension UILabel {
//    @IBInspectable var adjustFont: Bool {
//        get { return false } // we don't care about return value
//        set { // this is where the game starts
//            if newValue {
//                switch Commons.isArabicLanguage() {
//                case true:
//                    self.font = UIFont(name: "Arial", size: 17)
//                case false:
//                    self.font = UIFont(name: "Times new roman", size: 17)
//                }
//            }
//        }
//    }
//}
