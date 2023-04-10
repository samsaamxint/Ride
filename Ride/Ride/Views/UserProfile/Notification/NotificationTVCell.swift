//
//  NotificationTVCell.swift
//  Ride
//
//  Created by PSE on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit

class NotificationTVCell: UITableViewCell {
    
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var notificationDesc: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var readStatus: UILabel!
    
    var notificationData : GetNotificationData?{
        didSet{
            self.notificationTitle.text = notificationData?.title
            self.notificationDesc.text = notificationData?.message
            self.time.text = self.getTime(inputDate: (notificationData?.sentTime?.toDate(.isoDateTimeMilliSec))!)
            //readStatus.textColor = notificationData!.isRead == 1 ? .red : .green
            if notificationData!.isRead == 1{
                readStatus.isHidden = true
            }else{
                readStatus.isHidden = false
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
    
    func getTime(inputDate : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        let timeString = dateFormatter.string(from: inputDate)
        return timeString
    }
    
}
