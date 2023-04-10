//
//  AdjustEvent.swift
//  Ride
//
//  Created by Samsaam Zohaib on 09/02/2023.
//  Copyright © 2023 Xint Solutions. All rights reserved.
//

import Foundation

enum EventAction {
    case none
    case callBack
    case partnerParams
}

enum AdjustEventId {
    static let AfterCarSelectionEvent = "vlf8u5"
    static let ApplyPromo = "onbohl"
    static let ApplyPromoFailure = "8gf5d0"
    static let ApplyPromoSuccess = "v9wa3w"
    static let BankTransactionFailure = "m6evy8"
    static let BankTransactionforSubscriptionEvent = "a7nwor"
    static let BankTransactionSuccess = "c9g9cr"
    static let CarConfirmationFailed = "w1st13"
    static let CarConfirmationSuccess = "whg0q3"
    static let CardSaving = "ewptof"
    static let CardSkipped = "4mor9m"
    static let CarNotFound = "d0js76"
    static let CarSelectionFailed = "hoqtra"
    static let CarSelectionSuccess = "pz9jrz"
    static let ConfirmPickup = "gusrk6"
    static let ConfirmRide = "jvro0a"
    static let DriverSignup = "bg0dwt"
    static let IBANAdded = "srnbma"
    static let IBANAddedFailed = "trilea"
    static let IBANAddedSuccess = "h7zq04"
    static let KYCAttempts = "vvv2ii"
    static let KYCAttemptsFailed = "e0anwp"
    static let KYCAttemptsSuccess = "enseu0"
    static let LoginSessions = "2wa1tx"
    static let OTPFailure = "t7z6or"
    static let OTPforPayment = "1j95em"
    static let OTPSuccess = "5rlxf8"
    static let ProcessAfterCarSelection = "kfhnzx"
    static let RideAcceptanceFailed = "qn0c4k"
    static let RideAcceptanceSuccess = "oki8ud"
    static let RideCancelledAfterconfirmation = "8ihug3"
    static let RidecancelledBeforeconfirmation = "jfwqoz"
    static let RidesAccepted = "se0zt4"
    static let SelectCar = "98lx2s"
    static let SendUnifornicOTP = "y429vg"
    static let SequenceAdded = "yp05b4"
    static let SequenceFailed = "8m2i9e"
    static let SequenceNumberCount = "90ngb8"
    static let Sequencesuccess = "i07hel"
    static let SignUpEvent = "m4uql2"
    static let SubscribePackageFailed = "l9mxv8"
    static let SubscribePackageSuccess = "3jnui8"
    static let SubscriptionPackagesCount = "hto7qp"
    static let SubscriptionPackageUnSubscribed = "3c3two"
    static let SubscriptionTransactionFailed = "bvzlfr"
    static let SubscriptionTransactionSuccess = "msdst0"
    static let TAMMOTPFailure = "ew0sje"
    static let TAMMOTPSuccess = "t304t8"
    static let TopupFailed = "ldec2k"
    static let TopupSuccess = "9vt90q"
    static let UnifonicOTPFailed = "j8p68o"
    static let UnifonicOTPverified = "q6o3bi"
    static let WASLApproval = "2sa1us"
    static let WASLRejection = "jeoew6"
}
