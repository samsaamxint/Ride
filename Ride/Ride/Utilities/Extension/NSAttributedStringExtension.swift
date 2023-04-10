//
//  NSAttributedStringExtension.swift
//  Ride
//
//  Created by Mac on 05/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    var fontSize: CGFloat { return 14 }
    
    var boldFont :UIFont { return Commons.isArabicLanguage() ? UIFont.MadaniArabicBold!.withSize(fontSize) : UIFont.SFProDisplayBold!.withSize(fontSize)}
    var normalFont: UIFont { return UIFont.SFProDisplayRegular?.withSize(fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    var italicFont: UIFont { return UIFont.SFProDisplayRegular?.withSize(fontSize) ?? UIFont.italicSystemFont(ofSize: fontSize) }
    
    public func bold(_ value:String, color: UIColor? = nil) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: boldFont,
            .foregroundColor: color ?? .black
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    public func italic(_ value: String, color: UIColor? = nil) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : italicFont,
            .foregroundColor: color ?? .black
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    public func normal(_ value: String, color: UIColor? = nil) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
            .foregroundColor: color ?? .black
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    public func underlined(_ value: String, color: UIColor? = nil) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor: color ?? .black,
            .underlineStyle : NSUnderlineStyle.single.rawValue
                
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    public func strikeThrough(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: UIColor.darkGray,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
}

extension String {

   func contains(_ find: String) -> Bool{
     return self.range(of: find) != nil
   }

   func containsIgnoringCase(_ find: String) -> Bool{
     return self.range(of: find, options: .caseInsensitive) != nil
   }
 }
