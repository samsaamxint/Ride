//
//  RemoteNotification.swift
//  Expert App
//
//  Created by Nabeel Nazir on 04/08/2022.
//

import Foundation
import FirebaseCore
import FirebaseMessaging
import UIKit
import Firebase

public var firebaseToken = ""
public var verifyToken = ""

class RemoteNotification: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    static let shared = RemoteNotification()
    let gcmMessageIDKey = "gcm.message_id"
    
    func configure(_ application: UIApplication) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        firebaseToken = fcmToken ?? DefaultValue.string
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        if UserDefaultsConfig.isUserLoggedIn{
            ConfigurationsViewModel().updateCustomer(deviceId: deviceId,
                                                     deviceToken: firebaseToken,
                                                     deviceName: "iOS",
                                                     latitude: LocationManager.shared.lastLocation?.coordinate.latitude,
                                                     longitude: LocationManager.shared.lastLocation?.coordinate.longitude, email: nil, mobileNo: nil, profileImage: nil, prefferedLanguage: UserDefaults.standard.value(forKey: languageKey) as? String)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as? [String: Any]
        
        if userInfo?["type"] as! String == "trip_request" {
            UserDefaultsConfig.tripId = userInfo?["tripID"] as? String
        }

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        DLog("PushNotification Dataaa:=>\(userInfo)")

        
        guard let dict = userInfo as? [String: Any],
              let notification_type = dict["type"] as? String,
        let type = NotificationType(rawValue: notification_type) else {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let message = alert["title"] as? NSString {
                        if message == "Approved"{
                            UserDefaultsConfig.user?.isWASLApproved = 1
                            Commons.adjustEventTracker(eventId: AdjustEventId.WASLApproval)
                            if let mainVC = self.topMostViewController() as? MainDashboardViewController{
                                if let childNavigationController = (mainVC.containerView.subviews.first?.getParentController() as? UINavigationController) {
                                if let vc: ApplicationStatusApproveViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                                    UserDefaultsConfig.isDriver = true
                                    childNavigationController.pushViewController(vc, animated: false)
//                                    (mainVC.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
//                                    mainVC.addChildWithNavViewController(childController: vc, contentView: mainVC.containerView)
                                }
                                }
                            }
                        }
                    }
                } else if let alert = aps["alert"] as? NSString {
                    //Do stuff
                }
            }
            completionHandler([.alert, .sound, .badge])
            return
        }
        completionHandler([.alert, .sound, .badge])
        return
//        if let mainVC = self.topMostViewController() as? MainDashboardViewController,
//           let childNavigationController = (mainVC.containerView.subviews.first?.getParentController() as? UINavigationController) {
//
//            if UserDefaultsConfig.isDriver {
//                if type == .kTripCancelledByRider {
//                    guard let tripId = dict["tripID"] as? String else {
//                        completionHandler([[.alert, .sound]])
//                        return
//                    }
//
//                    delay(0) { [weak self] in
//                        guard let `self` = self else { return }
//                        guard let lastVC = childNavigationController.viewControllers.last else { return }
//
//                        if !lastVC.isKind(of: NoRidersViewController.self) && tripId == RideSingleton.shared.tripDetailObject?.data?.id {
//                            RideSingleton.shared.tripDetailObject = nil
//                            mainVC.setupSwitchUserModeView()
//                            mainVC.mapView?.clear()
//                            mainVC.addCurrentLocationMarker()
//                            childNavigationController.popToRootViewController(animated: false)
//                        }
//                    }
//                } else if type == .kTripRequest {
//                    delay(0) { [weak self] in
//                        guard let `self` = self else { return }
//                        if !childNavigationController.viewControllers.contains(where: { $0.isKind(of: RiderRequestViewController.self) }) {
//                            // TODO
//                        }
//                    }
//                }
//            } else {
//                guard let tripId = dict["tripID"] as? String else {
//                    completionHandler([[.alert, .sound]])
//                    return
//                }
//
//                if type == .kDriverAccepted || type == .kDriverReached {
//                    UserDefaultsConfig.tripId = tripId
//
//                    if !childNavigationController.viewControllers.contains(where: { $0.isKind(of: RiderEnterPinVC.self) }) {
//                        delay(0) {
//                            if let vc: RiderEnterPinVC = UIStoryboard.instantiate(with: .riderToDriver) {
//                                childNavigationController.pushViewController(vc, animated: false)
//                            }
//                        }
//                    }
//                } else if type == .kDriverReachedOnPickup { // Change Trip Started Event
//                    if childNavigationController.viewControllers.last?.isKind(of: RiderEnterPinVC.self) ?? DefaultValue.bool {
//                        delay(0) {
//                            if let vc: RiderDuringRide = UIStoryboard.instantiate(with: .riderToDriver) {
//                                childNavigationController.pushViewController(vc, animated: false)
//                            }
//                        }
//                    }
//                } else if type == .kRideCompletedBydriver {
//                    if childNavigationController.viewControllers.last?.isKind(of: RiderDuringRide.self) ?? DefaultValue.bool {
//                        delay(0) {
//                            mainVC.containerViewHeight.constant = 480
//                            if let vc: RiderCompletedRideVC = UIStoryboard.instantiate(with: .riderToDriver) {
//                                childNavigationController.pushViewController(vc, animated: false)
//                            }
//                        }
//                    }
//                }
//            }
//            completionHandler([[.alert, .sound]])
//        }
        
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
}

extension NSObject {
    public func topMostViewController() -> UIViewController {
        if let controller = UIApplication.shared.keyWindow?.rootViewController {
            return self.topMostViewController(withRootViewController: controller)
        }
        return UIViewController()
    }
    public func topMostViewController(withRootViewController rootViewController: UIViewController) -> UIViewController {
        if (rootViewController is UITabBarController) {
            let tabBarController = (rootViewController as! UITabBarController)
            return self.topMostViewController(withRootViewController: tabBarController.selectedViewController!)
        }
        else if (rootViewController is UINavigationController) {
            let navigationController = (rootViewController as! UINavigationController)
            return self.topMostViewController(withRootViewController: navigationController.visibleViewController!)
        }
        else if rootViewController.presentedViewController != nil {
            if let presentedViewController = rootViewController.presentedViewController {
                return self.topMostViewController(withRootViewController: presentedViewController)
            }
            return rootViewController
        } else {
            return rootViewController
        }
    }
}
