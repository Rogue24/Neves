//
//  JPMagicCubeBubbleView.swift
//  Neves
//
//  Created by aa on 2021/7/21.
//

// --- Test ---
//var bubbleCount = 0
// --- Test ---

class JPMagicCubeBubbleView: UIView {
    
    static let bubbleH: CGFloat = 29
    static let boxMargin: CGFloat = 5
    static let boxH: CGFloat = bubbleH - boxMargin
    static let arrMargin: CGFloat = 15
    static let arrSize: CGSize = [10, 5.5]
    
    enum Site {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    private let box = UIView()
    private let leftLabel = UILabel()
    private let iconView = UIImageView()
    private let rightLabel = UILabel()
    
    private let bubbleMaskView = UIView()
    private let boxMaskView = UIView()
    private let arrMaskView = UIImageView(image: UIImage(named: "prompt_bubble_triangle"))
    
    private var launchCompletion: ((JPMagicCubeBubbleView) -> ())? = nil
    
    private(set) var isAnimating: Bool = false
    private var isCancelByMe: Bool = false
    
    init() {
        super.init(frame: [0, 0, 157, JPMagicCubeBubbleView.bubbleH])
        isUserInteractionEnabled = false
        setupUI()
        
        // --- Test ---
//        bubbleCount += 1
//        JPrint("气泡出生了！", bubbleCount)
        // --- Test ---
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // --- Test ---
//    deinit {
//        bubbleCount -= 1
//        JPrint("气泡死掉了！", bubbleCount)
//    }
    // --- Test ---
}

extension JPMagicCubeBubbleView {
    
    @discardableResult
    static func launch(on view: UIView, awardInfo: JPMagicGiftInfo, site: Site, launchPoint: CGPoint, launchCompletion: ((JPMagicCubeBubbleView) -> ())? = nil) -> JPMagicCubeBubbleView {
        let bubble = JPMagicCubeBubbleView()
        view.addSubview(bubble)
        bubble.launch(awardInfo: awardInfo, site: site, launchPoint: launchPoint, launchCompletion: launchCompletion)
        return bubble
    }
    
    func launch(awardInfo: JPMagicGiftInfo, site: Site, launchPoint: CGPoint, launchCompletion: ((JPMagicCubeBubbleView) -> ())? = nil) {
        self.launchCompletion = launchCompletion
        prepareLaunch(awardInfo: awardInfo, site: site, launchPoint: launchPoint)
        startLaunch()
    }
    
    func stop(andRemove: Bool = false) {
        launchCompletion = nil
        if isAnimating {
            isCancelByMe = true
        }
        
        let transform: CATransform3D
        let opacity: Float
        if let presentation = layer.presentation() {
            transform = presentation.transform
            opacity = presentation.opacity
        } else {
            transform = layer.transform
            opacity = layer.opacity
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.removeAllAnimations()
        layer.transform = transform
        layer.opacity = opacity
        CATransaction.commit()
        
        isAnimating = true
        UIView.animate(withDuration: 0.15) {
            self.layer.opacity = 0
        } completion: { finish in
            if finish || !self.isCancelByMe {
                self.isAnimating = false
            }
            self.isCancelByMe = false
            if andRemove { self.removeFromSuperview() }
        }
    }
}

private extension JPMagicCubeBubbleView {
    func prepareLaunch(awardInfo: JPMagicGiftInfo, site: Site, launchPoint: CGPoint) {
        if isAnimating {
            isCancelByMe = true
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.removeAllAnimations()
        layer.transform = CATransform3DIdentity
        updateUI(awardInfo, site)
        
        var anchorPoint: CGPoint = [arrMaskView.frame.midX / bubbleMaskView.bounds.width, 0]
        switch site {
        case .topLeft, .topRight: anchorPoint.y = 1
        default: break
        }
        
        layer.anchorPoint = anchorPoint
        layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        layer.position = launchPoint
        layer.opacity = 0
        
        CATransaction.commit()
    }
    
    func startLaunch() {
        isAnimating = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: []) {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.layer.opacity = 1
        } completion: { finish in
            guard finish else {
                if !self.isCancelByMe {
                    self.isAnimating = false
                    self.launchCompletion?(self)
                    self.launchCompletion = nil
                }
                self.isCancelByMe = false
                return
            }
            UIView.animate(withDuration: 0.3, delay: 2, options: []) {
                self.layer.opacity = 0
            } completion: { finish in
                if finish || !self.isCancelByMe {
                    self.isAnimating = false
                    self.launchCompletion?(self)
                    self.launchCompletion = nil
                }
                self.isCancelByMe = false
            }
        }
    }
}

private extension JPMagicCubeBubbleView {
    func setupUI() {
        backgroundColor = .rgb(41, 30, 70, a: 0.9)
        
        leftLabel.font = .systemFont(ofSize: 11)
        leftLabel.textColor = .white
        leftLabel.text = "在魔方转得"
        leftLabel.sizeToFit()
        leftLabel.frame = [8, 0, leftLabel.frame.width, Self.boxH]
        
        iconView.contentMode = .scaleAspectFill
        iconView.frame = [leftLabel.frame.maxX + 5, HalfDiffValue(Self.boxH, 15), 15, 15]
        
        rightLabel.font = .systemFont(ofSize: 11)
        rightLabel.textColor = .rgb(255, 233, 104)
        
        box.addSubview(leftLabel)
        box.addSubview(iconView)
        box.addSubview(rightLabel)
        addSubview(box)
        
        boxMaskView.backgroundColor = .black
        boxMaskView.layer.cornerRadius = 7
        boxMaskView.layer.masksToBounds = true
        bubbleMaskView.addSubview(boxMaskView)
        bubbleMaskView.addSubview(arrMaskView)
        mask = bubbleMaskView
    }
    
    func updateUI(_ awardInfo: JPMagicGiftInfo, _ site: Site) {
        iconView.kf.setImage(with: URL(string: awardInfo.iconURL), placeholder: UIImage(named: "jp_icon"))
        rightLabel.text = "\(awardInfo.name) x1"
        rightLabel.sizeToFit()
        rightLabel.frame = [iconView.frame.maxX + 5, 0, rightLabel.frame.width, Self.boxH]
        
        var boxFrame: CGRect = [0, 0, rightLabel.frame.maxX + 8, Self.boxH]
        var arrFrame: CGRect = [0, 0, Self.arrSize.width, Self.arrSize.height]
        var arrTrans = CGAffineTransform.identity
        
        switch site {
        case .topLeft:
            boxFrame.origin = .zero
            arrFrame.origin = [Self.arrMargin, Self.bubbleH - Self.arrSize.height]
            
        case .topRight:
            boxFrame.origin = .zero
            arrFrame.origin = [boxFrame.width - Self.arrSize.width - Self.arrMargin, Self.bubbleH - Self.arrSize.height]
            
        case .bottomLeft:
            boxFrame.origin.y = Self.boxMargin
            arrFrame.origin.x = Self.arrMargin
            arrTrans = CGAffineTransform(rotationAngle: CGFloat.pi)
            
        case .bottomRight:
            boxFrame.origin.y = Self.boxMargin
            arrFrame.origin.x = boxFrame.width - Self.arrSize.width - Self.arrMargin
            arrTrans = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        box.frame = boxFrame
        boxMaskView.frame = boxFrame
        arrMaskView.transform = arrTrans
        arrMaskView.frame = arrFrame
        
        frame.size = [boxFrame.width, Self.bubbleH]
        bubbleMaskView.frame = .init(origin: .zero, size: frame.size)
    }
}
