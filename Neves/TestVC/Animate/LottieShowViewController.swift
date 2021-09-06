//
//  LottieShowViewController.swift
//  Neves
//
//  Created by aa on 2021/9/6.
//

class LottieShowViewController: TestBaseViewController {
    
    var animView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/gxq_rk_shitu_zhiyou") else {
            JPrint("路径错误！")
            return
        }
        
        // animation 和 provider 是必须的
        let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        
        animView = AnimationView(animation: animation, imageProvider: provider)
        animView.backgroundColor = .black
        animView.frame = [HalfDiffValue(PortraitScreenWidth, 300), NavTopMargin + 100, 300, 300]
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
        
    }
    
    @objc func changeAnim(_ btn: UIButton) {
        animView.stop()
        
        let lottieName: String
        switch btn.tag {
        case 0:
            lottieName = "album_sing_bg_lottie"
        case 1:
            lottieName = "cube_s_lottie"
        case 2:
            lottieName = "fire_lottie2"
        default:
            lottieName = "lottie_recordingmotion"
        }
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(lottieName)") else {
            JPrint("路径错误！")
            return
        }
        
        // animation 和 provider 是必须的
        let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        
        animView.animation = animation
        animView.imageProvider = provider
        
        animView.play()
    }

}
