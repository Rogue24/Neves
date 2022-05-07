//
//  PKChallengePopView.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

import UIKit

class PKChallengePopView: FloatContainer {
    let foldView = UIView()
    let challengeView = PKChallengeView.loadFromNib()
    
    init() {
        super.init(frame: .zero)
        setupFoldView()
        setupChallengeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("PKChallengePopView 死不瞑目")
    }
}

private extension PKChallengePopView {
    func setupFoldView() {
        addSubview(foldView)
        foldView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        foldView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(foldViewDidClick)))
    }
    
    @objc func foldViewDidClick() {
        challengeView.isFolded = true
    }
    
    func setupChallengeView() {
        challengeView.foldStateDidChangeHandler = { [weak self] isFolded in
            self?.foldView.isUserInteractionEnabled = !isFolded
        }
        
        challengeView.closeHandler = { [weak self] in
            self?.removeFromSuperview()
        }
        
        addSubview(challengeView)
        challengeView.setupLayout()
    }
}

extension PKChallengePopView {
    @discardableResult
    static func show(on superview: UIView) -> PKChallengePopView {
        let popView = PKChallengePopView()
        
        superview.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        superview.layoutIfNeeded()
        
        popView.show()
        return popView
    }
    
    private func show() {
        challengeView.show()
    }
    
    func close() {
        challengeView.close()
    }
}
