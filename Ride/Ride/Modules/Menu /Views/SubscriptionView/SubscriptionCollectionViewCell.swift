//
//  SubscriptionCollectionViewCell.swift
//  Ride
//
//  Created by Mac on 30/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class SubscriptionCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureView(with evenIndex: Bool , subcription : GetSubcriptionsData, selectedId: String) {
        
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        contentView.layoutIfNeeded()
        let subscriptionView: SubscriptionMainView = .fromNib()
        subscriptionView.configureView(with: evenIndex , subcription: subcription, selectedId: selectedId)
        contentView.addSubview(subscriptionView)
        
        subscriptionView.translatesAutoresizingMaskIntoConstraints = false
        subscriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        subscriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        subscriptionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: evenIndex ? 0 : 15).isActive = true
        subscriptionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: evenIndex ? -15 : 0).isActive = true
    }
    
    var subcriptionData : GetSubcriptionsData?{
        didSet{
            
        }
    }

}
