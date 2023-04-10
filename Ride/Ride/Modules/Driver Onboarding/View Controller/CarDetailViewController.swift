//
//  CarDetailViewController.swift
//  Ride
//
//  Created by Mac on 03/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class CarDetailViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var deliveryMainView: UIView!
    @IBOutlet weak var deliveryCheckBtn: UIButton!
    
    @IBOutlet weak var addressSV: UIStackView!
    
    @IBOutlet weak var pickupMainView: UIView!
    @IBOutlet weak var pickupCheckBtn: UIButton!
    
    @IBOutlet weak var acceptIcon: UIButton!
    
    @IBOutlet weak var proceedBtn: UIButton!
    
    @IBOutlet weak var mapParentView: UIView!
    @IBOutlet weak var addAddressBtn: UIButton!
    
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var cabNameModel: UILabel!
    @IBOutlet weak var fuelTupe: UILabel!
    @IBOutlet weak var seatingCapacity: UILabel!
    @IBOutlet weak var noOfCylinders: UILabel!
    @IBOutlet weak var displacement: UILabel!
    
    //MARK: - Constants and Variables
    private var selectedType: RidePreference = .deliver {
        didSet {
            if selectedType == .deliver {
                selectDeliveryView()
                
                proceedBtn.enableButton(isAccepted && addAddressBtn.isHidden)
            } else {
                selectPickupView()
                proceedBtn.enableButton(isAccepted)
            }
        }
    }
    private var isAccepted = false {
        didSet {
            acceptIcon.setImage(isAccepted ? UIImage(named: "CheckmarkIcon") : nil, for: .normal)
            if selectedType == .pickup {
                proceedBtn.enableButton(isAccepted)
            } else {
                proceedBtn.enableButton(isAccepted && addAddressBtn.isHidden)
            }
        }
    }
    private var mapView: GMSMapView?
    
    private let getCabDetailVM = GetCabDetailViewModel()
    var mobileNumber: String?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        bindViewToViewModel()
        hideKeyboardWhenTappedAround()
        getCabDetailVM.getCabDetail()
    }
    
    private func setupMap() {
        mapView = GMSMapView(frame: view.frame)
        mapParentView.addSubview(mapView!)
        
        mapView!.isMyLocationEnabled = true
        mapView!.tintColor = .primaryGreen
        mapView?.isUserInteractionEnabled = false
        
        mapParentView.sendSubviewToBack(mapView!)
        
        mapView?.translatesAutoresizingMaskIntoConstraints = false
        mapView?.leadingAnchor.constraint(equalTo: mapParentView.leadingAnchor).isActive = true
        mapView?.trailingAnchor.constraint(equalTo: mapParentView.trailingAnchor).isActive = true
        mapView?.topAnchor.constraint(equalTo: mapParentView.topAnchor).isActive = true
        mapView?.bottomAnchor.constraint(equalTo: mapParentView.bottomAnchor).isActive = true
        
        let location = CLLocation(latitude: 19.017615, longitude: 72.856164)
        
        let camera = GMSCameraPosition.camera(withLatitude:location.coordinate.latitude, longitude:location.coordinate.longitude, zoom: 16)
        
        mapView?.animate(to: camera)
        
        let marker = GMSMarker(position: location.coordinate)
        marker.icon = UIImage(named: "BlackMarker")
        marker.map = mapView
        marker.rotation = location.course
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped))
        deliveryMainView.addDoubleBorder()
        deliveryViewClicked(0)
        
        proceedBtn.enableButton(false)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func selectDeliveryView() {
        addressSV.isHidden = false

        pickupMainView.removeAllSublayers()
        pickupCheckBtn.setImage(nil, for: .normal)
        pickupCheckBtn.borderColor = .sepratorColor
        
        deliveryMainView.addDoubleBorder()
        if #available(iOS 13.0, *) {
            deliveryCheckBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        deliveryCheckBtn.borderColor = .primaryGreen
    }
    
    private func selectPickupView() {
        deliveryMainView.removeAllSublayers()
        deliveryCheckBtn.setImage(nil, for: .normal)
        deliveryCheckBtn.borderColor = .sepratorColor
        
        pickupMainView.addDoubleBorder()
        if #available(iOS 13.0, *) {
            pickupCheckBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        pickupCheckBtn.borderColor = .primaryGreen
        
        addressSV.isHidden = true
    }
    
    //MARK: - UIACTIONS
    @IBAction func deliveryViewClicked(_ sender: Any) {
        selectedType = .deliver
    }
    
    @IBAction func pickupViewClicked(_ sender: Any) {
        selectedType = .pickup
    }
    
    @IBAction func addAddressBtnClicked(_ sender: Any) {
        if let vc: CarDeliveryAddressViewController = UIStoryboard.instantiate(with: .rideARide) {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func acceptButtonClicked(_ sender: Any) {
        isAccepted.toggle()
    }
    
    @IBAction func proceedBtnClicked(_ sender: Any) {
        
        getCabDetailVM.cabCheckOut()
        
    }
}

//MARK: - CarDeliveryAddressViewControllerProtocol
extension CarDetailViewController: CarDeliveryAddressViewControllerProtocol {
    func didSelectAddress(address: String) {
        mapView?.removeFromSuperview()
        mapView = nil
        
        setupMap()
        
        addressLbl.text = address
        
        mapParentView.isHidden = false
        addAddressBtn.isHidden = true
        
        selectedType = .deliver
        
        proceedBtn.enableButton(isAccepted && addAddressBtn.isHidden)
    }
}

extension CarDetailViewController{
    func bindViewToViewModel(){
        getCabDetailVM.apiResponse.bind { [weak self] res in
            guard let self = self else {return}
            if res.statusCode == 200{
                self.cabNameModel.text = res.data?.description
                self.fuelTupe.text = res.data?.fuel_type
                self.noOfCylinders.text = String(res.data?.cylinder ?? 0)
                self.seatingCapacity.text = String(res.data?.seating_capacity ?? 0)
                self.displacement.text = res.data?.displacement
            }
        }
        
        getCabDetailVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        getCabDetailVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
        
        getCabDetailVM.checkOutApiResponse.bind { [weak self] res in
            guard let self = self else {return}
            if res.statusCode == 200{
                
                if let vc: ContractVC = UIStoryboard.instantiate(with: .rideARide) {
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                    vc.callback = {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            guard let `self` = self else { return }
                            if let vc: VerifyOTPViewController = UIStoryboard.instantiate(with: .onboarding) {
                                (self.parent?.parent as? GenericOnboardingViewController)?.containerViewHeight.constant = 320
                                vc.is_TAMM_OTP = true
                                vc.onboardingType = .signup
                                vc.isDriver = true
                                vc.mobileNumber = globalMobileNumber
                                vc.modalTransitionStyle = .crossDissolve
                                vc.modalPresentationStyle = .overCurrentContext
                                self.present(vc, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
}
