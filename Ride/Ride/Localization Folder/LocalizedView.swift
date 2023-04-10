//
//  LocalizedView.swift
//  Ride
//
//  Created by Ali Zaib on 02/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class LocalizedView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        if LocalizationHelper.currentLanguage() == kEnglish {
            semanticContentAttribute = .forceLeftToRight
        } else {
            semanticContentAttribute = .forceRightToLeft
        }
    }
}
