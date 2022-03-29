//
//  CosmicExplorationCountView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit

class CosmicExplorationCountView: UIView {
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var icon1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var icon1LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var icon1RightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var icon2WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var icon2LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var icon2RightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 11.px
        layer.masksToBounds = true
        
        countLabel.font = .systemFont(ofSize: 12.px)
        
        icon1WidthConstraint.constant = 15.px
        icon1LeftConstraint.constant = 5.px
        icon1RightConstraint.constant = 5.px
        
        icon2WidthConstraint.constant = 15.px
        icon2LeftConstraint.constant = 9.5.px
        icon2RightConstraint.constant = 3.5.px
    }
    
}
