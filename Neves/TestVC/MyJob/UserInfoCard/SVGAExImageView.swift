//
//  SVGAExImageView..swift
//  Falla
//
//  Created by aa on 2024/10/25.
//

import UIKit

@objc
enum SVGAExImgViewUseType: Int {
    case normal
    case gif
    case sweep
}

@objcMembers
class SVGAExImageView: UIView {
    // MARK: - 可读可写属性
    
    /// 要使用`ImageView`的类型（如果中途更换，则需要`isMultiplex`为`false`的同时切换新的图片源才会更新）
    var imgViewUseType: SVGAExImgViewUseType = .normal
    
    var imageContentMode = UIView.ContentMode.scaleToFill
    var imageRunloopMode: RunLoop.Mode = .default
    
    var playerContentMode = UIView.ContentMode.top
    var playerRunloopMode: RunLoop.Mode = .common
    var playerFromFrame = 0
    var playerIsAutoPlay = true
    var playerFinishedOnceHandler: ((_ player: SVGAExPlayer, _ source: String, _ loopCount: Int) -> Void)? = nil
    var playerLoader: SVGAExPlayer.Loader? = nil
    
    /// 扫光宽度（作用于`imgViewUseType`为`sweep`的情况，如果中途更换，则需要`isMultiplex`为`false`的同时切换新的图片源才会更新）
    var sweepWidth: CGFloat = 20
    
    /// 是否使用当前`image`作为`placeholder`（默认为`false`，传入的`placeholder`为空才有效）
    var isUseCurrentImageAsPlaceholder = false
    
    /// 是否复用控件（默认为`true`）
    /// 🌰：如果正在展示的是`image`，切换成`svga`时，为`true`则不移除`imageView`，否则就销毁。
    var isMultiplex = true
    
    /// 是否在【切换资源】前「立即」隐藏自身（默认为`false`）
    /// - 为`true`时，在【切换资源】前立即隐藏自身，不带淡入淡出的效果。
    /// - 为`false`时，如果`animated`传入为`true`时，先淡入淡出隐藏自身再【切换资源】，否则直接切换。
    /// - PS: 适用于滑动复用列表（`tableView`、`collectionView`）的场景，`cell`能快速清空旧内容，然后切换新内容。
    var isHideWhenSwitchSourceWithoutAnimtion = false
    
    /// 展示的动画时间（当`isAnimated`为`true`时才有效，默认为`0.2`）
    var showDuration: TimeInterval = 0.2 {
        didSet {
            player?.showDuration = showDuration
        }
    }
    
    /// 隐藏的动画时间（当`isAnimated`为`true`时才有效，默认为`0.2`）
    var hideDuration: TimeInterval = 0.2 {
        didSet {
            player?.hideDuration = hideDuration
        }
    }
    
    /// `image/svga`成功设置（包括缓存命中或请求完成）时触发的回调
    var sourceDidSet: ((_ isImage: Bool) -> Void)? = nil
    
    // MARK: - 只读属性
    
    /// 当前资源
    private(set) var source: Source = .none
    
    /// 视图尺寸（给子类使用）
    private(set) var viewBounds: CGRect = .zero {
        didSet {
            guard viewBounds != oldValue else { return }
            viewBoundsDidChange()
        }
    }
    
    // MARK: - 私有属性
    
    private var imgView: UIImageView? = nil
    private var player: SVGAExPlayer? = nil
    
    /// 灰度处理标识（资源url的参数key）
    private var grayscaleKey: String { "falla_grayscale" }
    
    private var isAnimated = false
    
    // MARK: - 生命周期
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        viewBounds = bounds
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = false
        viewBounds = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewBounds = bounds
    }
    
    deinit {
        imgView?.jkr_cancelCurrentImageRequest()
        player?.clean()
//        print("jpjpjp SVGAExImageView 死！！！")
    }
    
    // MARK: - Public
    
    /// 视图尺寸发生变化（主要给子类使用）
    func viewBoundsDidChange() {
        player?.frame = viewBounds
        imgView?.frame = viewBounds
    }
    
    /// 切换资源
    func updateUI(source: Source, animated: Bool) {
        self.source = source
        self.isAnimated = animated
        showImageIfNeeded(animated: animated)
        showSVGAIfNeeded(animated: animated)
    }
    
    /// 切换资源
    func updateUI(source: Source) {
        updateUI(source: source, animated: false)
    }
    
    /// 重置svga的播放区间
    func svgaResetStartFrameAndEndFrame() {
        player?.resetStartFrameAndEndFrame()
    }
    
    /// 重置svga的播放次数
    func svgaResetLoopCount() {
        player?.resetLoopCount()
    }
    
    /// 暂停svga
    func svgaPause() {
        player?.pause()
    }
    
    /// 播放svga
    func svgaPlay() {
        player?.play()
    }
    
    /// 清空内容但不移除视图
    func clean(animated: Bool) {
        source = .none
        isAnimated = animated
        hideImage(animated: animated)
        hideSVGA(animated: animated)
    }
    
    /// 清空内容但不移除视图
    func clean() {
        clean(animated: false)
    }
    
    /// 清空内容并移除视图
    func reset(animated: Bool) {
        source = .none
        isAnimated = animated
        hideImage(isRemove: true, animated: animated)
        hideSVGA(isRemove: true, animated: animated)
    }
    
    /// 清空内容并移除视图
    func reset() {
        reset(animated: false)
    }
}

// MARK: - Source
extension SVGAExImageView {
    enum Source: Equatable {
        case none
        case image(_ img: UIImage)
        case asset(_ name: String)
        case remote(
            _ url: String,
            _ isGrayscale: Bool = false,
            _ isSweep: Bool = false,
            _ placeholder: UIImage? = nil
        )
        case svga(
            _ url: String,
            _ isGrayscale: Bool = false,
            _ placeholder: UIImage? = nil
        )
        case svgaEntity(
            _ entity: SVGAVideoEntity,
            _ isGrayscale: Bool = false
        )
        
        var isImage: Bool {
            switch self {
            case .none, .svga, .svgaEntity: return false
            default: return true
            }
        }
        
        var isSvga: Bool {
            switch self {
            case .svga, .svgaEntity: return true
            default: return false
            }
        }
        
        var isGrayscale: Bool {
            switch self {
            case let .remote(_, isGrayscale, _, _): return isGrayscale
            case let .svga(_, isGrayscale, _): return isGrayscale
            case let .svgaEntity(_, isGrayscale): return isGrayscale
            default: return false
            }
        }
        
        var placeholder: UIImage? {
            switch self {
            case let .remote(_, _, _, placeholder): return placeholder
            case let .svga(_, _, placeholder): return placeholder
            default: return nil
            }
        }
    }
}

// MARK: - Image 加载&移除
private extension SVGAExImageView {
    func showImageIfNeeded(animated: Bool) {
        let imgView: UIImageView
        switch source {
        case let .image(img):
            imgView = _getImgView()
            imgView.jkr_cancelCurrentImageRequest()
            imgView.image = img
            sourceDidSet?(true)
            
        case let .asset(name):
            imgView = _getImgView()
            imgView.jkr_cancelCurrentImageRequest()
            imgView.image = UIImage(named: name)
            sourceDidSet?(true)
            
        case let .remote(url, isGrayscale, isSweep, placeholder):
            imgView = _getImgView()
            
            let imgURL: URL?
            if isGrayscale {
                // image的灰度处理#0：给url添加灰度标识
                imgURL = URL(string: url.fa.addOrUpdateParam(grayscaleKey, "0"))
            } else {
                imgURL = URL(string: url)
            }
            
            let kPlaceholder = placeholder ?? (isUseCurrentImageAsPlaceholder ? imgView.image : nil)
            
            var options: JKRWebImageOptions = []
            if animated {
                options.insert(.setImageWithFadeAnimation)
            }
            switch imgViewUseType {
            case .normal, .sweep:
                options.insert(.ignoreAnimatedImage)
            case .gif:
                if isGrayscale { // image的灰度处理#1：灰度处理无需展示动图
                    options.insert(.ignoreAnimatedImage)
                }
            }
            
            imgView.jkr_setImage(with: imgURL,
                                 placeholder: kPlaceholder,
                                 loadErrorPlaceholder: nil,
                                 options: options,
                                 progress: nil) { image, _ in
                if isGrayscale { // image的灰度处理#2：生成灰度图
                    return image.byGrayscale() ?? image
                } else {
                    return image
                }
            } completion: { [weak self] image, _, _, kURL, _ in
                guard let self, let sourceDidSet = self.sourceDidSet, image != nil, imgURL == kURL else { return }
                sourceDidSet(true)
            }
            
            if let sweepImgView = imgView as? SweepImageView {
                // image的灰度处理#3：灰度处理无需扫光
                if !isGrayscale, isSweep {
                    sweepImgView.startSweep()
                } else {
                    sweepImgView.stopSweep()
                }
            }
            
        case let .svga(_, isGrayscale, placeholder):
            // svga的灰度处理#0：需要使用imgView展示首帧灰度图
            let image = placeholder ?? (isUseCurrentImageAsPlaceholder ? self.imgView?.image : nil)
            guard isGrayscale || image != nil else {
                hideImage(animated: isHideWhenSwitchSourceWithoutAnimtion ? false : animated)
                return
            }
            
            imgView = _getImgView()
            imgView.jkr_cancelCurrentImageRequest()
            imgView.image = image
            
        case let .svgaEntity(_, isGrayscale):
            // svga的灰度处理#0：需要使用imgView展示首帧灰度图
            guard isGrayscale else {
                hideImage(animated: isHideWhenSwitchSourceWithoutAnimtion ? false : animated)
                return
            }
            
            imgView = _getImgView()
            imgView.jkr_cancelCurrentImageRequest()
            imgView.image = nil
            
        default:
            hideImage(animated: isHideWhenSwitchSourceWithoutAnimtion ? false : animated)
            return
        }
        
        guard animated else {
            imgView.alpha = 1
            return
        }
        
        UIView.animate(withDuration: showDuration) {
            imgView.alpha = 1
        }
    }
    
    func hideImage(isRemove: Bool = false, animated: Bool) {
        guard animated else {
            _removeImage(isRemove: isRemove)
            return
        }
        
        guard let imgView = self.imgView else { return }
        UIView.animate(withDuration: hideDuration) {
            imgView.alpha = 0
        } completion: { _ in
            guard !self.source.isImage else { return }
            self._removeImage(isRemove: isRemove)
        }
    }
    
    func _getImgView() -> UIImageView {
        let imgView = self.imgView ?? {
            let imgView: UIImageView
            switch imgViewUseType {
            case .normal:
                imgView = UIImageView()
            case .gif:
                imgView = YYAnimatedImageView()
            case .sweep:
                let sweepImgView = SweepImageView()
                sweepImgView.sweepWidth = sweepWidth
                imgView = sweepImgView
            }
            imgView.isUserInteractionEnabled = false
            imgView.alpha = 0
            imgView.frame = viewBounds
            addSubview(imgView)
            self.imgView = imgView
            return imgView
        }()
        imgView.contentMode = imageContentMode
        if let animImgView = imgView as? YYAnimatedImageView {
            animImgView.runloopMode = imageRunloopMode.rawValue
        }
        return imgView
    }
    
    func _removeImage(isRemove: Bool) {
        guard let imgView = self.imgView else { return }
        imgView.alpha = 0
        imgView.jkr_cancelCurrentImageRequest()
        imgView.image = nil
        if isRemove || !isMultiplex {
            imgView.removeFromSuperview()
            self.imgView = nil
        } else {
            if let sweepImgView = imgView as? SweepImageView {
                sweepImgView.stopSweep()
            }
        }
    }
}

// MARK: - SVGA 加载&移除
private extension SVGAExImageView {
    func showSVGAIfNeeded(animated: Bool) {
        // svga的灰度处理#1：隐藏播放器（无需播放仅渲染）
        switch source {
        case let .svga(svgaUrl, isGrayscale, _):
            let player = _getSvgaPlayer()
            player.isHidden = isGrayscale
            player.isAnimated = isGrayscale ? false : animated
            player.play(svgaUrl,
                        fromFrame: playerFromFrame,
                        isAutoPlay: isGrayscale ? false : playerIsAutoPlay)
            
        case let .svgaEntity(entity, isGrayscale):
            let player = _getSvgaPlayer()
            player.isHidden = isGrayscale
            player.isAnimated = isGrayscale ? false : animated
            player.play(with: entity,
                        fromFrame: playerFromFrame,
                        isAutoPlay: isGrayscale ? false : playerIsAutoPlay)
            
        default:
            hideSVGA(animated: isHideWhenSwitchSourceWithoutAnimtion ? false : animated)
        }
    }
    
    func hideSVGA(isRemove: Bool = false, animated: Bool) {
        guard animated else {
            _stopSVGA(isRemove: isRemove)
            return
        }
        
        guard let player = self.player else { return }
        UIView.animate(withDuration: hideDuration) {
            player.alpha = 0
        } completion: { _ in
            guard !self.source.isSvga else { return }
            self._stopSVGA(isRemove: isRemove)
        }
    }
    
    func _getSvgaPlayer() -> SVGAExPlayer {
        let player = self.player ?? {
            let player = SVGAExPlayer()
            player.isUserInteractionEnabled = false
            player.frame = viewBounds
            addSubview(player)
            self.player = player
            return player
        }()
        player.contentMode = playerContentMode
        player.mainRunLoopMode = playerRunloopMode
        player.loader = playerLoader
        player.showDuration = showDuration
        player.hideDuration = hideDuration
        player.isHideWhenSwitchSourceWithoutAnimtion = isHideWhenSwitchSourceWithoutAnimtion
        player.exDelegate = self
        return player
    }
    
    func _stopSVGA(isRemove: Bool) {
        guard let player = self.player else { return }
        player.isAnimated = false
        player.clean()
        if isRemove || !isMultiplex {
            player.removeFromSuperview()
            self.player = nil
        }
    }
}

// MARK: - <SVGAExPlayerDelegate>
extension SVGAExImageView: SVGAExPlayerDelegate {
    func svgaExPlayer(_ player: SVGAExPlayer, svga source: String, readyForPlay isNewSource: Bool, fromFrame: Int, isWillPlay: Bool, resetHandler: @escaping (Int, Bool) -> Void) {
        sourceDidSet?(false)
        
        // svga的灰度处理#2：展示首帧，停止不播放
        if self.source.isGrayscale {
            resetHandler(fromFrame, false)
            return
        }
        
        guard let imgView, imgView.alpha > 0 else { return }
        hideImage(isRemove: !isMultiplex, animated: isAnimated)
    }
    
    func svgaExPlayer(_ player: SVGAExPlayer, statusDidChanged status: SVGAExPlayerStatus, oldStatus: SVGAExPlayerStatus) {
        // 如果要灰度处理，必然是暂停中
        guard status == .paused, source.isGrayscale, let imgView else { return }
        
        // svga的灰度处理#3：截取首帧灰度图并缓存，使用imgView展示
        let cacheKey = player.svgaSource.fa.addOrUpdateParam(grayscaleKey, "\(playerFromFrame)")
        let cache = YYWebImageManager.shared().cache
        
        // 先从缓存获取灰度图
        var grayImg = cache?.getImageForKey(cacheKey)
        // 没有就现场截取并缓存
        if grayImg == nil, let kGrayImg = player.snapshotCurrentFrame()?.byGrayscale() {
            cache?.setImage(kGrayImg, forKey: cacheKey)
            grayImg = kGrayImg
        }
        
        imgView.image = grayImg
        imgView.alpha = 1
        guard isAnimated else { return }
        UIView.transition(with: imgView, duration: showDuration, options: .transitionCrossDissolve) {}
    }
    
    func svgaExPlayer(_ player: SVGAExPlayer, svga source: String, animationDidFinishedOnce loopCount: Int) {
        playerFinishedOnceHandler?(player, source, loopCount)
    }
}
