//
//  CosmicExplorationPlayView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationPlayView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var closeBtn: NoHighlightButton!
    @IBOutlet weak var moreBtn: NoHighlightButton!
    @IBOutlet weak var bannerView: CosmicExplorationBannerView!
    @IBOutlet weak var countView: CosmicExplorationCountView!
    @IBOutlet weak var recordView: CosmicExplorationRecordView!
    @IBOutlet weak var turntableView: CosmicExplorationTurntableView!
    @IBOutlet weak var bottomView: CosmicExplorationBottomView!
    
    @IBOutlet weak var bgImgViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var turntableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgImgViewHeightConstraint.constant = 475.px
        closeBtnWidthConstraint.constant = 30.px
        closeBtnTopConstraint.constant = 10.px
        closeBtnLeftConstraint.constant = 10.px
        moreBtnRightConstraint.constant = 10.px
        bannerViewHeightConstraint.constant = 22.px
        turntableViewTopConstraint.constant = 62.5.px
        bottomViewHeightConstraint.constant = 77.px
    }
    
}
