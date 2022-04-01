//
//  CosmicExplorationJackpotCell.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

import UIKit

class CosmicExplorationJackpotCell: UICollectionViewCell {
    
    @IBOutlet weak var giftIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var numLabel: UILabel!
    
    @IBOutlet weak var giftIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var coinIconWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.font = .systemFont(ofSize: 13.px)
        numLabel.font = .systemFont(ofSize: 11.px)
        stackView.spacing = 3.px
        
        giftIconWidthConstraint.constant = 80.px
        nameLabelHeightConstraint.constant = 18.5.px
        nameLabelBottomConstraint.constant = 2.px
        coinIconWidthConstraint.constant = 13.px
    }

}
