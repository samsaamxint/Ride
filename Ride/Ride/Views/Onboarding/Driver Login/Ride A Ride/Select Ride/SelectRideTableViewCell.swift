//
//  SelectRideTableViewCell.swift
//  Ride
//
//  Created by Mac on 03/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class SelectRideTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var chevronIcon: UIImageView!
    @IBOutlet weak var cabImage: UIImageView!
    @IBOutlet weak var capNameModel: UILabel!
    @IBOutlet weak var earnings: UILabel!
    @IBOutlet weak var rideType: UILabel!
    
    var Cabdata : GetCabsData?{
        didSet{
            self.capNameModel.text = Cabdata?.description
            self.rideType.text = Cabdata?.name
            if let url = URL(string: Cabdata?.categoryIcon ?? DefaultValue.string) {
                cabImage.kf.setImage(with: url)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
