//
//  FunFloatButton.swift
//  Neves
//
//  Created by aa on 2021/11/2.
//

class FunFloatButton: UIButton {
    static let shared = FunFloatButton()
    
    private let bgView: UIView = UIView()
    private let emojiLabel: UILabel = UILabel()
    private lazy var impactFeedbacker: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    var safeFrame: CGRect = .zero
    var safeMargin: CGFloat = 12
    
    var tapMeAction: (() -> ())?
    
    private var _isTouching: Bool = false
    private(set) var isTouching: Bool {
        set {
            if _isTouching == newValue { return }
            _isTouching = newValue
            if newValue {
                emojiLabel.text = "😝"
                impactFeedbacker.prepare()
                impactFeedbacker.impactOccurred()
                UIView.animate(withDuration: 0.28, animations: {
                    self.bgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.emojiLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                })
            } else {
                emojiLabel.text = "😛"
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: {
                    self.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.emojiLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
                }, completion: nil)
            }
        }
        get { _isTouching }
    }
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: [55.px, 55.px]))
        _setupUI()
        _setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {}
    }
    
    override func didMoveToSuperview() {
        guard let superview = superview, let window = superview.window else { return }
        safeFrame = [window.safeAreaInsets.left,
                     window.safeAreaInsets.top,
                     superview.frame.width - window.safeAreaInsets.left - window.safeAreaInsets.right,
                     superview.frame.height - window.safeAreaInsets.top - window.safeAreaInsets.bottom]
        frame = markSafeFrame(frame, isMoving: false)
    }
}

private extension FunFloatButton {
    func _setupUI() {
        bgView.frame = bounds
        bgView.layer.cornerRadius = bounds.height * 0.5
        bgView.layer.borderWidth = 0
        bgView.backgroundColor = .randomColor
        bgView.isUserInteractionEnabled = false
        addSubview(bgView)
        
        emojiLabel.text = "😛"
        emojiLabel.font = .systemFont(ofSize: bounds.height * 0.8)
        emojiLabel.textAlignment = .center
        emojiLabel.frame = bounds
        addSubview(emojiLabel)
        emojiLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
    }
    
    func _setupAction() {
        addTarget(self, action: #selector(_beginTouch), for: .touchDown)
        addTarget(self, action: #selector(_beginTouch), for: .touchDragInside)
        addTarget(self, action: #selector(_endTouch), for: .touchDragOutside)
        addTarget(self, action: #selector(_endTouch), for: .touchUpOutside)
        addTarget(self, action: #selector(_endTouch), for: .touchCancel)
        addTarget(self, action: #selector(_touchUpInside), for: .touchUpInside)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panMe(_:))))
    }
}

private extension FunFloatButton {
    @objc func _beginTouch() {
        isTouching = true
    }
    
    @objc func _endTouch() {
        isTouching = false
    }
    
    @objc func _touchUpInside() {
        isTouching = false
        tapMeAction?()
    }
    
    @objc func panMe(_ panGR: UIPanGestureRecognizer) {
        guard let superView = self.superview else { return }
        isTouching = false
        
        let translation = panGR.translation(in: superView)
        panGR.setTranslation(.zero, in: superView)
        
        var frame = self.frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y
        
        switch panGR.state {
        case .ended, .cancelled, .failed:
            let isToLeft = frame.midX < safeFrame.width * 0.5
            frame.origin.x = isToLeft ? safeMargin : (safeFrame.width - frame.width - safeMargin)
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
}

private extension FunFloatButton {
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
}
