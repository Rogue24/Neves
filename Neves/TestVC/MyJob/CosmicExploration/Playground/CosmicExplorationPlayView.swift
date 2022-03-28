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
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
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
        
        contentViewHeightConstraint.constant = 500.px
        contentViewBottomConstraint.constant = -contentViewHeightConstraint.constant
        bgImgViewHeightConstraint.constant = 475.px
        closeBtnWidthConstraint.constant = 30.px
        closeBtnTopConstraint.constant = 10.px
        closeBtnLeftConstraint.constant = 10.px
        moreBtnRightConstraint.constant = 10.px
        bannerViewHeightConstraint.constant = 22.px
        turntableViewTopConstraint.constant = 62.5.px
        bottomViewHeightConstraint.constant = 77.px
    }
    
    // MARK: - 点击空白关闭
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
//        if let popView = self.popView, !popView.frame.contains(point) {
//            popView.close()
//        } else if !contentView.frame.contains(point) {
//            close()
//        }
        
        if !contentView.frame.contains(point) {
            close()
        }
    }
    
    deinit {
        JPrint("死了啦！都是你害的啦！")
    }
    
    static func build() -> Self {
        Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.first as! Self
    }
    
}

extension CosmicExplorationPlayView {
    func show() {
        contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    @objc func close() {
        contentViewBottomConstraint.constant = -500.px
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func more() {
        
    }
}
