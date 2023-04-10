//
//  UpdateProfileVC.swift
//  Ride
//
//  Created by PSE on 05/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import CountryPicker

class UpdateProfileVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var idNumberOuterVu: UIView!
    @IBOutlet weak var usrerImageView: UIImageView!
    
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var UserMobile: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var IdTextFeild: UITextField!
    @IBOutlet weak var emaillbl: UILabel!
    @IBOutlet weak var emailTextFeild: UITextField!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var mobileTextFeild: UITextField!
    @IBOutlet weak var mobileMainView: UIView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var countryStackView: UIStackView!
    @IBOutlet weak var flagLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    //MARK: - Constants and Variables
    private let updateVM = UpdateProfileViewModel()
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupTextFields()
        bindToViewModel()
        
        setupUI()
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
        UserName.text = fullName
        UserMobile.text = user.mobileNo ?? ""
        IdTextFeild.text = user.idNumber ?? DefaultValue.string
        if !UserDefaultsConfig.isDriver{
        if user.idNumber == "" || user.idNumber == "0"{
            idNumberOuterVu.isHidden = true
        }
        }
        emailTextFeild.text = user.emailId
        mobileTextFeild.text = user.mobileNo?.dropCountryCode
        
      
        
        let countryCode = user.mobileNo?.getCountryCode
        flagLabel.text = Countries.getCountryIdentifierFromCode(code: (countryCode ?? "966")).getFlag()//"+\(countryCode ?? "966")".getCountryIdentifierFromCode.
        codeLabel.text = "+"+(countryCode ?? "966")
        
        
        usrerImageView.image = UIImage.init(named: UserDefaultsConfig.isDriver ? "DImages" :  "DummyProfile")
        if let imageUrl = user.profileImage {
            usrerImageView.kf.setImage(with: URL.init(string: imageUrl)  , placeholder: UIImage.init(named: (UserDefaultsConfig.isDriver ? "DImages" :  "DummyProfile")))
        }
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeCountry(gesture: )))
//        countryStackView.addGestureRecognizer(tapGesture)
//        countryStackView.isUserInteractionEnabled = true
        
        titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
        UserName.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        UserMobile.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        idLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        IdTextFeild.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        emaillbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        emailTextFeild.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        mobileLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
        mobileTextFeild.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
        updateBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
        flagLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        codeLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(16) : UIFont.SFProDisplayMedium?.withSize(16)
        emailTextFeild.textAlignment = Commons.isArabicLanguage() ? .right : .left
        mobileTextFeild.textAlignment = emailTextFeild.textAlignment
        IdTextFeild.textAlignment = emailTextFeild.textAlignment
        updateBtn.enableButton(false)
        phoneStackView.semanticContentAttribute = .forceLeftToRight
        mobileTextFeild.textAlignment = .left
    }
    
    private func setupTextFields() {
        IdTextFeild.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        emailTextFeild.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        mobileTextFeild.addTarget(self, action: #selector(textFieldValueChangeListener), for: .editingChanged)
        
        
        IdTextFeild.setLeadingPadding(15)
        emailTextFeild.setLeadingPadding(15)
        mobileTextFeild.setLeadingPadding(15)
        
        IdTextFeild.setRightPadding(15)
        emailTextFeild.setRightPadding(15)
        
        IdTextFeild.addBorder(with:.sepratorColor)
        emailTextFeild.addBorder(with:.sepratorColor)
        //mobileTextFeild.addBorder(with:.sepratorColor)
        
        IdTextFeild.delegate = self
        emailTextFeild.delegate = self
        mobileTextFeild.delegate = self
        
    }
    
    //MARK: - Observers
    @objc private func textFieldValueChangeListener() {
        
//        if mobileTextFeild.text?.count ?? DefaultValue.int < 9 {
//            updateBtn.enableButton(false)
//            return
//        }
       // updateBtn.enableButton(false)
        updateBtn.enableButton(true)
        updateBtn.backgroundColor = .primaryBtnBg
    }
    
    private func setupViews() {
        setLeftBackButton(selector: #selector(backButtonTapped) ,rotate: false)
    }
    
    private func openPhoto() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Open Camera".localizedString(), style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.openCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Open Gallery".localizedString(), style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.openGallary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Clear".localizedString(), style: UIAlertAction.Style.default, handler: {(alert:UIAlertAction!) -> Void in
            self.updateCustomer(clearImage: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString(), style: UIAlertAction.Style.cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func openGallary(){
        self.view.endEditing(true)
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .custom
        present(picker, animated: true, completion: nil)
    }
    
    private func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            callCamera()
        } else  {
            let alert  = UIAlertController(title: "Warning".localizedString(), message: "You don't have camera".localizedString(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localizedString(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func callCamera(){
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.allowsEditing = true
        myPickerController.sourceType = UIImagePickerController.SourceType.camera
        myPickerController.modalPresentationStyle = .custom
        self.present(myPickerController, animated: true, completion: nil)
    }
    

    
    // MARK: - Navigation
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UIACTIONS
    @IBAction func didTapUpdateProfileImage(_ sender: Any) {
        openPhoto()
    }
    
    @objc func changeCountry(gesture: UIGestureRecognizer) {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = "SA"
        countryPicker.delegate = self
        self.present(countryPicker, animated: true)
    }
    
    @IBAction func updateProfileTapped(_ sender: Any) {
        self.updateCustomer()
    }
    
    private func updateCustomer(clearImage : Bool = false) {
        let countryCode = codeLabel.text?.replacingOccurrences(of: "+", with: "")
        let mobileNo = (countryCode ?? "966")+self.mobileTextFeild.text!
        //if ( self.emailTextFeild.text! == "" Commons.isValidEmail(email: self.emailTextFeild.text ?? "")){
        if self.emailTextFeild.text! != ""{
            if Commons.isValidEmail(email: self.emailTextFeild.text ?? ""){
                let deviceId = UIDevice.current.identifierForVendor?.uuidString
                updateVM.updateCustomer(deviceId: deviceId,
                                        deviceToken: firebaseToken,
                                        deviceName: "iOS",
                                        latitude: LocationManager.shared.lastLocation?.coordinate.latitude ,
                                        longitude: LocationManager.shared.lastLocation?.coordinate.longitude,email: self.emailTextFeild.text, mobileNo: mobileNo, profileImage: (clearImage == true ? "clear" : nil), prefferedLanguage: UserDefaults.standard.value(forKey: languageKey) as? String, isLanguageUpdate: false)
            }else{
                Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Please enter a valid email")
            }
        }else{
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            updateVM.updateCustomer(deviceId: deviceId,
                                    deviceToken: firebaseToken,
                                    deviceName: "iOS",
                                    latitude: LocationManager.shared.lastLocation?.coordinate.latitude ,
                                    longitude: LocationManager.shared.lastLocation?.coordinate.longitude,email: nil, mobileNo: mobileNo, profileImage: (clearImage == true ? "clear" : nil), prefferedLanguage: UserDefaults.standard.value(forKey: languageKey) as? String, isLanguageUpdate: false)
        }
    }
}

//MARK: - UITextFieldDelegate
extension UpdateProfileVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mobileTextFeild{
            mobileMainView.addDoubleBorder(with: .primaryDarkBG, and: .primaryGreen)
        }else{
            textField.addDoubleBorder(with: .primaryDarkBG, and: .primaryGreen)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.addBorder(with:.sepratorColor)
        } else if (textField == emailTextFeild && !Commons.isValidEmail(email: textField.text!)) {
            if #available(iOS 13.0, *) {
                emailTextFeild.addDoubleBorder(with: .separator, and: .errorRed)
            } else {
                // Fallback on earlier versions
            }
        } else {
            if textField == mobileTextFeild{
                mobileMainView.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
            }else{
                textField.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
            }
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension UpdateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[picker.allowsEditing ? UIImagePickerController.InfoKey.editedImage : UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageData: Data = image.jpegData(compressionQuality: 0.6)! as Data
            let compressedImage = UIImage(data: imageData as Data)
            self.usrerImageView.image = compressedImage
            
            let file = AttachmentInfo(apiKey: "profileImage", data: imageData)
            picker.dismiss(animated: true, completion: nil)
            
            updateVM.updloadProfileImage(file: file)
        }
    }
}

extension UpdateProfileVC {
    private func bindToViewModel() {
        updateVM.updateProfile.bind { [weak self] res in
            guard let self = self else { return }
            if res.statusCode == 200{
                UserDefaultsConfig.user?.profileImage = res.data?.profileImage
                Commons.showErrorMessage(controller: self.navigationController ?? self, backgroundColor: .lightGreen, textColor: .greenTextColor, message: "Updated Successfully")
                self.navigationController?.popViewController(animated: false)
            }
        }
        
        updateVM.isLoading.bind { [weak self] value in
            guard let self = self else { return }
            self.showLoader(startAnimate: value)
        }
        
        updateVM.messageWithCode.bind { [weak self] res in
            guard let `self` = self else { return }
            guard !(res.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.navigationController ?? self, message: res.message ?? DefaultValue.string)
        }
        
        updateVM.userData.bind { [weak self] res in
            guard let `self` = self else { return }
            if res.statusCode == 200{
            Commons.showErrorMessage(controller: self.navigationController ?? self, backgroundColor: .lightGreen, textColor: .greenTextColor, message: "Updated Successfully")
            self.navigationController?.popViewController(animated: false)
            }
        }
    }
}

extension UpdateProfileVC: CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        flagLabel.text = country.isoCode.getFlag()
        codeLabel.text = "+"+country.phoneCode
    }
}



