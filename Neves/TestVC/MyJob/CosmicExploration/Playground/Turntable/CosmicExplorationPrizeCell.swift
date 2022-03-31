//
//  CosmicExplorationPrizeCell.swift
//  Neves
//
//  Created by aa on 2022/3/31.
//

import UIKit

class CosmicExplorationPrizeCell: UICollectionViewCell {

    @IBOutlet weak var giftIcon: UIImageView!
    @IBOutlet weak var countBgView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var numLabel: UILabel!
    
    @IBOutlet weak var bgImgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var giftIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var countBgViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var countBgViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var countBgViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var countLabelHorConstraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var nameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ticketIconWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countBgView.layer.cornerRadius = 5.px
        countBgView.layer.masksToBounds = true
        countLabel.font = .systemFont(ofSize: 8.px)
        nameLabel.font = .systemFont(ofSize: 10.px)
        numLabel.font = .systemFont(ofSize: 10.px)
        stackView.spacing = 3.px
        
        bgImgViewWidthConstraint.constant = 50.px
        giftIconWidthConstraint.constant = 40.px
        countBgViewHeightConstraint.constant = 10.px
        countBgViewRightConstraint.constant = -1.5.px
        countBgViewBottomConstraint.constant = -1.5.px
        countLabelHorConstraints.forEach { $0.constant = 2.5.px }
        nameLabelTopConstraint.constant = 3.5.px
        nameLabelHeightConstraint.constant = 12.px
        ticketIconWidthConstraint.constant = 11.px
    }

}
