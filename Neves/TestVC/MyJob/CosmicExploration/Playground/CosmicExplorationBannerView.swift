//
//  CosmicExplorationBannerView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit

class CosmicExplorationBannerView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leftIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftIconLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewRightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 11.px
        layer.masksToBounds = true
        
        leftIconWidthConstraint.constant = 15.px
        leftIconLeftConstraint.constant = 5.px
        tableViewLeftConstraint.constant = 5.px
        tableViewRightConstraint.constant = 5.px
    }
    
}
