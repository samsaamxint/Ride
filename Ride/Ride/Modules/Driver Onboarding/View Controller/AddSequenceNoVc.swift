//
//  AddSequenceNoVc.swift
//  Ride
//
//  Created by XintMac on 25/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class AddSequenceNoVc: UIViewController {
    //MARK: - IBOutlets
    
    @IBOutlet weak var ownerIDTF: UITextField!
    @IBOutlet weak var authorizeVehicleLabel: UILabel!
    @IBOutlet weak var sequenceNoTF: UITextField!
    @IBOutlet weak var sequenceNoView: UIView!
    @IBOutlet weak var addSeqenceNoLabel: UILabel!
    @IBOutlet weak var sequenceNoLabel: UILabel!
    @IBOutlet weak var findCarLabel: UILabel!
    @IBOutlet weak var viewOnerShip: UIView!
    @IBOutlet weak var learnMoreLabel: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    
    var carSequenceViewModel = CarSequenceViewModel()
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                btnCheck.setImage(UIImage(named: "checked"), for: .normal)
                
            } else {
                btnCheck.setImage(UIImage(named: "unchecked"), for: .normal)
            }
        }
    }
        //MARK: - Life Cycle methods
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.sequenceNoTF.delegate = self
            ownerIDTF.placeholder = "OwnershipNo".localizedString()
            sequenceNoTF.placeholder = "SeqNo".localizedString()
            bindViewToViewModel()
            
            addSeqenceNoLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(22) : UIFont.SFProDisplayBold?.withSize(22)
            sequenceNoLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(13) : UIFont.SFProDisplayMedium?.withSize(13)
            findCarLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.MadaniArabicSemiBold?.withSize(16)
            learnMoreLabel.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicMedium?.withSize(14) : UIFont.SFProDisplayMedium?.withSize(14)
            sequenceNoTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
            doneBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
            findCarLabel.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicSemiBold?.withSize(16) : UIFont.SFProDisplaySemiBold?.withSize(16)
            ownerIDTF.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular?.withSize(16) : UIFont.SFProDisplayRegular?.withSize(16)
            ownerIDTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
            sequenceNoTF.textAlignment = Commons.isArabicLanguage() ? .right : .left
            authorizeVehicleLabel.textAlignment = Commons.isArabicLanguage() ? .right : .left
            self.btnShowOwnerID(btnCheck)
        }
        
        
        //MARK: - IBActions
        
        @IBAction func learnMorePressed(_ sender: Any) {
        }
        
        @IBAction func donePressed(_ sender: Any) {
            Commons.adjustEventTracker(eventId: AdjustEventId.SequenceNumberCount)
            if let carSequence = self.sequenceNoTF.text, !carSequence.isEmpty {
                let ownerId: String = self.ownerIDTF.text ?? ""
                carSequenceViewModel.getCarDetails( carSequence: carSequence, onwerId: ownerId)
            } else {
                sequenceNoView.addDoubleBorder(with: .clear, and: .red)
                Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self , message: "Please Enter sequence number")
            }
            
            //        if let vc: SubcriptionSelectionVC = UIStoryboard.instantiate(with: .driverOnboarding) {
            ////            vc.CarDetail = res.data
            //            self.parent?.parent?.navigationController?.pushViewController(vc, animated: false)
            //        }
            
            
        }
    @IBAction func btnShowOwnerID(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let parent = (self.parent?.parent as? GenericOnboardingViewController) {
            parent.containerViewHeight.constant = !sender.isSelected ? 440 : 500
        } else {
            (self.parent?.parent as? MainDashboardViewController)?.containerViewHeight.constant = !sender.isSelected ? 440 : 500
        }
        
        sender.setImage(UIImage(named: sender.isSelected ? "checked_icn" : "unchecked_icn"), for: .normal)
        viewOnerShip.isHidden = !sender.isSelected
    }
}
    
    //MARK: - UITextFieldDelegate
    extension AddSequenceNoVc : UITextFieldDelegate {
        func textFieldDidBeginEditing(_ textField: UITextField) {
            sequenceNoView.addDoubleBorder(with: .primaryDarkBG, and: .primaryGreen)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField.text?.isEmpty ?? true {
                sequenceNoView.addDoubleBorder(with: .sepratorColor, and: .clear)
            } else {
                sequenceNoView.addDoubleBorder(with: .sepratorColor, and: .primaryGreen)
            }
        }
    }
    
    extension AddSequenceNoVc{
        func bindViewToViewModel() {
            carSequenceViewModel.apiResponse.bind { [weak self] res in
                guard let self = self else {return}
                if res.statusCode == 200{
                    Commons.adjustEventTracker(eventId: AdjustEventId.Sequencesuccess)
                    UserDefaultsConfig.carSequenceNo = self.sequenceNoTF.text ?? ""
                    //let platenumber = (res.data?.plateText3 ?? "")+(res.data?.plateText2 ?? "")+(res.data?.plateText1 ?? "")
                    let platenumber = "\(res.data?.plateText1 ?? "")\(res.data?.plateText2 ?? "")\(res.data?.plateText3 ?? "")"
                    UserDefaultsConfig.carPlateNo = String(res.data?.plateNumber ?? 0)+"-"+platenumber
                    UserDefaultsConfig.cab = "db8db63e-1501-44c2-ac1b-c4bc213e92dc"
                    UserDefaultsConfig.carLicenceType = res.data?.plateTypeCode
                    if let vc: SubcriptionSelectionVC = UIStoryboard.instantiate(with: .driverOnboarding) {
                        vc.CarDetail = res.data
                        self.parent?.parent?.navigationController?.pushViewController(vc, animated: false)
                    }
                }else if res.statusCode == 500{
                    Commons.adjustEventTracker(eventId: AdjustEventId.SequenceFailed)
                    //                if let vc: NoCarVC = UIStoryboard.instantiate(with: .driverOnboarding) {
                    //                    vc.modalPresentationStyle = .overCurrentContext
                    //                    vc.modalTransitionStyle = .crossDissolve
                    //                    self.present(vc, animated: true)
                    //                }
                    Commons.showErrorMessage(controller: self.parent?.parent ?? self,backgroundColor: .lightOrange,textColor: .darkOrange, message: "You don’t Have Any cars Registered to your iD number.")
                }
            }
            
            carSequenceViewModel.isLoading.bind { [unowned self] (value) in
                self.showLoader(startAnimate: value)
            }
            
            carSequenceViewModel.messageWithCode.bind { [weak self] value in
                guard let `self` = self else { return }
                if value.code == 500 {
                    //                if let vc: NoCarVC = UIStoryboard.instantiate(with: .driverOnboarding) {
                    //                    vc.modalPresentationStyle = .overCurrentContext
                    //                    vc.modalTransitionStyle = .crossDissolve
                    //                    self.present(vc, animated: true)
                    //                }
                    Commons.showErrorMessage(controller: self.parent?.parent ?? self,backgroundColor: .lightOrange,textColor: .darkOrange, message: "noCar".localizedString())
                }else{
                    guard !(value.code.isNone) else { return }
                    if let msg = value.message{
                        if msg.containsIgnoringCase("Sequence"){
                            Commons.showErrorMessage(controller: self.parent?.parent ?? self,backgroundColor: .lightOrange,textColor: .darkOrange, message: "Sequence number not found.")
                        }else{
                            self.sequenceNoView.addDoubleBorder(with: .clear, and: .red)
                            Commons.showErrorMessage(controller: self.parent?.parent ?? self, message: "Enter a valid sequence Number")
                        }
                    }
                    
                }
            }
        }
    }
