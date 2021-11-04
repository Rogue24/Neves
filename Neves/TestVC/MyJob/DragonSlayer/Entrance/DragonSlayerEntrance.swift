//
//  DragonSlayerEntrance.swift
//  Neves
//
//  Created by aa on 2021/11/4.
//

import UIKit

class DragonSlayerEntrance: UIView {
    static let size: CGSize = [75, 105]
    static let infoFrame: CGRect = [0, 33, 75, 72]
    
    let safeFrame: CGRect
    
    var task: DragonSlayer.Task {
        set {
            UIView.transition(with: contentView, duration: 0.17, options: .transitionCrossDissolve) {
                self.contentView.task = newValue
            } completion: { _ in }
        }
        get { contentView.task }
    }
    
    var prepareSecond = 0
    var fightSecond = 0
    
    enum Site {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    let bubbleSpace: CGFloat = 5
    let bubbleStayDuration: TimeInterval = 3
    var bubbles: [Bubble] = []
    var site: Site = .bottomRight {
        didSet {
            guard site != oldValue, bubbles.count > 0 else { return }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: []) {
                self.updateBubbles()
            } completion: { _ in }
        }
    }
    
    let bgAnimView = AnimationView.jp.build("dragon_enter_lottie_1")
    let contentView = ContentView()
    weak var countingDownView: CountingDownView? = nil
    
    init(safeFrame: CGRect) {
        self.safeFrame = safeFrame
        super.init(frame: CGRect(origin: .zero, size: DragonSlayerEntrance.size))
        
        bgAnimView.isUserInteractionEnabled = false
        bgAnimView.loopMode = .loop
        bgAnimView.frame = bounds
        addSubview(bgAnimView)
        bgAnimView.play()
        
        addSubview(contentView)
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panMe(_:))))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("死得好")
        bubbles.forEach { $0.removeAction?.cancel() }
    }
}

extension DragonSlayerEntrance {
    static func build(on view: UIView, superviewFrame: CGRect) -> DragonSlayerEntrance {
        let entrance = DragonSlayerEntrance(safeFrame: [10, NavTopMargin,
                                                        superviewFrame.width - 10 - 10,
                                                        superviewFrame.height - NavTopMargin - 42 - DiffTabBarH])
        entrance.frame.origin.x = superviewFrame.width - entrance.frame.width - 72
        entrance.frame.origin.y = superviewFrame.height - entrance.frame.height - 57 - DiffTabBarH
        view.addSubview(entrance)
        return entrance
    }
    
    func show() {
        guard alpha == 0 else { return }
        playAnim()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.stopAnim()
        }
    }
}

private extension DragonSlayerEntrance {
    func playAnim() {
//        guard self.animView == nil else {
//            return
//        }
//        let animView = AnimationView.jp.build("cube_s_lottie")
//        animView.loopMode = .loop
//        animView.isUserInteractionEnabled = false
//        insertSubview(animView, at: 0)
//        animView.snp.makeConstraints { $0.edges.equalToSuperview() }
//        animView.layoutIfNeeded()
//        animView.play()
//        self.animView = animView
    }
    
    func stopAnim() {
//        animView?.stop()
//        animView?.removeFromSuperview()
//        animView = nil
    }
}

private extension DragonSlayerEntrance {
    @objc func tapMe(_ tapGR: UITapGestureRecognizer) {
        launchBubble()
    }
    
    @objc func panMe(_ panGR: UIPanGestureRecognizer) {
        guard let superView = self.superview else { return }
        
        let translation = panGR.translation(in: superView)
        panGR.setTranslation(.zero, in: superView)
        
        var frame = self.frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y
        
        markSafeFrame(frame)
        markSite()
    }
}
    
private extension DragonSlayerEntrance {
    func markSafeFrame(_ frame: CGRect) {
        var targetFrame = frame
        
        if targetFrame.origin.x < safeFrame.origin.x {
            targetFrame.origin.x = safeFrame.origin.x
        } else if targetFrame.maxX > safeFrame.maxX {
            targetFrame.origin.x = safeFrame.maxX - targetFrame.width
        }
        
        if targetFrame.origin.y < safeFrame.origin.y {
            targetFrame.origin.y = safeFrame.origin.y
        } else if targetFrame.maxY > safeFrame.maxY {
            targetFrame.origin.y = safeFrame.maxY - targetFrame.height
        }
        
        self.frame = targetFrame
    }
    
    func markSite() {
        let judgeX = safeFrame.midX - Self.size.width * 0.5
        let judgeY = safeFrame.origin.y + Bubble.size.height + bubbleSpace
        
        let isTop = frame.origin.y < judgeY
        let isLeft = frame.origin.x < judgeX
        
        switch (isTop, isLeft) {
        case (true, true):
            site = .topLeft
        case (true, false):
            site = .topRight
        case (false, true):
            site = .bottomLeft
        case (false, false):
            site = .bottomRight
        }
    }
}


