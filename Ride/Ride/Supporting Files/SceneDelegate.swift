//
//  SceneDelegate.swift
//  Ride
//
//  Created by Mac on 18/08/2022.
//

import UIKit
import Network

var isConnectedToInternet = false

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let monitor = NWPathMonitor()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if UserDefaultsConfig.isUserLoggedIn {
            globalMobileNumber = UserDefaultsConfig.user?.mobileNo?.dropCountryCode
            if UserDefaultsConfig.isDriver {
                Commons.goToMain(type: .driver)
            } else {
                Commons.goToMain(type: .rider)
            }
        } else {
            Commons.goToOnboarding()
        }
        
        listenInternetStateChange()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
            
    func listenInternetStateChange() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isConnectedToInternet = true
            } else {
                isConnectedToInternet = false
            }
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if UserDefaultsConfig.appVersion.isSome {
            if AppVersion <  UserDefaultsConfig.appVersion! {
                if let url = URL(string: "\(AppLink)") {
                    UIApplication.shared.open(url)
                }
            }
        }
     
        // Called when thJe scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
//        guard let topViewController = UIApplication.topViewController() else { return }
//       guard let window = topViewController.view.window else { return }
//        let customLoaderViewToBeRemoved : UIView? = window.viewWithTag(kCustomLoaderViewTag)
//        if customLoaderViewToBeRemoved != nil {
////          customLoaderViewToBeRemoved!.removeFromSuperview()
//            let loader = Indicator()
//            loader.restartLoader()
//        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
//        guard let topViewController = UIApplication.topViewController() else { return }
//       guard let window = topViewController.view.window else { return }
//        let customLoaderViewToBeRemoved : UIView? = window.viewWithTag(kCustomLoaderViewTag)
//        if customLoaderViewToBeRemoved != nil {
////          customLoaderViewToBeRemoved!.removeFromSuperview()
//            let loader = Indicator()
//            loader.pauseLoader()
//        }
        
//        self.window?.endEditing(true)
    }


}

extension UIApplication {
    var statusBarUIView: UIView? {
        
        if #available(iOS 13.0, *) {
            let tag = 3848245
            
            let keyWindow = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows.first
            
            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let height = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
                statusBarView.layer.zPosition = 999999
                
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
            
        } else {
            
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}
