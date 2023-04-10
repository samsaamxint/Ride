//
//  UIViewExtensions.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /*
     Method Name : addParentFullLayout
     Input  Type : nil
     Return Type : nil
     Description : set constrain based on parentview layout
     */
    
    func addParentFullLayout()  {
        
        let superView = self.superview
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let dicView = ["self":self]
        
        superView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[self]-0-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: dicView))
        
        superView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[self]-0-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: dicView))
        
    }
    
    
    /*
     Method Name : setFixedLayoutAttribute : constant
     Input  Type : NSLayoutAttribute , float
     Return Type : NSLayoutConstraint
     Description : set constrian attributes based on parent layout
     */
    @discardableResult
    func setFixedLayoutAttribute(attribute: NSLayoutConstraint.Attribute, constant value: CGFloat) -> NSLayoutConstraint{
        
        let superView = self.superview
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let fixed = NSLayoutConstraint.init(item: self, attribute: attribute, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: value)
        
        superView?.addConstraints([fixed])
        
        return fixed
    }
    
    /*
     Method Name : addCenterLayout
     Input  Type : nil
     Return Type : nil
     Description : add centerlayout based on parent layout
     */
    
    func addCenterLayout() {
        let superView = self.superview
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint.init(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0)
        
        let centerY = NSLayoutConstraint.init(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0)
        
        superView?.addConstraints([centerX, centerY])
        
    }
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            removeAllSublayers()
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addDoubleBorder(with colorOne: UIColor = .primaryDarkBG, and colorTwo: UIColor = .primaryGreen, cornerRadius: CGFloat = 11) {
        
        removeAllSublayers()
        
        layoutIfNeeded()
        layer.name = "Border"
        layer.borderWidth = 1
        if UITraitCollection.current.userInterfaceStyle == .dark {
           // print("Dark mode")
            layer.borderColor = UIColor.clear.cgColor
        }
        else {
            layer.borderColor = colorOne.cgColor
        }
        
        layer.cornerRadius = cornerRadius
        
        let borderLayer = CALayer()
        borderLayer.name = "Border"
        borderLayer.frame = bounds
        borderLayer.borderColor = colorTwo.cgColor
        borderLayer.borderWidth = 2
        borderLayer.cornerRadius = cornerRadius
        layer.insertSublayer(borderLayer, above: layer)
        
    }
    
    func addBorder(with colorOne: UIColor = .primaryDarkBG, cornerRadius: CGFloat = 11) {
        
       // removeAllSublayers()
       // let borderLayer = CALayer()
        //borderLayer.name = "Border"
        //self..frame = bounds
        self.borderColor = colorOne
        self.borderWidth = 1
        self.cornerRadius = cornerRadius
        
    }
    
    func addPinCodeDoubleBorder(with colorOne: UIColor = .primaryDarkBG, and colorTwo: UIColor = .primaryGreen, cornerRadius: CGFloat = 11) {
        
        removeAllSublayers()
        
        layoutIfNeeded()
        layer.name = "Border"
        layer.borderWidth = 1
        if UITraitCollection.current.userInterfaceStyle == .dark {
            //print("Dark mode")
            layer.borderColor = colorOne.cgColor
        }
        else {
            layer.borderColor = colorOne.cgColor
        }
        
        layer.cornerRadius = cornerRadius
        
        let borderLayer = CALayer()
        borderLayer.name = "Border"
        borderLayer.frame = bounds
        borderLayer.borderColor = colorTwo.cgColor
        borderLayer.borderWidth = 2
        borderLayer.cornerRadius = cornerRadius
        layer.insertSublayer(borderLayer, above: layer)
        
    }
    
    func removeAllSublayers() {
        layer.borderWidth = 0
        layer.sublayers?.forEach({ layer in
            layer.borderWidth = 0
            if layer.name == "Border" {
                layer.removeFromSuperlayer()
            }
        })
    }
    
    func getParentController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    
    func roundTopCorners(radius: CGFloat = 10) {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.roundCorners(corners: [.topLeft, .topRight], radius: radius)
        }
    }
    
    func roundBottomCorners(radius: CGFloat = 10) {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            self.roundCorners(corners: [.bottomLeft, .bottomRight], radius: radius)
        }
    }
    
    private func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}

import Foundation

extension CALayer {
    func pause() {
        if self.isPaused() == false {
            let pausedTime: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil)
            self.speed = 0.0
            self.timeOffset = pausedTime
        }
    }

    func isPaused() -> Bool {
        return self.speed == 0.0
    }

    func resume() {
        let pausedTime: CFTimeInterval = self.timeOffset
        self.speed = 1.0
        self.timeOffset = 0.0
        self.beginTime = 0.0
        let timeSincePause: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.beginTime = timeSincePause
    }
}


class ViewWithPersistentAnimations : UIView {
    private var persistentAnimations: [String: CAAnimation] = [:]
    private var persistentSpeed: Float = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didBecomeActive() {
        self.restoreAnimations(withKeys: Array(self.persistentAnimations.keys))
        self.persistentAnimations.removeAll()
        if self.persistentSpeed == 1.0 { //if layer was plaiyng before backgorund, resume it
            self.layer.resume()
        }
    }

    @objc func willResignActive() {
        self.persistentSpeed = self.layer.speed

        self.layer.speed = 1.0 //in case layer was paused from outside, set speed to 1.0 to get all animations
        self.persistAnimations(withKeys: self.layer.animationKeys())
        self.layer.speed = self.persistentSpeed //restore original speed
        self.layer.pause()
    }

    func persistAnimations(withKeys: [String]?) {
        withKeys?.forEach({ (key) in
            if let animation = self.layer.animation(forKey: key) {
                self.persistentAnimations[key] = animation
            }
        })
    }

    func restoreAnimations(withKeys: [String]?) {
        withKeys?.forEach { key in
            if let persistentAnimation = self.persistentAnimations[key] {
                self.layer.add(persistentAnimation, forKey: key)
            }
        }
    }
}

extension UIView {
    func screenshot() -> UIImage {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: bounds.size).image { _ in
                drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            UIGraphicsEndImageContext()
            return image
        }
    }
}
