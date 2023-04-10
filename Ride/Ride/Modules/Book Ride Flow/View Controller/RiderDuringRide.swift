//
//  RiderDuringRide.swift
//  Ride
//
//  Created by XintMac on 16/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import AVFoundation

class RiderDuringRide: UIViewController {
    
     //MARK: - IBOutlets
    @IBOutlet weak var riderPickUpLocation: UILabel!
    @IBOutlet weak var riderDropOffLocation: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var changeDestinationBtn: UIButton!
    @IBOutlet weak var rideTypeLbl: UILabel!
    @IBOutlet weak var rideNameLbl: UILabel!
    @IBOutlet weak var noOfSeatBtn: UIButton!
    @IBOutlet weak var plateNoLbl: UILabel!
    @IBOutlet weak var driverNameLbl: UILabel!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var lblHelpWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeBtn: UIButton!
    
    var isChangeDestination  = false
    var audioPlayer: AVAudioPlayer?
    
     //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(RideSingleton.shared.tripDetailObject?.data?.tripDistance)
        setupViews()
        
        riderPickUpLocation.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        riderDropOffLocation.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        changeDestinationBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(15) : UIFont.SFProDisplayBold?.withSize(15)
        rideTypeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        rideNameLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        noOfSeatBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(12) : UIFont.SFProDisplayMedium?.withSize(12)
        //plateNoLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        driverNameLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        helpBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(15) : UIFont.SFProDisplayBold?.withSize(15)
        errorLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(12) : UIFont.SFProDisplayMedium?.withSize(12)
        changeBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(15) : UIFont.SFProDisplayBold?.withSize(15)
        self.playNotificationSound(soundName: "Trip Started")
    }
    
    func playNotificationSound(soundName : String){
       
        if let bundle = Bundle.main.path(forResource: soundName, ofType: "mp3") {
                   let backgroundMusic = NSURL(fileURLWithPath: bundle)
                   do {
                       audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                       guard let audioPlayer = audioPlayer else { return }
                       audioPlayer.prepareToPlay()
                       audioPlayer.play()
                   } catch {
                       print(error)
                   }
               }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.containerViewHeight.constant = 320
        let tripObj = RideSingleton.shared.tripDetailObject
        if let newDestination = tripObj?.data?.destinationNew?.address{
            if !newDestination.isEmpty{
                updateView()
            }
        }
        SocketIOHelper.shared.subscribeUser()
        parent?.navigationItem.leftBarButtonItem = nil
    }
    
    private func setupViews() {
        let tripDet = RideSingleton.shared.tripDetailObject?.data
        riderPickUpLocation.text = tripDet?.source?.address
        riderDropOffLocation.text =  isChangeDestination ? tripDet?.destinationNew?.address : tripDet?.destination?.address
        
        rideTypeLbl.text = tripDet?.cabType
        rideNameLbl.text = tripDet?.cabInfo?.description
        
        noOfSeatBtn.setTitle("\(tripDet?.cabInfo?.noOfSeats ?? DefaultValue.int)", for: .normal)
        
        if let url = URL(string: tripDet?.driverInfo?.profileImage ?? "") {
            profileImageView.kf.setImage(with: url)
        }
        self.lblHelpWidthConstraint.constant = Commons.isArabicLanguage() ? 70 : 45
        
        let platno = tripDet?.driverInfo?.carPlateNo
        let seperatedText = platno?.components(separatedBy: "-")
        if let arabicText = seperatedText?[1]{
            let characters = Array(arabicText).reversed()
            print(characters)
            var plateNo = ""
            for char in characters{
                plateNo = plateNo + "  \(char)"
            }
            plateNoLbl.text = plateNo + " - " + (seperatedText?[0] ?? "")
        }
        
        
        var fullName = tripDet?.driverInfo?.name
        if Commons.isArabicLanguage(){
            fullName = tripDet?.driverInfo?.arabicName
        }
        let firstName = fullName?.components(separatedBy: " ")
        driverNameLbl.text =  firstName?[0]
       
        
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.navigationItem.leftBarButtonItem = nil
        
        let tripObj = RideSingleton.shared.tripDetailObject
        self.instructionsLabel.text = "Go straight".localizedString() + (String(RideSingleton.shared.tripDetailObject?.data?.tripDistance ?? 0.0) ?? "0.1 m")
        let source = CLLocationCoordinate2D.init(latitude: tripObj?.data?.source?.latitude ?? DefaultValue.double,
                                                 longitude: tripObj?.data?.source?.longitude ?? DefaultValue.double)
        
        var destination = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
        if let newDestination = tripObj?.data?.destinationNew?.address{
            if newDestination.isEmpty{
                destination = CLLocationCoordinate2D.init(latitude: tripObj?.data?.destination?.latitude ?? DefaultValue.double,
                                                          longitude: tripObj?.data?.destination?.longitude ?? DefaultValue.double)
            }else{
                destination = CLLocationCoordinate2D.init(latitude: tripObj?.data?.destinationNew?.latitude ?? DefaultValue.double,
                                                          longitude: tripObj?.data?.destinationNew?.longitude ?? DefaultValue.double)
            }
            
        }
        parent?.drawPolyLine(startingLoc: source,
                             endingLocation: destination, isDrawPolyLine: true)
    }
    
  
    func updateView() {
        let tripDet = RideSingleton.shared.tripDetailObject?.data
        riderPickUpLocation.text = tripDet?.source?.address
        riderDropOffLocation.text =  isChangeDestination ? tripDet?.destinationNew?.address : tripDet?.destination?.address
        self.errorLabel.isHidden = false
        self.changeBtn.setTitleColor(.lightGray, for: .normal)
        self.changeBtn.isUserInteractionEnabled = false
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.navigationItem.leftBarButtonItem = nil
        parent?.containerViewHeight.constant = 360
        
        let tripObj = RideSingleton.shared.tripDetailObject
        let source = CLLocationCoordinate2D.init(latitude: tripObj?.data?.source?.latitude ?? DefaultValue.double,
                                                 longitude: tripObj?.data?.source?.longitude ?? DefaultValue.double)
        self.instructionsLabel.text = "Go straight".localizedString() + (String(RideSingleton.shared.tripDetailObject?.data?.tripDistance ?? 0.0) ?? "0.1 m")
        var destination = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
        if let newDestination = tripObj?.data?.destinationNew?.address{
            if newDestination.isEmpty{
                destination = CLLocationCoordinate2D.init(latitude: tripObj?.data?.destination?.latitude ?? DefaultValue.double,
                                                          longitude: tripObj?.data?.destination?.longitude ?? DefaultValue.double)
            }else{
                destination = CLLocationCoordinate2D.init(latitude: tripObj?.data?.destinationNew?.latitude ?? DefaultValue.double,
                                                          longitude: tripObj?.data?.destinationNew?.longitude ?? DefaultValue.double)
            }
        }
        
        parent?.drawPolyLine(startingLoc: source,
                             endingLocation: destination)
    }

     //MARK: - IBActions
    @IBAction func helpPressed(_ sender: Any) {
        if let vc: HelpRiderVC = UIStoryboard.instantiate(with: .riderToDriver) {
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func changePressed(_ sender: Any) {
        if let vc: RiderDropOffVC = UIStoryboard.instantiate(with: .riderPickup) {
            vc.toChangeDestination = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
}
