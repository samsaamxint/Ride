//
//  RiderEnterPinVC.swift
//  Ride
//
//  Created by XintMac on 16/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import AVFoundation

class RiderEnterPinVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var rideType: UILabel!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var noOfSeats: UIButton!
    @IBOutlet weak var rideImage: UIImageView!
    @IBOutlet weak var vehicleNo: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var driverRating: UILabel!
    @IBOutlet weak var msgDriver: UIButton!
    @IBOutlet weak var timeEstimateLabel: UILabel!
    @IBOutlet weak var callDriver: UIButton!
    @IBOutlet weak var riderPinToShare: UILabel!
    @IBOutlet weak var cancelRide: UIButton!
    @IBOutlet weak var sharePInLabel: UILabel!
    
    //MARK: - Constants and Variables
    private let cancelTripVM = CancelTripViewmodel()
    var audioPlayer: AVAudioPlayer?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        updateUI()
        bindViewToViewModel()
       
        sendSnapShotToServerIfNeeded()
        
        rideType.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        vehicleName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        noOfSeats.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(12) : UIFont.SFProDisplayMedium?.withSize(12)
        vehicleNo.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        driverName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        riderPinToShare.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(12) : UIFont.SFProDisplayBold?.withSize(12)
        cancelRide.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        sharePInLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        timeEstimateLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        self.playNotificationSound(soundName: "Request Accepted")
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
        
        NotificationCenter.default.post(name: .toggleUserSwitchView, object: "", userInfo: [:])
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.containerViewHeight.constant = 360
        SocketIOHelper.shared.subscribeUser()
        (self.parent?.parent as? MainDashboardViewController)?.navigationItem.leftBarButtonItem = nil
        
    }
    
    private func sendSnapShotToServerIfNeeded() {
        let trip = RideSingleton.shared.tripDetailObject?.data
        
        let fromLoc = CLLocationCoordinate2D(latitude: trip?.source?.latitude ?? DefaultValue.double,
                                             longitude: trip?.source?.longitude ?? DefaultValue.double)
        
        let toLoc = CLLocationCoordinate2D(latitude: trip?.destination?.latitude ?? DefaultValue.double,
                                             longitude: trip?.destination?.longitude ?? DefaultValue.double)
        
        Commons.getRouteSteps(from: fromLoc, to: toLoc, needSnapShot: true) { _, _, _ in
            
        }
    }
    
    private func updateUI(){
        
        let tripObj = RideSingleton.shared.tripDetailObject
        if Commons.isArabicLanguage(){
            rideType.text = tripObj?.data?.cabInfo?.nameArabic
            vehicleName.text = tripObj?.data?.cabInfo?.descriptionArabic
        }else{
            rideType.text = tripObj?.data?.cabType
            vehicleName.text = tripObj?.data?.cabInfo?.description
        }
      
        noOfSeats.setTitle(String(tripObj?.data?.cabInfo?.noOfSeats ?? DefaultValue.int), for: .normal)
        if let url = URL(string: tripObj?.data?.driverInfo?.profileImage ?? "") {
            driverImage.kf.setImage(with: url, placeholder: UIImage(named: "DImages"))
        }
        let platno = tripObj?.data?.driverInfo?.carPlateNo
        let seperatedText = platno?.components(separatedBy: "-")
        if let arabicText = seperatedText?[1]{
            let characters = Array(arabicText).reversed()
            print(characters)
            var plateNo = ""
            for char in characters{
                plateNo = plateNo + "  \(char)"
            }
            vehicleNo.text = plateNo + " - " + (seperatedText?[0] ?? "")
        }
        //vehicleNo.text = tripObj?.data?.driverInfo?.carPlateNo?.decodingUnicodeCharacters
        
        // Time connverter in minutes
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone.current //Current time zone
        let date = dateFormatter.date(from: "\(tripObj?.data?.estimatedTripTime ?? 0.0)") //according to date format your date string
        print(date ?? "") //Convert String to Date

        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date!)
        let hour = comp.hour ?? 0
        let minute = comp.minute ?? 0
        print(hour)
        let finalMinut:Int = (hour * 60) + minute
        print(finalMinut)
        
        if Commons.isArabicLanguage() {
            if finalMinut <= 0 {
                self.timeEstimateLabel.text =  " 1 " + "mins".localizedString()
            } else {
                self.timeEstimateLabel.text =  "\(finalMinut)" + "mins".localizedString()
            }
            
        } else {
            if finalMinut <= 0 {
                self.timeEstimateLabel.text = "Estimated Time".localizedString() + " 1 "  + "mins".localizedString()
            } else {
                self.timeEstimateLabel.text = "Estimated Time".localizedString() + "\(finalMinut)"  + "mins".localizedString()
            }
        }
       
        var fullName = tripObj?.data?.driverInfo?.name
        if Commons.isArabicLanguage(){
            fullName = tripObj?.data?.driverInfo?.arabicName
        }
        let firstName = fullName?.components(separatedBy: " ")
        driverName.text =  firstName?[0]
        driverRating.text = String(tripObj?.data?.driverInfo?.rating ?? DefaultValue.string)
        riderPinToShare.text = String(tripObj?.data?.tripOtp ?? DefaultValue.int)
        
        updateMapUI()
       
    }
    
    private func updateMapUI() {
        let parent = self.parent?.parent as? MainDashboardViewController
        let tripDetails = RideSingleton.shared.tripDetailObject
        parent?.mapView?.clear()
        parent?.addCurrentLocationMarker()
        var cords: [CLLocationCoordinate2D] = []
        cords.append(CLLocationCoordinate2D.init(latitude: tripDetails?.data?.driverInfo?.latitude ?? 0.0, longitude: tripDetails?.data?.driverInfo?.longitude ?? 0.0))
        parent?.drawCabMarkers(cords: cords)
        drawPolyLine()
    }
    
    private func drawPolyLine() {
        let tripObj = RideSingleton.shared.tripDetailObject
        let riderLoc = CLLocationCoordinate2D.init(latitude: tripObj?.data?.source?.latitude ?? DefaultValue.double,
                                                   longitude: tripObj?.data?.source?.longitude ?? DefaultValue.double)
        
        let driverLoc = CLLocationCoordinate2D.init(latitude: tripObj?.data?.driverInfo?.latitude ?? DefaultValue.double,
                                                    longitude: tripObj?.data?.driverInfo?.longitude ?? DefaultValue.double)
        
        let marker = GMSMarker(position: riderLoc)
        marker.map = (self.parent?.parent as? MainDashboardViewController)?.mapView
        //(self.parent?.parent as? MainDashboardViewController)?.

        Commons.getRouteSteps(from: driverLoc, to: riderLoc,needSnapShot: false, isDrawPolyLine: true) { polyline, polylines, route in
            for polyline in polylines ?? [] {
                polyline.map = (self.parent?.parent as? MainDashboardViewController)?.mapView
                
                var bounds = GMSCoordinateBounds()
                if let plylines = route?.polyLine {
                    for route in plylines {
                        for index in 1...(route.path?.count())! {
                            bounds = bounds.includingCoordinate((route.path?.coordinate(at: index))!)
                        }
                    }
                }
                bounds = bounds.includingCoordinate(riderLoc)
                bounds = bounds.includingCoordinate(driverLoc)
                let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(60))
                (self.parent?.parent as? MainDashboardViewController)?.mapView?.animate(with: update)
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func cancelRidePressed(_ sender: Any) {
        //cancelTripVM.cancelTrip(id: UserDefaultsConfig.tripId ?? "")
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.containerViewHeight.constant = 450
        if let vc : CancelRideByDriverViewController = UIStoryboard.instantiate(with: .driverToRider){
            vc.type = .CANCEL_BY_RIDER
            self.navigationController?.pushViewController(vc, animated: false)
        }
            
    }
    
    @IBAction func msgDriverPressed(_ sender: Any) {
        if let vc: MainChatVC = UIStoryboard.instantiate(with: .chat) {
            vc.receiverChatId = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.id
            var image = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.profileImage
            var fullName = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.name
            if Commons.isArabicLanguage(){
                fullName = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.arabicName
            }
            let firstName = fullName?.components(separatedBy: " ")
            vc.chatName = firstName?[0]
            vc.chatImage = image
            parent?.parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func callDriverPressed(_ sender: Any) {
        let number = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.mobile ?? ""
        guard let number = URL(string: "tel://+\(number)") else { return }
        UIApplication.shared.open(number)
    }
}


extension RiderEnterPinVC {
    func bindViewToViewModel() {
        cancelTripVM.cancelTripResponse.bind { [weak self] res in
            guard let self = self else { return }
            if res.statusCode == 200{
                print("msg : ",res.message as Any)
                ( self.parent?.parent as? MainDashboardViewController)?.setupSwitchUserModeView()
                let controllers = self.navigationController?.viewControllers ?? []
                for vc in controllers{
                    if vc.isKind(of: RiderDropOffVC.self){
                        self.navigationController?.popToViewController(vc, animated: false)
                        return
                    }
                }
            }else{
                print("res : ",res.data as Any)
            }
        }
        
        
        cancelTripVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
    }
}
