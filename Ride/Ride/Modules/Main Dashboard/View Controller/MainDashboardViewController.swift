//
//  MainDashboardViewController.swift
//  Ride
//
//  Created by Mac on 04/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import CoreLocation
import MapKit
import GoogleMapsUtils
//var containerViewheight = 150
class MainDashboardViewController: UIViewController, CurrentLocationProtocol {
    
    //MARK: - Outlets
    @IBOutlet weak var containerViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var myLoctionBtn: UIButton!
    @IBOutlet weak var goToGM: UIButton!
    
    //MARK: - Constants and Variables
    var mapView: GMSMapView?
    var currentLocationMarker: GMSMarker?
    var locationManager = CLLocationManager()
    var currentAddress : String = ""
    var tripId : String = ""
    var containerHeight : CGFloat = 0
    var route = RouteData()
    var calculatedTime = ""
    var isOnCurrentLocation = false
    var heatmapLayer = GMUHeatmapTileLayer()
    var heatmapGroupLayer = GMUHeatmapTileLayer()
    var markers = [GMSMarker]()
    var isFromSignup = false
    var waslRejectionReason = ""
    private let cancelTripVM = CancelTripViewmodel()
    let mainDashboardVM = MainDashbaordViewModel()
    private let rideCancelAfterAcceptVM = RiderCancelViewModel()
    private let balanceVM = BalanceViewModel()
    var previousAngle: Double = 0
    var didUpdateLocation = false
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //        if UserDefaultsConfig.isRider{
        //            showRiderMainScreen()
        //        }
        setupViews()
        bindViewToViewModel()
        
        setupSwitchUserModeView()
        hideKeyboardWhenTappedAround()
        addSocketListeners()
        addObservers()
        
        LocationManager.shared.locationManager?.startUpdatingLocation()
        myLoctionBtn.imageView?.contentMode = .scaleToFill
        
        if UserDefaultsConfig.tripId.isSome {
            mainDashboardVM.getTripDetail(tripid: UserDefaultsConfig.tripId!)
        }
        
        if !isFromSignup{
            mainDashboardVM.getCaptainStatus(check: .fromLanding)
        }
        //        } else {
        //            mainDashboardVM.getRiderTrip(shouldChangeMode: false)
        //            showRiderMainScreen()
        //        }
        
        updateCustomer()
        balanceVM.getBalance()
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let `self` = self else { return }
            
            if let location = self.locationManager.location {
                self.didUpdateLocation = false
                self.updateCaptainLocationWhereNeeded(location: location)
            }
        }
        
        self.view.semanticContentAttribute = .forceLeftToRight
        self.navigationItem.titleView?.semanticContentAttribute = .forceLeftToRight
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
        
        
        //UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
        
        //        self.showLoader(startAnimate: true, "keep showing")
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setProfileNavButton(selector: #selector(didTapProfileBtn))
        
        if RideSingleton.shared.subscriptionStatusChanged {
            RideSingleton.shared.subscriptionStatusChanged = false
            mainDashboardVM.getCaptainStatus(check: .toRefreshOnly)
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let parent = self.parent?.parent as? MainDashboardViewController
        self.containerHeight = parent?.containerViewHeight.constant ?? 0.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // mainDashboardVM.getUsersLocation()
        super.viewWillAppear(animated)
        checkAppUpdate()
        let tripObj = RideSingleton.shared.tripDetailObject
        let driverLoc = CLLocation(latitude: tripObj?.data?.driverInfo?.latitude ?? DefaultValue.double,
                                   longitude: tripObj?.data?.driverInfo?.longitude ?? DefaultValue.double)
        
        NotificationCenter.default.post(name: .updateLocationForDriver, object: nil, userInfo: ["location": driverLoc])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //        DispatchQueue.main.async {
        ////            self.containerViewHeight.constant = CGFloat(containerViewheight)
        //            self.containerView.setNeedsLayout()
        //            self.containerView.layoutSubviews()
        //           }
    }
    
    private func updateCustomer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            ConfigurationsViewModel().updateCustomer(deviceId: deviceId,
                                                     deviceToken: firebaseToken,
                                                     deviceName: "iOS",
                                                     latitude: LocationManager.shared.lastLocation?.coordinate.latitude ,
                                                     longitude: LocationManager.shared.lastLocation?.coordinate.longitude, email: nil, mobileNo: nil, profileImage: nil, prefferedLanguage: UserDefaults.standard.value(forKey: languageKey) as? String)
        }
    }
    
    private func goToPaymentForDriver() {
        if let vc: ChoosePaymentMethodViewController = UIStoryboard.instantiate(with: .paymentMethods) {
            containerViewHeight.constant = 500
            addChildWithNavViewController(childController: vc, contentView: containerView)
        }
    }
    
    private func setInitialChildController(){
        if !UserDefaultsConfig.isDriver {
            if let vc: RiderDropOffVC = UIStoryboard.instantiate(with: .riderPickup) {
                containerViewHeight.constant = 150
                addChildWithNavViewController(childController: vc, contentView: containerView)
                
            }
        } /*else if type == .driverRideARide {
           if let vc: RideStatusViewController = UIStoryboard.instantiate(with: .driverRideARideDashboard) {
           containerViewHeight.constant = 300
           addChildWithNavViewController(childController: vc, contentView: containerView)
           }
           } else if type == .driverOwnCar {
           if let vc: ApplicationStatusViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
           containerViewHeight.constant = 290
           addChildWithNavViewController(childController: vc, contentView: containerView)
           }
           }*/ else {
               if mainDashboardVM.checkCaptainStatus.value.0.data?.iban.isSome ?? true {
                   if let vc: NoRidersViewController = UIStoryboard.instantiate(with: .driverToRider) {
                       containerViewHeight.constant = 220
                       addChildWithNavViewController(childController: vc, contentView: containerView)
                   }
               }else{
                   if let vc: VerifyDriverIBANViewController = UIStoryboard.instantiate(with: .driverRideARideDashboard) {
                       containerViewHeight.constant = 400
                       (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                       addChildWithNavViewController(childController: vc, contentView: containerView)
                   }
               }
           }
    }
    
    func setupSwitchUserModeView() {
        let switchView: DashboardSwitchView = .fromNib()
        switchView.tag = CustomTag.SwitchUserModeView
        
        switchView.didTapRider = { [weak self] in
            guard let `self` = self else { return }
            
            guard UserDefaultsConfig.isDriver else { return }
            
            self.mainDashboardVM.getCaptainStatus(check: .onTogglingInterface)
        }
        
        switchView.didTapDriver = { [weak self] in
            guard let `self` = self else { return }
            
            guard !UserDefaultsConfig.isDriver else { return }
            self.mainDashboardVM.getCaptainStatus(check: .onTogglingInterface)
        }
        
        switchView.didTapPickup = { [weak self] in
            guard let `self` = self else { return }
            self.showBecomeDriverScreen(isDriver: false)
        }
        
        switchView.riderBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        switchView.driverBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold : UIFont.SFProDisplayBold
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: switchView)
    }
    
    func addHeatmap() {
        
        let heatMapJson = self.mainDashboardVM.activeUserLocations.value.data
        
        var list = [GMUWeightedLatLng]()
        for item in heatMapJson ?? [] {
            let lat = item.latitude ?? 0.0
            let lng = item.longitude ?? 0.0
            let coords = GMUWeightedLatLng(
                coordinate: CLLocationCoordinate2DMake(lat, lng),
                intensity: 1.0
            )
            list.append(coords)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: item.latitude ?? 0.0, longitude: item.longitude ?? 0.0)
            marker.opacity = 0
            marker.userData = item
            marker.map = self.mapView
        }
        
        // Add the latlngs to the heatmap layer.
        heatmapLayer.weightedData = list
        heatmapLayer.radius = 50
        let gradientColors: [UIColor] = [.orange, .red]
        let gradientStartPoints: [NSNumber] = [0.1, 1.0]
        heatmapLayer.gradient = GMUGradient(
            colors: gradientColors,
            startPoints: gradientStartPoints,
            colorMapSize: 256
        )
        
        //let parent = parent?.parent as? MainDashboardViewController
        heatmapLayer.map = self.mapView
    }
    
    func addGroupHeatmap() {
        
        
        var heatMapJson = self.mainDashboardVM.activeUserLocations.value.data
        
        
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        let coordinate = locManager.location
        
        //        let heatMapJson = self.mainDashboardVM.activeUserLocations.value.data
        if heatMapJson == nil {
            heatMapJson?.insert(ActiveUserLocationItem(latitude: coordinate?.coordinate.latitude, longitude: coordinate?.coordinate.longitude), at: 0)
        }
        
        var distanceInMeters = coordinate?.distance(from: CLLocation(latitude: heatMapJson?.first?.latitude ?? 0, longitude: heatMapJson?.first?.longitude ?? 0))
        
        var list = [GMUWeightedLatLng]()
        var groupList = [GMUWeightedLatLng]()
        
        for item in 0..<(heatMapJson?.count ?? 0) {
            let lat = heatMapJson?[item].latitude ?? 0.0
            let lng = heatMapJson?[item].longitude ?? 0.0
            
            if item == 0 {
                distanceInMeters = coordinate?.distance(from: CLLocation(latitude: lat, longitude: lng)) ?? 0
            } else {
                let lastLat = heatMapJson?[item - 1].latitude ?? 0.0
                let lastLng = heatMapJson?[item - 1].longitude ?? 0.0
                distanceInMeters = CLLocationCoordinate2D(latitude: lastLat, longitude: lastLng).distance(to: CLLocationCoordinate2D(latitude: lat, longitude: lng))
            }
            
            if (distanceInMeters ?? 0) >= 5000 {
                let coords = GMUWeightedLatLng(
                    coordinate: CLLocationCoordinate2DMake(lat, lng),
                    intensity: 1.0
                )
                list.append(coords)
            } else {
                let coords = GMUWeightedLatLng(
                    coordinate: CLLocationCoordinate2DMake(lat, lng),
                    intensity: 1.0
                )
                groupList.append(coords)
            }
        }
        
        heatmapLayer.weightedData = list
        heatmapLayer.radius = 50
        let gradientColors: [UIColor] = [.orange, .red]
        let gradientStartPoints: [NSNumber] = [0.1, 1.0]
        
        heatmapLayer.gradient = GMUGradient(
            colors: gradientColors,
            startPoints: gradientStartPoints,
            colorMapSize: 256
        )
        heatmapLayer.map = self.mapView
        heatmapGroupLayer.weightedData = groupList
        heatmapGroupLayer.radius = 100
        
        heatmapGroupLayer.gradient = GMUGradient(
            colors: gradientColors,
            startPoints: gradientStartPoints,
            colorMapSize: 256
        )
        
        //let parent = parent?.parent as? MainDashboardViewController
        heatmapGroupLayer.map = self.mapView
    }
    
    func addHeatMapLocation() {
        
        let data = self.mainDashboardVM.highDemandZone.value.data
        var heatMapJson = data?.coordinates ?? []
        print("heatMapJson.count\(heatMapJson.count)")
        //        heatMapJson = demyArray
        
        if let adminData = data?.adminCoordinates {
            for index in 0..<(adminData.count) {
                heatMapJson.append(adminData[index])
            }
        }
        
        if heatMapJson.count == 0 {
            heatMapJson.insert(Coordinate(lat: data?.user?.latitude, lng: data?.user?.longitude), at: 0)
        }
        
        var list = [GMUWeightedLatLng]()
        
        for item in 0..<heatMapJson.count {
            let lat = heatMapJson[item].lat ?? 0.0
            let lng = heatMapJson[item].lng ?? 0.0
            
            let coords = GMUWeightedLatLng(
                coordinate: CLLocationCoordinate2DMake(lat, lng),
                intensity: 1.0
            )
            list.append(coords)
            
            /// Marker - Google Place marker
            let marker: GMSMarker = GMSMarker() // Allocating Marker
            
            //             marker.title = "Title" // Setting title
            //             marker.snippet = "Sub title" // Setting sub title
            marker.icon = UIImage(named: "BlackMarker") // Marker icon
            marker.appearAnimation = .pop // Appearing animation. default
            marker.position = CLLocationCoordinate2DMake(lat, lng) // CLLocationCoordinate2D
            DispatchQueue.main.async { // Setting marker on mapview in main thread.
                marker.map = self.mapView // Setting marker on Mapview
            }
        }
        
        heatmapLayer.weightedData = list
        heatmapLayer.radius = 50
        let gradientColors: [UIColor] = [.orange, .red]
        let gradientStartPoints: [NSNumber] = [0.1, 1.0]
        
        heatmapLayer.gradient = GMUGradient(
            colors: gradientColors,
            startPoints: gradientStartPoints,
            colorMapSize: 256
        )
        heatmapLayer.map = self.mapView
    }
    
    func showRiderMainScreen() {
        let leftView = navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
        leftView?.selectRiderView()
        
        UserDefaultsConfig.isDriver = false
        
        if let vc: RiderDropOffVC = UIStoryboard.instantiate(with: .riderPickup) {
            self.containerViewHeight.constant = 150
            UserDefaultsConfig.isDriver = false
            (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
            self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
            //            self.addChildViewController(childController: vc, contentView: containerView)
        }
    }
    
    private func showApplicationStatusApproveIfNeeded() {
        if self.mainDashboardVM.checkCaptainStatus.value.0.data?.driverSubStatus == 0{
            mainDashboardVM.verifySubscription()
        }
    }
    
    private func showApplicationStatusApprove() {
        if let vc: ApplicationStatusApproveViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
            vc.payableAmount = self.mainDashboardVM.checkCaptainStatus.value.0.data?.driverSubAmount
            UserDefaultsConfig.isDriver = true
            vc.hasSubscribedBefore = true
            (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
            self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
        }
    }
    
    func showDriverMainScreen() {
        UserDefaultsConfig.isDriver = true
        
        if UserDefaultsConfig.user?.isWASLApproved == 0 {
            return
        }
        
        
        let leftView = navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
        leftView?.selectCaptainView()
        
        if UserDefaultsConfig.user?.isWASLApproved == 2{
            if let vc: ApplicationStatusViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                self.containerViewHeight.constant = 290
                vc.isRejected = true
                vc.rejectionReason = self.waslRejectionReason
                (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
            }
            return
            
        }
        
        
        if mainDashboardVM.checkCaptainStatus.value.0.data?.iban.isSome ?? true {
            
            if mainDashboardVM.highDemandZone.value.data?.coordinates?.isEmpty ?? true {
                mainDashboardVM.getHighDemadZone()
            }
            
            if let vc: NoRidersViewController = UIStoryboard.instantiate(with: .driverToRider) {
                containerViewHeight.constant = 220
                UserDefaultsConfig.isDriver = true
                (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                
                if let location = locationManager.location {
                    SocketIOHelper.shared.updateCaptainLocation(location: location)
                }
            }
        }else{
            
            guard mainDashboardVM.checkCaptainStatus.value.0.data?.driverSubStatus == 1 else { return }
            
            if let vc: VerifyDriverIBANViewController = UIStoryboard.instantiate(with: .driverRideARideDashboard) {
                containerViewHeight.constant = 400
                (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                addChildWithNavViewController(childController: vc, contentView: containerView)
            }
        }
    }
    
    private func showBecomeDriverScreen(isDriver: Bool) {
        if let vc: NotADriverViewController = UIStoryboard.instantiate(with: .switchUser) {
            containerViewHeight.constant = 365
            vc.isDriver = isDriver
            (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
            self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
        }
    }
    
    private func setupViews() {
        checkAppUpdate()
        setupMap()
        requestLocation()
        
        setProfileNavButton(selector: #selector(didTapProfileBtn))
    }
    
    @objc private func didTapProfileBtn() {
        if let vc: UserProfileMainVC = UIStoryboard.instantiate(with: .userProfile) {
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc func didPressSettingsButton(button: UIButton) {
        
        if let subView = view.viewWithTag(CustomTag.MainDashboardCancelView) {
            subView.removeFromSuperview()
            return
        }
        
        let y = topbarHeight
        let language = (UserDefaults.standard.value(forKey: languageKey) as? String) ?? "en"
        ///let xPoint = 9 //: UIScreen.main.bounds.width - 146 - 9
        let imageView = UIImageView(frame: CGRect(x: 9, y: y, width: 146, height: 55))
        imageView.image = UIImage(named: "RectangleBG")
        
        imageView.tag = CustomTag.MainDashboardCancelView
        
        let label = UILabel()
        label.text = "Cancel Ride".localizedString()
        label.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        label.textColor = .redText
        imageView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16).isActive = true
        label.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -13).isActive = true
        
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelRideBtnPressed))
        imageView.addGestureRecognizer(tap)
        
        view.addSubview(imageView)
    }
    
    
    @IBAction func goToMyLoc(_ sender: Any) {
        DispatchQueue.main.async() { () -> Void in
            guard let lat = self.locationManager.location?.coordinate.latitude else { return }
            guard let lng = self.locationManager.location?.coordinate.longitude else { return }
            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 16)
            self.mapView?.camera = camera
        }
    }
    
    @objc private func cancelRideBtnPressed() {
        if let subView = view.viewWithTag(CustomTag.MainDashboardCancelView) {
            subView.removeFromSuperview()
        }
        
        let childNavigationController = (containerView.subviews.first?.getParentController() as? UINavigationController)
        
        if let vc : CancelRideByDriverViewController = UIStoryboard.instantiate(with: .driverToRider){
            childNavigationController?.pushViewController(vc, animated: false)
            vc.previousContainerHeight = self.containerViewHeight.constant
            vc.type = .CANCEL_BY_DRIVER
            self.containerViewHeight.constant = 450
            
            vc.callback = { height in
                self.containerViewHeight.constant = height
            }
        }
        //bottomSheetState = .cancelRide(450)
    }
    
    private func addSocketListeners(){
        listenRequestForDriverAccept()
        listenCaptainLocationUpdate()
        listenTimeEstimateEvent()
    }
    
    func drawPolyLine(startingLoc: CLLocationCoordinate2D, endingLocation: CLLocationCoordinate2D, shouldBound: Bool = true , showCarMarker : Bool = true, rotation: Double? = nil , needSnapShot : Bool = false, isDrawPolyLine: Bool = false , completion: (() -> Void)? = nil) {
        print(isDrawPolyLine)
        if isDrawPolyLine {
            
            Commons.getRouteSteps(from: startingLoc , to: endingLocation , needSnapShot: needSnapShot, isDrawPolyLine: isDrawPolyLine) { polyline, polylines, route in
                self.drawPolyLineFormRoutes(startingLoc: startingLoc, endingLocation: endingLocation, polyline: polyline, polylines: polylines, route: route, shouldBound: shouldBound, showCarMarker: showCarMarker, rotation: rotation, needSnapShot: needSnapShot,  completion: completion)
            }
        } else {
            let previousPath = PathSave.shared
            self.drawPolyLineFormRoutes(startingLoc: startingLoc, endingLocation: endingLocation, polyline: previousPath.getPolyline(), polylines:  previousPath.getPolylineArray(), route:  previousPath.getRouts(), shouldBound: shouldBound, showCarMarker: showCarMarker, rotation: rotation, needSnapShot: needSnapShot,  completion: completion)
        }
    }
    
    func drawPolyLineFormRoutes(startingLoc: CLLocationCoordinate2D, endingLocation: CLLocationCoordinate2D, polyline: GMSPolyline?, polylines: [GMSPolyline]?, route: RouteData?, shouldBound: Bool = true, showCarMarker : Bool = true, rotation: Double? = nil , needSnapShot : Bool = false , completion: (() -> Void)? = nil) {
        for polyline in polylines ?? [] {
            //                polyline.path?.coordinate(at: 0)
            self.addMarkers(from: startingLoc , to: endingLocation ,  showCarMarker : showCarMarker, rotation: rotation)
            polyline.map = self.mapView
            
            var bounds = GMSCoordinateBounds()
            if let plylines = route?.polyLine {
                for route in plylines {
                    for index in 1...(route.path?.count())! {
                        bounds = bounds.includingCoordinate((route.path?.coordinate(at: index))!)
                    }
                }
            }
            bounds = bounds.includingCoordinate(startingLoc)
            bounds = bounds.includingCoordinate(endingLocation )
            
            let bottomPadding = self.containerViewHeight.constant + Commons.getSafeAreaInset().bottom + 40
            let topPadding = Commons.getSafeAreaInset().top + 20
            
            let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: topPadding, left: 20, bottom: bottomPadding, right: 20))
            
            if shouldBound {
                self.mapView?.animate(with: update)
            }
            completion?()
        }
    }
    
    
    func addMarkers(from: CLLocationCoordinate2D , to: CLLocationCoordinate2D ,showCarMarker : Bool = true, rotation: Double? = nil){
        self.mapView?.clear()
        
        let marker = GMSMarker(position: to)
        marker.map = self.mapView
        
        if showCarMarker{
            let Dmarker = GMSMarker(position: from)
            if rotation.isSome {
                Dmarker.isFlat = true
                Dmarker.rotation = rotation!
            }
            Dmarker.icon = UIImage(named: "CarMarker")
            Dmarker.map =  self.mapView
        }else{
            let marker = GMSMarker(position: from)
            marker.icon = UIImage(named: "BlackMarker")
            marker.map = self.mapView
        }
    }
    
    func updateMarker(from: CLLocationCoordinate2D , to: CLLocationCoordinate2D){
        
        let marker = GMSMarker(position: to)
        marker.map = self.mapView
        let Dmarker = GMSMarker(position: from)
        Dmarker.map =  self.mapView
    }
    
    func distanceUpdate(fromLoc: CLLocation, toLoc: CLLocation,isDrawPolyLine: Bool = false, onCompletionBlock:  @escaping (String) -> Void){
        
        Commons.getRouteSteps(from: fromLoc.coordinate, to: toLoc.coordinate, isDrawPolyLine: isDrawPolyLine) { [weak self] polyline, polylines, routeData in
            guard let `self` = self else { return }
            self.route.travelTime = routeData?.travelTime ?? ""
            self.route.travelDuration = routeData?.travelDuration ?? 0
            self.route.routeDistance = routeData?.routeDistance ?? ""
            self.route.travelInstruction = routeData?.travelInstruction ?? "0.1m"
            self.calculatedTime = self.calculateOngoingEstimatedTime(timeinSeconds: self.route.travelDuration , travelTime: self.route.travelTime , isDriver: false)
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.drawPolyLineFormRoutes(startingLoc: fromLoc.coordinate, endingLocation: toLoc.coordinate, polyline: polyline, polylines: polylines, route: routeData, shouldBound: false, rotation: fromLoc.course)
            }
            onCompletionBlock( self.calculatedTime)
        }
    }
    
    
    func calculateOngoingEstimatedTime(timeinSeconds: Int?, travelTime: String, isDriver: Bool) -> String {
        var estimatedTime = "\(travelTime)"
        
        if estimatedTime.lowercased() != "1 min" || (timeinSeconds ?? 0) > 59 {
            return estimatedTime
        } else {
            estimatedTime = calculatedTime(timeinSeconds: timeinSeconds, isDriver: isDriver)
        }
        
        return estimatedTime
    }
    
    func calculatedTime(timeinSeconds: Int?, isDriver: Bool) -> String {
        var estimatedTime = ""
        if let remainingTripTime = timeinSeconds, remainingTripTime > 0 {
            let (h, m, s) = secondsToHoursMinutesSeconds(seconds: Int(remainingTripTime))
            if h > 0 {
                estimatedTime = String(format: "%@ hour, %@ mins", "\(h)", "\(m)")
            } else if m > 0 {
                
                if m == 1 , s == 0 , Commons.isArabicLanguage(){
                    estimatedTime = "دقيقة واحدة"
                } else if m == 2 , s == 0, !Commons.isArabicLanguage(){
                    estimatedTime = "دقيقتين"
                } else {
                    estimatedTime = String(format: "%@ mins", "\(m)")
                }
                
            } else if s > 0 {
                estimatedTime = "Less than 1 min away".localizedString()
            } else {
                //estimatedTime = isDriver ? "Reached" : "Arrived"
            }
        } else {
            estimatedTime = isDriver ? "Reached".localizedString() : "Arrived".localizedString()
        }
        return estimatedTime
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @IBAction func openGoogleMaps(_ sender: Any) {
        openGoogleMap()
    }
    
    private func openAppleMap(){
        let tripData = RideSingleton.shared.tripDetailObject?.data
        var goToLocation = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
        if tripData?.status == TripStatus.ACCEPTED_BY_DRIVER {
            if let newDestination = tripData?.destinationNew?.address{
                if newDestination.isEmpty{
                    goToLocation = CLLocationCoordinate2D.init(latitude: tripData?.source?.latitude ?? DefaultValue.double,
                                                               longitude: tripData?.source?.longitude ?? DefaultValue.double)
                }else{
                    goToLocation = CLLocationCoordinate2D.init(latitude: tripData?.source?.latitude ?? DefaultValue.double,
                                                               longitude: tripData?.source?.longitude ?? DefaultValue.double)
                }}
        } else if tripData?.status == TripStatus.DRIVER_ARRIVED {
            if let newDestination = tripData?.destinationNew?.address{
                if newDestination.isEmpty{
                    goToLocation = CLLocationCoordinate2D.init(latitude: tripData?.destination?.latitude ?? DefaultValue.double,
                                                               longitude: tripData?.destination?.longitude ?? DefaultValue.double)
                }else{
                    goToLocation = CLLocationCoordinate2D.init(latitude: tripData?.destinationNew?.latitude ?? DefaultValue.double,
                                                               longitude: tripData?.destinationNew?.longitude ?? DefaultValue.double)
                }}
        }
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: goToLocation, addressDictionary: nil))
        mapItem.name = "Destination"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func openGoogleMap() {
        var lat = 0.0
        var lng = 0.0
        let tripData = RideSingleton.shared.tripDetailObject?.data
        if tripData?.status == TripStatus.PENDING || tripData?.status == TripStatus.ACCEPTED_BY_DRIVER {
            if let newDestination = tripData?.destinationNew?.address{
                if newDestination.isEmpty{
                    lat = tripData?.source?.latitude ?? DefaultValue.double
                    lng = tripData?.source?.longitude ?? DefaultValue.double
                }else{
                    lat = tripData?.source?.latitude ?? DefaultValue.double
                    lng = tripData?.source?.longitude ?? DefaultValue.double
                }
                
            }
        } else if tripData?.status == TripStatus.DRIVER_ARRIVED || tripData?.status == TripStatus.STARTED || tripData?.status == TripStatus.COMPLETED {
            if let newDestination = tripData?.destinationNew?.address{
                if newDestination.isEmpty{
                    lat = tripData?.destination?.latitude ?? DefaultValue.double
                    lng = tripData?.destination?.longitude ?? DefaultValue.double
                } else {
                    lat = tripData?.destinationNew?.latitude ?? DefaultValue.double
                    lng = tripData?.destinationNew?.longitude ?? DefaultValue.double
                }
                
            }
        } else {
            let heatMapVC = RideSingleton.shared.heatMaplocaionPoints
            lat = heatMapVC?.coordinate.latitude ?? 0.0
            lng = heatMapVC?.coordinate.longitude ?? 0.0
        }
        
        if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(lat),\(lng)&directionsmode=driving") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

//MARK: - Observers
extension MainDashboardViewController {
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSwitchUserView), name: .toggleUserSwitchView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNearbyVehicles), name: .showNearByCars, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripNavigation), name: .tripNavigation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSettingItem), name: .switchLeftBarItem, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDriversCurrentLocation), name: .updateLocationForDriver, object: nil)
    }
    
    @objc private func updateDriversCurrentLocation(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary?, let location = dict["location"] as? CLLocation {
            let tripData = RideSingleton.shared.tripDetailObject?.data
            let source = location.coordinate
            print(tripData?.status)
            if tripData?.status == .PENDING {
                let destination = CLLocationCoordinate2D.init(latitude: tripData?.source?.latitude ?? DefaultValue.double,
                                                              longitude: tripData?.source?.longitude ?? DefaultValue.double)
                
                drawPolyLine(startingLoc: source, endingLocation: destination, shouldBound: false, rotation: location.course)
                
            } else if tripData?.status == .STARTED {
                var destination = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
                if let newDestination = tripData?.destinationNew?.address{
                    if newDestination.isEmpty{
                        destination = CLLocationCoordinate2D.init(latitude: tripData?.destination?.latitude ?? DefaultValue.double,
                                                                  longitude: tripData?.destination?.longitude ?? DefaultValue.double)
                    }else{
                        destination = CLLocationCoordinate2D.init(latitude: tripData?.destinationNew?.latitude ?? DefaultValue.double,
                                                                  longitude: tripData?.destinationNew?.longitude ?? DefaultValue.double)
                    }}
                
                drawPolyLine(startingLoc: source, endingLocation: destination, shouldBound: false, rotation: location.course)
            } else if tripData?.status == .ACCEPTED_BY_DRIVER {
                let driverLocation = CLLocationCoordinate2D.init(latitude: tripData?.driverInfo?.latitude ?? DefaultValue.double,
                                                                 longitude: tripData?.driverInfo?.longitude ?? DefaultValue.double)
                var destination = CLLocationCoordinate2D.init(latitude: 0.0, longitude:0.0)
                if let newDestination = tripData?.destinationNew?.address{
                    if newDestination.isEmpty{
                        destination = CLLocationCoordinate2D.init(latitude: tripData?.destination?.latitude ?? DefaultValue.double,
                                                                  longitude: tripData?.destination?.longitude ?? DefaultValue.double)
                    }else{
                        destination = CLLocationCoordinate2D.init(latitude: tripData?.destinationNew?.latitude ?? DefaultValue.double,
                                                                  longitude: tripData?.destinationNew?.longitude ?? DefaultValue.double)
                    }}
                
                drawPolyLine(startingLoc: driverLocation, endingLocation: destination, shouldBound: false, rotation: location.course)
            }
        }
    }
    
    @objc private func showNearbyVehicles(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            if let drivers = dict["drivers"] as? [Driver]{
                var cords: [CLLocationCoordinate2D] = []
                for person in drivers{
                    cords.append(CLLocationCoordinate2D.init(latitude: person.latitude ?? 0.0, longitude: person.longitude ?? 0.0))
                }
                self.drawCabMarkers(cords: cords)
            }
        }
    }
    
    
    
    @objc func handleSwitchUserView() {
        setLeftBackButton(selector: #selector(backButton) , rotate: false)
    }
    
    @objc private func showSettingItem() {
        setLeftSettingsButton(selector: #selector(didPressSettingsButton))
    }
    
    @objc private func backButton() {
        let childNavigationController = (containerView.subviews.first?.getParentController() as? UINavigationController)
        
        let lastVC = childNavigationController?.viewControllers.last
        
        if let previousVC = lastVC{
            if previousVC.isKind(of: RiderPickUpVC.self) {
                setupSwitchUserModeView()
                previousVC.navigationController?.popViewController(animated: false)
            }
            if previousVC.isKind(of: RiderPickUpLocationVC.self) {
                previousVC.navigationController?.popViewController(animated: false)
            }
            if previousVC.isKind(of: RiderKYCVC.self) {
                previousVC.navigationController?.popViewController(animated: false)
            }
            if previousVC.isKind(of: RiderRideSelection.self) {
                previousVC.navigationController?.popViewController(animated: false)
                self.mapView?.clear()
                (parent?.parent as? MainDashboardViewController)?.addCurrentLocationMarker()
            }
            if previousVC.isKind(of: RiderNoDriverVC.self)  ||   previousVC.isKind(of: RiderWaitingVC.self) {
                cancelTripVM.cancelTrip(id: self.tripId)
            }
            if previousVC.isKind(of: RiderEnterPinVC.self) {
                rideCancelAfterAcceptVM.cancelTripByRider(id: self.tripId, reason: "test")
            } else if previousVC.isKind(of: AddPromoCodeVC.self) {
                previousVC.navigationController?.popViewController(animated: false)
            }
            
            if let vc = previousVC as? CancelRideByDriverViewController {
                vc.callback?(vc.previousContainerHeight)
                previousVC.navigationController?.popViewController(animated: false)
            }
            
            if previousVC.isKind(of: AddBalanceVC.self) {
                previousVC.navigationController?.popViewController(animated: false)
            }
            
            if previousVC.isKind(of: StatusAlertVC.self) {
                previousVC.navigationController?.popViewController(animated: false)
            }
        }
        
    }
    
    @objc private func tripNavigation(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let res = dict["data"] as? TripResponse{
                if res.statusCode == 201{
                    self.tripId = res.data?.id ?? ""
                }else{
                    self.tripId = res.data?.id ?? ""
                    //(self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = 350
                    if let vc: RiderNoDriverVC = UIStoryboard.instantiate(with: .riderToDriver) {
                        vc.tripId = self.tripId
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                    //                    if let vc: RiderNoDriverVC = UIStoryboard.instantiate(with: .riderToDriver) {
                    //                        vc.tripId = self.tripId
                    //                        self.navigationController?.pushViewController(vc, animated: false)
                    //                    }
                }
            }
        }
    }
}

extension MainDashboardViewController {
    func bindViewToViewModel() {
        cancelTripVM.cancelTripResponse.bind { [weak self] res in
            guard let self = self else { return }
            if res.statusCode == 200{
                print("msg : ",res.message as Any)
                let childNavigationController = (self.containerView.subviews.first?.getParentController() as? UINavigationController)
                
                let controllers = childNavigationController?.viewControllers ?? []
                for vc in controllers{
                    if vc.isKind(of: RiderDropOffVC.self){
                        self.setupSwitchUserModeView()
                        childNavigationController?.popToViewController(vc, animated: false)
                        return
                    }
                }
            }else{
                print("res : ",res.data as Any)
            }
        }
        
        cancelTripVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        rideCancelAfterAcceptVM.riderCancelResponse.bind { [weak self] res in
            guard let self = self else { return }
            if res.statusCode == 200{
                print("msg : ",res.message as Any)
                let childNavigationController = (self.containerView.subviews.first?.getParentController() as? UINavigationController)
                
                let controllers = childNavigationController?.viewControllers ?? []
                for vc in controllers{
                    if vc.isKind(of: RiderDropOffVC.self){
                        self.setupSwitchUserModeView()
                        childNavigationController?.popToViewController(vc, animated: false)
                        return
                    }
                }
            }
        }
        
        rideCancelAfterAcceptVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        mainDashboardVM.apiResponseData.bind { [weak self] data in
            guard let `self` = self else { return }
            
            if data.statusCode == 200 || data.statusCode == 201 {
                //MARK: case Pending or not accepted trip
                if data.statusCode == 1 {
                    RideSingleton.shared.tripDetailObject?.data = data.data
                    UserDefaultsConfig.tripId = data.data?.id
                    let childNavigationController = (self.containerView.subviews.first?.getParentController() as? UINavigationController)
                    self.containerViewHeight.constant = 420
                    if let vc: RiderRequestViewController = UIStoryboard.instantiate(with: .driverToRider) {
                        childNavigationController?.pushViewController(vc, animated: false)
                    }
                }else {
                    if UserDefaultsConfig.isDriver {
                        self.moveToDriverScreen(with: data.data)
                    } else {
                        self.moveToRiderScreen(with: data.data)
                    }
                }
                
            }
            
        }
        
        
        mainDashboardVM.checkCaptainStatus.bind { [weak self] (response, type) in
            guard let `self` = self else { return }
            
            guard let data = response.data else { return }
            
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            UserDefaultsConfig.user?.isWASLApproved = response.data?.isWASLApproved
            if type == .fromLanding {
                
                if UserDefaultsConfig.isDriver {
                    if data.driverModeSwitch == true {
                        if data.driverRideStatus == true {
                            self.showDriverMainScreen()
                            self.mainDashboardVM.getDriverTrip(shouldChangeMode: false)
                        } else {
                            if self.mainDashboardVM.checkCaptainStatus.value.0.data?.driverSubStatus == 1{
                                // Show Driver Main Screen Locally
                                self.showDriverMainScreen()
                            } else {
                                let leftView = self.navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
                                leftView?.selectCaptainView()
                            }
                        }
                    } else {
                        if response.data?.driverModeSwitch == false {
                            self.mainDashboardVM.getRiderTrip(shouldChangeMode: response.data?.isWASLApproved == 0 ? false : true)
                        } else if response.data?.isWASLApproved == 1 {
                            self.mainDashboardVM.getRiderTrip(shouldChangeMode: response.data?.isWASLApproved == 0 ? false : true)
                        }
                    }
                } else {
                    if data.driverModeSwitch == true {
                        if data.driverRideStatus == true {
                            if response.data?.driverModeSwitch == false {
                                self.mainDashboardVM.getRiderTrip(shouldChangeMode: response.data?.isWASLApproved == 0 ? false : true)
                            } else if response.data?.isWASLApproved == 1 {
                                self.mainDashboardVM.getRiderTrip(shouldChangeMode: response.data?.isWASLApproved == 0 ? false : true)
                            }
                        } else {
                            UserDefaultsConfig.isDriver = true
                            self.mainDashboardVM.changeDriverMode()
                        }
                    } else {
                        self.showRiderMainScreen()
                        self.mainDashboardVM.getRiderTrip(shouldChangeMode: false)
                    }
                }
            } else if type == .toRefreshOnly {
                self.showDriverMainScreen()
            } else {
                if response.statusCode == 200 {
                    if response.data?.driverRideStatus == false {
                        self.mainDashboardVM.changeDriverMode()
                        return
                    }
                } else if response.statusCode == 400 {
                    self.showBecomeDriverScreen(isDriver: true)
                }
            }
            
            if UserDefaultsConfig.isDriver{
                if response.data?.isWASLApproved == 0{
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    let leftView = self.navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
                    leftView?.selectCaptainView()
                    
                    if let vc: ApplicationStatusViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                        self.containerViewHeight.constant = 290
                        (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                        self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                    }
                    return
                }else if response.data?.isWASLApproved == 2{
                    if UserDefaultsConfig.waslRejectionStatus == false{
                        UserDefaultsConfig.waslRejectionStatus = true
                        Commons.adjustEventTracker(eventId: AdjustEventId.WASLRejection)
                    }
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    let leftView = self.navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
                    leftView?.selectCaptainView()
                    self.waslRejectionReason = response.data?.WASLRejectionReasons ?? ""
                    if let vc: ApplicationStatusViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                        self.containerViewHeight.constant = 290
                        
                        vc.isRejected = true
                        vc.rejectionReason =  response.data?.WASLRejectionReasons ?? ""
                        (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                        self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                    }
                    return
                    
                }
                else{
                    self.showApplicationStatusApproveIfNeeded()
                }
            }
        }
        
        mainDashboardVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        mainDashboardVM.updateCaptainStatus.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            if UserDefaultsConfig.isDriver == false {
                self.showDriverMainScreen()
            } else if UserDefaultsConfig.isDriver == true {
                self.showRiderMainScreen()
            }
            
            if UserDefaultsConfig.isDriver{
                if UserDefaultsConfig.user?.isWASLApproved == 0 {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    let leftView = self.navigationItem.leftBarButtonItem?.customView as? DashboardSwitchView
                    leftView?.selectCaptainView()
                    
                    if let vc: ApplicationStatusViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                        self.containerViewHeight.constant = 290
                        (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                        self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                    }
                    return
                }else{
                    self.showApplicationStatusApproveIfNeeded()
                }
            }
        }
        
        mainDashboardVM.getApplicationStatus.bind { [weak self] res in
            guard let self = self else {return}
            if res.code == 200{
                if res.data?.isApproved ?? false{
                    if let vc: ApplicationStatusApproveViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                        vc.payableAmount = self.mainDashboardVM.checkCaptainStatus.value.0.data?.driverSubAmount
                        UserDefaultsConfig.isDriver = true
                        (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                        self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                    }
                }else{
                    if let vc: ApplicationStatusViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
                        self.containerViewHeight.constant = 290
                        UserDefaultsConfig.isDriver = true
                        (self.containerView.subviews.first?.getParentController() as? UINavigationController)?.removeChildController()
                        self.addChildWithNavViewController(childController: vc, contentView: self.containerView)
                    }
                }
            }
        }
        
        mainDashboardVM.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        mainDashboardVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
        
        mainDashboardVM.getCaptainError.bind { [weak self] (error, type) in
            guard let `self` = self else { return }
            
            if error.code == 404{
                if type == .fromLanding {
                    self.mainDashboardVM.getRiderTrip(shouldChangeMode: false)
                    self.showRiderMainScreen()
                } else {
                    self.showBecomeDriverScreen(isDriver: true)
                }
            }else{
                //                if UserDefaultsConfig.isRider{
                //                    self.showRiderMainScreen()
                //                }
            }
        }
        
        balanceVM.apiResponseData.bind {[weak self] (value) in
            guard let `self` = self else { return }
            if value.statusCode == 200 {
                RideSingleton.shared.userBalance = value.data?.balance
            }
        }
        
        mainDashboardVM.verifySubscriptionRes.bind { [weak self] value in
            guard let `self` = self else { return }
            
            if value.statusCode == 200 {
                self.showDriverMainScreen()
            }
        }
        
        mainDashboardVM.verifySubscriptionError.bind { [weak self] value in
            guard let `self` = self else { return }
            
            if let code = value.code, code == 400 {
                self.showApplicationStatusApprove()
            }
        }
        
        mainDashboardVM.highDemandZone.bind { [weak self] value in
            guard let `self` = self else { return }
            
            if value.statusCode == 200 {
                self.addHeatMapLocation()
            } else {
                self.addHeatMapLocation()
            }
        }
    }
    
    private func moveToRiderScreen(with data: TripDetail?) {
        let childNavigationController = (containerView.subviews.first?.getParentController() as? UINavigationController)
        let tripObj = TripDetailResponse(data: data, action: nil)
        RideSingleton.shared.tripDetailObject = tripObj
        UserDefaultsConfig.tripId = data?.id
        self.tripId = data?.id ?? DefaultValue.string
        
        if data?.status == .ACCEPTED_BY_DRIVER || data?.status == .DRIVER_ARRIVED {
            containerViewHeight.constant = 360
            if let vc: RiderEnterPinVC = UIStoryboard.instantiate(with: .riderToDriver) {
                childNavigationController?.pushViewController(vc, animated: false)
            }
        } else if data?.status == .STARTED {
            containerViewHeight.constant = 320
            if let vc: RiderDuringRide = UIStoryboard.instantiate(with: .riderToDriver) {
                childNavigationController?.pushViewController(vc, animated: false)
            }
        } else if data?.status == .COMPLETED {
            containerViewHeight.constant = 480
            if let vc: RiderCompletedRideVC = UIStoryboard.instantiate(with: .riderToDriver) {
                childNavigationController?.pushViewController(vc, animated: false)
            }
        } else if data?.status == .CANCELLED_BY_RIDER || data?.status == .CANCELLED_BY_DRIVER {
            UserDefaultsConfig.tripId = nil
            RideSingleton.shared.tripDetailObject = nil
        }
    }
    
    private func moveToDriverScreen(with data: TripDetail?) {
        let childNavigationController = (containerView.subviews.first?.getParentController() as? UINavigationController)
        
        let tripObj = TripDetailResponse(data: data, action: nil)
        RideSingleton.shared.tripDetailObject = tripObj
        
        if data?.status == .ACCEPTED_BY_DRIVER { // riode accepted by driver
            UserDefaultsConfig.tripId = data?.id
            containerViewHeight.constant = 270
            if let vc: RiderConfirmedViewController = UIStoryboard.instantiate(with: .driverToRider) {
                childNavigationController?.pushViewController(vc, animated: false)
            }
        }
        
        if data?.status == .CANCELLED_BY_DRIVER {   // ride cancel by driver after accepting
            UserDefaultsConfig.tripId = nil
            RideSingleton.shared.tripDetailObject = nil
        }
        
        if data?.status == .DRIVER_ARRIVED { //enter pin by driver
            UserDefaultsConfig.tripId = data?.id
            containerViewHeight.constant = 340
            if let vc: EnterPINToStartRideViewController = UIStoryboard.instantiate(with: .driverToRider) {
                childNavigationController?.pushViewController(vc, animated: false)
            }
        }
        
        if data?.status == .CANCELLED_BY_RIDER { //ride cancelled
            UserDefaultsConfig.tripId = nil
            RideSingleton.shared.tripDetailObject = nil
        }
        
        if data?.status == .STARTED { //ride in progress
            UserDefaultsConfig.tripId = data?.id
            containerViewHeight.constant = 280
            if let vc: RideInProgressViewController = UIStoryboard.instantiate(with: .driverToRider) {
                childNavigationController?.pushViewController(vc, animated: false)
            }
        }
        
        if data?.status == .COMPLETED { //submit rating screen
            UserDefaultsConfig.tripId = data?.id
            containerViewHeight.constant = 400
            if let vc: CompleteRideViewController = UIStoryboard.instantiate(with: .driverToRider) {
                childNavigationController?.pushViewController(vc, animated: false)
            }
        }
        
    }
    
    func checkAppUpdate() {
        if UserDefaultsConfig.appVersion.isSome {
            if AppVersion < UserDefaultsConfig.appVersion! {
                if let url = URL(string: "\(AppLink)") {
                    UIApplication.shared.open(url)
                }
            } else {
                let vc = GenericOnboardingViewController()
                vc.checkLatestVersionApp()
            }
        } else {
            let vc = GenericOnboardingViewController()
            vc.checkLatestVersionApp()
        }
    }
}
