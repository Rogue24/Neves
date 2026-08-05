//
//  LottieShowViewController.swift
//  Neves
//
//  Created by aa on 2021/9/6.
//

import UIKit
import Lottie

class LottieShowViewController: TestBaseViewController {
    lazy var animView: LottieAnimationView = {
        let animView = LottieAnimationView()
        animView.backgroundColor = .black
        animView.frame = [HalfDiffValue(PortraitScreenWidth, 300), NavTopMargin + 20, 300, 300]
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop
        view.addSubview(animView)
        return animView
    }()
    
    lazy var placeholderView: UIImageView = {
        let imgView = UIImageView()
        imgView.frame = [HalfDiffValue(PortraitScreenWidth, 300), animView.jp_maxY + 65, 300, 300]
        imgView.backgroundColor = .black
        view.addSubview(imgView)
        return imgView
    }()
    
    lazy var slider: UISlider = {
        let s = UISlider(frame: [30, placeholderView.jp_maxY + 15, PortraitScreenWidth - 60, 20])
        s.addTarget(self, action: #selector(sliderDidChanged(_:)), for: .valueChanged)
        view.addSubview(s)
        return s
    }()
    
    var baseLottieLayer: MainThreadAnimationLayer?
    var dotLottieLayer: LottieAnimationLayer?
    
    lazy var imageMakerQueue: DispatchQueue = DispatchQueue(label: "ImageMaker.SerialQueue")
    var makerItem: DispatchWorkItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let s: CGFloat = 5
        let x: CGFloat = 15
        let y = animView.maxY + 10
        let w = (PortraitScreenWidth - 2 * x - 3 * s) / 4
        let h: CGFloat = 20
        (0 ..< 8).forEach {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .systemFont(ofSize: 15)
            btn.setTitle("动画\($0 + 1)", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            let col = $0 % 4
            let row = $0 / 4
            btn.frame = [x + CGFloat(col) * (w + s), y + CGFloat(row) * (h + s), w, h]
            btn.addTarget(self, action: #selector(changeAnim(_:)), for: .touchUpInside)
            btn.tag = $0
            view.addSubview(btn)
        }
        
        setupBaseLottie("gxq_rk_shitu_zhiyou")
    }
    
    deinit {
        makerItem?.cancel()
        makerItem = nil
    }
}

extension LottieShowViewController {
    @objc func changeAnim(_ btn: UIButton) {
        animView.stop()
        makerItem?.cancel()
        baseLottieLayer = nil
        dotLottieLayer = nil
        placeholderView.image = nil
        
        let lottieName: String
        switch btn.tag {
        case 0:
//            lottieName = "s_smelt_open2_lottie" // BaseLottie
            lottieName = "theming" // DotLottie
        case 1:
//            lottieName = "smelt_flash_lottie" // BaseLottie
            lottieName = "clipped-traffic-lights" // DotLottie
        case 2:
//            lottieName = "smelt_open1_lottie" // BaseLottie
            lottieName = "multiple_animations" // DotLottie
        case 3:
//            lottieName = "smelt_open2_lottie" // BaseLottie
            lottieName = "pigeon" // DotLottie
        case 4:
//            lottieName = "smelt_popup_lottie" // BaseLottie
            lottieName = "LTR_D3" // DotLottie
        case 5:
//            lottieName = "smelt_selected_lottie" // BaseLottie
            lottieName = "pr_2271" // DotLottie
        case 6:
//            lottieName = "room_renewguard01_lottie" // BaseLottie
            lottieName = "svip_main_lottie_9" // DotLottie
        case 7:
            lottieName = "pk_duel_start_lottie" // BaseLottie
//            lottieName = "svip_main_lottie_10" // DotLottie
        default:
            lottieName = "room_upgradeguard_lottie" // BaseLottie
//            lottieName = "collecting_cards_open_bag_level_5" // DotLottie
        }
        
        guard let filepath = Bundle.main.path(forResource: lottieName, ofType: "lottie") else {
            setupBaseLottie(lottieName)
            return
        }
        
        DotLottieFile.loadedFrom(filepath: filepath) { result in
            switch result {
            case .success(let file):
                JPrint("DotLottie 加载成功: \(file)")
                self.setupDotLottie(file)
            case .failure(let error):
                JPrint("DotLottie 加载失败: \(error)")
            }
        }
    }
    
    func setupBaseLottie(_ lottieName: String) {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(lottieName)"),
              let animation = LottieAnimation.filepath(filepath, animationCache: DefaultAnimationCache.sharedCache)
        else {
            JPrint("BaseLottie 路径错误！")
            return
        }
        // animation 和 provider 是必须的
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        
        animView.animation = animation
        animView.imageProvider = provider
        animView.play()
        
        let baseLottieLayer = makeBaseLottieLayer(animation, provider)
        self.baseLottieLayer = baseLottieLayer
        
        slider.minimumValue = Float(animation.startFrame)
        slider.maximumValue = Float(animation.endFrame)
        slider.value = slider.minimumValue
        
        makeBaseLottieImage(baseLottieLayer, animation.startFrame, isAsync: true)
        
        JPrint("-------------", Thread.current)
        JPrint("BaseLottie 时长", animation.duration)
        JPrint("BaseLottie 大小", animation.size)
    }
    
    func setupDotLottie(_ file: DotLottieFile) {
        guard let dotLottieAnimation = file.animations.first else {
            JPrint("DotLottie 文件错误！")
            return
        }
        let animation = dotLottieAnimation.animation
        
        animView.loadAnimation(from: file)
        animView.loopMode = .loop
        animView.animationSpeed = 1
        animView.play()
        
        let dotLottieLayer = makeDotLottieLayer(file)
        self.dotLottieLayer = dotLottieLayer
        
        slider.minimumValue = Float(animation.startFrame)
        slider.maximumValue = Float(animation.endFrame)
        slider.value = slider.minimumValue
        
        makeDotLottieImage(dotLottieLayer, animation.startFrame, isAsync: false)
        
        JPrint("-------------", Thread.current)
        JPrint("DotLottie 时长", animation.duration)
        JPrint("DotLottie 大小", animation.size)
    }
}

extension LottieShowViewController {
    @objc func sliderDidChanged(_ slider: UISlider) {
        let currentFrame = CGFloat(slider.value)
        if let baseLottieLayer {
            baseLottieLayer.currentFrame = currentFrame
            baseLottieLayer.display()
            makeBaseLottieImage(baseLottieLayer, currentFrame, isAsync: true)
        }
        else if let dotLottieLayer {
            dotLottieLayer.currentFrame = currentFrame
            dotLottieLayer.forceDisplayUpdate()
            makeDotLottieImage(dotLottieLayer, currentFrame, isAsync: false)
        }
    }
}

// MARK: - 截取Lottie动画的其中一帧生成图片
///
/// 主线程:  `lottieLayer.currentFrame = X` // 异步，`CATransaction completion`里才真正刷新
/// 主线程:  `lottieLayer.display()`
/// 子线程: ` renderInContext:` // 读图层树内容
/// 这里有两个坑叠加:
/// 1. 设帧是异步的。
/// - `currentFrame`的`setter`把`forceDisplayUpdate()`塞进`CATransaction`的`completion block(LottieAnimationLayer.swift:1093-1099)`，下一个 runloop 才刷新。你子线程可能在内容还没更新到 X 帧时就抓了。
/// 2. 跨线程读同一棵图层树。
/// - 主线程可能正在因为下一次 slider 变化重算这棵树，子线程同时在`renderInContext:`遍历它 —— 数据竞争，可能崩，也可能抓到半新半旧的画面（这恰好也是“画面不完整”的原因之一）。
/// 也就是说：Lottie 主线程引擎的图层内容，天然是【主线程持有】的，你不能一边让主线程算、一边让子线程抓同一个对象。
///
/// 主线程：正在为下一次 slider 变化跑`forceDisplayUpdate()`   // 写 shapeLayer.path
/// 子线程：正在`renderInContext:`遍历同一批 CAShapeLayer    // 读 path / bounds
/// 这俩碰同一批 CALayer 对象。CoreAnimation 的 layer 不是线程安全的：
/// - 轻则抓到半新半旧的画面（最初说的“画面不完整”）
/// - 重则**`EXC_BAD_ACCESS`崩溃**
/// 回调里的`currentFrame == currentFrame`判断只能丢弃错帧结果，拦不住崩溃，也拦不住读到撕裂的中间态。
///
/// 理想方案：
/// 1. 让`抓图用的layer`和`主线程实时操作的layer`隔离（`专属离屏layer`只归抓图队列，或双缓冲交替），从根上避免同一对象被两个线程同时碰。
/// 2. 把【子线程抓图】操作也放到主线程执行。原因：
/// - 子线程抓图可以分担一部分主线程负担，但分担的量比你想象的少。分担收益不划算，为此还换来数据竞争风险。
/// - 在 Lottie 主线程引擎里，【定帧】这一步本身就已经完成了大部分 CPU 计算，`renderInContext:`抓图时的真正 CPU 消耗其实不大 —— 它抓的往往是 CAShapeLayer 里已经算好的 path，栅格化主要在 GPU 合成期。
///
/// **🔥综合推荐：把【定帧】和【抓图】都放「主线程」同步执行最稳！**
///
extension LottieShowViewController {
    func makeBaseLottieImage(_ baseLottieLayer: MainThreadAnimationLayer, _ currentFrame: CGFloat, isAsync: Bool) {
        makerItem?.cancel()
        makerItem = nil
        
        guard isAsync else {
            if let image = baseLottieLayer.jp_convertToImage() {
                placeholderView.image = image
            } else {
                JPrint("BaseLottie 图片截取失败 ---", currentFrame)
            }
            return
        }
        
        let workItem = DispatchWorkItem {
            let image = baseLottieLayer.jp_convertToImage()
            Asyncs.main { [weak self] in
                guard let self, let baseLottieLayer = self.baseLottieLayer else { return }
                guard baseLottieLayer.currentFrame == currentFrame else { return }
                guard let image else {
                    JPrint("BaseLottie 图片截取失败 ---", currentFrame)
                    return
                }
                self.placeholderView.image = image
            }
        }
        
        imageMakerQueue.async(execute: workItem)
        makerItem = workItem
    }
    
    func makeDotLottieImage(_ dotLottieLayer: LottieAnimationLayer, _ currentFrame: CGFloat, isAsync: Bool) {
        makerItem?.cancel()
        makerItem = nil
        
        guard isAsync else {
            if let image = dotLottieLayer.animationLayer?.jp_convertToImage() {
                placeholderView.image = image
            } else {
                JPrint("DotLottie 图片截取失败 ---", currentFrame)
            }
            return
        }
        
        let workItem = DispatchWorkItem {
            
            // *** 尝试解决警告1：“warning, deleted thread with uncommitted CATransaction ...” ***
            // 在子线程做 CA 相关工作时，自己用显式 CATransaction 包起来并手动 commit，
            // 这样事务在你的代码里就提交掉了，不会遗留给线程销毁时：
            CATransaction.begin()
            CATransaction.setDisableActions(true) // 1.顺带禁掉隐式动画，抓图更干净
            let image = dotLottieLayer.animationLayer?.jp_convertToImage()
            CATransaction.commit() // 2.关键：在本线程内提交，不留尾巴
            // *** 结果：不太行，还是会有警告 ***
            
            Asyncs.main { [weak self] in
                guard let self, let dotLottieLayer = self.dotLottieLayer else { return }
                guard dotLottieLayer.currentFrame == currentFrame else { return }
                guard let image else {
                    JPrint("DotLottie 图片截取失败 ---", currentFrame)
                    return
                }
                self.placeholderView.image = image
            }
        }
        
        // *** 尝试解决警告2：“Unsupported layout off the main thread for ...” ***
        // 1.在派发到子线程之前，主线程先强制布局一次，把待处理的`setNeedsLayout`清空：
        dotLottieLayer.layoutIfNeeded() // 或`lottieView.layoutIfNeeded()`
        dotLottieLayer.animationLayer?.layoutIfNeeded()
        // 2.然后再派发到子线程抓图
        imageMakerQueue.async(execute: workItem)
        // *** 结果：不太行，还是会有警告 ***
        
        makerItem = workItem
    }
}

extension LottieShowViewController {
    func makeBaseLottieLayer(_ animation: LottieAnimation, _ provider: AnimationImageProvider) -> MainThreadAnimationLayer {
        let baseLottieLayer = MainThreadAnimationLayer(
            animation: animation,
            imageProvider: provider,
            textProvider: DefaultTextProvider(),
            fontProvider: DefaultFontProvider(),
            maskAnimationToBounds: true,
            logger: LottieLogger.shared
        )
        
        baseLottieLayer.backgroundColor = UIColor.black.cgColor
        baseLottieLayer.frame = [0, 0, 300, 300]
        
        let scale: CGFloat
        if animation.bounds.size.width < animation.bounds.size.height {
            scale = baseLottieLayer.bounds.height / animation.bounds.size.height
        } else {
            scale = baseLottieLayer.bounds.width / animation.bounds.size.width
        }
        baseLottieLayer.animationLayers.forEach {
            $0.transform = CATransform3DMakeScale(scale, scale, 1)
            // $0.anchorPoint 是 [0, 0]
            $0.position = [HalfDiffValue(baseLottieLayer.bounds.width, $0.frame.width),
                           HalfDiffValue(baseLottieLayer.bounds.height, $0.frame.height)]
        }
        
        baseLottieLayer.renderScale = ScreenScale
        baseLottieLayer.reloadImages()
        baseLottieLayer.setNeedsDisplay()
        
        baseLottieLayer.currentFrame = animation.startFrame
        baseLottieLayer.display()
        
        return baseLottieLayer
    }
    
    func makeDotLottieLayer(_ file: DotLottieFile) -> LottieAnimationLayer {
//        let dotLottieLayer = LottieAnimationLayer(animation: animation)
//        let dotLottieLayer = LottieAnimationLayer(animation: animation, frame: [0, 0, 300, 300], renderScale: ScreenScale)
//        let dotLottieLayer = LottieAnimationLayer(animation: animation, configuration: LottieConfiguration(renderingEngine: .mainThread))
        let dotLottieLayer = LottieAnimationLayer(
            dotLottie: file,
            configuration: LottieConfiguration(renderingEngine: .mainThread)
        )
        dotLottieLayer.backgroundColor = UIColor.black.cgColor
        dotLottieLayer.frame = [0, 0, 300, 300]
        
        if let animation = file.animations.first?.animation, let animationLayer = dotLottieLayer.animationLayer as? MainThreadAnimationLayer {
            animationLayer.frame = dotLottieLayer.bounds
            
            let scale: CGFloat
            if animation.bounds.size.width < animation.bounds.size.height {
                scale = animationLayer.bounds.height / animation.bounds.size.height
            } else {
                scale = animationLayer.bounds.width / animation.bounds.size.width
            }
            animationLayer.animationLayers.forEach {
                $0.transform = CATransform3DMakeScale(scale, scale, 1)
                // $0.anchorPoint 是 [0, 0]
                $0.position = [HalfDiffValue(animationLayer.bounds.width, $0.frame.width),
                               HalfDiffValue(animationLayer.bounds.height, $0.frame.height)]
            }
            
            dotLottieLayer.screenScale = ScreenScale
            
            animationLayer.reloadImages()
            animationLayer.setNeedsDisplay()
            
            dotLottieLayer.currentFrame = animation.startFrame
        }
        
        dotLottieLayer.forceDisplayUpdate()
        
        return dotLottieLayer
    }
}


















    // 1.参考 LottieAnimationLayer(animation: animation) 的构造方法，在这里第一次创建LottieAnimationLayer：
//    public init(
//      animation: LottieAnimation?,
//      imageProvider: AnimationImageProvider? = nil,
//      textProvider: AnimationKeypathTextProvider = DefaultTextProvider(),
//      fontProvider: AnimationFontProvider = DefaultFontProvider(),
//      configuration: LottieConfiguration = .shared,
//      logger: LottieLogger = .shared
//    ) {
//      lottieAnimationLayer = LottieAnimationLayer(
//        animation: animation,
//        imageProvider: imageProvider,
//        textProvider: textProvider,
//        fontProvider: fontProvider,
//        configuration: configuration,
//        logger: logger
//      )
//      self.logger = logger
//      super.init(frame: .zero)
//      commonInit()
//      if let animation {
//        frame = animation.bounds
//      }
//    }
    
    // 2.参考 self.animView.loadAnimation(from: file) 里面的流程，在这里切换LottieAnimationLayer的animation：
//    lottieAnimationLayer.loadAnimation(animationId, from: dotLottieFile)
//
//    guard let dotLottieAnimation = dotLottieFile.animation(for: animationId) else { return }
//        loadAnimation(dotLottieAnimation)
//
//    loopMode = dotLottieAnimation.configuration.loopMode
//    animationSpeed = CGFloat(dotLottieAnimation.configuration.speed)
//
//    if let imageProvider = dotLottieAnimation.configuration.imageProvider {
//      self.imageProvider = imageProvider
//    }
//
//    animation = dotLottieAnimation.animation
    
    // 3.需要自定义View，然后参考LottieAnimationView的layoutAnimation方法调整lottieLayer
//    let lottieLayer = LottieAnimationLayer(animation: animation, frame: [0, 0, 300, 300], renderScale: ScreenScale)
//    self.lottieLayer = lottieLayer
//    self.lottieView.layer.addSublayer(lottieLayer)




//class LottieView: UIView {
//    var lottieLayer: LottieAnimationLayer? = nil
//    
//    func addLottieLayer(_ lottieLayer: LottieAnimationLayer?) {
//        self.lottieLayer?.removeFromSuperlayer()
//        self.lottieLayer = nil
//        
//        guard let lottieLayer else { return }
//        layer.addSublayer(lottieLayer)
//        self.lottieLayer = lottieLayer
//        
//        layoutAnimation()
//    }
//    
//    func layoutAnimation() {
//        guard let lottieLayer, let animation = lottieLayer.animation, let animationLayer = lottieLayer.animationLayer else { return }
//        
//        var position = CGPoint(x: animation.bounds.midX, y: animation.bounds.midY)
//        let xform: CATransform3D
//        var shouldForceUpdates = false
//        
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        
//        switch contentMode {
//        case .scaleToFill:
//            position = center
//            xform = CATransform3DMakeScale(
//                bounds.size.width / animation.size.width,
//                bounds.size.height / animation.size.height,
//                1
//            )
//
//        case .scaleAspectFit:
//            position = center
//            let compAspect = animation.size.width / animation.size.height
//            let viewAspect = bounds.size.width / bounds.size.height
//            let dominantDimension = compAspect > viewAspect ? bounds.size.width : bounds.size.height
//            let compDimension = compAspect > viewAspect ? animation.size.width : animation.size.height
//            let scale = dominantDimension / compDimension
//            xform = CATransform3DMakeScale(scale, scale, 1)
//
//        case .scaleAspectFill:
//            position = center
//            let compAspect = animation.size.width / animation.size.height
//            let viewAspect = bounds.size.width / bounds.size.height
//            let scaleWidth = compAspect < viewAspect
//            let dominantDimension = scaleWidth ? bounds.size.width : bounds.size.height
//            let compDimension = scaleWidth ? animation.size.width : animation.size.height
//            let scale = dominantDimension / compDimension
//            xform = CATransform3DMakeScale(scale, scale, 1)
//
//        case .redraw:
//            shouldForceUpdates = true
//            xform = CATransform3DIdentity
//
//        case .center:
//            position = center
//            xform = CATransform3DIdentity
//
//        case .top:
//            position.x = center.x
//            xform = CATransform3DIdentity
//
//        case .bottom:
//            position.x = center.x
//            position.y = bounds.maxY - animation.bounds.midY
//            xform = CATransform3DIdentity
//
//        case .left:
//            position.y = center.y
//            xform = CATransform3DIdentity
//
//        case .right:
//            position.y = center.y
//            position.x = bounds.maxX - animation.bounds.midX
//            xform = CATransform3DIdentity
//
//        case .topLeft:
//            xform = CATransform3DIdentity
//
//        case .topRight:
//            position.x = bounds.maxX - animation.bounds.midX
//            xform = CATransform3DIdentity
//
//        case .bottomLeft:
//            position.y = bounds.maxY - animation.bounds.midY
//            xform = CATransform3DIdentity
//
//        case .bottomRight:
//            position.x = bounds.maxX - animation.bounds.midX
//            position.y = bounds.maxY - animation.bounds.midY
//            xform = CATransform3DIdentity
//
//        @unknown default:
//            xform = CATransform3DIdentity
//        }
//
//        if let key = layer.animationKeys()?.first, let animation = layer.animation(forKey: key) {
//            // The layout is happening within an animation block. Grab the animation data.
//
//            let positionKey = "LayoutPositionAnimation"
//            let transformKey = "LayoutTransformAnimation"
//            animationLayer.removeAnimation(forKey: positionKey)
//            animationLayer.removeAnimation(forKey: transformKey)
//
//            let positionAnimation = animation.copy() as? CABasicAnimation ?? CABasicAnimation(keyPath: "position")
//            positionAnimation.keyPath = "position"
//            positionAnimation.isAdditive = false
//            positionAnimation.fromValue = (animationLayer.presentation() ?? animationLayer).position
//            positionAnimation.toValue = position
//            positionAnimation.isRemovedOnCompletion = true
//
//            let xformAnimation = animation.copy() as? CABasicAnimation ?? CABasicAnimation(keyPath: "transform")
//            xformAnimation.keyPath = "transform"
//            xformAnimation.isAdditive = false
//            xformAnimation.fromValue = (animationLayer.presentation() ?? animationLayer).transform
//            xformAnimation.toValue = xform
//            xformAnimation.isRemovedOnCompletion = true
//
//            animationLayer.position = position
//            animationLayer.transform = xform
//            animationLayer.anchorPoint = lottieLayer.anchorPoint
//            animationLayer.add(positionAnimation, forKey: positionKey)
//            animationLayer.add(xformAnimation, forKey: transformKey)
//        } else {
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(0.0)
//            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
//            animationLayer.position = position
//            animationLayer.transform = xform
//            CATransaction.commit()
//        }
//        
//        if shouldForceUpdates {
//            lottieLayer.forceDisplayUpdate()
//        }
//    }
//}
