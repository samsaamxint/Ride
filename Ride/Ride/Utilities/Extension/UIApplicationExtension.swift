//
//  UIApplicationExtension.swift
//  Ride
//
//  Created by Mac on 18/08/2022.
//

import Foundation
import UIKit

let app = UIApplication.shared.delegate as! AppDelegate

extension UIApplication {
    class func topViewController() -> UIViewController? {
        let base: UIViewController? = UIApplication.shared.windows.first?.rootViewController
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController

            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
    
    class func topViewController(base: UIViewController?) -> UIViewController? {
        
        var baseVC : UIViewController? = base
        if base == nil {
            if #available(iOS 13, *) {
                baseVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            }else{
                baseVC = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        
        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
