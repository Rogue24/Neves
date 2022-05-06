//
//  PKStarBottle.swift
//  Neves
//
//  Created by aa on 2022/4/29.
//

import UIKit

protocol PKStarContainer: UIView {
    var starCenter: CGPoint { get }
}

class PKStarBottle: UIView {
    static var size: CGSize { [50, 50] }
    
    private let bottleImgView = UIImageView(image: UIImage(named: "pk_star_emptybottle_grey"))
    private let starImgViews = Array(1...6).map { UIImageView(image: UIImage(named: "pk_star_grey\($0)")) }
    private let starCountLabel: UILabel = {
        let label =  UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.text = "0"
        return label
    }()
    
    private(set) var starCount: Int = 0
    private(set) var isActivated: Bool = false
    private(set) var isLaunching: Bool = false {
        didSet {
            delayWorkItem?.cancel()
            delayWorkItem = nil
            
            replicatorLayer?.removeFromSuperlayer()
            replicatorLayer = nil
        }
    }
    
    private var replicatorLayer: CAReplicatorLayer?
    private var delayWorkItem: DispatchWorkItem?
    
    private let updateDuration: TimeInterval = 0.12
    private let appearDuration: TimeInterval = 0.12
    private let disappearDuration: TimeInterval = 0.12
    private let launchDuration: TimeInterval = 0.58
    private let intervalDuration: TimeInterval = 0.3
    
    init() {
        super.init(frame: .zero)
        
        addSubview(bottleImgView)
        bottleImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        starImgViews.forEach {
            $0.alpha = 0
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        addSubview(starCountLabel)
        starCountLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        delayWorkItem?.cancel()
        replicatorLayer?.removeFromSuperlayer()
    }
}

extension PKStarBottle {
    func updateStar(count: Int, isActivate: Bool) {
        isLaunching = false
        starCount = count
        
        let isDidChangedState = isActivated != isActivate
        isActivated = isActivate
        
        updateBottleImgView(isDidChangedState)
        updateStarImgViews(isDidChangedState)
        updateStarCountLabel(isDidChangedState)
        
        if isDidChangedState, isActivated {
            playActivateAnim()
        }
    }
    
    func launchStar(on view: UIView, to terminal: PKStarContainer) {
        guard !isLaunching, starCount > 0 else { return }
        isLaunching = true
        
        let count = starCount > 6 ? 6 : starCount
        let maxIndex = count - 1
        
        launchStar(on: view, to: terminal, count: count)
        tryHideStar(at: maxIndex)
    }
}

private extension PKStarBottle {
    func updateStarCountLabel(_ isDidChangedState: Bool) {
        starCountLabel.text = "\(starCount)"
        guard isDidChangedState else { return }
        let textColor = isActivated ? UIColor.rgb(255, 233, 104) : UIColor(white: 1, alpha: 0.8)
        UIView.transition(with: starCountLabel, duration: updateDuration, options: .transitionCrossDissolve) {
            self.starCountLabel.textColor = textColor
        } completion: { _ in }
    }
    
    func updateBottleImgView(_ isDidChangedState: Bool) {
        guard isDidChangedState else { return }
        let imgName = isActivated ? "pk_star_emptybottle_active" : "pk_star_emptybottle_grey"
        UIView.transition(with: bottleImgView, duration: updateDuration, options: .transitionCrossDissolve) {
            self.bottleImgView.image = UIImage(named: imgName)
        } completion: { _ in }
    }
    
    func updateStarImgViews(_ isDidChangedState: Bool) {
        for (i, starImgView) in starImgViews.enumerated() {
            let alpha: CGFloat = i < starCount ? 1 : 0
            if isDidChangedState {
                let imgName = isActivated ? "pk_star_active\(i + 1)" : "pk_star_grey\(i + 1)"
                UIView.transition(with: starImgView, duration: updateDuration, options: .transitionCrossDissolve) {
                    starImgView.image = UIImage(named: imgName)
                    starImgView.alpha = alpha
                } completion: { _ in }
            } else {
                UIView.animate(withDuration: updateDuration) {
                    starImgView.alpha = alpha
                }
            }
        }
    }
    
    func playActivateAnim() {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_star_activation_lottie"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else { return }
        
        let animView = AnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
        animView.backgroundBehavior = .pauseAndRestore
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .playOnce
        animView.isUserInteractionEnabled = false
        
        addSubview(animView)
        animView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        layoutIfNeeded()
        
        animView.play { [weak animView] _ in
            animView?.removeFromSuperview()
        }
    }
}
 
private extension PKStarBottle {
    func launchStar(on view: UIView, to terminal: PKStarContainer, count: Int) {
        guard isLaunching, count > 0 else { return }
        
        var origin = convert(bounds, to: view).origin
        origin.x += width * 0.5
        origin.y += 5.5
        
        var target = terminal.convert(terminal.bounds, to: view).origin
        target.x += terminal.starCenter.x
        target.y += terminal.starCenter.y
        
        var control: CGPoint = [origin.x, target.y]
        control.x += (target.x - origin.x) * 0.6
        control.y -= 70
        
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = view.bounds
        view.layer.addSublayer(replicatorLayer)
        self.replicatorLayer = replicatorLayer

        let imgView = UIImageView(image: UIImage(named: "pk_flyingstar"))
        imgView.layer.frame = [0, 0, 11, 11]
        imgView.layer.position = origin
        imgView.layer.opacity = 0
        replicatorLayer.addSublayer(imgView.layer)
        
        replicatorLayer.instanceCount = count
        replicatorLayer.instanceDelay = intervalDuration

        let opacAnim = Self.createOpacityAnimation(1, duration: appearDuration)
        imgView.layer.add(opacAnim, forKey: "opacity")
        
        let pathAnim = Self.createPathAnimation(from: origin, to: target, controlPoint: control, duration: launchDuration)
        pathAnim.beginTime = CACurrentMediaTime() + appearDuration
        imgView.layer.add(pathAnim, forKey: "position")
    }
    
    func tryHideStar(at index: Int) {
        guard isLaunching, index >= 0 else { return }
        
        let starImgView = starImgViews[index]
        UIView.animate(withDuration: disappearDuration) {
            starImgView.alpha = 0
        } completion: { _ in
            guard index == 0 else { return }
            self.delayWorkItem = Asyncs.mainDelay(self.intervalDuration) {
                self.updateStar(count: 0, isActivate: false)
            }
        }

        guard index > 0 else { return }
        let nextIndex = index - 1
        delayWorkItem = Asyncs.mainDelay(intervalDuration) {
            self.tryHideStar(at: nextIndex)
        }
    }
}

private extension PKStarBottle {
    static func createPathAnimation(from: CGPoint, to: CGPoint, controlPoint: CGPoint, duration: TimeInterval) -> CAKeyframeAnimation {
        let path = UIBezierPath()
        path.move(to: from)
        path.addQuadCurve(to: to, controlPoint: controlPoint)
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.cgPath
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.duration = duration
        return anim
    }
    
    static func createOpacityAnimation(_ opacity: CGFloat, duration: TimeInterval) -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.toValue = opacity
        anim.duration = duration
        return anim
    }
}
