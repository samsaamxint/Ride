//
//  RiderPickUpLocationVC.swift
//  Ride
//
//  Created by XintMac on 15/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

class RiderPickUpLocationVC : UIViewController{
    
     //MARK: - IBOutlets
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var mainTitleLbl: UILabel!
    @IBOutlet weak var subAddressTitleLbl: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    //MARK: - Constants and Variables
    var primaryAddress: String?
    var secondaryAddress: String?
    
    var dropOffLocationString: String?
    
    var destinationLocation: CLLocation?
    var pickupLocation: CLLocation?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setData()
        
        pickUpLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        mainTitleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
        subAddressTitleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(14) : UIFont.SFProDisplayRegular?.withSize(14)
        confirmBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        editBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
    }
    
    private func setData() {
        mainTitleLbl.text = primaryAddress
        subAddressTitleLbl.text = secondaryAddress
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let parent = self.parent?.parent as? MainDashboardViewController
        parent?.mapView?.clear()
        parent?.addCurrentLocationMarker()
        SocketIOHelper.shared.subscribeUser()
        let destinationMarker = GMSMarker()
        destinationMarker.icon = UIImage(named: "BlackMarker")
        destinationMarker.position = destinationLocation?.coordinate ?? CLLocationCoordinate2D()
        destinationMarker.map = parent?.mapView
        destinationMarker.userData = dropOffLocationString
        
        let pickupMarker = GMSMarker()
        pickupMarker.icon = UIImage(named: "BlackMarker")
        pickupMarker.position = pickupLocation?.coordinate ?? CLLocationCoordinate2D()
        pickupMarker.map = parent?.mapView
        pickupMarker.userData = secondaryAddress
        parent?.containerViewHeight.constant = 220
    }
    
     //MARK: - IBActions
    @IBAction func confirmPressed(_ sender: Any) {
//        pickup confirm event
        Commons.adjustEventTracker(eventId: AdjustEventId.ConfirmPickup)
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 600
        if let vc: RiderRideSelection = UIStoryboard.instantiate(with: .riderPickup) {
            vc.pickupLocationString = secondaryAddress
            vc.dropOffLocationString = dropOffLocationString
            
            vc.destLocation = destinationLocation
            vc.pickupLocation = pickupLocation
            
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func didTapEditBtn(_ sender: Any) {
        (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 350
        navigationController?.popViewController(animated: false)
    }
    
    
}
