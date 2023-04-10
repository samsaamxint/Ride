//
//  InvoiceViewController.swift
//  Ride
//
//  Created by Mac on 29/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class InvoiceViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var invoiceTitle: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addresLbl: UILabel!
    @IBOutlet weak var vatNumberLbl: UILabel!
    @IBOutlet weak var invoiceLbl: UILabel!
    @IBOutlet weak var issuanceDate: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var rideUnitPrice: UILabel!
    @IBOutlet weak var natureOfServce: UILabel!
    @IBOutlet weak var natureOfServiceRide: UILabel!
    @IBOutlet weak var serviceQuanlity: UILabel!
    @IBOutlet weak var rideQuality: UILabel!
    @IBOutlet weak var rideVAT: UILabel!
    @IBOutlet weak var riderTotal: UILabel!
    @IBOutlet weak var compnayUnitPrice: UILabel!
    @IBOutlet weak var companyVAT: UILabel!
    @IBOutlet weak var companyTotal: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var totalVAT: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalAmountDue: UILabel!
    @IBOutlet weak var QRCode: UIImageView!
    @IBOutlet weak var discountAmount: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var invoiceView: UIScrollView!
    
    @IBOutlet weak var supplierLbl: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var vat: UILabel!
    @IBOutlet weak var invoice: UILabel!
    @IBOutlet weak var issuanceDateLbl: UILabel!
    @IBOutlet weak var customerLbl: UILabel!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var nosLbl: UILabel!
    @IBOutlet weak var unitPriceLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var iSEV: UILabel!
    @IBOutlet weak var iSIV: UILabel!
    @IBOutlet weak var totalAmountTitle: UILabel!
    @IBOutlet weak var totalEV: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var totalVATXV: UILabel!
    @IBOutlet weak var ttoalVatLbl: UILabel!
    @IBOutlet weak var totalAmountDueLbl: UILabel!
    @IBOutlet weak var systemLbl: UILabel!
    //MARK: - Constants and Variables
    var tripData: TripsDetails?
    private let riderVM = RideDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        riderVM.getTripDetail(tripid: tripData?.id ?? "")
        riderVM.getInvoiceDetail(tripid: tripData?.id ?? "")
        bindToViewModel()
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped),rotate: false)
        setupInvoice()
        
       issuanceDate.textAlignment = Commons.isArabicLanguage() ? .right : .left
        titleLbl.textAlignment = issuanceDate.textAlignment
        addresLbl.textAlignment = issuanceDate.textAlignment
        vatNumberLbl.textAlignment = issuanceDate.textAlignment
        invoiceLbl.textAlignment = issuanceDate.textAlignment
       customerName.textAlignment = issuanceDate.textAlignment
       rideUnitPrice.textAlignment = Commons.isArabicLanguage() ? .left : .right
       rideVAT.textAlignment =  rideUnitPrice.textAlignment
       riderTotal.textAlignment =  rideUnitPrice.textAlignment
       compnayUnitPrice.textAlignment =  rideUnitPrice.textAlignment
       companyVAT.textAlignment =  rideUnitPrice.textAlignment
       companyTotal.textAlignment =  rideUnitPrice.textAlignment
       totalPrice.textAlignment =  rideUnitPrice.textAlignment
       totalVAT.textAlignment =  rideUnitPrice.textAlignment
       totalAmount.textAlignment = rideUnitPrice.textAlignment
       totalAmountDue.textAlignment =  rideUnitPrice.textAlignment
       discountAmount.textAlignment =  rideUnitPrice.textAlignment
       natureOfServce.textAlignment =  rideUnitPrice.textAlignment
       serviceQuanlity.textAlignment =  rideUnitPrice.textAlignment
       rideQuality.textAlignment =  rideUnitPrice.textAlignment
       natureOfServiceRide.textAlignment =  rideUnitPrice.textAlignment
        
        issuanceDate.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
         titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
         addresLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
         vatNumberLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
         invoiceLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        customerName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        rideUnitPrice.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        rideVAT.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        riderTotal.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        compnayUnitPrice.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        companyVAT.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        companyTotal.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        totalPrice.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        totalVAT.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        totalAmount.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        totalAmountDue.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        discountAmount.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        natureOfServce.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        serviceQuanlity.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        rideQuality.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        natureOfServiceRide.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        
      supplierLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        address.textAlignment = Commons.isArabicLanguage() ? .right : .left
//      address.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      vat.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      invoice.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      issuanceDateLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      customerLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      serviceLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
//      nosLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      unitPriceLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      quantityLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      iSEV.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      iSIV.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
      totalAmountTitle.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
//      totalEV.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      discountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      totalVATXV.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      ttoalVatLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
//      totalAmountDueLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
      systemLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        
        downloadBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        invoiceTitle.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func setupInvoice(){
        print(" hi its id\(tripData?.id)")
        issuanceDate.text = tripData?.createdAt
        customerName.text = tripData?.rider?.firstName ?? "Customer"
        rideUnitPrice.text =  "\(tripData?.riderAmount ?? DefaultValue.double)" + " SAR"
        rideVAT.text =  "1 SAR"
        compnayUnitPrice.text = "\(tripData?.riderAmount ?? DefaultValue.double)" + " SAR"
        companyVAT.text = "1 SAR"
        //totalPrice.text = "\(tripData?.riderAmount ?? DefaultValue.double)" + " SAR"
        totalVAT.text = "1 SAR"
        let total = (tripData?.riderAmount ?? DefaultValue.double) + 1.0
        totalAmountDue.text = "\(total)" + " SAR"
        totalAmount.text = "\(tripData?.riderAmount ?? DefaultValue.double)" + " SAR"
        let image = generateQRCode(from: "\(tripData?.createdAt ?? "") \(tripData?.riderAmount ?? DefaultValue.double)" )
        QRCode.image = image
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadInvoice(_ sender: Any) {
        let OptionAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let shareAction = UIAlertAction(title: "Share", style: .destructive) { (action: UIAlertAction) in
            let screenShot = self.invoiceView.screenshot()
            let items = [screenShot]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(ac, animated: true)
        }
        
        let downloadAction = UIAlertAction(title: "Download", style: .destructive) { (action: UIAlertAction) in
            self.downloadBtn.isHidden = true
            let screenShot = self.invoiceView.screenshot()
            self.downloadBtn.isHidden = false
            self.writeToPhotoAlbum(image: screenShot)
        }
        
        OptionAlert.addAction(shareAction)
        OptionAlert.addAction(downloadAction)
        self.present(OptionAlert, animated: true, completion:{
            OptionAlert.view.superview?.isUserInteractionEnabled = true
            OptionAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
         })
    }
    
    @IBAction func didTapDownloadBtn(_ sender: Any) {
        if let vc: PdfWebViewController = UIStoryboard.instantiate(with: .invoice) {
            vc.tripId = tripData?.id
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
        Commons.showErrorMessage(controller:  self.navigationController ?? self,backgroundColor: .lightGreen,textColor: .greenTextColor, message: "Image saved to gallery")
    }
    
}

extension InvoiceViewController {
    private func bindToViewModel() {
        riderVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        riderVM.messageWithCode.bind { [weak self] error in
            guard let `self` = self else { return }
            guard !(error.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: error.message ?? DefaultValue.string)
        }
        
        riderVM.getTripDetail.bind { [weak self] response  in
            guard let `self` = self else { return }
            
            
            guard response.statusCode.isSome else { return }
            
            self.customerName.text = response.data?.trip?.rider?.fullName
            
            self.rideUnitPrice.text =  "\(response.data?.trip?.tripBaseAmount ?? DefaultValue.double)" + " SAR"
            
            self.rideVAT.text =  "\(response.data?.trip?.tripBaseAmount ?? DefaultValue.double)" + " SAR"
            
            let riderTotalCal = ((response.data?.trip?.tripBaseAmount ?? DefaultValue.double) * ((response.data?.trip?.taxPercentage ?? DefaultValue.double) / 100))
            
            self.riderTotal.text =  (NSString(format: "%.2f",riderTotalCal  + (response.data?.trip?.tripBaseAmount ?? DefaultValue.double)) as String) + " SAR"
            
            self.compnayUnitPrice.text = "\((response.data?.trip?.waslFee ?? DefaultValue.double) + (response.data?.trip?.processingFee ?? DefaultValue.double))" + " SAR"
            
            self.companyVAT.text = "\((response.data?.trip?.waslFee ?? DefaultValue.double) + (response.data?.trip?.processingFee ?? DefaultValue.double))" + " SAR"
            
            let companyPrice : Double = (response.data?.trip?.waslFee ?? DefaultValue.double) + (response.data?.trip?.processingFee ?? DefaultValue.double)
            
            let companyTotalCal = (companyPrice * ((response.data?.trip?.taxPercentage ?? DefaultValue.double) / 100)) + companyPrice
            
            self.companyTotal.text = (NSString(format: "%.2f",companyTotalCal) as String) + " SAR"
            
            self.totalVAT.text = "\(response.data?.trip?.taxAmount ?? DefaultValue.double)" + " SAR"
            self.totalAmountDue.text = "\(response.data?.trip?.riderAmount ?? DefaultValue.double)" + " SAR"
            let totalamountNoVat = (response.data?.trip?.riderAmount ?? DefaultValue.double) - (response.data?.trip?.taxAmount ?? DefaultValue.double)
            
            self.totalPrice.text =  (NSString(format: "%.2f",totalamountNoVat) as String) + " SAR"
            
            let discountAdded = totalamountNoVat + (response.data?.trip?.promoCodeAmount ?? DefaultValue.double)
            self.totalAmount.text =  (NSString(format: "%.2f",discountAdded) as String) + " SAR"
            
            self.discountAmount.text = "\(response.data?.trip?.promoCodeAmount ?? DefaultValue.double)" + " SAR"
            
            let image = self.generateQRCode(from: response.data?.trip?.zatcaQR ?? "WRONG QR CODE")
            self.QRCode.image = image
        }
        riderVM.getInvoiceDetail.bind { [weak self] response  in
            guard let `self` = self else { return }
            
            
            guard response.statusCode.isSome else { return }
            
           
            
            self.invoiceLbl.text = response.data?.invoiceNo
        }
    }
}


