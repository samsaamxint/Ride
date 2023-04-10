//
//  RequestType.swift
//  Ride
//
//  Created by Mac on 22/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

enum RequestType {
    // Configurations
    static let updateCustomer = "user/update-customer"
    
    static let latestVersionCheck = "master/setting/IOS_MINIMUM_ALLOWED_VERSION"
    // AUTH
    static let sendOTP = "sendotp" //send-otp"
    static let otp_verification = "verifyotp" //otp-verification"
    static let update_profile = "user/update-picture"
    static let driverSignup = "DriverSignup"
    static let getTripDetail = "trips/socket/"
    static let getUserDetail = "getuserdetails"
    static let getCarDetails = "car-info-by-sequence"

    static let getSubscriptionPlan = "subscription"
    static let checkApplicationStatus = "CheckApplicationStatus"
    static let selectedPlanSummary = "SelectedPlanSummary"
    
    //get trips
    static let riderTrips = "trips/rider"
    static let driverTrips = "trips/driver"
    
    
    //rideaRide
    static let getCabs = "GetCabs"
    static let getCabDetail = "GetCabDetail"
    static let carCheckout = "CarCheckout"
    
    //send mapphoto
    static let uploadMapPhoto = "trips/upload-photo/"

    
    //Mock
    static let getCarDetailsMock = "CarSequenceNumber"
    
    //payment
    static let getCardsList = "GetCardsList"
    static let addCard = "AddCard"
//    static let purchaseSubscription = "PurchaseSubscription"
    
    static let cancelReasons = "master/rejected-reason/type/"
    
    //Riders
    static let getCars = "master/cab-type/all"
    static let getTrip = "trips"
    static let cancelTrip = "trips/cancel-trip-request/"
    static let rateDriver = "reviews/driver"
    static let riderCancel = "trips/rider-cancelled/"
    static let changeDestination = "trips/change-destination/"
    static let riderKYC = "user/kyc"
    static let checkKYCStatus = "user/kyc-status-check"
    static let getTripDetailsApi = "trips/"
    static let getInvoiceDetailsApi = "trips/invoice/"
    
    //Driver
    static let driver_rejected = "trips/driver-rejected/"
    static let driver_accepted = "trips/driver-accepted/"
    static let driver_reached = "trips/driver-reached-at-pickup-point/"
    static let driver_trip_started = "trips/started/"
    static let driver_completed = "trips/completed/"
    static let rateRider = "reviews/rider"
    static let tripCancelledByDriver = "trips/driver-cancelled/"
    static let becomeCaptain = "captains/become-captain"
    static let driverWelcome = "driver-welcome"
    static let validateIban = "user/validate-iban/"
    static let captainInvoice = "captains/subscription/invoice"
    static let getIban = "user/get-iban"
    static let getActiveUsersLocation = "user/get-all-active-users-locations"
    static let getHighDemandZones = "trips/high-demand_zones"
    
    
    // Switch User Model
    static let getCaptainStatus = "captains"
    static let changeDriverMode = "captains/change-driver-mode"
    
    // User Profile
    static let uploadUserProfileImage = "profile/image/upload"
    
    // Balance
    static let getBalance = "user/get-balance"
    static let addBalance = "user/clickpay-hosted-method-top-up" //"user/add-balance"
    static let validatePromocode = "promo-code/validate"
    static let topUpHistory = "user/top-up-history"
    static let changeCardStatus = "https://dev-panel.ride.sa/api/changecardstatus"
    
    
    //topup
    static let topUp = "https://dev-panel.ride.sa/api/topup"
    
    //Subscription
    static let purchaseSubscription = "captains/subscription/purchase"
    static let verifySubscription = "captains/verify-subscription"
    static let getSubscriptions = "captains/subscriptions"
    static let cancelSubscription = "captains/subscription/cancel"
    static let activateSubscription = "captains/subscription/activate"
    static let updateSubscription = "captains/subscription/update"
    static let changeRenewalStatus = "captains/subscription/change-renwal-status"
    
    //Chat
    static let getChatList = "chat/get-user-messages/"
    
    
    //CMS
    static let addTicket = "ticket/save"
    static let tickerPerCustomer = "ticket/per-customer"
    static let getComplaintType = "ticket/get-complaint-type"
    
    //notification
    static let getNotification = "user/notifications"
    
    //termsAndConditions
    static let TermsAndConditions = "terms-and-condition.html"
    static let TermsAndConditionsAR = "terms-and-condition-ar.html"
    //privacyPolicy
    static let PrivacyPolicy = "privacy-policy.html"
    static let PrivacyPolicyAR = "privacy-policy-arn.html"
    
    //customerCare
    static let getCustomerCare = "master/setting/SUPPORT_TOLL_FREE_NO"
    
}
