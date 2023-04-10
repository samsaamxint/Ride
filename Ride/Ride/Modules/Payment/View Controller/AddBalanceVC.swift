//
//  AddBalanceVC.swift
//  Ride
//
//  Created by PSE on 12/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import PassKit
import TextFieldFormatter


class AddBalanceVC: UIViewController {
    
    //MARK: - IBOutlets
  
    @IBOutlet weak var addBalanceLbl: UILabel!
    @IBOutlet weak var enterAmountLbl: UILabel!
    @IBOutlet weak var savedCardsLbl: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var currencyBtn: UIButton!
    @IBOutlet weak var suggestionStackView: UIStackView!
    @IBOutlet var suggestionsList: [UIButton]!
    @IBOutlet weak var addNewBtn: UIButton!
    @IBOutlet weak var savedCardsCV: UICollectionView!
    @IBOutlet weak var addBalanceBtn: UIButton!
    @IBOutlet weak var topUpAppleBtn: UIButton!
    
    //MARK: - Constants and Variables
    private let addBalanceVM = BalanceViewModel()
    var shouldShowCard = false
    var isApplePay = false
    var applePaymentRequest = AddBalanceRequestNew()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldShowCard {
            let card = CardItem(card_id: 0, name: UserDefaultsConfig.user?.firstName,
                                company: "AQUA",
                                card_number: "4111 1111 1111 1111")
            UserDefaultsConfig.cards = [card]
        } else {
            UserDefaultsConfig.cards = []
        }
        
        setupViews()
    }
    
    private func setupViews() {
       
        
        if !(navigationController?.viewControllers.first?.isKind(of: AddBalanceVC.self) ?? DefaultValue.bool) {
            setLeftBackButton(selector: #selector(backButtonTapped))
        }
        
        savedCardsCV.register(UINib(nibName: SavedCardsCVCell.className, bundle: nil), forCellWithReuseIdentifier: SavedCardsCVCell.className)
        
        savedCardsCV.reloadData()
        amountTF.delegate = self
        addBalanceBtn.enableButton(false)
        savedCardsCV.showErrorIfZero(count: 3, message: "No saved cards available".localizedString())
        bindViewToViewModel()
        
        addBalanceLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
        enterAmountLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        savedCardsLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(16) : UIFont.SFProDisplayBold?.withSize(16)
        amountTF.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        addNewBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(14) : UIFont.SFProDisplaySemiBold?.withSize(14)
        addBalanceBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        //        topUpAppleBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        //        let label = topUpAppleBtn.value(forKey: "titleLabel")! as! UILabel
        //        label.font = UIFont(name: label.font.fontName, size: 18)
        topUpAppleBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parent = (self.parent?.parent as? MainDashboardViewController) {
            parent.containerViewHeight.constant = 560
        } else {
            (self.parent?.parent as? EmptyTopupViewController)?.containerViewHConstraint.constant = 560
        }
        savedCardsCV.reloadData()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func suggestedAmountPressed(_ sender: UIButton) {
        let amount = sender.tag
        suggestionsList.forEach({ btn in
            btn.removeAllSublayers()
        })
        
        self.amountTF.text = String(amount)
        sender.addDoubleBorder()
        addBalanceBtn.enableButton(true)
        addBalanceBtn.backgroundColor = .primaryBtnBg
    }
    
    @IBAction func didTapAddNewBtn(_ sender: Any) {
        if let vc: SaveCardForPaymentViewController = UIStoryboard.instantiate(with: .paymentMethods) {
            vc.comingFrom = .addBalance
            if let navVC = parent?.parent as? MainDashboardViewController {
                vc.definesPresentationContext = true
                navVC.navigationController?.pushViewController(vc, animated: false)
            } else if let parentVC = parent?.parent as? EmptyTopupViewController  {
                self.definesPresentationContext = true
                self.providesPresentationContextTransitionStyle = true
                vc.modalPresentationStyle = .overCurrentContext
                parentVC.navigationController?.pushViewController(vc, animated: false)
                
            }
        }
    }
    
    @IBAction func payWithApplePressed(_ sender: Any) {
        if self.amountTF.text! == ""{
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Please add amount for top up".localizedString())
            // displayDefaultAlert(title: "Error", message: "Please add amount for top up.")
            return
        }
        let wallet = PKPaymentPassActivationState.activated
        let paymentItem = PKPaymentSummaryItem.init(label: AppName, amount: NSDecimalNumber.init(string:  self.amountTF.text))
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa ,.mada]
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            request.currencyCode = "SAR" // 1
            request.countryCode = "SA" // 2
            request.merchantIdentifier = "merchant.com.Ride.RideCompany" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
            request.paymentSummaryItems = [paymentItem] // 6
            request.requiredShippingContactFields = [.name, .phoneNumber, .postalAddress]
                
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                //displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Unable to present Apple Pay authorization".localizedString())
                return
            }
            isApplePay = true
            paymentVC.delegate = self
            self.present(paymentVC, animated: true, completion: nil)
        } else {
            // displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
          //  Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Please add your card in Apple Wallet then you'll be able to pay.".localizedString())
            let passLibrary = PKPassLibrary()
            passLibrary.openPaymentSetup()
    
        }
    }
    
    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localizedString(), style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapBackBtn(_ sender: Any) {
        navigationController?.dismiss(animated: false)
    }
    
    @IBAction func addBalancePressed(_ sender: Any) {
        isApplePay = false
        addBalanceVM.addBalance(balance: Int(amountTF.text ?? DefaultValue.string) ?? DefaultValue.int)
    }
}

//MARK: - Collectionview Delegates
extension AddBalanceVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return UserDefaultsConfig.cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedCardsCVCell.className, for: indexPath)  as? SavedCardsCVCell else {
            return SavedCardsCVCell()
        }
        
        cell.item = UserDefaultsConfig.cards[indexPath.section]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 250, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

//MARK: - UITextFieldDelegate
extension AddBalanceVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountView.addDoubleBorder(with: .primaryDarkBG, and: .primaryGreen)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            amountView.addDoubleBorder(with: .sepratorColor, and: .clear)
        } else {
            amountView.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
        }
        suggestionsList.forEach({ btn in
            btn.removeAllSublayers()
        })

    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count ?? 0  < 1{
            self.addBalanceBtn.enableButton(false)
        }else{
            self.addBalanceBtn.enableButton(true)
            addBalanceBtn.backgroundColor = .primaryBtnBg
        }

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTF{
                   let maxLength = 5
                      let currentString = (textField.text ?? "") as NSString
                      let newString = currentString.replacingCharacters(in: range, with: string)

                      return newString.count <= maxLength
               }

        //Prevent "0" characters as the first characters. (i.e.: There should not be values like "003" "01" "000012" etc.)
        if textField.text?.count == 0 && string == "0" {

            return false
        }


        //Have a decimal keypad. Which means user will be able to enter Double values. (Needless to say "." will be limited one)
        if ((textField.text?.contains(".")) != nil) && string == "." {
            return false
        }

        //Only allow numbers. No Copy-Paste text values.
        let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789.")
        let textCharacterSet = CharacterSet.init(charactersIn: (textField.text ?? "") + string)
        if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
            return false
        }

        suggestionsList.forEach({ btn in
            btn.removeAllSublayers()
        })
        return true
    }
    
}

extension AddBalanceVC {
    private func showSuccessPopup() {
        //let message = String(format: "SAR will be credited to your wallet shorlty".localizedString(), amountTF.text ?? "0")
        let localizedText = "SAR will be credited to your wallet shorlty".localizedFormat(arguments: amountTF.text ?? "0")
        let vc = StatusAlertVC.instantiate(title: "Topup Successful".localizedString(), message: localizedText, image: UIImage.init(named: "SuccessImage") ?? UIImage())
        vc.onlySuccess = true
        vc.alertAction = { (isDone) in
            if isDone{
                //if done/yes is pressed
                let controllers = self.navigationController?.viewControllers ?? []
                for vc in controllers{
                    if vc.isKind(of: RiderRideSelection.self){
                        self.navigationController?.popToViewController(vc, animated: false)
                        break
                    }
                    if vc.isKind(of: UserProfileMainVC.self){
                        self.navigationController?.popToViewController(vc, animated: false)
                        break
                    }
                    if vc.isKind(of: OwnCarSubscriptionViewController.self){
                        self.navigationController?.popToViewController(vc, animated: false)
                        break
                    }
                }
            }else{
                //if no/tryagain is pressed
            }
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    private func showErrorPopup(message: String = "Please try again after some time we are facing some server issues".localizedString()) {
        let vc = StatusAlertVC.instantiate(title: "Topup Failed".localizedString(), message: message, image: UIImage.init(named: "FailedImage") ?? UIImage())
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.alertAction = { (isDone) in
            if isDone{
                //if done/yes is pressed
            }else{
                //if no/tryagain is pressed
            }
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func bindViewToViewModel() {
        addBalanceVM.addBalanceResponse.bind {[weak self] (value) in
            guard let `self` = self else { return }
            guard value.statusCode.isSome else {return}
            
            if value.statusCode == 200{
                Commons.adjustEventTracker(eventId: AdjustEventId.BankTransactionSuccess)
                if self.isApplePay == false{
                    if let vc: PaymentWebViewVC = UIStoryboard.instantiate(with: .paymentMethods) {
                        vc.urlStringToLoad = value.data?.redirect_url
                        vc.delegate = self
                        self.parent?.parent?.navigationController?.pushViewController(vc, animated: true)
                    }
                }else{
                    self.showSuccessPopup()
                }
            } else {
                Commons.adjustEventTracker(eventId: AdjustEventId.BankTransactionFailure)
                self.showErrorPopup()
            }
        }
        
        addBalanceVM.topUpResponse.bind {[weak self] (value) in
            guard let `self` = self else { return }
            guard value.success != nil else {return}
            if value.success == true{
                if let urlString = value.data![0].data?.redirect_url, let url = URL(string: urlString){
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.open(url)
                    }
                }
            }else{
                self.showErrorPopup()
            }
        }
        
        addBalanceVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        
        addBalanceVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
    }
}

extension AddBalanceVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        //        dismiss(animated: true, completion: nil)
        
        print("TransactionID: \(payment.token.transactionIdentifier)")
        print("Network: \(payment.token.paymentMethod.network?.rawValue)")
        print("Display Name: \(payment.token.paymentMethod.displayName)")
        print("Type: \(payment.token.paymentMethod.type.rawValue)")
        let network = "\(payment.token.paymentMethod.network?.rawValue ?? "")"
        let identifier = payment.token.transactionIdentifier
        let paymentMethod = PaymentMethod(network: network, type: "\(payment.token.paymentMethod.type.rawValue)", displayName: payment.token.paymentMethod.displayName)
        
        
        var request = AddBalanceRequestNew.init(amount: 0, applePayToken: ApplePayToken(paymentMethod: paymentMethod, transactionIdentifier: payment.token.transactionIdentifier, paymentData: nil))
        
        print(request)
        self.applePaymentRequest = request
        print(applePaymentRequest)
      //  CarSequenceRequest.init(userid : UserDefaultsConfig.user?.idNumber ?? DefaultValue.string , sequenceNumber : String(carSequence))
        
        
        
        self.applePaymentRequest.applePayToken?.paymentMethod = paymentMethod
            //.init(network: network, type: "\(payment.token.paymentMethod.type.rawValue)", displayName: payment.token.paymentMethod.displayName)
       
        
      //  Apple_pay_token?.paymentMethod = paymentMethod
        applePaymentRequest.applePayToken?.transactionIdentifier = payment.token.transactionIdentifier
        
        
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: payment.token.paymentData, options: []) as? [String: Any]
            let value = try JSONDecoder().decode(PaymentData.self, from: payment.token.paymentData)
            let name = payment.shippingContact?.name
            let customerName = "\(name?.givenName ?? "") " + "\(name?.familyName ?? "")"
            let address = payment.shippingContact?.postalAddress
            let phone = payment.shippingContact?.phoneNumber
            
            request = AddBalanceRequestNew.init(amount: Int(amountTF.text ?? DefaultValue.string), name: customerName, country: address?.country ?? "", street: address?.street ?? "", city: address?.city ?? "", ip: UIDevice.current.getIP(), phone: phone?.stringValue.description ?? "", applePayToken: ApplePayToken(paymentMethod: paymentMethod, transactionIdentifier: identifier , paymentData: value))
            print(value)
            applePaymentRequest.applePayToken?.paymentData = value
            self.applePaymentRequest = request
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            print(applePaymentRequest)

            addBalanceVM.addBalanceNew(tokenApplePay: applePaymentRequest)
        } catch {
            print("Error: \(error.localizedDescription)")
            completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
        }
        
    }
    
    
}


extension AddBalanceVC: PaymentWebViewProtcol {
    func paymentSuccessfull() {
        showSuccessPopup()
    }
    
    func paymentFailed(with error: String) {
        showErrorPopup(message: error)
    }
}
