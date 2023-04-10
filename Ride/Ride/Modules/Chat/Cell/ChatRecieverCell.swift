//
//  UserCell.swift
//  Ride
//
//  Created by Ali Zaib on 09/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class ChatRecieverCell : BaseChatCell{
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var msgContendView: UIStackView!
    @IBOutlet weak var msgTimeLbl: UILabel!
    
    var item : ChatResponse?{
        didSet{
            switch item?.chatType {
            case .TEXT:
                let msglbl = getMsgCell(msg: item?.messageContent ?? "Waiting for msg", color: .primaryTxtReceiver)
                msgContendView.addArrangedSubview(msglbl)
                break
            case .IMAGE:
                let msgImage = UIImageView()
                msgImage.contentMode = .scaleToFill
                msgContendView.addArrangedSubview(msgImage)
                break
            case .VIDEO:
                let msgVideo = UIView()
                msgContendView.addArrangedSubview(msgVideo)
                break
            case .AUDIO:
                let msglbl = PaddingLabel()
                msgContendView.addArrangedSubview(msglbl)
                break
            case .FILE:
                let msglbl = UIButton()
                msgContendView.addArrangedSubview(msglbl)
                break
            default:
                let msglbl = PaddingLabel()
                msglbl.textColor = UIColor(red: 0.329, green: 0.329, blue: 0.329, alpha: 1)
                msglbl.font = UIFont(name: "SFProDisplay-Regular", size: 16)
                msgContendView.addArrangedSubview(msglbl)
                break
            }
            
            if let timeStamp = item?.timestamp{
                self.msgTimeLbl.text = timeStamp.getCorrectTime()
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        msgContendView.removeAllArrangedSubviews()
    }
}
