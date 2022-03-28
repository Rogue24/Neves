//
//  CosmicExplorationBottomView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationBottomView: UIView {
    
    @IBOutlet weak var leftBtn1: NoHighlightButton!
    @IBOutlet weak var leftBtn2: NoHighlightButton!
    @IBOutlet weak var rightBtn1: NoHighlightButton!
    @IBOutlet weak var rightBtn2: NoHighlightButton!
    
    @IBOutlet weak var leftBtn1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBtn2WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBtn1LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBtn1RightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightBtn1LeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightBtn1RightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftBtn1WidthConstraint.constant = 90.px
        leftBtn2WidthConstraint.constant = 80.px
        leftBtn1LeftConstraint.constant = 10.px
        leftBtn1RightConstraint.constant = 4.5.px
        rightBtn1LeftConstraint.constant = 4.5.px
        rightBtn1RightConstraint.constant = 10.px
    }
    
}
