//
//  PKResultPopView.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

class PKResultPopView: UIView {
    
    let animView = AnimationView(animation: nil, imageProvider: nil)
    
    init() {
        super.init(frame: PortraitScreenBounds)
        backgroundColor = .randomColor(0.3)
        
        animView.backgroundBehavior = .pauseAndRestore
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .playOnce
        addSubview(animView)
        animView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_fm_win_lottie"),
           let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
            JPrint("animation.size", animation.bounds.size)
            JPrint("animation.duration", animation.duration)
            animView.animation = animation
            animView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        close()
    }
    
    @discardableResult
    static func show(on superview: UIView) -> PKResultPopView {
        let popView = PKResultPopView.init()
        superview.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        superview.layoutIfNeeded()
        popView.show()
        return popView
    }
    
    func show() {
        animView.play { [weak self] _ in
            guard let self = self else { return }
            self.close()
        }
    }
    
    func close() {
        removeFromSuperview()
    }
}
