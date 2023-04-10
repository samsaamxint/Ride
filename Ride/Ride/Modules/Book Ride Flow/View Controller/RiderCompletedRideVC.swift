//
//  RiderCompletedRideVC.swift
//  Ride
//
//  Created by XintMac on 16/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import AVFoundation

class RiderCompletedRideVC: UIViewController {

     //MARK: - IBOutlets
    @IBOutlet weak var rateCaptainLbl: UILabel!
    @IBOutlet weak var captainNameLbl: UILabel!
    @IBOutlet weak var downloadVATBtn: UIButton!
    @IBOutlet weak var submitRatingBtn: UIButton!
    @IBOutlet var ratingViews: [UIButton]!
    @IBOutlet weak var paymentLbl: UILabel!
    @IBOutlet weak var totalPaymentLable: UILabel!
    @IBOutlet weak var balancelLbl: UILabel!
    @IBOutlet weak var userBalance: UILabel!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var loyalityPoints: UILabel!
    
    //MARK: - Constants and Variables
    private let ratingVieWModel = RatingViewModel()
    private var selectedRatingIndex = 1
    private var tripId = ""
    private let balanceVM = BalanceViewModel()
    var audioPlayer: AVAudioPlayer?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        UserDefaultsConfig.rideCount += 1
        
        bindViewToViewModel()
        balanceVM.getBalance()
        tripId = UserDefaultsConfig.tripId ?? ""
        
        UserDefaultsConfig.tripId = nil
        RideSingleton.shared.tripDetailObject = nil
        
        rateCaptainLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(15) : UIFont.SFProDisplayMedium?.withSize(15)
        captainNameLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        downloadVATBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(15) : UIFont.SFProDisplayBold?.withSize(18)
        submitRatingBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        paymentLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        totalPaymentLable.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        balancelLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        userBalance.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        pointsLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        
        paymentLbl.textAlignment = Commons.isArabicLanguage() ? .right : .left
        totalPaymentLable.textAlignment = paymentLbl.textAlignment
        balancelLbl.textAlignment = paymentLbl.textAlignment
        userBalance.textAlignment = paymentLbl.textAlignment
        pointsLbl.textAlignment = paymentLbl.textAlignment
        loyalityPoints.textAlignment = paymentLbl.textAlignment
        
        self.playNotificationSound(soundName: "Trip Ended")
        
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
    
    
    private func resetBorders() {
        ratingViews.forEach { button in
            button.borderWidth = 0
        }
    }
    
    private func setupViews() {
        resetBorders()
        submitRatingBtn.enableButton(false)
        
        
        var fullName = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.name
        if Commons.isArabicLanguage(){
            fullName = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.arabicName
        }
        let firstName = fullName?.components(separatedBy: " ")
        captainNameLbl.text =  firstName?[0]
        totalPaymentLable.text  = String(RideSingleton.shared.tripDetailObject?.data?.riderAmount ?? 0.0) + " SAR"
        //captainNameLbl.text = RideSingleton.shared.tripDetailObject?.data?.driverInfo?.name
        
        if let url = URL(string: RideSingleton.shared.tripDetailObject?.data?.driverInfo?.profileImage ?? "") {
            driverImageView.kf.setImage(with: url)
        }
        
        
//        let newBalance = (RideSingleton.shared.userBalance ?? 0.0) - (RideSingleton.shared.tripDetailObject?.data?.riderAmount ?? 0.0)
//        RideSingleton.shared.userBalance = newBalance
//        userBalance.text = "\(NSString(format: "%.2f", newBalance )) SAR"
    }
    
    private func resetToRiderMainView() {
        let parent = (parent?.parent as? MainDashboardViewController)
        parent?.setupSwitchUserModeView()
        
        parent?.containerViewHeight.constant = 100
        navigationController?.popToRootViewController(animated: false)
    }
    
    //MARK: - UIACTIONS
    @IBAction func ratingViewSelected(_ sender: UIButton) {
        resetBorders()
        ratingViews[sender.tag - 1].addDoubleBorder(cornerRadius: 22)
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            // light mode detected
            submitRatingBtn.enableButton(true)
        case .dark:
            // dark mode detected
            submitRatingBtn.enableButton(true)
            submitRatingBtn.backgroundColor = .primaryGreen
        }
        selectedRatingIndex = sender.tag
    }
    
    @IBAction func submitRatingClicked(_ sender: Any) {
        ratingVieWModel.reviewDriver(title: "test", desc: "", rating: Float(selectedRatingIndex), tripid: tripId)
    }
    @IBAction func didTapDownloadInvoice(_ sender: Any) {
        if let vc: InvoiceViewController = UIStoryboard.instantiate(with: .invoice) {
            let rider = CustomUser(firstName: UserDefaultsConfig.user?.firstName)
            
            let tripDetail = TripsDetails(id : tripId ,riderAmount: Double(totalPaymentLable.text?.replacingOccurrences(of: " SAR", with: "") ?? "0"), rider: rider, createdAt: FormattedDate(string: "Just Now"))
            vc.tripData = tripDetail
            
            parent?.parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - API
extension RiderCompletedRideVC{
    func bindViewToViewModel() {
        ratingVieWModel.submitRatingResponse.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200 || res.statusCode == 201 {
                self.resetToRiderMainView()
            }
        }
        
        ratingVieWModel.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        ratingVieWModel.apiResponseMessage.bind { [weak self] (value) in
            guard let `self` = self else { return }
            guard !value.isEmpty else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: value)
        }
        
        balanceVM.apiResponseData.bind {[weak self] (value) in
            guard let `self` = self else { return }
            
            if value.statusCode == 200 {
                self.userBalance.text = "\(NSString(format: "%.2f", value.data?.balance ?? 0.0 )) SAR"
            }
        }
        
        balanceVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
//            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
    }
}
