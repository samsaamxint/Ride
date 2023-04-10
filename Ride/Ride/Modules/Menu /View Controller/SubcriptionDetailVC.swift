//
//  SubcriptionDetailVC.swift
//  Ride
//
//  Created by XintMac on 10/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import DropDown

class SubcriptionDetailVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var subscriptionTV: UITableView!
    @IBOutlet weak var daysRemaining: UILabel!
    @IBOutlet weak var currentSubcriptionFee: UILabel!
    @IBOutlet weak var subcriptionStatuc: UISwitch!
    @IBOutlet weak var TVheightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var activeSubBtn: UIButton!
    @IBOutlet weak var allSubBtn: UIButton!
    @IBOutlet weak var sepLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var allSubscriptionCV: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var activeSubscriptionMainView: UIView!
    @IBOutlet weak var upcomingSubcriptionParentView: UIStackView!
    
    @IBOutlet weak var bottomRenewBtn: UIButton!
    @IBOutlet weak var upcomingRenewalDate: UILabel!
    @IBOutlet weak var upcomingRenewalPrice: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    
    //MARK: - Constants and Variables
    private let subscriptionVM = SubscriptionViewModel()
    private let getSubscriptionVM = GetSubcriptionViewModel()
    private var subcriptions = [GetSubcriptionsData]()
    private var currentPage = 1
    let dropDown = DropDown()
    var showAllSub : Bool = false
    
    //MARK: - View LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLeftBackButton(selector: #selector(backButtonTapped))
        setupTableView()
        setupCollectionView()
        
        subscriptionVM.getSubscriptions(with: 1, limit: 10)
        getSubscriptionVM.getSubcription()
        currentPage += 1
        bindToViewModel()
    }
    
    private func setupTableView() {
        subscriptionTV.delegate = self
        subscriptionTV.dataSource = self
        
        subscriptionTV.register(UINib(nibName: RenewalHistoryTVCell.className, bundle: nil), forCellReuseIdentifier: RenewalHistoryTVCell.className)
        
    }
    
    private func setupCollectionView() {
        allSubscriptionCV.delegate = self
        allSubscriptionCV.dataSource = self
        
        allSubscriptionCV.register(UINib(nibName: SubscriptionCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: SubscriptionCollectionViewCell.className)
    }
    
    private func setupData() {
//        let data = subscriptionVM.getSubscriptionData.value
        activeSubscriptionMainView.isHidden = subscriptionVM.activeSubscription.isNone
        upcomingSubcriptionParentView.isHidden = activeSubscriptionMainView.isHidden
        
        let endDate = subscriptionVM.activeSubscription?.dueDate?.toDate(.isoDate) ?? Date()
        let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day
        daysRemaining.text = "\(diffInDays ?? 1) Days"
        currentSubcriptionFee.text = "SAR \(String(subscriptionVM.activeSubscription?.subscriptionAmount ?? 0.0))"
        subcriptionStatuc.isOn = subscriptionVM.activeSubscription?.autoRenewal ?? true 
        TVheightConstant.constant = CGFloat(140 * subscriptionVM.subscriptionHistory.count)
        subscriptionTV.reloadData()
        upcomingRenewalPrice.text = "SAR \(String(subscriptionVM.activeSubscription?.subscriptionAmount ?? 0.0))"
        
        upcomingRenewalDate.text = subscriptionVM.activeSubscription?.endDate ?? ""
        
        if showAllSub{
            setSepratorView(with: allSubBtn)
            
            allSubBtn.titleLabel?.font = UIFont.SFProDisplaySemiBold?.withSize(16)
            allSubBtn.setTitleColor(UIColor.label, for: .normal)
            
            activeSubBtn.titleLabel?.font = UIFont.SFProDisplayRegular?.withSize(16)
            activeSubBtn.setTitleColor(UIColor.secondaryGrayTextColor, for: .normal)
            
            scrollView.isHidden = true
            allSubscriptionCV.isHidden = false
            filterBtn.isHidden = false
            
            bottomRenewBtn.setTitle("Proceed", for: .normal)
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
                self.subcriptions = self.getSubscriptionVM.activeSubscription
                self.allSubscriptionCV.reloadData()
            }else{
                let filterSub = self.getSubscriptionVM.activeSubscription
                self.subcriptions = filterSub.filter { $0.planType == index }
                self.allSubscriptionCV.reloadData()
            }
        }
    }
    
    private func setSepratorView(with button: UIButton) {
        sepLeadingConstraint.constant = button.frame.origin.x
    }
    
    @IBAction func filterBtnTapped(_ sender: Any) {
        dropDown.show()
    }
    
    // MARK: - Navigation
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showPayNowScreen() {
        if let vc: EmptyTopupViewController = UIStoryboard.instantiate(with: .paymentMethods) {
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalTransitionStyle = .crossDissolve
            navVC.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            vc.type = .purchaseSubscription
            navigationController?.present(navVC, animated: false)
        }
    }
    
    //MARK: - IBActions
    @IBAction func didTapActiveSubBtn(_ sender: UIButton) {
        setSepratorView(with: sender)
        
        activeSubBtn.titleLabel?.font = UIFont.SFProDisplaySemiBold?.withSize(16)
        activeSubBtn.setTitleColor(UIColor.label, for: .normal)
        
        allSubBtn.titleLabel?.font = UIFont.SFProDisplayRegular?.withSize(16)
        allSubBtn.setTitleColor(UIColor.secondaryGrayTextColor, for: .normal)
        
        scrollView.isHidden = false
        allSubscriptionCV.isHidden = true
        filterBtn.isHidden = true
        bottomRenewBtn.setTitle("Renew subscription now", for: .normal)
    }
    
    @IBAction func didTapAllSubBtn(_ sender: UIButton) {
        setSepratorView(with: sender)
        
        allSubBtn.titleLabel?.font = UIFont.SFProDisplaySemiBold?.withSize(16)
        allSubBtn.setTitleColor(UIColor.label, for: .normal)
        
        activeSubBtn.titleLabel?.font = UIFont.SFProDisplayRegular?.withSize(16)
        activeSubBtn.setTitleColor(UIColor.secondaryGrayTextColor, for: .normal)
        
        scrollView.isHidden = true
        allSubscriptionCV.isHidden = false
        filterBtn.isHidden = false
        bottomRenewBtn.setTitle("Proceed", for: .normal)
    }
    
    @IBAction func didTapCancelSubsciption(_ sender: Any) {
        let OptionAlert = UIAlertController(title: "Are you sure you want to cancel subscription ?", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] (action: UIAlertAction) in
            guard let `self` = self else { return }
            self.subscriptionVM.cancelSubscription()
        }
        
        let noAction = UIAlertAction(title: "No", style: .destructive)
        
        OptionAlert.addAction(noAction)
        OptionAlert.addAction(yesAction)
        self.present(OptionAlert, animated: true, completion: nil)
    }
    
    @IBAction func didTapPBottomBtn(_ sender: Any) {
        if allSubscriptionCV.isHidden {
            // Renew Subscription Now
        } else {
            // Update Susbcription
            if !getSubscriptionVM.selectedId.isEmpty {
                subscriptionVM.updateSubscription(with: getSubscriptionVM.selectedId)
            }
        }
    }
    
    @IBAction func didChangeToggleBtn(_ sender: Any) {
        subscriptionVM.changeRenewalStatus()
    }
}

//MARK: - Tableview delegate and datasource
extension SubcriptionDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        subscriptionVM.subscriptionHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RenewalHistoryTVCell.className, for: indexPath) as? RenewalHistoryTVCell else { return RenewalHistoryTVCell() }
        let item = subscriptionVM.subscriptionHistory[indexPath.section]
        
        cell.cellData = item
        
        return cell
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
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 {
            if subscriptionVM.canLoad{
                subscriptionVM.getSubscriptions(with: currentPage, limit: 10, showLoader: false)
                currentPage += 1
            }
        }
    }
}

extension SubcriptionDetailVC {
    private func bindToViewModel() {
        subscriptionVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        subscriptionVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        subscriptionVM.getSubscriptionData.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            self.setupData()
        }
        
        getSubscriptionVM.apiResponse.bind { [weak self] res in
            guard let self = self else {return}
            if res.statusCode == 200{
                self.subcriptions = self.getSubscriptionVM.activeSubscription
                self.allSubscriptionCV.reloadData()
            }
        }
        
        getSubscriptionVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
        
        subscriptionVM.cancelSubscriptionRes.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            RideSingleton.shared.subscriptionStatusChanged = true
            
            self.activeSubscriptionMainView.isHidden = true
            self.upcomingSubcriptionParentView.isHidden = true
        }
        
        subscriptionVM.updateSubscription.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            self.showPayNowScreen()
        }
        
        subscriptionVM.changeRenewalError.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
            self.subcriptionStatuc.setOn(!self.subcriptionStatuc.isOn, animated: false)
        }
    }
}

extension SubcriptionDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.subcriptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubscriptionCollectionViewCell.className, for: indexPath) as? SubscriptionCollectionViewCell else { return SubscriptionCollectionViewCell() }
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        cell.configureView(with: indexPath.item % 2 == 0 , subcription:  self.subcriptions[indexPath.item], selectedId: getSubscriptionVM.selectedId )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.frame.width - 10) / 2, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getSubscriptionVM.selectedId =  self.subcriptions[indexPath.item].id ?? DefaultValue.string
        collectionView.reloadData()
    }
    
}

extension SubcriptionDetailVC: EmptyTopupViewControllerProtocol {
    func subscriptionPurchased() {
        RideSingleton.shared.subscriptionStatusChanged = true
        self.navigationController?.popViewController(animated: true)
    }
}
