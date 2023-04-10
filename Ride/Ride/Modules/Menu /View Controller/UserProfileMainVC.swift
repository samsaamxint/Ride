//
//  UserProfileMainVC.swift
//  Ride
//
//  Created by PSE on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import Kingfisher

enum MenuEnum: String , CaseIterable{
    case subcription = "Subscriptions"
    case myRides = "My Rides"
    case myReports = "My Reports"
    case setting = "App Setting"
    case custmerCare = "Customer Care"
    case termCondition = "Terms & Condition"
    case privacyPolicy = "Privacy Policy"
    case friendShare = "Share With Friends"
    case deleteAccount = "Delete my account"
    case logOut = "Log Out"
}

class UserProfileMainVC: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuTV: UITableView!
    @IBOutlet weak var menuTVHeight: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDOBLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userRatingLabel: UILabel!
    @IBOutlet weak var loyaltyPointsLabel: UILabel!
    @IBOutlet weak var userBalanceLabel: UILabel!
    @IBOutlet weak var ibanLabel: UILabel!
    @IBOutlet weak var userIBANLabel: UILabel!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var userBankNameLabel: UILabel!
    @IBOutlet weak var versionNoLbl: UILabel!
    @IBOutlet weak var topUpBtn: UIButton!
    @IBOutlet weak var viewDetailBtn: UIButton!
    @IBOutlet weak var updateIBanBtn: UIButton!
    
    @IBOutlet weak var topUpView: UIView!
    @IBOutlet weak var ibanView: UIView!
    @IBOutlet weak var balanceTitleLbl: UILabel!
    @IBOutlet weak var topUpViewHeight: NSLayoutConstraint!
    //MARK: - Constants and Variables
    private let profileViewModel = ProfileViewModel()
    private let getIBANVM = GetIBANViewModel()
    private let balanceVM = BalanceViewModel()
    private let notificationVM = NotificationViewModel()
    let notificationBtn = BadgeButton()
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewToViewModel()
        getIBANVM.getIBAN()
        profileViewModel.getProfileDetail()
        notificationVM.getNotification(with: 1, limit: 20)
        self.navigationItem.titleView?.semanticContentAttribute = .forceLeftToRight
        self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        balanceVM.getBalance()
        setupUI()
        menuTV.reloadData()
//        notificationVM.getNotification(with: 1, limit: 20)
//        getNotifCount()
        let backButton = getNotificationButton()
        //backButton.rotateBtnIfNeeded()
        backButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    private func setupUI(){
        guard let user = UserDefaultsConfig.user else { return }
        let additinalInfo = user.additionalInfo ?? ""
         let dict = additinalInfo.toJSON() as? [String:AnyObject] // can be any type here
        let familyNameKey = dict?["CitizenDLInfo"]?["englishLastName"] as? [String:Any]
        let famName = familyNameKey?["_text"] as? String ?? ""

        var fullName = (user.firstName ?? "") + " " + famName
        if Commons.isArabicLanguage(){
            let familyNameArabicKey = dict?["CitizenDLInfo"]?["familyName"] as? [String:Any]
            let famNameArabic = familyNameArabicKey?["_text"] as? String ?? ""
            fullName = (user.arabicFirstName ?? "") + " " + famNameArabic
        }
        userNameLabel.text = fullName
        userDOBLabel.text = user.dateOfBirth ?? ""
        userRatingLabel.text = ""
        loyaltyPointsLabel.text = ""
//        userBalanceLabel.text =  "SAR \(user.totalEarned ?? 0)"
        
       
        
        
        userImageView.image = UIImage.init(named: UserDefaultsConfig.isDriver ? "DImages" :  "DummyProfile")
        if let imageUrl = user.profileImage {
            userImageView.kf.setImage(with: URL.init(string: imageUrl)  , placeholder: UIImage.init(named: UserDefaultsConfig.isDriver ? "DImages" :  "DummyProfile"))
        }
        
        balanceTitleLbl.text = UserDefaultsConfig.isDriver ? "Total Earning".localizedString() : "Balance".localizedString()
        
        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? DefaultValue.string
        
        let versionMessage = String(format: "Version".localizedString(), appVersion)
        versionNoLbl.text =  AppVersion //"\(UserDefaults.standard.integer(forKey: "directionsCount"))"

   
        userNameLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        userDOBLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        userBalanceLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        ibanLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        userIBANLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(14) : UIFont.SFProDisplayBold?.withSize(14)
        bankNameLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(13) : UIFont.SFProDisplayRegular?.withSize(13)
        userBankNameLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        versionNoLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        topUpBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        viewDetailBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(15) : UIFont.SFProDisplayBold?.withSize(15)
        balanceTitleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
        updateIBanBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)

    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
        menuTV.register(UINib(nibName: MenuTVCell.className, bundle: nil), forCellReuseIdentifier: MenuTVCell.className)
        if UserDefaultsConfig.isDriver{
            let items = MenuEnum.allCases.count-1
            menuTVHeight.constant = CGFloat(items * 65)
            ibanView.isHidden = false
            topUpBtn.isHidden = true
            viewDetailBtn.isHidden = true
            //topUpView.isHidden = true
            topUpViewHeight.constant = 80
        }else{
            let items = MenuEnum.allCases.count-1
            menuTVHeight.constant = CGFloat(items * 65)
            ibanView.isHidden = true
            topUpBtn.isHidden = false
            viewDetailBtn.isHidden = false
            balanceTitleLbl.text = "Balance"
            topUpViewHeight.constant = 140
            //topUpView.isHidden = false
        }
        
        scrollView.contentInset.top = 20
    }
    private func getNotifCount(){
        let notification = notificationVM.notificationHistory
        var seenData = 0
        if notification.count != 0 && !notification.isEmpty{
            for notif in notification{
                if notif.isRead == 0{
                    seenData += 1
                }
            }
        }
        if seenData != 0{
            notificationBtn.badge = String(seenData)
        }
    }
    
    private func getNotificationButton() -> BadgeButton {
       
       
        notificationBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
//        let notificationBtn = BadgeButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        notificationBtn.cornerRadius = notificationBtn.frame.height / 2
//        notificationBtn.layoutIfNeeded()
        if #available(iOS 13.0, *) {
            notificationBtn.setImage(UIImage(named: "Notification"), for: .normal)
        } else {
            notificationBtn.setTitleColor(.primaryDarkBG, for: .normal)
            notificationBtn.setTitle("Back".localizedString(), for: .normal)
        }
        notificationBtn.badgeEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 15)
        notificationBtn.tintColor = .primaryDarkBG
        notificationBtn.backgroundColor = .primaryLightTextColor
        notificationBtn.borderWidth = 1
        notificationBtn.borderColor = .sepratorColor
//        notificationBtn.bringSubviewToFront(notificationBtn.badgeLabel)
        let count = getNotifCount()
       
        notificationBtn.badge = nil
       
        return notificationBtn
    }
    
    // MARK: - Navigation
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - IBActions
    @IBAction func editPressed(_ sender: Any) {
        if let vc: UpdateProfileVC = UIStoryboard.instantiate(with: .userProfile) {
           navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func topUpPressed(_ sender: Any) {
        if let vc: EmptyTopupViewController = UIStoryboard.instantiate(with: .paymentMethods) {
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalTransitionStyle = .crossDissolve
            navVC.modalPresentationStyle = .overCurrentContext
//            navVC.setNavigationBarHidden(true, animated: false)
            vc.delegate = self
            vc.type = .addbalance
            navigationController?.present(navVC, animated: false)
        }
    }
    
    @IBAction func viewDetailsPressed(_ sender: Any) {
        if let vc: TopDetailsVC = UIStoryboard.instantiate(with: .paymentMethods) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func didTapUpdateIBAN(_ sender: Any) {
        if let vc: EmptyTopupViewController = UIStoryboard.instantiate(with: .paymentMethods) {
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalTransitionStyle = .crossDissolve
            navVC.modalPresentationStyle = .overCurrentContext
//            navVC.setNavigationBarHidden(true, animated: false)
            vc.delegate = self
            vc.type = .updateIBAN
            vc.ibanData = getIBANVM.getIBANRes.value.data
            navigationController?.present(navVC, animated: false)
        }
    }
    
    @objc func notificationTapped(){
        if let vc: NotificationVC = UIStoryboard.instantiate(with: .userProfile) {
           navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Tableview delegate and datasource
extension UserProfileMainVC: UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTVCell.className, for: indexPath) as? MenuTVCell else { return MenuTVCell() }
        cell.menu = MenuEnum.allCases[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = MenuEnum.allCases[indexPath.row]
        print("selected option : ", option)
        switch option {
//        case .savedCards :
//            if let vc: SavedCardsVC = UIStoryboard.instantiate(with: .userProfile) {
//                vc.shouldShowCard = balanceVM.apiResponseData.value.data?.card == 1
//                navigationController?.pushViewController(vc, animated: true)
//            }
        case .myRides:
            if let vc: MyRidesVC = UIStoryboard.instantiate(with: .userProfile) {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .myReports:
            if let vc: MyReportsViewController = UIStoryboard.instantiate(with: .userProfile) {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .setting :
            if let vc: AppSettingVC = UIStoryboard.instantiate(with: .userProfile) {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .custmerCare:
            if let vc: CustomerCareVC = UIStoryboard.instantiate(with: .userProfile) {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .termCondition:
            if let vc: TermsAndPoliciesVC = UIStoryboard.instantiate(with: .userProfile) {
                vc.setTitle = option.rawValue
                navigationController?.pushViewController(vc, animated: true)
            }
        case .privacyPolicy:
            if let vc: TermsAndPoliciesVC = UIStoryboard.instantiate(with: .userProfile) {
                vc.setTitle = option.rawValue
                vc.isPolicy = true
                navigationController?.pushViewController(vc, animated: true)
            }
        case .subcription:
            if let vc: SubcriptionDetailVC = UIStoryboard.instantiate(with: .userProfile) {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .logOut:
            if let vc: LogOutPopUpVC = UIStoryboard.instantiate(with: .userProfile) {
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.view.backgroundColor = .lightGray.withAlphaComponent(0.5)
                present(vc, animated: true)
            }
        case .deleteAccount:
            let alert  = UIAlertController(title: "Delete Accounnt".localizedString(), message: "DeleteAccountDesc".localizedString(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel".localizedString(), style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete".localizedString(), style: .default, handler: { (alert:UIAlertAction!) -> Void in
                self.showLoader(startAnimate: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.stopLoader()
                }
            }))
            self.present(alert, animated: true, completion: nil)
                
        case .friendShare:
            let language = (UserDefaults.standard.value(forKey: languageKey) as? String) ?? "en"
            let url = URL(string: "https://apps.apple.com/pk/app/ride-%D8%B1%D8%A7%D9%8A%D8%AF/id6443488537")!
            var message: String!
            if language == "ar" {
                message = "مرحبا، اود دعوتك لتحميل تطبيق رايد لتجربة رحلات سعيدة. حمل التطبيق الآن"
            } else {
                message = "Hi! I'd like to invite you to RiDE to experience good RiDE services. Download the app now."
            }
            let vc = UIActivityViewController(activityItems: [url, message], applicationActivities: nil)
            self.present(vc, animated: true)
        default :
            print("nothing")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //if !UserDefaultsConfig.isDriver{
            if MenuEnum.allCases[indexPath.row] == .subcription {
                return 0
            }
       // }
        return 65
    }
}

extension UserProfileMainVC {
    func bindViewToViewModel(){
        profileViewModel.apiResponseData.bind { [weak self] res in
            guard let self = self else { return }
            if res.statusCode == 200{
//                UserDefaultsConfig.user = res.data
                if UserDefaultsConfig.isDriver{
                self.userBalanceLabel.text = "SAR " + String(res.data?.totalEarned ?? 0)
                }
//                self.setupUI()
            }
        }
        
        profileViewModel.isLoading.bind { [weak self] value in
            guard let self = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        profileViewModel.messageWithCode.bind { [weak self] res in
            guard let `self` = self else { return }
            guard !(res.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: res.message ?? DefaultValue.string)
        }
        
        balanceVM.apiResponseData.bind {[weak self] (value) in
            guard let `self` = self else { return }
            if value.statusCode == 200 {
                if !UserDefaultsConfig.isDriver{
                self.userBalanceLabel.text = "SAR \(String(value.data?.balance ?? 0.0))"
            }
            }
        }
        
        balanceVM.isLoading.bind { [weak self] value in
            guard let self = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        getIBANVM.getIBANRes.bind { [weak self] (response) in
            guard let `self` = self else { return }
            guard let data = response.data else { return }
            if UserDefaultsConfig.isDriver{
            self.ibanView.isHidden = false
            self.userIBANLabel.text = data.iban
            self.userBankNameLabel.text = data.bank
            }
        }
        notificationVM.apiResponseData.bind { [weak self] res in
            guard let `self` = self else { return }
            guard res.statusCode == 200 else { return }
            self.getNotifCount()
        }
    }
  
}

extension UserProfileMainVC: EmptyTopupViewControllerProtocol {
    func updateBalance() {
        viewWillAppear(true)
    }
    
    func updateIBAN() {
        getIBANVM.getIBAN()
    }
}
