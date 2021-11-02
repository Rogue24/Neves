//
//  MagicCubeSuspendView.swift
//  Neves
//
//  Created by aa on 2021/7/15.
//

class MagicCubeSuspendView: UIView {
    
    var safeFrame: CGRect = .zero
    var safeMargin: CGFloat = 12
    
    var horBubbleSpace: CGFloat = -20
    var verBubbleSpace: CGFloat = 5
    
    private(set) var site: MagicCubeBubbleView.Site = .topLeft
    
    private var launchPoint: CGPoint {
        switch site {
        case .topLeft:
            return [-horBubbleSpace, -verBubbleSpace]
        case .topRight:
            return [frame.width + horBubbleSpace, -verBubbleSpace]
        case .bottomLeft:
            return [-horBubbleSpace, frame.height + verBubbleSpace]
        case .bottomRight:
            return [frame.width + horBubbleSpace, frame.height + verBubbleSpace]
        }
    }
    
    var bubbleView: MagicCubeBubbleView? = nil {
        didSet {
            guard let oldBubbleView = oldValue else { return }
            oldBubbleView.stop(andRemove: true)
        }
    }
    
    init() {
        super.init(frame: [0, 0, 50, 50])
        backgroundColor = .randomColor
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panMe(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MagicCubeSuspendView {
    static func show(on view: UIView, contentInset: UIEdgeInsets) -> MagicCubeSuspendView {
        let suspendView = MagicCubeSuspendView()
        suspendView.safeFrame = [contentInset.left,
                                 contentInset.top,
                                 view.width - contentInset.left - contentInset.right,
                                 view.height - contentInset.top - contentInset.bottom]
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
        updateSite()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    func hide(andRemove: Bool = false) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { finish in
            if finish, andRemove { self.removeFromSuperview() }
        }
    }
}

private extension MagicCubeSuspendView {
    func markSafeFrame(_ frame: CGRect, isMoving: Bool) -> CGRect {
        var f = frame
        
        let interFrame = isMoving ? safeFrame : safeFrame.insetBy(dx: safeMargin, dy: safeMargin)
        
        if f.origin.x < interFrame.origin.x {
            f.origin.x = interFrame.origin.x
        } else if f.maxX > interFrame.maxX {
            f.origin.x = interFrame.maxX - f.width
        }
        
        if f.origin.y < interFrame.origin.y {
            f.origin.y = interFrame.origin.y
        } else if f.maxY > interFrame.maxY {
            f.origin.y = interFrame.maxY - f.height
        }
        
        return f
    }
    
    func updateSite() {
        let isToLeft = frame.midX < safeFrame.width * 0.5
        
        var isToTop = true
        let minY = frame.origin.y - MagicCubeBubbleView.bubbleH - verBubbleSpace
        if minY < safeFrame.origin.y {
            isToTop = false
        }
        
        switch (isToLeft, isToTop) {
        case (true, true):
            site = .topLeft
        case (false, true):
            site = .topRight
        case (false, false):
            site = .bottomRight
        case (true, false):
            site = .bottomLeft
        }
        
        bubbleView?.site = site
    }
}

extension MagicCubeSuspendView {
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
            let isToLeft = frame.midX < safeFrame.width * 0.5
            frame.origin.x = isToLeft ? safeMargin : (safeFrame.width - frame.width - safeMargin)
            frame = markSafeFrame(frame, isMoving: false)
            
            isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: []) {
                self.frame = frame
            } completion: { _ in
                self.updateSite()
                self.isUserInteractionEnabled = true
            }
            return
            
        default:
            break
        }
        
        self.frame = markSafeFrame(frame, isMoving: true)
    }
    
    @objc func tapMe(_ tapGR: UITapGestureRecognizer) {
        if let bubbleView = self.bubbleView, !bubbleView.isAnimating {
            bubbleView.launch(launchPoint)
        } else {
            bubbleView = MagicCubeBubbleView.launch(on: self, site: site, launchPoint: launchPoint)
        }
    }
}
