//
//  EmptyTopupViewController.swift
//  Ride
//
//  Created by Ali Zaib on 25/10/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

enum EmptyTopupType {
    case addbalance, updateIBAN, purchaseSubscription
}

protocol EmptyTopupViewControllerProtocol: AnyObject {
    func updateBalance()
    func updateIBAN()
    func subscriptionPurchased()
}

extension EmptyTopupViewControllerProtocol {
    func updateBalance() { }
    func updateIBAN() { }
    func subscriptionPurchased() { }
}

class EmptyTopupViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var blurrView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHConstraint: NSLayoutConstraint!
    
    //MARK: - Constants and Variables
    weak var delegate: EmptyTopupViewControllerProtocol?
    var type: EmptyTopupType = .addbalance
    var ibanData: GetIBANData?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decideChildVC()
    }
    
    private func decideChildVC() {
        switch type {
        case .addbalance:
            addBalanceVC()
        case .updateIBAN:
            updateIBANVC()
        case .purchaseSubscription:
            showSubscriptionVC()
        }
    }
    
    private func addBalanceVC() {
        if let vc: AddBalanceVC = UIStoryboard.instantiate(with: .paymentMethods) {
            containerViewHConstraint.constant = 560
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            addChildWithNavViewController(childController: vc, contentView: containerView)
        }
    }
    
    private func updateIBANVC() {
        if let vc: VerifyDriverIBANViewController = UIStoryboard.instantiate(with: .driverRideARideDashboard) {
            containerViewHConstraint.constant = 400
            vc.comingFromUpdate = true
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            vc.ibanData = ibanData
            addChildViewController(childController: vc, contentView: containerView)
        }
    }

    private func showSubscriptionVC() {
        if let vc: OwnCarSubscriptionViewController = UIStoryboard.instantiate(with: .driverOwnCarDashboard) {
            containerViewHConstraint.constant = 440
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            addChildWithNavViewController(childController: vc, contentView: containerView)
        }
    }
    
    //MARK: - UIACTIONS
    @IBAction func dismissBalancePopup(_ sender: Any) {
        type == .addbalance ? delegate?.updateBalance() : delegate?.updateIBAN()
        containerView.subviews.first?.removeFromSuperview()
        dismiss(animated: true)
    }
}
