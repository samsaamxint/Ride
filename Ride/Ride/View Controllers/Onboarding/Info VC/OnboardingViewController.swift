//
//  OnboardingViewController.swift
//  Ride
//
//  Created by Mac on 01/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import AVKit

class OnboardingViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var carIcon: UIImageView!
    var player: AVPlayer?
    var isLogout = false
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if Commons.isArabicLanguage() {
//            let image = carIcon.image!
//            let newImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .upMirrored)
//            carIcon.image = newImage
//        }
        //self.initializeVideoPlayerWithVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //animateCarView()
        if !isLogout{
            self.initializeVideoPlayerWithVideo()
        }else{
            self.goToGenericOnboarding()
        }
    }
   
    func initializeVideoPlayerWithVideo() {
        
        // get the path string for the video from assets
        let videoString:String? = Bundle.main.path(forResource: "newSplash", ofType: "mp4")
        guard let unwrappedVideoPath = videoString else {return}
        
        // convert the path string to a url
        let videoUrl = URL(fileURLWithPath: unwrappedVideoPath)
        player = AVPlayer(url: videoUrl)
        // create a video layer for the player
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
        
      
        player?.play()
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    @objc private func videoDidEnded() {
        self.view.removeAllSublayers()
        NotificationCenter.default.removeObserver(self)
        goToGenericOnboarding()
    }
    
    private func animateCarView() {
        let sign: CGFloat = Commons.isArabicLanguage() ? -1 : 1
        carIcon.transform = CGAffineTransform(translationX: sign * UIScreen.main.bounds.size.width , y: 0)
        
        UIView.animate(withDuration: 1.5) { [weak self] in
            guard let `self` = self else { return }
            self.carIcon.transform = .identity
        } completion: { [weak self] finished in
            guard let `self` = self else { return }
            self.goToGenericOnboarding()
        }
    }
    
    private func goToGenericOnboarding() {
        if let vc: GenericOnboardingViewController = UIStoryboard.instantiate(with: .onboarding) {
            let navVC = OnboardingNavViewController(rootViewController: vc)
            navVC.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
            navVC.navigationBar.shadowImage = UIImage()
            navVC.navigationBar.isTranslucent = true
            navVC.view.backgroundColor = .clear
            navVC.navigationBar.backgroundColor = .clear
            navVC.modalTransitionStyle = .crossDissolve
            navVC.modalPresentationStyle = .overCurrentContext
            present(navVC, animated: true)
        }
    }
    
    //MARK: - UIACTIONS
    @IBAction func didClickOnSkipBtn(_ sender: UIButton) {
        goToGenericOnboarding()
    }
}
