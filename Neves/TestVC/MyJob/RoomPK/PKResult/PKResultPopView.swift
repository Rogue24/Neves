//
//  PKResultPopView.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

class PKResultPopView: UIView {
    let result: PKResult
    let animView = AnimationView(animation: nil, imageProvider: nil)
    
    init(result: PKResult) {
        self.result = result
        super.init(frame: PortraitScreenBounds)
        
        animView.backgroundBehavior = .pauseAndRestore
        animView.contentMode = .scaleAspectFill
        animView.loopMode = .playOnce
        addSubview(animView)
        animView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    static func show(withResult result: PKResult, on superview: UIView) -> PKResultPopView {
        let popView = PKResultPopView(result: result)
        superview.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        superview.layoutIfNeeded()
        popView.show()
        return popView
    }
    
    func show() {
        var imageReplacement: [String: CGImage?] = [:]
        Asyncs.async {
            imageReplacement = self.prepareImages()
        } mainTask: { [weak self] in
            guard let self = self else { return }
            self.playAnim(imageReplacement)
        }
    }
    
    @objc func close() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

extension PKResultPopView {
    func prepareImages() -> [String: CGImage?] {
        let result = self.result
        let isFm = result.isFm
        
        var imageReplacement: [String: CGImage?] = [:]
        result.infos.forEach { info in
            UIGraphicsBeginImageContextWithOptions(info.size, false, 0)
            defer { UIGraphicsEndImageContext() }
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            
            Syncs.main {
                let view = Self.makeInfoView(info, isFm)
                view.layer.render(in: ctx)
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            imageReplacement[info.replaceKey] = image?.cgImage
        }
        
        return imageReplacement
    }
    
    func playAnim(_ imageReplacement: [String: CGImage?]) {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(result.lottieName)"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) else {
            removeFromSuperview()
            return
        }
        
        setupCloseBtn(animation.bounds.size)
        
        animView.animation = animation
        animView.imageProvider = ImageReplacementProvider(imageReplacement: imageReplacement, filePath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        animView.play { [weak self] _ in
            guard let self = self else { return }
            self.close()
        }
    }
}

extension PKResultPopView {
    func setupCloseBtn(_ animSize: CGSize) {
        let scale = PortraitScreenWidth / animSize.width
        
        let wh = 60 * scale
        
        let x = (PortraitScreenWidth - wh) * 0.5
        
        var y = 1170 * scale// (270 + 800 + 40) * scale
        y += (PortraitScreenHeight - animSize.height * scale) * 0.5
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.frame = [x, y, wh, wh]
        closeBtn.addTarget(self, action: #selector(closeBtnDicClick), for: .touchUpInside)
//        closeBtn.backgroundColor = .green
        addSubview(closeBtn)
    }
    
    @objc func closeBtnDicClick() {
        // 暂停也会调用LottieCompletionBlock，只是finish为false，这里不用管是否为finish，直接关掉
        animView.pause()
    }
}

extension PKResultPopView {
    static func makeInfoView(_ info: PKResult.Info, _ isFm: Bool) -> UIView {
        switch info {
        case let .title(size, _):
            return makeTitleView(size)
        case let .star(size, _):
            return makeStarView(size)
        case let .icon(size, _):
            return makeIconView(size, isFm)
        case let .name(size, _):
            return makeNameView(size)
        case let .boosters(size, _):
            return makeBoostersView(size)
        }
    }
    
    static func makeTitleView(_ size: CGSize) -> UIView {
        let label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.text = "恭喜获得20颗星星"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        return label
    }
    
    static func makeStarView(_ size: CGSize) -> UIView {
        let bgView = UIView(frame: CGRect(origin: .zero, size: size))
        
        let starIcon = UIImageView(frame: [2.5, 0.5, 13, 13])
        starIcon.image = UIImage(named: "pk_fm_star")
        starIcon.contentMode = .scaleToFill
        
        let starCountLabel = UILabel()
        starCountLabel.text = "99"
        starCountLabel.textColor = .white
        starCountLabel.font = .systemFont(ofSize: 10)
        starCountLabel.sizeToFit()
        starCountLabel.frame = [starIcon.maxX + 1.5, 0, starCountLabel.width, 14]
        
        let starView = GradientView(frame: [0, 0, starCountLabel.maxX + 4, 14])
        starView.layer.cornerRadius = 7
        starView.layer.masksToBounds = true
        starView
            .startPoint(0, 0.5)
            .endPoint(1, 0.5)
            .colors(.rgb(254, 83, 3),
                    .rgb(254, 149, 32))
        starView.addSubview(starIcon)
        starView.addSubview(starCountLabel)
        
        let addStarCountLabel = UILabel()
        addStarCountLabel.text = "+ 99"
        addStarCountLabel.textColor = .white
        addStarCountLabel.font = .systemFont(ofSize: 12)
        addStarCountLabel.sizeToFit()
        
        let totalWidth = starView.width + 4 + addStarCountLabel.width
        starView.origin = [HalfDiffValue(bgView.width, totalWidth), HalfDiffValue(bgView.height, starView.height)]
        addStarCountLabel.origin = [starView.maxX + 4, HalfDiffValue(bgView.height, addStarCountLabel.height)]
        bgView.addSubview(starView)
        bgView.addSubview(addStarCountLabel)
        
        return bgView
    }
    
    static func makeIconView(_ size: CGSize, _ isFm: Bool) -> UIView {
        let imgView = UIImageView(frame: CGRect(origin: .zero, size: size))
        imgView.image = UIImage(named: "jp_icon")
        if isFm {
            imgView.layer.cornerRadius = size.height * 0.5
        } else {
            imgView.layer.cornerRadius = 8
            imgView.layer.borderWidth = 2
            imgView.layer.borderColor = UIColor.white.cgColor
        }
        imgView.layer.masksToBounds = true
        return imgView
    }
    
    static func makeNameView(_ size: CGSize) -> UIView {
        let label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.text = "宇宙第一无敌超级帅哥"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        return label
    }
    
    static func makeBoostersView(_ size: CGSize) -> UIView {
        let bgView = UIView(frame: CGRect(origin: .zero, size: size))
        
        let count = 3
        let space: CGFloat = 12
        let width: CGFloat = 30
        let totalWidth = CGFloat(count) * width + CGFloat(count - 1) * space
        var x: CGFloat = HalfDiffValue(size.width, totalWidth)
        
        for i in 0 ..< count {
            let userView = UIView(frame: [x, 0, width, size.height])
            
            let imgView = UIImageView(frame: [0, 0, width, width])
            imgView.image = UIImage(named: "jp_icon")
            imgView.layer.cornerRadius = 15
            imgView.layer.masksToBounds = true
            userView.addSubview(imgView)
            
            let label = UILabel(frame: [0, size.height - 12, width, 12])
            label.font = .systemFont(ofSize: 10)
            label.textAlignment = .center
            label.textColor = .white
            label.text = "美男\(i)"
            userView.addSubview(label)
            
            bgView.addSubview(userView)
            x += (width + space)
        }
        
        return bgView
    }
}
