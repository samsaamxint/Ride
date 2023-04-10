//
//  RideDetailsVC.swift
//  Ride
//
//  Created by PSE on 11/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class RideDetailsVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var rideName: UILabel!
    @IBOutlet weak var rideDateTime: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var yourCaptainLbl: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var carType: UILabel!
    @IBOutlet weak var carNumberPlate: UILabel!
    @IBOutlet weak var subTotallabel: UILabel!
    @IBOutlet weak var taxAmountLabel: UILabel!
    @IBOutlet weak var ridePayment: UILabel!
    @IBOutlet weak var loyaltyPOints: UILabel!
    @IBOutlet weak var reportAProblem: UIButton!
    @IBOutlet weak var invoiceView: UIView!
    @IBOutlet weak var yourCaptainNameLbl: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var ratingMainView: UIStackView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var rideStatusLbl: UILabel!
    @IBOutlet weak var carTypelbl: UILabel!
    @IBOutlet weak var noPlateLbl: UILabel!
    @IBOutlet weak var subTotalLbl: UILabel!
    @IBOutlet weak var taxAmountLbl: UILabel!
    @IBOutlet weak var paymentLbl: UILabel!
    @IBOutlet weak var downloadVatBtn: UIButton!
    @IBOutlet weak var downloadVATBtn: UIView!
    
    //MARK: - Constants and Variables
    var tripData: TripsDetails?
    var tripType: MyRidesType?
    var carPlateNo : String?
    var taxAmount : Double?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        downloadVATBtn.isHidden = tripType == .RidesGiven
    }
    
    override func viewDidLayoutSubviews() {
        rideName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        rideDateTime.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        yourCaptainLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        driverName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        carType.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        carNumberPlate.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.MadaniArabicBold?.withSize(16)
        subTotallabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        taxAmountLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        ridePayment.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        loyaltyPOints.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        reportAProblem.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        yourCaptainNameLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        ratingLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        carTypelbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        noPlateLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        subTotalLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        taxAmountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        paymentLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        downloadVatBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        rideStatusLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(15) : UIFont.SFProDisplayMedium?.withSize(15)
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped),rotate: false)
        setupData()
        
        
    }
    
    private func setupData() {
        if tripType == .RidesTaken {
            yourCaptainNameLbl.text = "Your Captain".localizedString()
            driverName.text = tripData?.driver?.firstName
            if Commons.isArabicLanguage(){
                driverName.text = tripData?.driver?.arabicFirstName
            }
            taxAmountLabel.text = String(taxAmount ?? 0.0) + " SAR"
            let subtotal = (tripData?.riderAmount ?? DefaultValue.double) - (taxAmount ?? 0.0)
            subTotallabel.text = (NSString(format: "%.2f",subtotal) as String) + " SAR"
            ridePayment.text = "\(tripData?.riderAmount ?? DefaultValue.double)" + " SAR"
            taxAmountLbl.text = "VAT Amount"
        } else {
            yourCaptainNameLbl.text = "Your Rider".localizedString()
            driverName.text = tripData?.rider?.firstName
            if Commons.isArabicLanguage(){
                driverName.text = tripData?.rider?.arabicFirstName
            }
            taxAmountLabel.text = "0.5 SAR" // + String(taxAmount ?? 0.0)
            let subtotal = (tripData?.driverAmount ?? DefaultValue.double) - 0.5 //(taxAmount ?? 0.0)
            subTotallabel.text = (NSString(format: "%.2f",subtotal) as String) + " SAR"
            ridePayment.text = "\(tripData?.driverAmount ?? DefaultValue.double)" + " SAR"
            
            taxAmountLbl.text = "Transaction Fees"
        }
        
        
        mapImageView.kf.indicatorType = .activity
        mapImageView.kf.setImage(with: URL(string: tripData?.images?.first?.url ?? DefaultValue.string))
        carType.text = Commons.isArabicLanguage() ? tripData?.cab?.nameArabic : tripData?.cab?.name
        rideDateTime.text = tripData?.createdAt
        ratingLbl.text = tripData?.riderReview?.rating ?? ""
        ratingMainView.isHidden = tripData?.riderReview.isNone ?? true
        
        if let platno = carPlateNo, !platno.isEmpty {
            let seperatedText = platno.components(separatedBy: "-")
            let arabicText = seperatedText[1]
            let characters = Array(arabicText).reversed()
            print(characters)
            var plateNo = ""
            for char in characters{
                plateNo = plateNo + "  \(char)"
            }
            carNumberPlate.text = plateNo + " - " + (seperatedText.first ?? "")
            
        }
        
        let status = tripData?.status
        
        if status == .PENDING {
            rideStatusLbl.text = "Pending".localizedString()
        } else if status == .ACCEPTED_BY_DRIVER {
            rideStatusLbl.text = "Trip Accepted".localizedString()
        } else if status == .REJECTED_BY_DRIVER {
            rideStatusLbl.text = "Trip Rejected".localizedString()
        } else if status == .CANCELLED_BY_RIDER || status == .CANCELLED_BY_DRIVER || status == .CANCELLED_BY_ADMIN || status == .BOOKING_CANCELLED {
            rideStatusLbl.text = "Trip Cancelled".localizedString()
        } else if status == .DRIVER_ARRIVED {
            rideStatusLbl.text = "Driver Arrived".localizedString()
        } else if status == .STARTED {
            rideStatusLbl.text = "Trip Started".localizedString()
        } else if status == .COMPLETED {
            rideStatusLbl.text = "Trip Completed".localizedString()
        } else if status == .EXPIRED {
            rideStatusLbl.text = "Trip Expired".localizedString()
        }
        
    }
    
    // MARK: - Navigation
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - IBActions
    @IBAction func reportProblemPressed(_ sender: Any) {
        if let vc: ReportaProblemVC = UIStoryboard.instantiate(with: .userProfile) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func downloadVATPressed(_ sender: Any) {
        
        if let vc: InvoiceViewController = UIStoryboard.instantiate(with: .invoice) {
            vc.tripData = self.tripData
            navigationController?.pushViewController(vc, animated: false)
        }
        
//        let OptionAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
//
//        let shareAction = UIAlertAction(title: "Share", style: .destructive) { (action: UIAlertAction) in
//            let screenShot = self.invoiceView.screenshot()
//            let items = [screenShot]
//            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//            self.present(ac, animated: true)
//        }
//
//        let downloadAction = UIAlertAction(title: "Download", style: .destructive) { (action: UIAlertAction) in
//            let screenShot = self.invoiceView.screenshot()
////            let imageSaver = ImageSaver()
//            self.writeToPhotoAlbum(image: screenShot)
//        }
//
//        OptionAlert.addAction(shareAction)
//        OptionAlert.addAction(downloadAction)
//        self.present(OptionAlert, animated: true, completion: nil)

    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
        Commons.showErrorMessage(controller:  self.navigationController ?? self,backgroundColor: .lightGreen,textColor: .greenTextColor, message: "Image saved to gallery".localizedString())
    }
    
    
}
