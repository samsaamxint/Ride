//
//  MenuTVCell.swift
//  Ride
//
//  Created by PSE on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class MenuTVCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var Icon: UIImageView!
    @IBOutlet weak var Name: UILabel!
    
    
    public var menu : MenuEnum? {
        didSet{
            if let item = menu{
                Icon.image = UIImage(named: item.rawValue.replacingOccurrences(of: " ", with: "") )
                Name.text = item.rawValue.localizedString()

            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Name.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        Name.textAlignment = Commons.isArabicLanguage() ? .right : .left
        
        //Icon.rotateImageIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        Name.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
    }
    
}
