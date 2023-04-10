//
//  AppDelegate.swift
//  Ride
//
//  Created by Mac on 18/08/2022.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import CountryPicker
import Adjust
import Foundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [CarDeliveryAddressViewController.self, CountryPickerViewController.self]
        
        GMSServices.provideAPIKey(APIKeys.GoogleMapsKey)
        GMSPlacesClient.provideAPIKey(APIKeys.GooglePlacesKey)
        UserDefaults.standard.setValue(0, forKey: "directionsCount")
        GoogleApi.shared.initialiseWithKey(APIKeys.GooglePlacesKey)
        
        let _ = RideConfigSetup.init()
        RemoteNotification.shared.configure(application)
        Thread.sleep(forTimeInterval: 1.5)
        
        if UserDefaults.standard.value(forKey: languageKey) == nil {
            let langStr = Locale.current.languageCode
            if langStr == "en" || langStr == "ar"{
                //                UserDefaults.standard.set([langStr], forKey: languageKeyDefault)
                UserDefaults.standard.set(langStr, forKey: languageKey)
                LocalizationHelper.setCurrentLanguage(langStr ?? "en")
            } else {
                //                UserDefaults.standard.set(["en"], forKey: languageKeyDefault)
                UserDefaults.standard.set("en", forKey: languageKey)
                LocalizationHelper.setCurrentLanguage("en")
            }
        } else {
            guard let language = UserDefaults.standard.value(forKey: languageKey) as? String else { return true }
            UserDefaults.standard.set(language, forKey: languageKey)
            LocalizationHelper.setCurrentLanguage(language)
        }
       
        let AppToken = "px2ppe35dgjk"
        let environment = ADJEnvironmentProduction as? String ?? ""
        let adjustConfig = ADJConfig(
            appToken: AppToken,
            environment: environment)
        adjustConfig?.logLevel = ADJLogLevelVerbose
        
        Adjust.appDidLaunch(adjustConfig)
        if !UserDefaults.standard.bool(forKey: isLunchedApp) {
            UserDefaults.standard.set(true, forKey: isLunchedApp)
            let preferredLanguage = NSLocale.preferredLanguages[0]
            if preferredLanguage.contains("en") {
                UserDefaults.standard.set("en", forKey: languageKey)
                UserDefaults.standard.synchronize()
                LocalizationHelper.setCurrentLanguage("en")
            } else if preferredLanguage.contains("ar") {
                    UserDefaults.standard.set("ar", forKey: languageKey)
                    UserDefaults.standard.synchronize()
                    LocalizationHelper.setCurrentLanguage("ar")
            }
        } else {
            print("this is not first time load")
        }
//        UIView.appearance().semanticContentAttribute = .forceLeftToRight
       UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        guard let topViewController = UIApplication.topViewController() else { return }
       guard let window = topViewController.view.window else { return }
        let customLoaderViewToBeRemoved : UIView? = window.viewWithTag(kCustomLoaderViewTag)
        if customLoaderViewToBeRemoved != nil {
          customLoaderViewToBeRemoved!.removeFromSuperview()
        }

    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

