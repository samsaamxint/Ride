//
//  SaveCardForPaymentViewController.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import TextFieldFormatter
import TapCardScanner_iOS
import AVFoundation
import TapCardVlidatorKit_iOS
import CommonDataModelsKit_iOS

enum ComingFrom {
    case signup, addBalance, other
}

class SaveCardForPaymentViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var addPaymentLbl: UILabel!
    @IBOutlet weak var cardNumberMainView: UIView!
    @IBOutlet weak var cardNumberTF: TextFieldFormatter!
    
    @IBOutlet weak var nameOnCardView: UIStackView!
    @IBOutlet weak var nameOnCardTF: UITextField!
    
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var nameLbl: NSLayoutConstraint!
    @IBOutlet weak var expiryDateView: UIStackView!
    @IBOutlet weak var expDateLbl: UILabel!
    @IBOutlet weak var expiryDateTF: UITextField!
    @IBOutlet weak var cvvView: UIStackView!
    @IBOutlet weak var cvvLbl: UILabel!
    @IBOutlet weak var cvvTF: UITextField!
    @IBOutlet weak var saveCardBtn: UIButton!
    
    //MARK: - Constants and Variables
    private var fullScanner: TapFullScreenScannerViewController?
    var addCardVM = AddCardViewModel()
    
    var comingFrom: ComingFrom = .other
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupTextFields()
        
        saveCardBtn.enableButton(false)
        setupLanguage()
        bindViewToViewModel()
        
        self.view.backgroundColor  = .systemBackground
     
        addPaymentLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        cardNumberTF.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        nameOnCardTF.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        cardNumberLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        expDateLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        expiryDateTF.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        cvvLbl.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        cvvTF.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        saveCardBtn.titleLabel?.font =  Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        
    }
    
// 
    
    private func setupLanguage() {
        cardNumberTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
        nameOnCardTF.textAlignment = cardNumberTF.textAlignment
        expiryDateTF.textAlignment = cardNumberTF.textAlignment
        cvvTF.textAlignment = cardNumberTF.textAlignment
        
        nameOnCardTF.placeholder = "Name on Card".localizedString()
    }
    
    private func setupNavigation() {
        setLeftBackButton(selector: #selector(backButtonTapped))
        
        if comingFrom == .signup {
            let skipButton = getAppNavSkipButton()
            skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: skipButton)
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func skipButtonTapped() {
        Commons.goToMain(type: .rider)
    }
    
    private func setupTextFields() {
                
        nameOnCardTF.setLeadingPadding(15)
        expiryDateTF.setLeadingPadding(15)
        cvvTF.setLeadingPadding(15)
        
        nameOnCardTF.setRightPadding(15)
        expiryDateTF.setRightPadding(15)
        cvvTF.setRightPadding(15)
        
        expiryDateTF.addInputViewDatePicker(target: self, selector: #selector(didSelectDate), minDate: Date())
        
        cardNumberTF.delegate = self
        nameOnCardTF.delegate = self
        expiryDateTF.delegate = self
        cvvTF.delegate = self
        
        cardNumberTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        nameOnCardTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        expiryDateTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        cvvTF.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        
        cardNumberMainView.addDoubleBorder(with: .sepratorColor, and: .clear)
        nameOnCardTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        expiryDateTF.addDoubleBorder(with: .sepratorColor, and: .clear)
        cvvTF.addDoubleBorder(with: .sepratorColor, and: .clear)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardNumberTF.layoutIfNeeded()
        nameOnCardTF.layoutIfNeeded()
        expiryDateTF.layoutIfNeeded()
        cvvTF.layoutIfNeeded()
        DispatchQueue.main.async {[weak self] in
            self?.view.backgroundColor = .systemBackground
        }
    }
    
    //MARK: - Observers
    @objc private func textFieldValueChangeListener() {
        if !CreditCardValidator(cardNumberTF.text ?? DefaultValue.string).isValid {
            saveCardBtn.enableButton(false)
            return
        }
        if nameOnCardTF.text?.isEmpty ?? true {
            saveCardBtn.enableButton(false)
            return
        }
        
        if expiryDateTF.text?.isEmpty ?? true {
            saveCardBtn.enableButton(false)
            return
        }
        
        if cvvTF.text?.isEmpty ?? true {
            saveCardBtn.enableButton(false)
            return
        }
        
        saveCardBtn.enableButton(true)
    }
    
    @objc private func didSelectDate(){
        if let datePicker = expiryDateTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            expiryDateTF.text = dateFormatter.string(from: datePicker.date)
        }
        expiryDateTF.resignFirstResponder()
    }
    
    //MARK: - UIACTIONS
    @IBAction func saveBtnDidClicked(_ sender: Any) {
        //Commons.goToMain(type: .rider)
//        addCardVM.addCard(name: "Jim Brown", company: "Kotak AQUA", card_number: 6292, exp_date: "01-01-2022", cvv: 123)
        
        if cardNumberTF.text?.tap_trimWhitespacesAndNewlines() == "4111 1111 1111 1111" {
            if cvvTF.text == "111" {
                if UserDefaultsConfig.cards.isEmpty {
                    let card = CardItem(card_id: 0, name: nameOnCardTF.text, company: "AQUA", card_number: cardNumberTF.text)
                    UserDefaultsConfig.cards = [card]
                    addCardVM.changeCardStatus(status: "1")
                } else {
                    Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Card Already exists".localizedString())
                }
            } else {
                Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Please Enter valid CVV".localizedString())
            }
        } else {
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Please Enter valid card number".localizedString())
        }
    }
    
    @IBAction func didTapCameraIcon(_ sender: Any) {
        showFullScanner()
    }
    
    func showFullScanner(with customiser: TapFullScreenUICustomizer = .init()) {
        // First grant the authorization to use the camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
            if response {
                //access granted
                DispatchQueue.main.async {[weak self] in
                    self?.fullScanner = TapFullScreenScannerViewController(dataSource: self!)
                    self?.fullScanner?.delegate = self
                    self?.present((self?.fullScanner)!, animated: true)
                }
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension SaveCardForPaymentViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField  == cardNumberTF {
            cardNumberMainView.addDoubleBorder()
        } else {
            textField.addDoubleBorder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            if textField == cardNumberTF  {
                cardNumberMainView.addDoubleBorder(with: .sepratorColor, and: .clear)
            } else {
                textField.addDoubleBorder(with: .sepratorColor, and: .clear)
            }
        } else if (textField == cardNumberTF && !CreditCardValidator(textField.text ?? DefaultValue.string).isValid) {
            cardNumberMainView.addDoubleBorder(with: .sepratorColor, and: .clear)
        } else {
            if textField == cardNumberTF  {
                cardNumberMainView.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
            } else {
                textField.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
            }
        }
    }
}


extension SaveCardForPaymentViewController: TapScannerDataSource {
    func allowedCardBrands() -> [CardBrand] {
        CardBrand.allCases
    }
}

extension SaveCardForPaymentViewController:TapCreditCardScannerViewControllerDelegate {
    func creditCardScannerViewControllerDidCancel(_ viewController: TapFullScreenScannerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func creditCardScannerViewController(_ viewController: TapFullScreenScannerViewController, didErrorWith error: Error) {
        viewController.dismiss(animated: true)
    }
    
    func creditCardScannerViewController(_ viewController: TapFullScreenScannerViewController, didFinishWith card: TapCard) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.cardNumberTF.text = card.tapCardNumber
            self.expiryDateTF.text = "\(card.tapCardExpiryMonth ?? "")/\(card.tapCardExpiryYear ?? "")"
            self.nameOnCardTF.text = card.tapCardName
        }
    }
}

extension SaveCardForPaymentViewController{
    func bindViewToViewModel() {
        addCardVM.apiResponseData.bind { [weak self] res in
            guard let self = self else {return}
            if res.code == 200{
                self.navigationController?.popViewController(animated: false)
            }
        }
        
        addCardVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        addCardVM.messageWithCode.bind { [weak self] value in
            guard let `self` = self else { return }
            guard !(value.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: value.message ?? "")
        }
        
        addCardVM.changeCardStatus.bind { [weak self] value in
            guard let `self` = self else { return }
            
            guard value.status.isSome else { return }
            
            if self.comingFrom == .signup {
                Commons.goToMain(type: .rider)
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
