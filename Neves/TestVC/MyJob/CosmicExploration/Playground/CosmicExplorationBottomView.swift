//
//  CosmicExplorationBottomView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit

class CosmicExplorationBottomView: UIView {
    
    @IBOutlet weak var leftBtn1: NoHighlightButton!
    @IBOutlet weak var leftGiftIcon1: UIImageView!
    @IBOutlet weak var leftLabel1: UILabel!
    
    @IBOutlet weak var leftBtn2: NoHighlightButton!
    @IBOutlet weak var leftGiftIcon2: UIImageView!
    @IBOutlet weak var leftLabel2: UILabel!
    
    @IBOutlet weak var rightBtn2: NoHighlightButton!
    @IBOutlet weak var rightGiftIcon2: UIImageView!
    @IBOutlet weak var rightLabel2: UILabel!
    
    @IBOutlet weak var rightBtn1: NoHighlightButton!
    @IBOutlet weak var rightGiftIcon1: UIImageView!
    @IBOutlet weak var rightLabel1: UILabel!
    
    @IBOutlet weak var bottomTitleLabel: UILabel!
    
    @IBOutlet weak var leftBtn1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBtn1LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBtn1RightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftGiftIcon1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftGiftIcon1LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftIcon1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftIcon1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftIcon1RightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftBtn2WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftGiftIcon2LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftIcon2RightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightGiftIcon2LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightIcon2RightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightBtn1LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightBtn1RightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightGiftIcon1LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightIcon1RightConstraint: NSLayoutConstraint!
    
    @IBOutlet var labelIconSpaceConstraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var bottomTitleLabelTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftBtn1WidthConstraint.constant = 90.px
        leftBtn1LeftConstraint.constant = 10.px
        leftBtn1RightConstraint.constant = 4.5.px
        leftGiftIcon1WidthConstraint.constant = 18.px
        leftGiftIcon1LeftConstraint.constant = 11.px
        leftIcon1WidthConstraint.constant = 10.px
        leftIcon1TopConstraint.constant = 17.px
        leftIcon1RightConstraint.constant = -14.5.px
        
        leftBtn2WidthConstraint.constant = 80.px
        leftGiftIcon2LeftConstraint.constant = -9.px
        leftIcon2RightConstraint.constant = 9.5.px
        
        rightGiftIcon2LeftConstraint.constant = -9.px
        rightIcon2RightConstraint.constant = 9.5.px
        
        rightBtn1LeftConstraint.constant = 4.5.px
        rightBtn1RightConstraint.constant = 10.px
        rightGiftIcon1LeftConstraint.constant = -14.5.px
        rightIcon1RightConstraint.constant = 9.5.px
        
        for lisCon in labelIconSpaceConstraints {
            lisCon.constant = 2.px
        }
        
        bottomTitleLabelTopConstraint.constant = 5.px
        
        leftLabel1.font = .systemFont(ofSize: 11.px)
        leftLabel2.font = .systemFont(ofSize: 11.px)
        rightLabel1.font = .systemFont(ofSize: 11.px)
        rightLabel2.font = .systemFont(ofSize: 11.px)
        bottomTitleLabel.font = .systemFont(ofSize: 9.px)
        
        leftBtn1.addTarget(self, action: #selector(btnDidClick(_:)), for: .touchUpInside)
        leftBtn2.addTarget(self, action: #selector(btnDidClick(_:)), for: .touchUpInside)
        rightBtn1.addTarget(self, action: #selector(btnDidClick(_:)), for: .touchUpInside)
        rightBtn2.addTarget(self, action: #selector(btnDidClick(_:)), for: .touchUpInside)
    }
    
    var isActived = false
    
}

extension CosmicExplorationBottomView {
    
    @objc func btnDidClick(_ sender: UIButton) {
        isActived.toggle()
        
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
            self.leftBtn1.isSelected = self.isActived
            self.leftBtn2.isSelected = self.isActived
            self.rightBtn1.isSelected = self.isActived
            self.rightBtn2.isSelected = self.isActived
        } completion: { _ in }
    }
    
}
