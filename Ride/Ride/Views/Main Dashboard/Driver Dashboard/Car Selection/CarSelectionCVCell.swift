//
//  CarSelectionCVCell.swift
//  Ride
//
//  Created by XintMac on 19/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class CarSelectionCVCell : UICollectionViewCell{
    
     //MARK: - IBOutlets
    @IBOutlet weak var vehicleLogo: UIImageView!
    @IBOutlet weak var vehicleName_Model: UILabel!
    @IBOutlet weak var vehicleNo: UILabel!
    @IBOutlet weak var vehcileNoOfSeats: UIButton!
    @IBOutlet weak var vehiclePlateNo: CustomSpacingLabel!
    @IBOutlet weak var vehiclePlateText: CustomSpacingLabel!
    
    var carData : CarSequenceData? {
        didSet {
            if let carInfo = carData{
                vehicleLogo.kf.setImage(with: URL.init(string: carData?.makerIcon ?? ""))
                vehicleName_Model.text = " \(carInfo.vehicleMaker ?? "")  \(carInfo.vehicleModel ?? "")  (\(carInfo.modelYear ?? 0))"
                vehicleNo.text = carData?.carSequenceNo
                vehiclePlateNo.text = String(carInfo.plateNumber ?? 0)
                vehiclePlateText.text = "\(carInfo.plateText3 ?? "") \(carInfo.plateText2 ?? "") \(carInfo.plateText1 ?? "")"
            }
        }
    }
    
}

