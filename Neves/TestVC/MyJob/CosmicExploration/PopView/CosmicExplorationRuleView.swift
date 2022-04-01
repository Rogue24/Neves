//
//  CosmicExplorationRuleView.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

import UIKit

class CosmicExplorationRuleView: UIView, CosmicExplorationPopViewCompatible {
    
    @IBOutlet weak var titleImgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleImgViewWidthConstraint.constant = 228.px
        closeBtnWidthConstraint.constant = 30.px
    }
    
    @IBAction func closeAction() {
        close()
    }
    
    func reloadData() {
        
    }
}
