//
//  NoRidersViewController.swift
//  Ride
//
//  Created by Mac on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import GoogleMapsUtils

class NoRidersViewController: UIViewController {
    
    private var heatmapLayer: GMUHeatmapTileLayer!
    @IBOutlet weak var noriderLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var navigateBtn: UIButton!
    
    var locationManager = CLLocationManager()
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //heatmapLayer = GMUHeatmapTileLayer()
       
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let parent = parent?.parent as? MainDashboardViewController
        parent?.mapView?.clear()
        parent?.addCurrentLocationMarker()
        parent?.mainDashboardVM.getHighDemadZone()
        parent?.containerViewHeight.constant = 220
       
        
        DispatchQueue.main.async {
            self.noriderLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(22)
            self.descLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(18) : UIFont.SFProDisplayRegular?.withSize(18)
            self.navigateBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        }
    }
    

    
    
    @IBAction func NavigateToArea(_ sender: Any) {
        
        let parent = self.parent?.parent as? MainDashboardViewController
        if let vc : NavigateToHeatmapVC = UIStoryboard.instantiate(with: .driverToRider){
            let parent = self.parent?.parent as? MainDashboardViewController
            parent?.containerViewHeight.constant = 230
            if parent?.mainDashboardVM.highDemandZone.value.data?.coordinates?.isEmpty ?? true {
                parent?.mainDashboardVM.getHighDemadZone()
            }
            let highDemandArea = parent?.mainDashboardVM.highDemandZone.value.data?.coordinates?.randomElement()
            vc.heatMaplocaion =  CLLocation.init(latitude: highDemandArea?.lat ?? 0.0 , longitude: highDemandArea?.lng ?? 0.0)
            RideSingleton.shared.heatMaplocaionPoints = vc.heatMaplocaion
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    
}
