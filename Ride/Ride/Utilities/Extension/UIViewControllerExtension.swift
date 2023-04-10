//
//  UIViewControllerExtension.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

//To show custom indicator
var customLoaderView: UIView?
var customLoaderBG: UIView?
let kCustomLoaderViewTag = 3218

extension UIViewController {
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? DefaultValue.cgfloat) +
        (self.navigationController?.navigationBar.frame.height ?? DefaultValue.cgfloat)
    }
    
    
    func getAppNavBackButton() -> UIButton {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        backButton.cornerRadius = backButton.frame.height / 2
        backButton.layoutIfNeeded()
        if #available(iOS 13.0, *) {
            backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        } else {
            backButton.setTitleColor(.primaryDarkBG, for: .normal)
            backButton.setTitle("Back", for: .normal)
        }
        backButton.tintColor = .primaryDarkBG
        backButton.backgroundColor = .primarybackBtn
        backButton.borderWidth = 1
        backButton.borderColor = .sepratorColor
        return backButton
    }
    
    func getAppNavRightBackButton() -> UIButton {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        backButton.cornerRadius = backButton.frame.height / 2
        backButton.layoutIfNeeded()
        if #available(iOS 13.0, *) {
            backButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        } else {
            backButton.setTitleColor(.primaryDarkBG, for: .normal)
            backButton.setTitle("Back", for: .normal)
        }
        backButton.tintColor = .primaryDarkBG
        backButton.backgroundColor = .primarybackBtn
        backButton.borderWidth = 1
        backButton.borderColor = .sepratorColor
        return backButton
    }
    
    func getAppNavSkipButton() -> UIButton {
        let skipButton = UIButton()
        skipButton.titleLabel?.font = UIFont.SFProDisplayRegular?.withSize(16)
        skipButton.setTitleColor(.primaryDarkBG, for: .normal)
        skipButton.setTitle("Skip", for: .normal)
        return skipButton
    }
    
    func setLeftBackButton(selector: Selector , rotate : Bool = true) {
        let backButton = getAppNavBackButton()
        if rotate{
            backButton.rotateBtnIfNeeded()
        }
        backButton.addTarget(self, action: selector, for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func getAppSettingsButton() -> UIButton {
        let settingsBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        settingsBtn.cornerRadius = settingsBtn.frame.height / 2
        settingsBtn.layoutIfNeeded()
        if #available(iOS 13.0, *) {
            settingsBtn.setImage(UIImage(named: "VerticalSettings"), for: .normal)
            settingsBtn.tintColor = .primaryDarkBG
        } else {
            settingsBtn.setTitleColor(.primaryDarkBG, for: .normal)
            settingsBtn.setTitle("Back", for: .normal)
        }
        settingsBtn.tintColor = .primaryDarkBG
        settingsBtn.backgroundColor = .primaryLightTextColor
        settingsBtn.borderWidth = 1
        settingsBtn.borderColor = .sepratorColor
        return settingsBtn
    }
    
    func setLeftSettingsButton(selector: Selector) {
        let settingBtn = getAppSettingsButton()
        //settingBtn.rotateBtnIfNeeded()
        settingBtn.addTarget(self, action: selector, for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingBtn)
    }
    
    private func getProfileImage() -> UIImageView {
        
        let liveIcon = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 3))
       
        let profileIV = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        profileIV.translatesAutoresizingMaskIntoConstraints = false
        profileIV.widthAnchor.constraint(equalToConstant: 38).isActive = true
        profileIV.heightAnchor.constraint(equalToConstant: 38).isActive = true
        profileIV.cornerRadius = 19
        profileIV.backgroundColor = .black
        profileIV.contentMode = .scaleAspectFit
        profileIV.layoutIfNeeded()
//        profileIV.image = UIImage(named: "DummyProfile")
        profileIV.kf.setImage(with: URL(string: UserDefaultsConfig.user?.profileImage ?? ""), placeholder: UIImage(named: (UserDefaultsConfig.isDriver ? "DImages" :  "DummyProfile")))
        profileIV.backgroundColor = .black
        profileIV.borderWidth = 2
        profileIV.borderColor = .primaryLightTextColor
       
        
//        profileIV.addSubview(liveIcon)
//        liveIcon.translatesAutoresizingMaskIntoConstraints = false
//        liveIcon.widthAnchor.constraint(equalToConstant: 5).isActive = true
//        liveIcon.heightAnchor.constraint(equalToConstant: 5).isActive = true
//        liveIcon.trailingAnchor.constraint(equalTo: profileIV.trailingAnchor).isActive = true
//        liveIcon.topAnchor.constraint(equalTo: profileIV.topAnchor, constant: -10).isActive = true
//        liveIcon.cornerRadius = 2.5
//        liveIcon.layoutIfNeeded()
//        liveIcon.backgroundColor = .greenTextColor
//        profileIV.bringSubviewToFront(liveIcon)
        
        
        return profileIV
    }
    
    func setProfileNavButton(selector: Selector) {
        let profileIV = getProfileImage()
        profileIV.isUserInteractionEnabled = true
        profileIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileIV)
    }
    
    func addChildWithNavViewController(childController: UIViewController, contentView: UIView) {
        
        let navChild = UINavigationController(rootViewController: childController)
        navChild.setNavigationBarHidden(true, animated: false)
        // First, add the view of the child to the view of the parent
        contentView.addSubview(navChild.view)
        
        navChild.view.translatesAutoresizingMaskIntoConstraints = false
        navChild.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        navChild.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        navChild.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        navChild.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        // Then, add the child to the parent
        addChild(navChild)

        // Finally, notify the child that it was moved to a parent
        navChild.didMove(toParent: parent)
    }
    
    func addChildViewController(childController: UIViewController, contentView: UIView) {
        contentView.addSubview(childController.view)
        
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        childController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        childController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        childController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        childController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        // Then, add the child to the parent
        addChild(childController)

        // Finally, notify the child that it was moved to a parent
        childController.didMove(toParent: parent)
    }
    
    func removeChildController() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func showLoader(startAnimate:Bool? = true, _ msg: String? = "") {
        if !Reachability.isConnectedToNetwork() {
            if let parent = self.parent?.parent?.navigationController {
                Commons.showErrorMessage(controller: parent , message: "Please Connect to internet")
            } else {
                Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Please Connect to internet")
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            guard let topViewController = UIApplication.topViewController() else { return }
//            var window: UIWindow?
//            if let wind = topViewController.view.window {
//                window = wind
//            } else {
//                window = topViewController.presentingViewController?.view.window
//            }
            guard let window = topViewController.view.window else { return }
            let customLoaderViewToBeRemoved : UIView? = window.viewWithTag(kCustomLoaderViewTag)

            if startAnimate!
            {
                // Don't add if already present
                if customLoaderViewToBeRemoved != nil {
                    return
                }

                let height = CGFloat(70)
                
                let loader = Indicator.init()
                customLoaderBG = UIView.init()
                customLoaderBG?.backgroundColor = UIColor.clear
                customLoaderBG?.cornerRadius = 8.0
                customLoaderBG?.shadow = true
                customLoaderBG?.isOpaque = true

                
                customLoaderView = UIView()
                customLoaderView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)

                //UIApplication.topViewController()?.view.addSubview(customLoaderView!)
                customLoaderView?.tag = kCustomLoaderViewTag
//                guard let topViewController = UIApplication.topViewController() else { return }
//                guard let window = topViewController.view.window else { return }
                window.addSubview(customLoaderView!)
                window.bringSubviewToFront(customLoaderView!)

                customLoaderView?.addSubview(customLoaderBG!)
                customLoaderBG?.addSubview(loader)

                customLoaderBG?.addCenterLayout()
                
                loader.addCenterLayout()
                loader.setFixedLayoutAttribute(attribute: NSLayoutConstraint.Attribute.height, constant: height)
                loader.setFixedLayoutAttribute(attribute: NSLayoutConstraint.Attribute.width, constant: height)

                customLoaderView?.addParentFullLayout()
                customLoaderBG?.setFixedLayoutAttribute(attribute: NSLayoutConstraint.Attribute.height, constant: 140)
                customLoaderBG?.setFixedLayoutAttribute(attribute: NSLayoutConstraint.Attribute.width, constant: 140 )

                loader.show(text:  msg)
            }
            else
            {
                UIView.animate(withDuration: 0.1, animations: {
                    if customLoaderViewToBeRemoved != nil {
                        customLoaderViewToBeRemoved!.alpha = 0
                    }
                }, completion: { (isComplete) in
                    if customLoaderViewToBeRemoved != nil {
                        customLoaderViewToBeRemoved!.removeFromSuperview()
                    }
                })

            }
        }
    }
    func stopLoader(){
        guard let topViewController = UIApplication.topViewController() else { return }
        guard let window = topViewController.view.window else { return }
        let customLoaderViewToBeRemoved : UIView? = window.viewWithTag(kCustomLoaderViewTag)
        if customLoaderViewToBeRemoved != nil {
            customLoaderViewToBeRemoved!.removeFromSuperview()
        }
    }
    
//    func playNotificationSound(soundName : String){
//        var player = AVAudioPlayer()
//        do {
//            let path = Bundle.main.path(forResource: soundName, ofType : "mp3")!
//            let url = URL(fileURLWithPath : path)
//            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//            /* iOS 10 and earlier require the following line:
//             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
//            //guard let player = player else { return }
//            player.play()
//        } catch {
//            print ("There is an issue with this code!")
//        }
//    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
