//
//  MapViewVC.swift
//  Ride
//
//  Created by XintMac on 14/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class MapViewVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var currentAddress: UILabel!
    @IBOutlet weak var setLocationLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var locationTV: UITableView!
    @IBOutlet weak var locationTVView: UIView!
    @IBOutlet weak var myLocBtn: UIButton!
    
    //MARK: - Constants and Variables
    private let mapVM = MapViewModel()
    var mapView: GMSMapView?
    var currentLocationMarker: GMSMarker?
    var nLat: Double?
    var nLong: Double?
    var subText : String?
    private var workItemReference: DispatchWorkItem? = nil
    var locationSelected : ((CLLocation,String,String, Float?) -> ())?
    lazy var searchBar = UISearchBar()

     //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        goToLocation()
        
        confirmBtn.enableButton(false)
        self.setupViews()
        
        addCurrentLocationMarker()
        
        currentAddress.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        setLocationLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(22) : UIFont.SFProDisplaySemiBold?.withSize(22)
        confirmBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(18) : UIFont.SFProDisplayRegular?.withSize(18)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationTVView.isHidden = true
        //addObservers()
        self.locationTV.isHidden = true
        mapVM.autocompleteResults.removeAll()
        locationTV.reloadData()
        searchBar.backgroundImage = nil
        searchBar.delegate = self
        searchBar.searchTextField.attributedPlaceholder =  NSAttributedString.init(string: "Search".localizedString(), attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
        searchBar.searchTextField.leftView?.tintColor = .black
        
       // searchBar.placeholder = "Search".localizedString()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchTextField.textColor = .black
        searchBar.searchTextField.backgroundColor = .white
        self.navigationItem.titleView = searchBar
        self.navigationItem.titleView?.semanticContentAttribute = .forceLeftToRight
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
        searchBar.searchTextField.textAlignment = Commons.isArabicLanguage() ? .right : .left
        self.searchBar.searchTextField.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        self.mapView = nil
    }
    
    private func addCurrentLocationMarker() {
        if let location = LocationManager.shared.locationManager?.location {
            currentLocationMarker = GMSMarker(position: location.coordinate)
            currentLocationMarker?.icon = UIImage(named: "MapCurrentMarker")
            currentLocationMarker?.map = mapView
        }
    }
    
    private func setupViews() {
        setupTableView()
        
        view.layoutIfNeeded()
    }
    
    private func setupTableView() {
        locationTV.register(UINib(nibName: GoogleLocationSuggestionTableViewCell.className, bundle: nil), forCellReuseIdentifier: GoogleLocationSuggestionTableViewCell.className)
    }
    
    private func moveScreen(){
        if self.mapVM.autocompleteResults.count != 0{
            self.locationTV.isHidden = false
            self.locationTVView.isHidden = false
        } else {
            self.locationTV.isHidden = true
            self.locationTVView.isHidden = true
        }
    }
    
    private func goToLocation() {
        if let currentLocation = LocationManager.shared.locationManager?.location{
            let camera = GMSCameraPosition.camera(withLatitude:currentLocation.coordinate.latitude, longitude:currentLocation.coordinate.longitude, zoom: 16)
            
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                CATransaction.begin()
                CATransaction.setValue(0, forKey: kCATransactionAnimationDuration)
                self.mapView?.animate(to: camera)
                CATransaction.commit()
                
                self.reverseGeocode(location: CLLocation(latitude:currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else { return }
                let camera = GMSCameraPosition.camera(withLatitude:currentLocation.coordinate.latitude, longitude:currentLocation.coordinate.longitude, zoom: 16)
                
                self.mapView(self.mapView!, idleAt: camera)
            }
        }
    }
    
    func setupMap() {
        mapView = GMSMapView(frame: view.frame)
        view.addSubview(mapView!)
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            setDarkMap()
        } else {
            mapView?.mapStyle = nil
        }
        mapView?.delegate = self
        
        setLeftBackButton(selector: #selector(backButton),rotate: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            setDarkMap()
        } else {
            mapView?.mapStyle = nil
        }
    }
    
    private func setDarkMap() {
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "DarkGMSStyle", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        view.sendSubviewToBack(mapView!)
        view.bringSubviewToFront(marker)
    }
    
    @objc private func backButton() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func myLocBtnPressed(_ sender: Any) {
        let loc = LocationManager.shared.locationManager
        guard let lat = loc?.location?.coordinate.latitude else { return }
        guard let lng = loc?.location?.coordinate.longitude else { return }
        
        DispatchQueue.main.async { [weak self] in
            let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng , zoom: self?.mapView?.camera.zoom ?? 16)
            self?.mapView?.animate(to: camera)
        }

    }
    
    
    func reverseGeocode(location: CLLocation) {
        
        GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                                      longitude: location.coordinate.longitude)) { res, error in
            if let address = res?.firstResult(), let lines = address.lines {
                
                self.nLat = location.coordinate.latitude
                self.nLong = location.coordinate.longitude
                self.currentAddress.text = lines.joined(separator: ", ")
                if self.currentAddress.text?.isEmpty ?? true {
                    self.currentAddress.text = "Unnamed Location".localizedString()
                }
                self.confirmBtn.enableButton(true)
                self.confirmBtn.backgroundColor = .primaryBtnBg
            } else {
                self.confirmBtn.enableButton(true)
                self.confirmBtn.backgroundColor = .primaryBtnBg
                self.currentAddress.text = "Unnamed Location".localizedString()
            }
        }
    }
    
    func reverseGeocodeArabicLanguage(location: CLLocation) {
        
        LocationManager.shared.getReverseGeoCodedLocationArabic(location: location) { [weak self] (loc, place, error) in
            guard let self = self else {return}
            if let place = place {
                self.nLat = location.coordinate.latitude
                self.nLong = location.coordinate.longitude
                self.currentAddress.text = Commons.getAddressStrFromPlaceMark(place: place) // place.description
            }
        }
    }
    
    @IBAction func comfirmPressed(_ sender: Any) {
        let zoomLevel = mapView?.camera.zoom
        
        let location = CLLocation(latitude: nLat ?? DefaultValue.double,
                                                  longitude: nLong ?? DefaultValue.double)
        self.locationSelected?(location , currentAddress.text ?? "", subText ?? (currentAddress.text ?? ""), zoomLevel)
        self.navigationController?.popViewController(animated: false)
    }
}

// MARK:- Extensions
extension MapViewVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        confirmBtn.enableButton(false)
        
        let point = CGPoint(x: mapView.center.x, y: marker.frame.maxY)
        
        nLat = mapView.projection.coordinate(for: point).latitude
        nLong = mapView.projection.coordinate(for: point).longitude
        
        print("NLAT: \(position.target.latitude)")
        print("NLAT2: \(mapView.projection.coordinate(for: mapView.center).latitude)")
        
        self.reverseGeocode(location: CLLocation(latitude: nLat ?? 0, longitude: nLong ?? 0))
    }
}



//MARK: - Tableview delegate and datasource
extension MapViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mapVM.autocompleteResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GoogleLocationSuggestionTableViewCell.className, for: indexPath) as? GoogleLocationSuggestionTableViewCell else { return GoogleLocationSuggestionTableViewCell() }
        
        cell.item = mapVM.autocompleteResults[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    fileprivate func resetSearch() {
        self.mapVM.autocompleteResults.removeAll()
        searchBar.text = ""
        self.locationTV.isHidden = true
        self.locationTVView.isHidden = true
        self.locationTV.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapVM.getAPIDetail(index: indexPath.row) { [weak self] index, placeDetail in
            guard let `self` = self else { return }
            
            let location = CLLocation(latitude: placeDetail.latitude ?? DefaultValue.double,
                                      longitude: placeDetail.longitude ?? DefaultValue.double)
            
            let camera = GMSCameraPosition.camera(withLatitude:location.coordinate.latitude, longitude:location.coordinate.longitude, zoom: 16)
            self.mapView?.animate(to: camera)
            self.resetSearch()
        }
    }
}

 //MARK: - Searchbar delegates

extension MapViewVC : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //let fullText = searchText.text
        if searchText.count == 0 {
            resetSearch()
            return
        }
        workItemReference?.cancel()
        let searchWorkItem = DispatchWorkItem {
            self.mapVM.showResults(string: searchText) { [weak self] in
                guard let `self` = self else { return }
                
                self.moveScreen()
                self.locationTV.reloadData()
            }
        }
        workItemReference = searchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500), execute: searchWorkItem)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

