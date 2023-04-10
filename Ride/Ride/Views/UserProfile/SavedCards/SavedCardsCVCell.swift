//
//  SavedCardsCVCell.swift
//  Ride
//
//  Created by PSE on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class SavedCardsCVCell : UICollectionViewCell{
    //MARK: - IBOutlets
    @IBOutlet weak var cardNameLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var cardHolderNameLbl: UILabel!
    
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
