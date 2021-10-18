//
//  LottieShowViewController.swift
//  Neves
//
//  Created by aa on 2021/9/6.
//

class LottieShowViewController: TestBaseViewController {
    
    var animView: AnimationView!
    var animationLayer: AnimationContainer?
    
    lazy var imageMakerQueue: DispatchQueue = DispatchQueue(label: "ImageMaker.SerialQueue")
    var makerItem: DispatchWorkItem? = nil
    
    lazy var placeholderView: UIImageView = {
        let imgView = UIImageView()
        imgView.frame = [HalfDiffValue(PortraitScreenWidth, 300), animView.jp_maxY + 80, 300, 300]
        imgView.backgroundColor = .black
        view.addSubview(imgView)
        return imgView
    }()
    
    lazy var slider: UISlider = {
        let s = UISlider(frame: [30, placeholderView.jp_maxY + 20, PortraitScreenWidth - 60, 20])
        s.addTarget(self, action: #selector(sliderDidChanged(_:)), for: .valueChanged)
        view.addSubview(s)
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/gxq_rk_shitu_zhiyou"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else {
            JPrint("路径错误！")
            return
        }
        
        // animation 和 provider 是必须的
//        let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        
        animView = AnimationView(animation: animation, imageProvider: provider)
        animView.backgroundColor = .black
        animView.frame = [HalfDiffValue(PortraitScreenWidth, 300), NavTopMargin + 20, 300, 300]
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop
        view.addSubview(animView)
        animView.play()
        
        let s: CGFloat = 5
        let x: CGFloat = 15
        let y = animView.maxY + 20
        let w = (PortraitScreenWidth - 2 * x - 3 * s) / 4
        let h: CGFloat = 50
        
        (0 ..< 4).forEach {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .systemFont(ofSize: 20)
            btn.setTitle("动画\($0 + 1)", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [x + CGFloat($0) * (w + s), y, w, h]
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
            lottieName = "album_sing_bg_lottie"
        case 1:
            lottieName = "cube_s_lottie"
        case 2:
            lottieName = "video_tx_jielong_lottie"//"fire_lottie2"
        default:
            lottieName = "album_videobg_jielong_lottie"//"lottie_recordingmotion"
        }
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(lottieName)"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else {
            JPrint("路径错误！")
            return
        }
        
        // animation 和 provider 是必须的
//        let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
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
    }
    
    @objc func sliderDidChanged(_ slider: UISlider) {
        let currentFrame = CGFloat(slider.value)
        
        guard let animationLayer = self.animationLayer else { return }
        animationLayer.currentFrame = currentFrame
        animationLayer.display()
        
        makeAnimationImage(animationLayer, currentFrame)
    }
}

// MARK:- 截取Lottie动画的其中一帧生成图片
extension LottieShowViewController {
    func makeAnimationImage(_ animationLayer: AnimationContainer, _ currentFrame: CGFloat) {
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
    
    func makeAnimationLayer(_ animation: Animation, _ provider: FilepathImageProvider) -> AnimationContainer {
        let animationLayer = AnimationContainer(animation: animation, imageProvider: provider, textProvider: DefaultTextProvider(), fontProvider: DefaultFontProvider())
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
