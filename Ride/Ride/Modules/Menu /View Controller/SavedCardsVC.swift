//
//  SavedCardsVC.swift
//  Ride
//
//  Created by PSE on 10/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class SavedCardsVC: UIViewController {
    
    //MARK: -  IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var savedCardsTV: UITableView!
    @IBOutlet weak var addNewBtn: UIButton!
    
    //MARK: - Constants and Variables
//    private let cardsVM = ChoosePaymentMethodViewModel()
    private let addCardVM = AddCardViewModel()
    
    var shouldShowCard = false

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
//         cardsVM.getCardList(request: "1")
         bindViewToViewModel()
     }
     
     private func setupViews() {
         setLeftBackButton(selector: #selector(backButtonTapped))
         
         savedCardsTV.register(UINib(nibName: SavedCardsCell.className, bundle: nil), forCellReuseIdentifier: SavedCardsCell.className)
         savedCardsTV.reloadData()
         
         titleLbl.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(24) : UIFont.SFProDisplayBold?.withSize(24)
         addNewBtn.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
     }

     // MARK: - Navigation
      
     @objc private func backButtonTapped() {
         navigationController?.popViewController(animated: true)
     }
 }

 //MARK: - Tableview delegate and datasource
extension SavedCardsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        UserDefaultsConfig.cards.count //cardsVM.apiResponse.value.data?.count ?? DefaultValue.int
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedCardsCell.className, for: indexPath) as? SavedCardsCell else { return SavedCardsCell() }
        
        
        cell.item = UserDefaultsConfig.cards[indexPath.section] //cardsVM.apiResponse.value.data?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action =  UIContextualAction(style: .normal, title: "Delete".localizedString(), handler: { [weak self] (action,view,completionHandler ) in
            completionHandler(true)
            
            guard let `self` = self else { return }
            
            self.addCardVM.changeCardStatus(status: "0")
        })
        
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "trash")?.withTintColor(.white)
            action.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
                image?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
            }
            action.backgroundColor = .red
            let confrigation = UISwipeActionsConfiguration(actions: [action])
            return confrigation
        } else {
            // Fallback on earlier versions
            let image = UIImage(systemName: "trash")?.withTintColor(.white)
            action.image = image
            action.backgroundColor = .red
            let confrigation = UISwipeActionsConfiguration(actions: [action])
            
            return confrigation
        }
    }
}

extension SavedCardsVC {
    private func bindViewToViewModel() {
//        cardsVM.isLoading.bind { [weak self] value in
//            self?.showLoader(startAnimate: value)
//        }
//
//        cardsVM.messageWithCode.bind { [weak self] error in
//            guard let `self` = self else { return }
//            guard !(error.message?.isEmpty ?? true) else { return }
//            Commons.showErrorMessage(controller: self.navigationController ?? self, message: error.message ?? DefaultValue.string)
//        }
//
//        cardsVM.apiResponse.bind { [weak self] response in
//            guard let `self` = self else { return }
//
//            if response.code == 200 {
//                self.savedCardsTV.reloadData()
//            }
//        }
        
        addCardVM.changeCardStatus.bind { [weak self] value in
            guard let `self` = self else { return }
            
            guard value.status.isSome else { return }
            
            UserDefaultsConfig.cards = []
            self.savedCardsTV.reloadData()
        }
    }
}
