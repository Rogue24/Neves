//
//  MagicCubeBubbleView.swift
//  Neves
//
//  Created by aa on 2021/7/15.
//

var bubbleCount = 0

class MagicCubeBubbleView: UIView {
    
    static let bubbleH: CGFloat = 29
    
    enum Site {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    private let boxMargin: CGFloat = 5
    private let arrMargin: CGFloat = 15
    private let arrSize: CGSize = [10, 5.5]
    
    private let bubbleMaskView = UIView()
    private let boxMaskView = UIView()
    private let arrMaskView = UIImageView(image: UIImage(named: "prompt_bubble_triangle"))
    
    private var _site: Site = .bottomRight
    var site: Site {
        get { _site }
        set {
            guard _site != newValue else { return }
            _site = newValue
            updateMaskView()
        }
    }
    
    private(set) var isAnimating: Bool = false
    
    init() {
        super.init(frame: [0, 0, 157, MagicCubeBubbleView.bubbleH])
        isUserInteractionEnabled = false
        backgroundColor = .randomColor
        setupMaskView()
        
        bubbleCount += 1
        JPrint("气泡出生了！", bubbleCount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        bubbleCount -= 1
        JPrint("气泡死掉了！", bubbleCount)
    }
    
    @discardableResult
    static func launch(on view: UIView, site: Site, launchPoint: CGPoint) -> MagicCubeBubbleView {
        let bubble = MagicCubeBubbleView()
        view.addSubview(bubble)
        bubble.prepareLaunch(site: site, launchPoint: launchPoint)
        bubble.launch()
        return bubble
    }
    
    func launch(_ launchPoint: CGPoint) {
        prepareLaunch(site: site, launchPoint: launchPoint)
        launch()
    }
    
    func stop(andRemove: Bool = false) {
        isAnimating = false
        layer.removeAllAnimations()
        isAnimating = true
        UIView.animate(withDuration: 0.15) {
            self.layer.opacity = 0
        } completion: { finish in
            if finish { self.isAnimating = false }
            if andRemove { self.removeFromSuperview() }
        }
    }
}

private extension MagicCubeBubbleView {
    func prepareLaunch(site: Site, launchPoint: CGPoint) {
        JPrint("中断前")
        isAnimating = false
        layer.removeAllAnimations()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.site = site
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
        
        JPrint("中断后")
    }
    
    func launch() {
        JPrint("开始新动画")
        isAnimating = true
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.5, options: []) {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.layer.opacity = 1
        } completion: { finish in
            guard finish else {
                JPrint("被中断了1 ---", self.isAnimating)
                return
            }
            UIView.animate(withDuration: 0.3, delay: 2, options: []) {
                self.layer.opacity = 0
            } completion: { finish in
                if finish { self.isAnimating = false } else {
                    JPrint("被中断了2 ---", self.isAnimating)
                }
            }
        }
    }
}

private extension MagicCubeBubbleView {
    func setupMaskView() {
        boxMaskView.backgroundColor = .black
        boxMaskView.layer.cornerRadius = 7
        boxMaskView.layer.masksToBounds = true
        bubbleMaskView.addSubview(boxMaskView)
        bubbleMaskView.addSubview(arrMaskView)
        updateMaskView()
        mask = bubbleMaskView
    }
    
    func updateMaskView() {
        bubbleMaskView.frame = bounds
        
        var boxFrame: CGRect = [0, 0, bounds.width, bounds.height - boxMargin]
        var arrFrame: CGRect = [0, 0, arrSize.width, arrSize.height]
        var arrTrans = CGAffineTransform.identity
        
        switch site {
        case .topLeft:
            boxFrame.origin = .zero
            arrFrame.origin = [arrMargin, bounds.height - arrSize.height]
            
        case .topRight:
            boxFrame.origin = .zero
            arrFrame.origin = [bounds.width - arrSize.width - arrMargin, bounds.height - arrSize.height]
            
        case .bottomLeft:
            boxFrame.origin.y = boxMargin
            arrFrame.origin.x = arrMargin
            arrTrans = CGAffineTransform(rotationAngle: CGFloat.pi)
            
        case .bottomRight:
            boxFrame.origin.y = boxMargin
            arrFrame.origin.x = bounds.width - arrSize.width - arrMargin
            arrTrans = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        boxMaskView.frame = boxFrame
        arrMaskView.transform = arrTrans
        arrMaskView.frame = arrFrame
    }
}
