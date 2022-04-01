//
//  CosmicExplorationJackpotView.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

import UIKit

class CosmicExplorationJackpotView: UIView, CosmicExplorationPopViewCompatible {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleImgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleImgViewWidthConstraint.constant = 228.px
        closeBtnWidthConstraint.constant = 30.px
        collectionViewTopConstraint.constant = 13.px
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 14.px, bottom: DiffTabBarH + 10.px, right: 14.px)
            flowLayout.minimumLineSpacing = 10.px
            flowLayout.itemSize = [105.px - 1, (105 + 10 + 18.5 + 2 + 15).px]
            flowLayout.minimumInteritemSpacing = (PortraitScreenWidth - 28.px - 105.px * 3) / 2
        }
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(UINib(nibName:"CosmicExplorationJackpotCell", bundle: nil), forCellWithReuseIdentifier:"CosmicExplorationJackpotCell")
        collectionView.dataSource = self
    }
    
    @IBAction func closeAction() {
        close()
    }
    
    func reloadData() {
        
    }

}

extension CosmicExplorationJackpotView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CosmicExplorationJackpotCell", for: indexPath) as! CosmicExplorationJackpotCell
        
        return cell
    }
}
