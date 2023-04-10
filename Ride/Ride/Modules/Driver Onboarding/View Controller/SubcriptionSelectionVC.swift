//
//  SubcriptionSelectionVC.swift
//  Ride
//
//  Created by XintMac on 23/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import DropDown

class SubcriptionSelectionVC: UIViewController {
    
    
   //MARK: - IBoutlets
    @IBOutlet weak var subcriptionCV : UICollectionView!
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var subscriptionLabel: UILabel!
    
    //MARK: - Constants and Variables
    var CarDetail : CarSequenceData?
    //var subcrioptionsModel = [GetSubcriptionsData]()
    private let getsubcriptionViewModel = GetSubcriptionViewModel()
    private let driverKYCVM = DriverKYCViewModel()
    private var subcriptions = [GetSubcriptionsData]()
    var hasSubscribedBefore : Bool = false
    let dropDown = DropDown()
    
     //MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setLeftBackButton(selector: #selector(backButtonTapped),rotate: false)
        subcriptionCV.delegate = self
        subcriptionCV.dataSource = self
        
        subcriptionCV.register(UINib(nibName: SubscriptionCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: SubscriptionCollectionViewCell.className)
        
        bindViewToViewModel()
        
        getsubcriptionViewModel.getSubcription()
        self.proceedBtn.enableButton(false)
        
        proceedBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        filterBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(12) : UIFont.SFProDisplaySemiBold?.withSize(12)
        subscriptionLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasSubscribedBefore{
        if let vc: CarSelectionVC = UIStoryboard.instantiate(with: .driverOnboarding) {
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.CarDetail = self.CarDetail
            present(vc, animated: true)
            vc.selectedIndex = { [weak self] (index) in
//                self.chooseCarView.isHidden = true
//                self.chosenCarView.isHidden = false
//                self.mainStackview.setNeedsLayout()
//                self.mainStackview.sizeToFit()
                UserDefaultsConfig.subscriptionId = "testSubscriptionId"
                self?.driverKYCVM.becomeCaption(driverName: "", driverNationalId: "", carPlateNo: "", carLicenceType: UserDefaultsConfig.carLicenceType ?? 0, carCategoryType: 1, cab: "", carSequenceNo: "", drivingModes: [], acceptTC: true, isShowLoader: false, isForWaslCheck: false, subscriptionId: "", autoRenewal: false, transactionId: "")
            }
        }
        }
        
        dropDown.anchorView = filterBtn
        dropDown.direction = .bottom
        dropDown.dismissMode = .onTap
        dropDown.width = 100
        dropDown.dataSource = ["All", "Monthly", "Yearly"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            dropDown.hide()
            filterBtn.setTitle(item, for: .normal)
            if index == 0{
                self.subcriptions = self.getsubcriptionViewModel.activeSubscription
                self.subcriptionCV.reloadData()
            }else{
                let filterSub = self.getsubcriptionViewModel.activeSubscription
                self.subcriptions = filterSub.filter { $0.planType == index }
                self.subcriptionCV.reloadData()
            }
        }
    }
    

  
     //MARK: - IBActions
    @IBAction func proceedBtnPressed(_ sender: Any) {
//        Commons.goToMain(type: .driver, isSignUp: true)
        Commons.adjustEventTracker(eventId: AdjustEventId.CarConfirmationSuccess)
        
       // checkApplicationViewModel.checkApplication(reason: "1")
        
        driverKYCVM.becomeCaption(driverName: "", driverNationalId: "", carPlateNo: "", carLicenceType: UserDefaultsConfig.carLicenceType ?? 0, carCategoryType: 1, cab: "", carSequenceNo: "", drivingModes: [], acceptTC: true, isShowLoader: false, isForWaslCheck: false, subscriptionId: "", autoRenewal: false, transactionId: "")
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func filterBtnTapped(_ sender: Any) {
        dropDown.show()
    }
    
    
}

////MARK: - Tableview delegate and datasource
//extension SubcriptionSelectionVC: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return getsubcriptionViewModel.activeSubscription.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    // Set the spacing between sections
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 4
//    }
//    
//    // Make the background color show through
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionSelection.className, for: indexPath) as? SubscriptionSelection else { return SubscriptionSelection() }
//    }
//        //
//        //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        //        return 1
//        //    }
//        //
//        //    // Set the spacing between sections
//        //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        //        return 4
//        //    }
//        //
//        //    // Make the background color show through
//        //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        //        let headerView = UIView()
//        //        headerView.backgroundColor = UIColor.clear
//        //        return headerView
//        //    }
//        //
//        //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        //        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionSelection.className, for: indexPath) as? SubscriptionSelection else { return SubscriptionSelection() }
//        ////
//        ////        if indexPath.section == 1{
//        ////            cell.salePercent.backgroundColor = .primaryGreen
//        ////            cell.popularLabel.isHidden  = false
//        ////            cell.outerStackView.backgroundColor = .lightGrayBG
//        ////            cell.subscriptionTypeLabel.textColor = .black
//        ////            cell.subscriptionTypeLabel.text = "Monthly"
//        ////            cell.salePercent.isHidden = false
//        ////        }else{
//        //           cell.contentView.backgroundColor = .lightGrayBG
//        //           cell.outerStackView.backgroundColor = .lightGrayBG
//        //           cell.subscriptionTypeLabel.textColor = .black
//        ////        }
//        //
//        //        cell.subcriptionModel = getsubcriptionViewModel.activeSubscription[indexPath.section]
//        //
//        //        return cell
//        //    }
//        //
//        //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //        UserDefaultsConfig.subscriptionId = self.getsubcriptionViewModel.activeSubscription[indexPath.section].id ?? ""
//        //        self.proceedBtn.enableButton(true)
//        //    }
//        //
//        //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        //        return UITableView.automaticDimension
//        //    }
//        //}
//}

extension SubcriptionSelectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subcriptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubscriptionCollectionViewCell.className, for: indexPath) as? SubscriptionCollectionViewCell else { return SubscriptionCollectionViewCell() }
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        cell.configureView(with: indexPath.item % 2 == 0 , subcription: subcriptions[indexPath.item], selectedId: getsubcriptionViewModel.selectedId )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.frame.width - 10) / 2, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getsubcriptionViewModel.selectedId = subcriptions[indexPath.item].id ?? DefaultValue.string
        collectionView.reloadData()
        UserDefaultsConfig.subscriptionId = subcriptions[indexPath.section].id ?? ""
        self.proceedBtn.enableButton(true)
    }
    
}


extension SubcriptionSelectionVC{
    func bindViewToViewModel() {
        getsubcriptionViewModel.apiResponse.bind { [weak self] res in
            guard let self = self else {return}
            if res.statusCode == 200{
                self.subcriptions = self.getsubcriptionViewModel.activeSubscription
                self.subcriptionCV.reloadData()
            }
        }
        
        getsubcriptionViewModel.isLoading.bind { [unowned self] (value) in
            self.showLoader(startAnimate: value)
        }
        
        getsubcriptionViewModel.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
       
        driverKYCVM.isLoading.bind { [weak self] value in
            guard let `self` = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        driverKYCVM.messageWithCode.bind { [weak self] errorWithCode in
            guard let `self` = self else { return }
            guard !(errorWithCode.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self,
                                     message: errorWithCode.message ?? DefaultValue.string)
        }
        
        driverKYCVM.apiResponsebecomeCap.bind { [weak self] res in
            guard let `self` = self else { return }
            guard res.data.isSome else { return }
            UserDefaultsConfig.user?.isWASLApproved = res.data?.isWASLApproved
            Commons.goToMain(type: .driver)
        }
    }
}
