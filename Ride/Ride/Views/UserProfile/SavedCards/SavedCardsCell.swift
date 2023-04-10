//
//  SavedCardsCell.swift
//  Ride
//
//  Created by PSE on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class SavedCardsCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var cardNameLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var cardHolderNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var item: CardItem? {
        didSet {
            cardNameLbl.text = item?.company
            if let cardNumber = item?.card_number {
                let last4 = String(describing: cardNumber.suffix(4))
                cardNumberLbl.text = last4
            }
            cardHolderNameLbl.text = item?.name
        }
    }
    
}
