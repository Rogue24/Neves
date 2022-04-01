//
//  CosmicExplorationMenuView.swift
//  app
//
//  Created by aa on 2022/1/15.
//  Copyright © 2022 Quwan. All rights reserved.
//

import UIKit

protocol CosmicExplorationMenuViewDelegate: UIView {
    func showRuleView()
    func showJackpotView()
    func showRecordView()
    func showJournalView()
}

class CosmicExplorationMenuView: UIView {
    
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var popViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: (UIView & CosmicExplorationMenuViewDelegate)? = nil
    private var isAnimating = false
    
    @discardableResult
    static func show(withDelegate delegate: UIView & CosmicExplorationMenuViewDelegate) -> CosmicExplorationMenuView {
        let menuView = CosmicExplorationMenuView.loadFromNib()
        menuView.delegate = delegate
        delegate.addSubview(menuView)
        menuView.snp.makeConstraints { $0.edges.equalToSuperview() }
        delegate.layoutIfNeeded()
        menuView.initializeLayoutBeforeShow()
        menuView.show()
        return menuView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        popViewRightConstraint.constant = 6.px
        popViewBottomConstraint.constant = 300.px
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        if !isAnimating, !popView.frame.contains(point) {
            close()
        }
    }
    
    func initializeLayoutBeforeShow() {
        let frame = popView.layer.frame
        popView.layer.anchorPoint = [0.8, 0]
        popView.layer.frame = frame
        popView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        popView.layer.opacity = 0
    }
    
    func show() {
        isAnimating = true
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: []) {
            self.popView.layer.transform = CATransform3DIdentity
            self.popView.layer.opacity = 1
        } completion: { _ in
            self.isAnimating = false
        }
    }
    
    func close() {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.popView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
            self.popView.layer.opacity = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func ruleAction(_ sender: Any) {
        close()
        delegate?.showRuleView()
    }
    
    @IBAction func jackpotAction(_ sender: Any) {
        close()
        delegate?.showJackpotView()
    }
    
    @IBAction func recordAction(_ sender: Any) {
        close()
        delegate?.showRecordView()
    }
    
    @IBAction func journalAction(_ sender: Any) {
        close()
        delegate?.showJournalView()
    }
}
