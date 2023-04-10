//
//  OneSignalWidgetExtensionBundle.swift
//  OneSignalWidgetExtension
//
//  Created by Samsaam Zohaib on 17/02/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import WidgetKit
import SwiftUI

@available(iOS 16.1, *)

struct OneSignalWidgetBundle: WidgetBundle {
    var body: some Widget {
        //OneSignalWidget()
        OneSignalWidgetLiveActivity()
    }
}
