//
//  LocalizationHelper.swift
//  Ride
//
//  Created by Ali Zaib on 02/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

let kArabic = "ar"
let kEnglish = "en"


/// Default language english. If english is unavailable defaults to base localization.
let DefaultLanguage = "en"

/// Base bundle as fallback.
let BaseBundle = "Base"

/// Name for language change notification
public let LanguageChangeNotification = "LanguageChangeNotification"

// MARK: Localization Syntax

/**public extension String
 friendly localization syntax, replaces NSLocalizedString
 - Parameter string: Key to be localized.
 - Returns: The localized string.
 */

let languageKeyDefault = "AppleLanguages"
let languageKey = "AppleLanguage"
let languageArray = ["en", "ar"]
let currencyStr = "SAR"
let isLunchedApp = "isLunchedApp"


public extension String {
    /**
     friendly localization syntax, replaces NSLocalizedString
     - Returns: The localized string.
     */
    func localizedString() -> String {
        let bundle: Bundle = .main
        if let path = bundle.path(forResource: LocalizationHelper.currentLanguage(), ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        } else if let path = bundle.path(forResource: BaseBundle, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        } else {
            return self
        }
    }
    /**
    Swift 2 friendly localization syntax with format arguments, replaces String(format:NSLocalizedString)
     - Returns: The formatted localized string with arguments.
     */
    func localizedFormat(arguments: CVarArg...) -> String {
      return String(format: localizedString(), arguments: arguments)
    }
         
}

class LocalizationHelper: NSObject {
    /**
     List available languages
     - Returns: Array of available languages.
     */
    open class func availableLanguages(_ excludeBase: Bool = false) -> [String] {
        var availableLanguages = Bundle.main.localizations
        // If excludeBase = true, don't include "Base" in available languages
        if let indexOfBase = availableLanguages.firstIndex(of: "Base"), excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }
    
    /**
     Current language
     - Returns: The current language. String.
     */
    open class func currentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: languageKey) as? String {
            return currentLanguage
        }
        return DefaultLanguage
    }
    
    /**
     Change the current language
     - Parameter language: Desired language.
     */
    open class func setCurrentLanguage(_ language: String) {
        let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
        let selectedLanguage = availableLanguages().contains(language) ? language : DefaultLanguage
        UserDefaults.standard.set(selectedLanguage, forKey: languageKey)
//        UserDefaults.standard.set([selectedLanguage], forKey: languageKeyDefault)
        UserDefaults.standard.synchronize()
       // notificationCenter.post(name: Notification.Name(rawValue: LanguageChangeNotification), object: nil)
        //        let semanticContentAttribute:UISemanticContentAttribute = language == kArabic || language == "he" || language == "ur" ? .forceRightToLeft : .forceLeftToRight
        UILabel.appearance().semanticContentAttribute = language == "ar" || language == "he" || language == "ur" ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = language == "ar" || language == "he" || language == "ur" ? .forceRightToLeft : .forceLeftToRight
        UITextField.appearance().semanticContentAttribute = language == "ar" || language == "he" || language == "ur" ? .forceRightToLeft : .forceLeftToRight
        UINavigationBar.appearance().semanticContentAttribute = language == "ar" || language == "he" || language == "ur" ? .forceRightToLeft : .forceLeftToRight
        UICollectionView.appearance().semanticContentAttribute = language == "ar" || language == "he" || language == "ur" ? .forceRightToLeft : .forceLeftToRight

//        kAppDelegate.navigationController?.navigationBar.semanticContentAttribute = language == "ar" || language == "he" || language == "ur" ? .forceRightToLeft : .forceLeftToRight
//        kAppDelegate.navigationController?.view.semanticContentAttribute = .forceRightToLeft

    }
    
    /**
     Default language
     - Returns: The app's default language. String.
     */
    open class func defaultLanguage() -> String {
        var defaultLanguage: String = String()
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return DefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if availableLanguages.contains(preferredLanguage) {
            defaultLanguage = preferredLanguage
        } else {
            defaultLanguage = DefaultLanguage
        }
        return defaultLanguage
    }
    
    /**
     Resets the current language to the default
     */
    open class func resetCurrentLanguageToDefault() {
        setCurrentLanguage(defaultLanguage())
    }
    
    /**
     Get the current language's display name for a language.
     - Parameter language: Desired language.
     - Returns: The localized string.
     */
    open class func displayNameForLanguage(_ language: String) -> String {
        let locale: NSLocale = NSLocale(localeIdentifier: currentLanguage())
        if let displayName = locale.displayName(forKey: NSLocale.Key.identifier, value: language) {
            return displayName
        }
        return String()
    }
}

protocol Localizable {
    var localized: String { get }
}


protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localizedString()
        }
    }
}
extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localizedString(), for: .normal)
        }
   }
}

