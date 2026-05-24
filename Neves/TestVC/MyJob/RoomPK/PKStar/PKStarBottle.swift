//
//  PKStarBottle.swift
//  Neves
//
//  Created by aa on 2022/4/29.
//

import UIKit
import Lottie

protocol PKStarTerminal: UIView {
    var starCenter: CGPoint { get }
}

class PKStarBottle: UIView {
    /// 视图基本尺寸
    static var size: CGSize { [50, 50] }
    /// 可显示的最大星星数
    static var appearMaxStarCount: Int { 6 }
    
    /// 当前星星数
    private(set) var starCount: Int = 0
    /// 是否已激活
    private(set) var isActivated: Bool = false
    /// 是否正在发射星星
    private(set) var isLaunching: Bool = false {
        didSet { launchReset() }
    }
    
    private var replicatorLayer: CAReplicatorLayer?
    private var delayWorkItem: DispatchWorkItem?
    
    private let updateDuration: TimeInterval = 0.12
    private let appearDuration: TimeInterval = 0.12
    private let disappearDuration: TimeInterval = 0.12
    private let launchDuration: TimeInterval = 0.58
    private let intervalDuration: TimeInterval = 0.3
    
    private let bottleImgView = UIImageView(image: UIImage(named: "pk_star_emptybottle_grey"))
    private let starBgView = UIView()
    private let starImgViews = Array(1...PKStarBottle.appearMaxStarCount).map { UIImageView(image: UIImage(named: "pk_star_grey\($0)")) }
    private let starCountLabel: UILabel = {
        let label =  UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.text = "0"
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(bottleImgView)
        bottleImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(starBgView)
        starBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        starImgViews.forEach {
            $0.alpha = 0
            starBgView.addSubview($0)
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

// MARK: - API
extension PKStarBottle {
    /// 刷新星星数
    /// - Parameters:
    ///   - count: 星星数量
    ///   - isActivate: 是否激活
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
    
    /// 发射星星
    /// - Parameters:
    ///   - view: 发射平台view（房间view）
    ///   - terminal: 终点view
    func launchStar(on view: UIView, to terminal: PKStarTerminal) {
        guard !isLaunching, starCount > 0 else { return }
        isLaunching = true
        
        let count = starCount > Self.appearMaxStarCount ? Self.appearMaxStarCount : starCount
        let maxIndex = count - 1
        
        launchStar(on: view, to: terminal, count: count)
        eachToHideBottleStar(at: maxIndex)
    }
}

// MARK: - UI刷新
private extension PKStarBottle {
    /// 刷新星星数
    /// - Parameters:
    ///   - isDidChangedState: 激活状态是否发生了变化
    func updateStarCountLabel(_ isDidChangedState: Bool) {
        starCountLabel.text = "\(starCount)"
        guard isDidChangedState else { return }
        let textColor = isActivated ? UIColor.rgb(255, 233, 104) : UIColor(white: 1, alpha: 0.8)
        UIView.transition(with: starCountLabel, duration: updateDuration, options: .transitionCrossDissolve) {
            self.starCountLabel.textColor = textColor
        } completion: { _ in }
    }
    
    /// 刷新瓶子
    /// - Parameters:
    ///   - isDidChangedState: 激活状态是否发生了变化
    func updateBottleImgView(_ isDidChangedState: Bool) {
        guard isDidChangedState else { return }
        let imgName = isActivated ? "pk_star_emptybottle_active" : "pk_star_emptybottle_grey"
        UIView.transition(with: bottleImgView, duration: updateDuration, options: .transitionCrossDissolve) {
            self.bottleImgView.image = UIImage(named: imgName)
        } completion: { _ in }
    }
    
    /// 刷新瓶子内的星星
    /// - Parameters:
    ///   - isDidChangedState: 激活状态是否发生了变化
    func updateStarImgViews(_ isDidChangedState: Bool) {
        UIView.transition(with: starBgView, duration: updateDuration, options: .transitionCrossDissolve) {
            for (i, starImgView) in self.starImgViews.enumerated() {
                if isDidChangedState {
                    let imgName = self.isActivated ? "pk_star_active\(i + 1)" : "pk_star_grey\(i + 1)"
                    starImgView.image = UIImage(named: imgName)
                }
                let alpha: CGFloat = i < self.starCount ? 1 : 0
                starImgView.alpha = alpha
            }
        } completion: { _ in }
    }
    
    /// 播放激活动画
    func playActivateAnim() {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_star_activation_lottie"),
              let animation = LottieAnimation.filepath(filepath, animationCache: DefaultAnimationCache.sharedCache)
        else { return }
        
        let animView = LottieAnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
        animView.backgroundBehavior = .pauseAndRestore
        animView.contentMode = .scaleToFill
        animView.loopMode = .playOnce
        animView.isUserInteractionEnabled = false
        
        starBgView.addSubview(animView)
        animView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(-20)
        }
        starBgView.layoutIfNeeded()
        
        animView.play { [weak animView] _ in
            animView?.removeFromSuperview()
        }
    }
}
 
// MARK: - ⭐️动画
private extension PKStarBottle {
    /// 发射星星
    /// - Parameters:
    ///   - view: 发射平台view（房间view）
    ///   - terminal: 终点view
    ///   - count: 发射次数
    func launchStar(on view: UIView, to terminal: PKStarTerminal, count: Int) {
        guard isLaunching, count > 0 else { return }
        
        var origin = convert(bounds, to: view).origin
        origin.x += width * 0.5
        origin.y += 5.5
        
        var target = terminal.convert(terminal.bounds, to: view).origin
        target.x += terminal.starCenter.x
        target.y += terminal.starCenter.y
        
        var control: CGPoint = [origin.x, target.y]
        control.x += (target.x - origin.x) * 0.6
        control.y -= 70.px
        
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

        let showAnim = Self.createOpacityAnimation(1, duration: appearDuration)
        showAnim.beginTime = CACurrentMediaTime()
        imgView.layer.add(showAnim, forKey: "show")
        
        let pathAnim = Self.createPathAnimation(from: origin, to: target, controlPoint: control, duration: launchDuration)
        pathAnim.beginTime = CACurrentMediaTime() + appearDuration
        imgView.layer.add(pathAnim, forKey: "flying")
        
        let hideAnim = Self.createOpacityAnimation(0, duration: disappearDuration)
        hideAnim.beginTime = CACurrentMediaTime() + appearDuration + launchDuration
        imgView.layer.add(hideAnim, forKey: "hide")
    }
    
    /// 逐个隐藏瓶子内的星星
    /// - Parameters:
    ///   - index: 星星图片下标
    func eachToHideBottleStar(at index: Int) {
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

        if index > 0 {
            let nextIndex = index - 1
            delayWorkItem = Asyncs.mainDelay(intervalDuration) {
                self.eachToHideBottleStar(at: nextIndex)
            }
        }
    }
    
    /// 发射重置（全部完成 or 中途取消）
    func launchReset() {
        delayWorkItem?.cancel()
        delayWorkItem = nil
        
        replicatorLayer?.removeFromSuperlayer()
        replicatorLayer = nil
    }
}

// MARK: - 动画🏭
private extension PKStarBottle {
    /// 创建发射路径动画
    /// - Parameters:
    ///   - from: 发射点
    ///   - to: 终点
    ///   - controlPoint: 控制弯曲点
    ///   - duration: 动画时长
    /// - Returns: 帧动画 CAKeyframeAnimation
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
    
    /// 创建不透明度动画
    /// - Parameters:
    ///   - opacity: 不透明度
    ///   - duration: 动画时长
    /// - Returns: 基本动画 CABasicAnimation
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
