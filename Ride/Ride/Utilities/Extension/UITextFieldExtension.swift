//
//  UITextFieldExtension.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func setLeadingPadding(_ space: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: space, height: self.frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setRightPadding(_ space: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: space, height: self.frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
    
    func addInputViewDatePicker(target: Any, selector: Selector, minDate: Date? = nil, maxDate: Date? = nil ,calender : Calendar = Calendar(identifier: .gregorian)) {
        let screenWidth = UIScreen.main.bounds.width
        
        //Add DatePicker as inputView
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Before its wheels by default
        }
        
        if maxDate.isSome {
            datePicker.maximumDate = maxDate
        }
        
        if minDate.isSome {
            datePicker.minimumDate = minDate
        }
        
        datePicker.datePickerMode = .date
        self.inputView = datePicker
        datePicker.stylizeView()
        datePicker.calendar = calender
        if calender.identifier == .islamicUmmAlQura{
            datePicker.locale = Locale.init(identifier: "ar")
        }
        
        //Add Tool Bar as input AccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: false)
        
        self.inputAccessoryView = toolBar
    }
    
    @objc func cancelPressed() {
        self.resignFirstResponder()
    }
}

private var kAssociationKeyMaxLength: Int = 0

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        text =  String(prospectiveText[..<maxCharIndex])
        selectedTextRange = selection
        
//        prospectiveText.substring(to: maxCharIndex)
    }
}

extension UIDatePicker {

func stylizeView(view: UIView? = nil) {
    let view = view ?? self
    for subview in view.subviews {
        if let label = subview as? UILabel {
            if let text = label.text {
                print("UIDatePicker :: sylizeLabel :: \(text)\n")

                label.font = UIFont.MadaniArabicMedium
            }
        } else { stylizeView(view: subview) }
    }
}}
