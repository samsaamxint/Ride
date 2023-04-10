//
//  TopUpDetailTVCell.swift
//  Ride
//
//  Created by XintMac on 17/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class TopUpDetailTVCell : UITableViewCell{
    
    @IBOutlet weak var cardNameLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var topUpAmountLbl: UILabel!
    @IBOutlet weak var topUpAmount: UILabel!
    @IBOutlet weak var topUpTimeLbl: UILabel!
    @IBOutlet weak var topUpTime: UILabel!
    @IBOutlet weak var topTimeLbl: UILabel!
    @IBOutlet weak var topUpDate: UILabel!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var topupStatusLbl: UILabel!
    
    var details : TopUpDetailsData?{
        didSet{
            
            let additinalInfo = details?.eWalletAPIResponse ?? ""
            let dict = additinalInfo.toJSON() as? [String:AnyObject] // can be any type here
            let paymentMethod: String = dict?["payment_info"]?["payment_method"] as? String ?? ""
            cardNameLbl.text = paymentMethod
            topUpAmount.text = " SAR \(details?.transactionAmount ?? 0)"
            topUpTime.text = getTime(createdAt: (details?.createdAt)!)
            topUpDate.text = getDate(createdAt: (details?.createdAt)!)
            cardNumberLbl.text = details?.transactionId ?? ""
            imgCard.image = UIImage(named: paymentMethod.lowercased())
            topupStatusLbl.text = getPaymentStatus(with: details?.status ?? .PENDING)
            //topupStatusLbl.text = getPaymentStatus(with: details?.payment_status ?? .PENDING).localizedString()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardNameLbl.text = "Click Pay".localizedString()
        cardNameLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        cardNumberLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(12) : UIFont.SFProDisplayRegular?.withSize(12)
        topUpAmountLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        topUpAmount.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        topUpTimeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        topUpTime.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        topTimeLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        topUpDate.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        topupStatusLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
    }
    
    private func getPaymentStatus(with status: PaymentStatus) -> String {
        switch status {
        case .PENDING:
            return "Pending".localizedString()
        case .COMPLETED:
            return "Successfull".localizedString()
        case .CANCELLED:
            return "Cancelled".localizedString()
        case .REFUNDED:
            return "Refunded".localizedString()
        case .FAILED:
            return "Failed".localizedString()
        }
    }
    
    func getDate(createdAt : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: createdAt) {
            dateFormatter.dateFormat = "dd MMM YYYY"
            return dateFormatter.string(from: date)
        }
        return createdAt
    }
    
    func getTime(createdAt : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: createdAt) {
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: date)
        }
        return createdAt
    }
}
