//
//  CosmicExplorationPopViewCompatible.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

import UIKit

protocol CosmicExplorationPopViewCompatible: UIView {
    static func build() -> Self
    
    var viewHeight: CGFloat { get }
    
    func setupLayout(_ superView: UIView)
    
    func show()
    func initializeLayoutBeforeShow()
    func showing()
    
    func reloadData()
    
    func close()
    func setupLayoutBeforeClose()
    func closing()
}

extension CosmicExplorationPopViewCompatible {
    static func build() -> Self {
        Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.first as! Self
    }
    
    // MARK: - 创建+弹出
    @discardableResult
    static func show(on superView: UIView) -> Self {
        let popView = build()
        popView.setupLayout(superView)
        popView.show()
        return popView
    }
    
    var viewHeight: CGFloat { 500.px }
    
    func show() {
        initializeLayoutBeforeShow()
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.showing()
        }, completion: nil)
        reloadData()
    }
    
    func close() {
        setupLayoutBeforeClose()
        UIView.animate(withDuration: 0.3) {
            self.closing()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    func setupLayout(_ superView: UIView) {
        superView.addSubview(self)
        self.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(viewHeight)
            $0.bottom.equalToSuperview().offset(viewHeight)
        }
        superView.layoutIfNeeded()
    }
    
    func initializeLayoutBeforeShow() {
        self.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
    
    func showing() {
        superview?.layoutIfNeeded()
    }
    
    func setupLayoutBeforeClose() {
        self.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(viewHeight)
        }
    }
    
    func closing() {
        superview?.layoutIfNeeded()
    }
}

