//
//  JPMagicCubeSuspendView.swift
//  Neves
//
//  Created by aa on 2021/7/21.
//

class JPMagicCubeSuspendView: UIView, JPMagicCubeBubbleLaunchAble {
    
    var bubbleView: JPMagicCubeBubbleView? = nil
    let isCacheBubble = true
    let horBubbleSpace: CGFloat = -20
    let verBubbleSpace: CGFloat = 5
    var bubbleSafeFrame: CGRect = .zero
    var bubbleSafeMargin: CGFloat { 12 }
    
    var progress: Int = 0 {
        didSet {
            progressLabel.text = "连转中：\(progress)"
        }
    }
    
    var animView: LottieAnimationView? = nil
    
    let progressLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 8)
        lab.textColor = .rgb(145, 209, 255)
        lab.textAlignment = .center
        lab.text = "连转中：0"
        lab.frame = [0, CGFloat(50 - 12), 50, 12]
        lab.layer.backgroundColor = UIColor.rgb(49, 11, 105).cgColor
        lab.layer.cornerRadius = 6
        lab.layer.masksToBounds = true
        return lab
    }()
    
    init() {
        super.init(frame: [0, 0, 50, 50])
        addSubview(progressLabel)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panMe(_:))))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension JPMagicCubeSuspendView {
    static func show(on view: UIView, contentInset: UIEdgeInsets) -> JPMagicCubeSuspendView {
        let suspendView = JPMagicCubeSuspendView()
        suspendView.bubbleSafeFrame = [contentInset.left,
                                       contentInset.top,
                                       view.frame.width - contentInset.left - contentInset.right,
                                       view.frame.height - contentInset.top - contentInset.bottom]
        suspendView.frame.origin.x = view.frame.width - suspendView.frame.width
        suspendView.frame.origin.y = (view.frame.height - suspendView.frame.height) * 0.5
        suspendView.alpha = 0
        view.addSubview(suspendView)
        suspendView.show()
        return suspendView
    }
    
    func show() {
        guard alpha == 0 else { return }
        frame = markSafeFrame(frame, isMoving: false)
        playAnim()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    func hide(andRemove: Bool = false) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.stopAnim()
            if andRemove { self.removeFromSuperview() }
        }
    }
}

private extension JPMagicCubeSuspendView {
    func markSafeFrame(_ frame: CGRect, isMoving: Bool) -> CGRect {
        var targetFrame = frame
        
        let interFrame = isMoving ? bubbleSafeFrame : bubbleSafeFrame.insetBy(dx: bubbleSafeMargin, dy: bubbleSafeMargin)
        
        if targetFrame.origin.x < interFrame.origin.x {
            targetFrame.origin.x = interFrame.origin.x
        } else if targetFrame.maxX > interFrame.maxX {
            targetFrame.origin.x = interFrame.maxX - targetFrame.width
        }
        
        if targetFrame.origin.y < interFrame.origin.y {
            targetFrame.origin.y = interFrame.origin.y
        } else if targetFrame.maxY > interFrame.maxY {
            targetFrame.origin.y = interFrame.maxY - targetFrame.height
        }
        
        return targetFrame
    }
    
    func playAnim() {
        guard self.animView == nil else {
            return
        }
        let animView = LottieAnimationView.jp.build("cube_s_lottie")
        animView.loopMode = .loop
        animView.isUserInteractionEnabled = false
        insertSubview(animView, at: 0)
        animView.snp.makeConstraints { $0.edges.equalToSuperview() }
        animView.layoutIfNeeded()
        animView.play()
        self.animView = animView
    }
    
    func stopAnim() {
        animView?.stop()
        animView?.removeFromSuperview()
        animView = nil
    }
}

extension JPMagicCubeSuspendView {
    @objc func panMe(_ panGR: UIPanGestureRecognizer) {
        guard let superView = self.superview else { return }
        
        let translation = panGR.translation(in: superView)
        panGR.setTranslation(.zero, in: superView)
        
        var frame = self.frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y
        
        switch panGR.state {
        case .began:
            // 隐藏气泡
            bubbleView?.stop()
            
        case .ended, .cancelled, .failed:
            let isToLeft = frame.midX < bubbleSafeFrame.width * 0.5
            frame.origin.x = isToLeft ? bubbleSafeMargin : (bubbleSafeFrame.width - frame.width - bubbleSafeMargin)
            frame = markSafeFrame(frame, isMoving: false)
            
            isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: []) {
                self.frame = frame
            } completion: { _ in
                self.isUserInteractionEnabled = true
            }
            return
            
        default:
            break
        }
        
        self.frame = markSafeFrame(frame, isMoving: true)
    }
    
    @objc func tapMe(_ tapGR: UITapGestureRecognizer) {
        let awardInfo = JPMagicGiftInfo(name: "美少男帅哥平", iconURL: "")
        launchMagicCubeBubble(awardInfo: awardInfo)
    }
}
