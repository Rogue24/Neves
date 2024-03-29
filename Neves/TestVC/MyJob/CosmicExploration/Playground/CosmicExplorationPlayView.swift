//
//  CosmicExplorationPlayView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit

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
    
    private weak var popView: (UIView & CosmicExplorationPopViewCompatible)? = nil {
        willSet { popView?.close() }
    }
    
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
        
        turntableView.delegate = self
        
        moreBtn.addTarget(self, action: #selector(more), for: .touchUpInside)
        countView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBuy)))
    }
    
    // MARK: - 点击空白关闭
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 停止响应事件的回传
//        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        if let popView = self.popView, !popView.frame.contains(point) {
            popView.close()
        } else if !contentView.frame.contains(point) {
            close()
        }
    }
    
    deinit {
        JPrint("死了啦！都是你害的啦！")
    }
    
}

extension CosmicExplorationPlayView {
    static func show(on view: UIView) -> CosmicExplorationPlayView {
        let playView = CosmicExplorationPlayView.loadFromNib()
//        playView.frame = PortraitScreenBounds
//        playView.layoutIfNeeded()
        view.addSubview(playView)
        playView.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.layoutIfNeeded()
        
        // TODO: 临时做法
        Asyncs.main {
            playView.show()
        }
        
        return playView
    }
    
    func show() {
        updateStage(CosmicExplorationManager.shared.stage, .idle, animated: false)
        CosmicExplorationManager.shared.resetTargetPlanet()
        
        contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.layoutIfNeeded()
        } completion: { _ in }
    }
    
    @objc func close() {
        contentViewBottomConstraint.constant = -500.px
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func more() {
        CosmicExplorationMenuView.show(withDelegate: self)
    }
    
    @objc func goBuy() {
        CosmicExplorationBuyTicketView.show(on: self)
    }
}

extension CosmicExplorationPlayView {
    
    func addSupplyFromOther(toPlant plant: CosmicExploration.Planet) {
        guard let planetView = turntableView.findPlanetView(for: plant) else { return }
        planetView.addSupplyFromOther()
    }
    
}

extension CosmicExplorationPlayView: CosmicExplorationTurntableViewDelegate {
    func turntableView(_ turntableView: CosmicExplorationTurntableView,
                       updateSuppliesFromSupplyType supplyType: CosmicExploration.SupplyType,
                       toItemFrame itemFrame: CGRect) {
        let giftIcon: UIImageView
        switch supplyType {
        case .supply1:
            giftIcon = bottomView.leftGiftIcon1
        case .supply2:
            giftIcon = bottomView.leftGiftIcon2
        case .supply3:
            giftIcon = bottomView.rightGiftIcon2
        case .supply4:
            giftIcon = bottomView.rightGiftIcon1
        }
        
        let fromFrame = giftIcon.convert(giftIcon.bounds, to: contentView)
        let toCenter: CGPoint = [itemFrame.origin.x + 9.px, itemFrame.origin.y + 7.px]
        let scale = 10.px / giftIcon.frame.width
         
        let imageView = UIImageView(frame: fromFrame)
        imageView.image = giftIcon.image
        contentView.addSubview(imageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: []) {
            imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            imageView.center = toCenter
        } completion: { _ in
            imageView.removeFromSuperview()
        }

    }
}

extension CosmicExplorationPlayView {
    
    func updateStage(_ stage: CosmicExploration.Stage, _ oldStage: CosmicExploration.Stage, animated: Bool = true) {
        turntableView.updateStage(stage, oldStage, animated: animated)
        bottomView.updateStage(stage, oldStage, animated: animated)
    }
    
    
}


extension CosmicExplorationPlayView: CosmicExplorationMenuViewDelegate {
    func showRuleView() {
        popView = CosmicExplorationRuleView.show(on: self)
    }
    
    func showJackpotView() {
        popView = CosmicExplorationJackpotView.show(on: self)
    }
    
    func showRecordView() {
        popView = CosmicExplorationRecordDetailView.show(on: self)
    }
    
    func showJournalView() {
        popView = CosmicExplorationJournalView.show(on: self)
    }
}
