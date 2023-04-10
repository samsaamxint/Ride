//
//  BaseChatCell.swift
//  Ride
//
//  Created by Ali Zaib on 18/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class BaseChatCell: UITableViewCell {

    func getMsgCell(msg : String , color : UIColor) -> PaddingLabel{
        let msglbl = PaddingLabel()
        msglbl.topInset = 10
        msglbl.bottomInset = 10
        msglbl.leftInset = 10
        msglbl.rightInset = 10
        msglbl.textColor = color
        msglbl.font = UIFont(name: "SFProDisplay-Regular", size: 16)
        msglbl.numberOfLines = 0
        msglbl.textAlignment = .left
        msglbl.lineBreakMode = .byClipping
        msglbl.text = msg
        return msglbl
    }
    
    
    func getMsgStatusImage(msgStatus : MessageStatus) -> UIImage? {
        var image = UIImage.init(named: "ReceivedChatIcon")
        
        switch msgStatus {
        case .sent:
            image = UIImage.init(named: "SentChatIcon")
            return image
        case .delivered:
            return image?.withTintColor(.lightGray)
        case .read:
            return image?.withTintColor(.green)
        case .notDefined:
            return nil
        case .pending:
            // Show Pending Image ICon
            return nil
        }
    }

}
