//
//  MyRidesVC.swift
//  Ride
//
//  Created by PSE on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

enum MyRidesType {
    case RidesTaken, RidesGiven
}

class MyRidesVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var ridesTaken: UIButton!
    @IBOutlet weak var ridesGiven: UIButton!
    @IBOutlet weak var ridesTV: UITableView!
    @IBOutlet weak var chartsView: UIView!
    @IBOutlet weak var chartsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chartsViewTop: NSLayoutConstraint!
    
    @IBOutlet var timebtns: [UIButton]!

    //MARK: - Constants and Variables
    private let riderVM = MyRidesViewModel()
    private var selectedRide : TripsDetails?
    private var rideType = MyRidesType.RidesTaken {
        didSet {
            if rideType == .RidesTaken {
                if riderVM.getRiderRides.value.data?.trips?.isEmpty ?? true {
//                    riderVM.getRiderTrip()
                }
            } else {
                if riderVM.getDriverRides.value.data?.trips?.isEmpty ?? true {
//                    riderVM.getDriverTrip()
                }
            }
            
            ridesTV.reloadData()
        }
    }
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        bindToViewModel()
        riderVM.getRiderTrip()
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
        ridesTV.register(UINib(nibName: MyRidesCell.className, bundle: nil), forCellReuseIdentifier: MyRidesCell.className)
        self.ridesTaken.isSelected = true
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        ridesTaken.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        ridesGiven.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        
        DispatchQueue.main.async {
            self.ridesGiven.setTitle("Rides Given".localizedString(), for: .selected)
            self.ridesTaken.setTitle(("Rides Taken".localizedString()), for: .selected)
        }
    }
    
    // MARK: - Navigation
     
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - IBActions
    @IBAction func ridesTakenPressed(_ sender: Any) {
        self.ridesGiven.backgroundColor = .lightGrayBG
        self.ridesGiven.isSelected = false
        self.ridesTaken.isSelected = true
        self.ridesTaken.backgroundColor = .primaryBtnBg
        
        self.showCharts(show: false)
        
        rideType = .RidesTaken
        
        if riderVM.getRiderRides.value.data?.trips?.isEmpty ?? true {
            riderVM.getRiderTrip()
        }
        
//        ridesTaken.setTitle(("Rides Taken".localizedString()), for: .selected)
//        ridesGiven.setTitle("Rides Given".localizedString(), for: .selected)
    }
    
    @IBAction func ridesGivenPressed(_ sender: Any) {
        self.ridesGiven.backgroundColor = .primaryBtnBg
        self.ridesGiven.isSelected = true
        self.ridesTaken.isSelected = false
        self.ridesTaken.backgroundColor = .lightGrayBG
        
        rideType = .RidesGiven
        
        if riderVM.getDriverRides.value.data?.trips?.isEmpty ?? true {
            riderVM.getDriverTrip()
        }
        
        if !(riderVM.getDriverRides.value.data?.trips?.isEmpty ?? true) {
            self.showCharts(show: false)
            let topRow = IndexPath(row: 0,section: 0)
            self.ridesTV.scrollToRow(at: topRow,at: .top,animated: true)
        }
//        DispatchQueue.main.async {
//            self.ridesGiven.setTitle("Rides Given".localizedString(), for: .selected)
//            self.ridesTaken.setTitle(("Rides Taken".localizedString()), for: .selected)
//        }
        
    }
    
    @IBAction func timePressed(_ sender: UIButton) {
        print("view tag = ",sender.tag)
        timebtns.forEach({(time) in
            time.isSelected = false
            time.backgroundColor = .clear
        })
        let tag = sender.tag
        timebtns[tag].isSelected = true
        timebtns[tag].backgroundColor = .black
    } 
    
    //MARK: - custom Functions
    
    func showCharts(show : Bool){
        if show{
            self.chartsViewHeight.constant = 200
            self.chartsViewTop.constant = 16
        }else{
            self.chartsViewHeight.constant = 0
            self.chartsViewTop.constant = 0
        }
    }
    
}

//MARK: - Tableview delegate and datasource
extension MyRidesVC: UITableViewDelegate, UITableViewDataSource {
   
   func numberOfSections(in tableView: UITableView) -> Int {
       rideType == .RidesTaken ? riderVM.getRiderRides.value.data?.trips?.count ?? DefaultValue.int : riderVM.getDriverRides.value.data?.trips?.count ?? DefaultValue.int
   }
   
   // There is just one row in every section
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
   }
   
   // Set the spacing between sections
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 0
   }
   
   // Make the background color show through
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
       headerView.backgroundColor = UIColor.clear
       return headerView
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: MyRidesCell.className, for: indexPath) as? MyRidesCell else { return MyRidesCell() }
       let item = rideType == .RidesTaken ? riderVM.getRiderRides.value.data?.trips?[indexPath.section] : riderVM.getDriverRides.value.data?.trips?[indexPath.section]
       
       cell.type = rideType
       cell.item = item
       
       return cell
   }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rideType == .RidesTaken{
            let trip : TripsDetails = riderVM.getRiderRides.value.data!.trips![indexPath.section]
            self.selectedRide = trip
            riderVM.getTripDetail(tripid: trip.id ?? "")
            tableView.allowsSelection = false
        }else{
            let trip : TripsDetails = riderVM.getDriverRides.value.data!.trips![indexPath.section]
            self.selectedRide = trip
            riderVM.getTripDetail(tripid: trip.id ?? "")
            tableView.allowsSelection = false
        }
        
//
    }
}

extension MyRidesVC {
    private func bindToViewModel() {
        riderVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        riderVM.messageWithCode.bind { [weak self] error in
            guard let `self` = self else { return }
            guard !(error.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: error.message ?? DefaultValue.string)
            self.ridesTV.allowsSelection = true
        }
        
        
        riderVM.getRiderRides.bind { [weak self] response in
            guard let `self` = self else { return }
            
            if response.statusCode == 200 {
                //                self.ridesTakenPressed(0)
                self.ridesTV.reloadData()
            }
        }
        
        riderVM.getDriverRides.bind { [weak self] response in
            guard let `self` = self else { return }
            
            if response.statusCode == 200 {
                //                self.ridesGivenPressed(0)
                self.ridesTV.reloadData()
            }
        }
        
        riderVM.getTripDetail.bind { [weak self] response  in
            guard let `self` = self else { return }
            guard response.statusCode.isSome else { return }
            self.ridesTV.allowsSelection = true
            if let vc: RideDetailsVC = UIStoryboard.instantiate(with: .userProfile) {
                vc.tripType = self.rideType
                vc.tripData = self.selectedRide
                vc.taxAmount = response.data?.taxAmount
                vc.carPlateNo = response.data?.driverInfo?.carPlateNo
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


