//
//  CarSelectionVC.swift
//  Ride
//
//  Created by XintMac on 19/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit

class CarSelectionVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var carSelectionCV: UICollectionView!
    @IBOutlet weak var chooseCarButton: UIButton!
    var CarDetail : CarSequenceData?
    var selectedIndex:((Int) -> ())?
    //MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carSelectionCV.register(UINib(nibName: CarSelectionCVCell.className, bundle: nil), forCellWithReuseIdentifier: CarSelectionCVCell.className)
        
        if #available(iOS 14.0, *) {
            pageIndicator.preferredIndicatorImage = UIImage(named:"PageUnselected")
            pageIndicator.currentPageIndicatorTintColor = .greenTextColor
            //pageIndicator.pageIndicatorTintColor = .secondaryGrayTextColor
        } else {
            // Fallback on earlier versions
        }
        pageIndicator.isHidden = true
 
    }
    
    override func viewDidLayoutSubviews() {
        chooseCarButton.titleLabel?.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicBold?.withSize(18) : UIFont.SFProDisplayBold?.withSize(18)
    }
    
    //MARK: - IBActions
    @IBAction func chooseCarPresssed(_ sender: Any) {
        self.selectedIndex?(self.pageIndicator.currentPage)
        self.dismiss(animated: true)
    }
    
    
    
}
//MARK: - Collectionview Delegates
extension CarSelectionVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarSelectionCVCell.className, for: indexPath)  as? CarSelectionCVCell else {
            return CarSelectionCVCell()
        }
        cell.carData = self.CarDetail
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.width , height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if pageIndicator.currentPage == indexPath.row {
            guard let visible = collectionView.visibleCells.first else { return }
            guard let index = collectionView.indexPath(for: visible)?.row else { return }
            pageIndicator.currentPage = index
        }
        
    }
}


