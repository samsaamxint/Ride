//
//  NotificationService.swift
//  RideServiceExtention
//
//  Created by Ali Zaib on 05/01/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    private let defaults = UserDefaults(suiteName: "com.Ride.RideCompany")

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        defer {
            contentHandler(bestAttemptContent ?? request.content)
        }
        
        /// Update the badge value
        if var count = defaults?.value(forKey: "badge") as? Int {
            bestAttemptContent?.badge = NSNumber(value: count)
            count += 1
            defaults?.set(count, forKey: "badge")
        }
        
        bestAttemptContent?.sound = UNNotificationSound(named: .init(rawValue: "Notification.mp3"))
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
