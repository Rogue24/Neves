//
//  PKProgressOutSideView.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

class PKProgressOutSideView: UIView {
    @IBOutlet weak var bgImgView: UIImageView!
    
    @IBOutlet weak var progressBgView: UIView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var leftProgressView: UIImageView!
    @IBOutlet weak var rightProgressView: UIImageView!
    
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var leftTitleLabel: UILabel!
    
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var rightTitleLabel: UILabel!
    
    @IBOutlet weak var pkAnimContainer: UIView!
    @IBOutlet weak var watchBtn: NoHighlightButton!
    
    private(set) var isShot: Bool = false
    private var viewWidth: CGFloat { PortraitScreenWidth - 30 - (isShot ? 55 : 0) }
    
    private(set) var progress: CGFloat = 0 // 临时用的
    private lazy var totalProgress = viewWidth - 69
    
    let leftProgressMaskView = UIView(frame: [-8, 0, 0, 10])
    let posAnimView = LottieAnimationView(animation: nil, imageProvider: nil)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        leftIcon.layer.borderWidth = 1.5
        leftIcon.layer.borderColor = UIColor.white.cgColor
        leftIcon.layer.cornerRadius = 5
        leftIcon.layer.masksToBounds = true
        
        rightIcon.layer.borderWidth = 1.5
        rightIcon.layer.borderColor = UIColor.white.cgColor
        rightIcon.layer.cornerRadius = 5
        rightIcon.layer.masksToBounds = true
        
        watchBtn.layer.cornerRadius = 8.5
        watchBtn.layer.masksToBounds = true
        
        progressContainerView.layer.cornerRadius = 5
        progressContainerView.layer.masksToBounds = true
        
        leftProgressMaskView.backgroundColor = .black
        leftProgressView.mask = leftProgressMaskView
        
//        posAnimView.backgroundColor = .randomColor(0.3)
        posAnimView.backgroundBehavior = .pauseAndRestore
        posAnimView.contentMode = .scaleAspectFill
        posAnimView.frame = [0, HalfDiffValue(10, 32), 69, 32]
        posAnimView.loopMode = .loop
        progressBgView.addSubview(posAnimView)
        if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_progressbar_lottie"),
           let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
            posAnimView.animation = animation
            posAnimView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
            posAnimView.play()
        }
        
        if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_tag_lottie"),
           let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
            let pkLogoAnimView = LottieAnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
            pkLogoAnimView.backgroundBehavior = .pauseAndRestore
            pkLogoAnimView.contentMode = .scaleAspectFit
            pkLogoAnimView.loopMode = .loop
            pkAnimContainer.addSubview(pkLogoAnimView)
            pkLogoAnimView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            pkAnimContainer.layoutIfNeeded()
            pkLogoAnimView.play()
        }
        
        update(progress: 0.5)
    }
}

extension PKProgressOutSideView {
    func put(on superview: UIView, top: CGFloat) {
        superview.addSubview(self)
        snp.makeConstraints { make in
            make.width.equalTo(viewWidth)
            make.height.equalTo(110)
            make.centerX.equalToSuperview()
            make.top.equalTo(top)
        }
    }
    
    func updateLauout(isShot: Bool) {
        guard self.isShot != isShot else { return }
        self.isShot = isShot
        
        bgImgView.image = UIImage(named: isShot ? "pk_yule_bg_short" : "pk_yule_bg_long")
        
        totalProgress = viewWidth - 69
        snp.updateConstraints { make in
            make.width.equalTo(viewWidth)
        }
        superview?.layoutIfNeeded()
        
        update(progress: progress)
    }
    
    func update(progress: CGFloat) {
        self.progress = progress
        let progressValue = progress * totalProgress
        posAnimView.frame.origin.x = progressValue
        leftProgressMaskView.frame.size.width = 34.5 + progressValue
    }
}
