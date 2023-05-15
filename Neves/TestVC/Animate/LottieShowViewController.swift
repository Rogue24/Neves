//
//  LottieShowViewController.swift
//  Neves
//
//  Created by aa on 2021/9/6.
//

class LottieShowViewController: TestBaseViewController {
    
    var animView: LottieAnimationView!
    var animationLayer: MainThreadAnimationLayer?
    
    lazy var imageMakerQueue: DispatchQueue = DispatchQueue(label: "ImageMaker.SerialQueue")
    var makerItem: DispatchWorkItem? = nil
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/gxq_rk_shitu_zhiyou"),
              let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else {
            JPrint("路径错误！")
            return
        }
        
        // animation 和 provider 是必须的
//        let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        
        animView = LottieAnimationView(animation: animation, imageProvider: provider)
        animView.backgroundColor = .black
        animView.frame = [HalfDiffValue(PortraitScreenWidth, 300), NavTopMargin + 20, 300, 300]
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop
        view.addSubview(animView)
        animView.play()
        
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
        
        let animationLayer = makeAnimationLayer(animation, provider)
        self.animationLayer = animationLayer
        
        slider.minimumValue = Float(animation.startFrame)
        slider.maximumValue = Float(animation.endFrame)
        slider.value = slider.minimumValue
        
        makeAnimationImage(animationLayer, animation.startFrame)
    }
    
    deinit {
        makerItem?.cancel()
        makerItem = nil
    }
    
    @objc func changeAnim(_ btn: UIButton) {
        animView.stop()
        
        makerItem?.cancel()
        animationLayer = nil
        placeholderView.image = nil
        
        let lottieName: String
        switch btn.tag {
        case 0:
            lottieName = "s_smelt_open2_lottie"
        case 1:
            lottieName = "smelt_flash_lottie"
        case 2:
            lottieName = "smelt_open1_lottie"
        case 3:
            lottieName = "smelt_open2_lottie"
        case 4:
            lottieName = "smelt_popup_lottie"
        case 5:
            lottieName = "smelt_selected_lottie"
        case 6:
            lottieName = "room_renewguard01_lottie"
        case 7:
            lottieName = "pk_duel_start_lottie"
        default:
            lottieName = "room_upgradeguard_lottie"
        }
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(lottieName)"),
              let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else {
            JPrint("路径错误！")
            return
        }
        
        // animation 和 provider 是必须的
//        let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        
        animView.animation = animation
        animView.imageProvider = provider
        animView.play()
        
        let animationLayer = makeAnimationLayer(animation, provider)
        self.animationLayer = animationLayer
        
        slider.minimumValue = Float(animation.startFrame)
        slider.maximumValue = Float(animation.endFrame)
        slider.value = slider.minimumValue
        
        makeAnimationImage(animationLayer, animation.startFrame)
        
        JPrint("时长", animation.duration)
        JPrint("大小", animation.size)
        JPrint("-------------")
    }
    
    @objc func sliderDidChanged(_ slider: UISlider) {
        let currentFrame = CGFloat(slider.value)
        
        guard let animationLayer = self.animationLayer else { return }
        animationLayer.currentFrame = currentFrame
        animationLayer.display()
        
        makeAnimationImage(animationLayer, currentFrame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            if self.animView.isAnimationPlaying {
                self.animView.stop()
                if let animation = self.animView.animation {
                    self.animView.currentFrame = (animation.endFrame - animation.startFrame) / 2
                }
            } else {
                self.animView.play()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunnyActions()
    }
}

// MARK: - 截取Lottie动画的其中一帧生成图片
extension LottieShowViewController {
    func makeAnimationImage(_ animationLayer: MainThreadAnimationLayer, _ currentFrame: CGFloat) {
        makerItem?.cancel()
        let workItem = DispatchWorkItem {
            let image = animationLayer.jp_convertToImage()
            Asyncs.main { [weak self] in
                guard let self = self,
                      let animationLayer = self.animationLayer,
                      animationLayer.currentFrame == currentFrame else { return }
                self.placeholderView.image = image
            }
        }
        imageMakerQueue.async(execute: workItem)
        makerItem = workItem
    }
    
    func makeAnimationLayer(_ animation: LottieAnimation, _ provider: FilepathImageProvider) -> MainThreadAnimationLayer {
        let animationLayer = MainThreadAnimationLayer(animation: animation, imageProvider: provider, textProvider: DefaultTextProvider(), fontProvider: DefaultFontProvider(), logger: LottieLogger.shared)
        animationLayer.backgroundColor = UIColor.black.cgColor
        animationLayer.frame = [0, 0, 300, 300]
        
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
        
        animationLayer.renderScale = ScreenScale
        animationLayer.reloadImages()
        animationLayer.setNeedsDisplay()
        
        animationLayer.currentFrame = animation.startFrame
        animationLayer.display()
        
        return animationLayer
    }
}
