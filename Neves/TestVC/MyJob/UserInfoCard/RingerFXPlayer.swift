//
//  RingerFXPlayer.swift
//  Falla
//
//  Created by aa on 2025/5/23.
//

import UIKit

class RingerFXPlayer: UIView {
    enum Mode: Equatable {
        case none
        case mp4_svga(mp4Url: String, svgaUrl: String, svgaStartFrameInMp4: Int = -1, svgaLoopFrame: Int = 0)
        case mp4_loopMp4(mp4Url: String, loopMp4Url: String)
    }
    
    enum Status {
        case idle
        case loading
        case loadFailed
        case playing
        case paused
    }
    
    fileprivate enum SvgaResult {
        case entity(_ entity: SVGAVideoEntity)
        case image(_ image: UIImage)
    }
    
    private(set) var mode: Mode = .none
    private(set) var status: Status = .idle
    
    private(set) var isPlayingSvga = false
    private(set) var isPlayingLoopMp4 = false
    
    private var mp4LoadTag: UUID? = nil
    private var mp4FilePath: String? = nil
    
    private var svgaLoadTag: UUID? = nil
    private var svgaResult: SvgaResult? = nil
    
    private var loopMp4LoadTag: UUID? = nil
    private var loopMp4FilePath: String? = nil
    
    private var vapView: QGVAPWrapView? = nil
    private var svgaView: SVGAExImageView? = nil
    private var loading: LoadingPlayer? = nil
    private var jvhua: UIActivityIndicatorView? = nil
    
    /// 📢：如果尺寸为0，`QGVAPWrapView`就无法播放！会打印："quit rendering cuz layer.superlayer or size error is nil! "
    /// 📢：太小也不行！即便能播放，但实际上是没画面的，可以去看日志："update drawablesize : NSSize: {xx, xx}" --- 看看尺寸对不对
    private var mySize: CGSize = [1, 1] {
        didSet {
            guard mySize != oldValue else { return }
            vapView?.frame = CGRect(origin: .zero, size: mySize)
            svgaView?.frame = CGRect(origin: .zero, size: mySize)
            loading?.center = [mySize.width * 0.5, mySize.height * 0.5]
            jvhua?.center = [mySize.width * 0.5, mySize.height * 0.5]
        }
    }
    
    private func _updateMySize() {
        guard bounds.width >= 1, bounds.height >= 1 else { return }
        mySize = bounds.size
    }
    
    private var myProfile: String {
        String(describing: Self.self) + "_" + String(format: "%p", self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentMode = .scaleAspectFill
        _updateMySize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        EML_DebugLog("\(myProfile) 死！！！")
    }
    
    override var contentMode: UIView.ContentMode {
        get { super.contentMode }
        set {
            super.contentMode = newValue
            
            if let vapView {
                switch newValue {
                case .scaleAspectFill:
                    vapView.contentMode = .aspectFill
                case .scaleAspectFit:
                    vapView.contentMode = .aspectFit
                default:
                    vapView.contentMode = .scaleToFill
                }
            }
            
            if let svgaView {
                svgaView.imageContentMode = newValue
                svgaView.playerContentMode = newValue
            }
        }
    }
    
    /// 📢：设置 frame 不会立刻调用`layoutSubviews`！
    /// - 但会触发布局流程，真正的回调是在之后的布局阶段发生的。
    /// - 过程：改 frame → 标记需要布局 → 下次布局阶段统一调用 layoutSubviews。
    ///
    /// 设置 frame 后 UIKit 做的事情是：
    /// 1️⃣ 记录下这个 view 需要布局（会调用`setNeedsLayout`）。
    /// 2️⃣ 在当前 runloop 结束前（下次绘制前），统一调用`layoutIfNeeded`，然后调用`layoutSubviews`。
    /// - 所以不是「设置完 frame 的那一行代码」就立即调用`layoutSubviews`，而是之后才调用。
    ///
    /// ⚡️如果要在设置 frame 之后就「立刻」调用`layoutSubviews`，可以手动调用`layoutIfNeeded`。
    ///
    /// 🤔为什么不重写 frame 的 get 方法？
    /// - 正如上面所述，连续设置 frame 也只会在下次布局阶段统一更新，不重写是防止频繁修改导致的性能问题。
    override func layoutSubviews() {
        super.layoutSubviews()
        _updateMySize()
    }
}

extension RingerFXPlayer {
    // MARK: - 配置🌊加载
    func setNeedLoading(scale: CGFloat = 1.0) {
        let loading = self.loading ?? {
            jvhua?.removeFromSuperview()
            jvhua = nil
            
            let loading = LoadingPlayer()
            loading.isUserInteractionEnabled = false
//            loading.isAnimated = false
//            loading.isHideWhenStopped = false
//            loading.alpha = 0
            addSubview(loading)
            self.loading = loading
            
            return loading
        }()
        
        loading.transform = CGAffineTransform(scaleX: scale, y: scale)
        loading.center = [mySize.width * 0.5, mySize.height * 0.5]
    }
    
    // MARK: - 配置菊花加载
    func setNeedJvhua(style: UIActivityIndicatorView.Style = .medium, scale: CGFloat = 1.0) {
        let jvhua = self.jvhua ?? {
            loading?.removeFromSuperview()
            loading = nil
            
            let jvhua = UIActivityIndicatorView()
            jvhua.isUserInteractionEnabled = false
            jvhua.hidesWhenStopped = false
            jvhua.stopAnimating()
            jvhua.alpha = 0
            addSubview(jvhua)
            self.jvhua = jvhua
            
            return jvhua
        }()
        
        jvhua.style = style
        jvhua.transform = CGAffineTransform(scaleX: scale, y: scale)
        jvhua.center = [mySize.width * 0.5, mySize.height * 0.5]
    }
    
    // MARK: - 播放
    
    /// 播放`MP4`+`SVGA`
    /// - Parameters:
    ///   - mp4Url: `MP4`视频的URL
    ///   - svgaUrl: `SVGA`动画的URL
    ///   - svgaStartFrameInMp4: `SVGA`动画开始帧（表示`MP4`播放到第几帧开始播放`SVGA`，传`-1`代表从结尾处开始）
    ///   - svgaLoopFrame: `SVGA`动画指定循环帧（传`0`表示从头循环）
    ///   - isReplayIfSame: 播放源相同时是否重新播放（如果是，则会重置播放器，默认为`false`）
    func play(mp4Url: String, svgaUrl: String,
              svgaStartFrameInMp4: Int = -1, svgaLoopFrame: Int = 0,
              isReplayIfSame: Bool = false) {
        play(mode: .mp4_svga(
            mp4Url: mp4Url,
            svgaUrl: svgaUrl,
            svgaStartFrameInMp4: svgaStartFrameInMp4,
            svgaLoopFrame: svgaLoopFrame
        ), isReplayIfSame: isReplayIfSame)
    }
    
    /// 播放`MP4`+`循环MP4`
    /// - Parameters:
    ///  - mp4Url: `MP4`视频的URL
    ///  - loopMp4Url: `循环MP4`视频的URL（从开头`MP4`结尾处开始循环播放）
    ///  - isReplayIfSame: 播放源相同时是否重新播放（如果是，则会重置播放器，默认为`false`）
    func play(mp4Url: String, loopMp4Url: String, isReplayIfSame: Bool = false) {
        play(mode: .mp4_loopMp4(
            mp4Url: mp4Url,
            loopMp4Url: loopMp4Url
        ), isReplayIfSame: isReplayIfSame)
    }
    
    /// 自定义播放
    /// - Parameters:
    ///  - mode: 播放`MP4`+`SVGA`或`MP4`+`循环MP4`的模式
    ///  - isReplayIfSame: 播放源相同时是否重新播放（如果是，则会重置播放器，默认为`false`）
    func play(mode: Mode, isReplayIfSame: Bool = false) {
        if !isReplayIfSame, self.mode == mode {
            // 如果选择的是「播放源相同时不重新播放」：
            if status == .loading || status == .playing || status == .paused {
                // 当`加载中`或`播放中`就无需重置，直接跳过，若`暂停中`就继续播放
                if status == .paused {
                    resume()
                }
                return
            } // 若`空闲中`当然直接去播放，而`加载失败`则尝试重新播放
        }
        
        reset()
        
        switch mode {
        case .none:
            EML_DebugLog("\(myProfile) 啥都不播！")
            return
        case .mp4_svga:
            EML_DebugLog("\(myProfile) 播放MP4+SVGA")
        case .mp4_loopMp4:
            EML_DebugLog("\(myProfile) 播放MP4+MP4(loop)")
        }
        
        self.mode = mode
        
        buildVapViewIfNeeded()
        buildSvgaViewIfNeeded()
        
        tryPlay()
    }
    
    // MARK: - 重置（清空）
    func reset() {
        terminateLoadingAndClear()
        
        mode = .none
        status = .idle
        
        isPlayingSvga = false
        isPlayingLoopMp4 = false
        
        clearVapView()
        clearSvgaView()
        
        hideLoading()
    }
    
    // MARK: - 重播
    func replay() {
        guard status == .playing || status == .paused else { return }
        
        switch mode {
        case .none:
            break
            
        case .mp4_svga:
            switch (mp4FilePath, svgaResult) {
            case let (filePath?, result?):
                status = .playing
                isPlayingSvga = false
                prePlaySvga(result)
                playMp4(filePath)
            default:
                break
            }
                
        case .mp4_loopMp4:
            switch (mp4FilePath, loopMp4FilePath) {
            case let (filePath?, _?):
                status = .playing
                isPlayingLoopMp4 = false
                playMp4(filePath)
            default:
                break
            }
        }
    }
    
    // MARK: - 暂停
    func pause() {
        guard status == .playing else { return }
        status = .paused
        vapView?.pauseHWDMP4()
        svgaView?.svgaPause()
    }
    
    // MARK: - 继续
    func resume() {
        guard status == .paused else { return }
        status = .playing
        vapView?.resumeHWDMP4()
        svgaView?.svgaPlay()
    }
}

private extension RingerFXPlayer {
    func tryPlay() {
        if status == .playing || status == .paused || status == .loadFailed {
            return
        }
        
        switch mode {
        case .none: break
            
        case let .mp4_svga(mp4Url, svgaUrl, _, _):
            showLoading()
            status = .loading
            
            switch (mp4FilePath, svgaResult) {
            case let (filePath?, result?):
                status = .playing
                prePlaySvga(result)
                playMp4(filePath)
                
            case (nil, _?):
                loadMp4(mp4Url)
//                Asyncs.mainDelay(3) { self.loadMp4(mp4Url) }
            case (_?, nil):
                loadSvga(svgaUrl)
//                Asyncs.mainDelay(3) { self.loadSvga(svgaUrl) }
            case (nil, nil):
                loadMp4(mp4Url)
                loadSvga(svgaUrl)
//                Asyncs.mainDelay(3) { self.loadMp4(mp4Url) }
//                Asyncs.mainDelay(3) { self.loadSvga(svgaUrl) }
            }
            
        case let .mp4_loopMp4(mp4Url, loopMp4Url):
            showLoading()
            status = .loading
            
            switch (mp4FilePath, loopMp4FilePath) {
            case let (filePath?, _?):
                status = .playing
                playMp4(filePath)
                
            case (nil, _?):
                loadMp4(mp4Url)
//                Asyncs.mainDelay(3) { self.loadMp4(mp4Url) }
            case (_?, nil):
                loadLoopMp4(loopMp4Url)
//                Asyncs.mainDelay(3) { self.loadLoopMp4(loopMp4Url) }
            case (nil, nil):
                loadMp4(mp4Url)
                loadLoopMp4(loopMp4Url)
//                Asyncs.mainDelay(3) { self.loadMp4(mp4Url) }
//                Asyncs.mainDelay(3) { self.loadLoopMp4(loopMp4Url) }
            }
        }
    }
}

private extension RingerFXPlayer {
    func buildVapViewIfNeeded() {
        switch mode {
        case .none:
            return
        case let .mp4_svga(mp4Url, _, _, _):
            guard mp4Url.fa.isMp4Url else { return }
        case let .mp4_loopMp4(mp4Url, loopMp4Url):
            guard mp4Url.fa.isMp4Url || loopMp4Url.fa.isMp4Url else { return }
        }
        
        guard self.vapView == nil else { return }
        _updateMySize() // 此时mySize可能还没同步当前的视图尺寸（设置了frame但还没触发layoutSubviews），所以手动刷新一下
        let vapView = QGVAPWrapView(frame: CGRect(origin: .zero, size: mySize))
        switch contentMode {
        case .scaleAspectFill:
            vapView.contentMode = .aspectFill
        case .scaleAspectFit:
            vapView.contentMode = .aspectFit
        default:
            vapView.contentMode = .scaleToFill
        }
        vapView.autoDestoryAfterFinish = false
        vapView.isUserInteractionEnabled = false
        vapView.isHidden = true
        insertSubview(vapView, at: 0)
        self.vapView = vapView
    }
    
    func clearVapView() {
        guard let vapView else { return }
        vapView.isHidden = true
        vapView.stopHWDMP4()
    }
    
    func buildSvgaViewIfNeeded() {
        switch mode {
        case let .mp4_svga(_, svgaUrl, _, _):
            guard !svgaUrl.isEmpty else { return }
        default:
            return
        }
        
        guard self.svgaView == nil else { return }
        _updateMySize() // 此时mySize可能还没同步当前的视图尺寸（设置了frame但还没触发layoutSubviews），所以手动刷新一下
        let svgaView = SVGAExImageView(frame: CGRect(origin: .zero, size: mySize))
        svgaView.imageContentMode = contentMode
        svgaView.playerContentMode = contentMode
        svgaView.playerIsAutoPlay = false
        svgaView.isUserInteractionEnabled = false
        svgaView.isHidden = true
        if let vapView {
            insertSubview(svgaView, belowSubview: vapView)
        } else {
            insertSubview(svgaView, at: 0)
        }
        addSubview(svgaView)
        self.svgaView = svgaView
        
        svgaView.playerFinishedOnceHandler = { [weak self] player, _, _ in
            guard player.startFrame == 0 else { return }
            guard let self, self.status == .playing else { return }
            switch self.mode {
            case let .mp4_svga(_, _, _, svgaLoopFrame):
                guard svgaLoopFrame > 0 else { return }
                player.setStartFrameUntilTheEnd(svgaLoopFrame)
            default:
                break
            }
        }
    }
    
    func clearSvgaView() {
        guard let svgaView else { return }
        svgaView.isHidden = true
        svgaView.clean()
        svgaView.svgaResetStartFrameAndEndFrame()
        svgaView.svgaResetLoopCount()
    }
}

private extension RingerFXPlayer {
    func showLoading() {
        if let loading, loading.alpha == 0 {
            loading.show()
//            UIView.animate(withDuration: 0.2) {
//                loading.alpha = 1
//            } completion: { finished in
//                guard finished, !loading.isPlaying else { return }
//                loading.show()
//            }
            return
        }
        
        if let jvhua, jvhua.alpha == 0 {
            jvhua.startAnimating()
            UIView.animate(withDuration: 0.2) {
                jvhua.alpha = 1
            } completion: { finished in
                guard finished else { return }
                jvhua.startAnimating()
            }
            return
        }
    }
    
    func hideLoading() {
        if let loading, loading.alpha > 0 {
//            UIView.animate(withDuration: 0.2) {
//                loading.alpha = 0
//            } completion: { finished in
//                guard finished else { return }
//                loading.pause()
//            }
            loading.hide()
            return
        }
        
        if let jvhua, jvhua.alpha > 0 {
            UIView.animate(withDuration: 0.2) {
                jvhua.alpha = 0
            } completion: { finished in
                guard finished else { return }
                jvhua.stopAnimating()
            }
            return
        }
    }
}

private extension RingerFXPlayer {
    func loadMp4(_ mp4Url: String) {
        guard status == .loading else { return }
        guard mp4FilePath == nil, mp4LoadTag == nil else { return }
        
        guard mp4Url.fa.isMp4Url else {
            EML_DebugLog("\(myProfile)_不是MP4！")
            mp4FilePath = ""
            mp4LoadTag = nil
            tryPlay()
            return
        }
        
        guard mp4Url.fa.isRemoteUrl else {
            EML_DebugLog("\(myProfile)_是本地MP4！")
            mp4FilePath = mp4Url
            mp4LoadTag = nil
            tryPlay()
            return
        }
        
        let newTag = UUID()
        mp4LoadTag = newTag
        
        EML_DebugLog("\(myProfile)_MP4开始下载！")
        FallaDownloader.downloadMP4(from: mp4Url) { [weak self] videoPath in
            guard let self, self.mp4LoadTag == newTag else { return }
            EML_DebugLog("\(self.myProfile)_MP4下载成功！")
            self.mp4FilePath = videoPath
            self.mp4LoadTag = nil
            self.tryPlay()
        } failure: { [weak self] error in
            guard let self, self.mp4LoadTag == newTag else { return }
            EML_DebugLog("\(self.myProfile)_MP4下载失败！", error.message)
            self.terminateLoadingAndClear()
            self.status = .loadFailed
        }
    }
    
    func loadSvga(_ svgaUrl: String) {
        guard status == .loading else { return }
        guard svgaResult == nil, svgaLoadTag == nil else { return }
        
        let newTag = UUID()
        svgaLoadTag = newTag
        
        guard svgaUrl.fa.isSvgaUrl else {
            EML_DebugLog("\(myProfile)_不是SVGA！是图片！开始下载图片!")
            YYWebImageManager.shared().requestImage(with: URL(string: svgaUrl) ?? URL(fileURLWithPath: svgaUrl), progress: nil, transform: nil) { [weak self] image, _, _, _, _ in
                Asyncs.main {
                    guard let self, self.svgaLoadTag == newTag else { return }
                    if let image {
                        EML_DebugLog("\(self.myProfile)_图片下载成功！")
                        self.svgaResult = .image(image)
                        self.svgaLoadTag = nil
                        self.tryPlay()
                    } else {
                        EML_DebugLog("\(self.myProfile)_图片下载失败！")
                        self.terminateLoadingAndClear()
                        self.status = .loadFailed
                    }
                }
            }
            return
        }
        
        guard svgaUrl.fa.isRemoteUrl else {
            EML_DebugLog("\(myProfile)_是本地SVGA，直接解析！")
            var name = svgaUrl
            var components = name.components(separatedBy: ".")
            if components.count > 1 {
                components.removeAll { $0 == "svga" }
                name = components.joined(separator: ".")
            }
            SVGAParser().parse(withNamed: name, in: nil) { [weak self] entity in
                guard let self, self.svgaLoadTag == newTag else { return }
                EML_DebugLog("\(self.myProfile)_SVGA解析成功！")
                self.svgaResult = .entity(entity)
                self.svgaLoadTag = nil
                self.tryPlay()
            } failureBlock: { [weak self] error in
                guard let self, self.svgaLoadTag == newTag else { return }
                EML_DebugLog("\(self.myProfile)_SVGA解析失败！", error)
                self.terminateLoadingAndClear()
                self.status = .loadFailed
            }
            return
        }
        
        EML_DebugLog("\(myProfile)_SVGA开始下载！")
        FallaDownloader.downloadSVGA(from: svgaUrl) { [weak self] entity in
            guard let self, self.svgaLoadTag == newTag else { return }
            EML_DebugLog("\(self.myProfile)_SVGA下载成功！")
            self.svgaResult = .entity(entity)
            self.svgaLoadTag = nil
            self.tryPlay()
        } failure: { [weak self] error in
            guard let self, self.svgaLoadTag == newTag else { return }
            EML_DebugLog("\(self.myProfile)_SVGA下载失败！", error.message)
            self.terminateLoadingAndClear()
            self.status = .loadFailed
        }
    }
    
    func loadLoopMp4(_ loopMp4Url: String) {
        guard status == .loading else { return }
        guard loopMp4FilePath == nil, loopMp4LoadTag == nil else { return }
        
        guard loopMp4Url.fa.isMp4Url else {
            EML_DebugLog("\(myProfile)_不是MP4(loop)！")
            loopMp4FilePath = ""
            loopMp4LoadTag = nil
            tryPlay()
            return
        }
        
        guard loopMp4Url.fa.isRemoteUrl else {
            EML_DebugLog("\(myProfile)_是本地MP4(loop)！")
            loopMp4FilePath = loopMp4Url
            loopMp4LoadTag = nil
            tryPlay()
            return
        }
        
        let newTag = UUID()
        loopMp4LoadTag = newTag
        
        EML_DebugLog("\(myProfile)_MP4(loop)开始下载！")
        FallaDownloader.downloadMP4(from: loopMp4Url) { [weak self] videoPath in
            guard let self, self.loopMp4LoadTag == newTag else { return }
            EML_DebugLog("\(self.myProfile)_MP4(loop)下载成功！")
            self.loopMp4FilePath = videoPath
            self.loopMp4LoadTag = nil
            self.tryPlay()
        } failure: { [weak self] error in
            guard let self, self.loopMp4LoadTag == newTag else { return }
            EML_DebugLog("\(self.myProfile)_MP4(loop)下载失败！", error.message)
            self.terminateLoadingAndClear()
            self.status = .loadFailed
        }
    }
    
    func terminateLoadingAndClear() {
        mp4LoadTag = nil
        mp4FilePath = nil
        
        svgaLoadTag = nil
        svgaResult = nil
        
        loopMp4LoadTag = nil
        loopMp4FilePath = nil
    }
}

private extension RingerFXPlayer {
    func prePlaySvga(_ svgaResult: SvgaResult) {
        guard let svgaView else { return }
        svgaView.isHidden = true
        switch svgaResult {
        case let .entity(entity):
            svgaView.updateUI(source: .svgaEntity(entity))
        case let .image(image):
            svgaView.updateUI(source: .image(image))
        }
    }
    
    func playMp4(_ mp4FilePath: String) {
        if let vapView, !mp4FilePath.isEmpty {
            vapView.alpha = 0
            vapView.isHidden = false
            vapView.playHWDMP4(mp4FilePath, repeatCount: 0, delegate: self)
        } else {
            mp4PlayDoneHandling(animated: true)
        }
    }
}

private extension RingerFXPlayer {
    func mp4PlayDoneHandling(animated: Bool = false) {
        hideLoading()
        
        switch mode {
        case .none: break
            
        case .mp4_svga:
            vapView?.isHidden = true
            
            guard !isPlayingSvga else { return }
            isPlayingSvga = true
            
            guard let svgaView else { return }
            svgaView.alpha = animated ? 0 : 1
            svgaView.isHidden = false
            svgaView.svgaPlay()
            
            guard animated else { return }
            UIView.animate(withDuration: 0.2) {
                svgaView.alpha = 1
            }
            
        case .mp4_loopMp4:
            guard !isPlayingLoopMp4 else { return }
            isPlayingLoopMp4 = true
            
            if let loopMp4FilePath, !loopMp4FilePath.isEmpty {
                vapView?.alpha = 1
                vapView?.isHidden = false
                vapView?.playHWDMP4(loopMp4FilePath, repeatCount: -1, delegate: self)
            } else {
                vapView?.isHidden = true
            }
        }
    }
}

// MARK: - <VAPWrapViewDelegate>
extension RingerFXPlayer: VAPWrapViewDelegate {
    /// 能否继续播放即便没有window
    func vapWrap_shouldPlayMP4EvenIfWithoutWindow() -> Bool {
        return true
    }
    
    /// 在【子线程】调用
    func vapWrap_viewDidStartPlayMP4(_ container: UIView) {
        guard status == .playing else { return }
        EML_DebugLog("\(myProfile) MP4\(isPlayingLoopMp4 ? "(loop)" : "")开始")
        guard !isPlayingLoopMp4 else { return }
        Asyncs.main {
            self.hideLoading()
            guard let vapView = self.vapView else { return }
            vapView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                vapView.alpha = 1
            }
        }
    }
    
    /// 在【子线程】调用
    func vapWrap_viewDidPlayMP4(at frame: QGMP4AnimatedImageFrame, view container: UIView) {
        guard status == .playing else { return }
        guard !isPlayingSvga else { return }
//        EML_DebugLog("\(myProfile) MP4 playing:", frame.frameIndex)
        switch mode {
        case let .mp4_svga(_, _, svgaStartFrame, _):
            guard svgaStartFrame >= 0, frame.frameIndex >= svgaStartFrame else { return }
            isPlayingSvga = true
            Asyncs.main {
                self.hideLoading()
                self.svgaView?.isHidden = false
                self.svgaView?.svgaPlay()
            }
            
        default:
            break
        }
    }
    
    /// 在【主线程】调用
    func vapWrap_viewDidStopPlayMP4(_ lastFrameIndex: Int, view container: UIView, warpView: QGVAPWrapView) {
        guard status == .playing else { return }
        EML_DebugLog("\(myProfile) MP4\(isPlayingLoopMp4 ? "(loop)" : "")停止")
        mp4PlayDoneHandling()
    }
    
    /// 在【主线程】调用
    func vapWrap_viewDidFinishPlayMP4(_ totalFrameCount: Int, view container: UIView, warpView: QGVAPWrapView) {
        guard status == .playing else { return }
        EML_DebugLog("\(myProfile) MP4\(isPlayingLoopMp4 ? "(loop)" : "")结束")
        mp4PlayDoneHandling()
    }
    
    /// 在【主线程】调用
    func vapWrap_viewDidFailPlayMP4(_ error: Error, warpView: QGVAPWrapView) {
        guard status == .playing else { return }
        EML_DebugLog("\(myProfile) MP4\(isPlayingLoopMp4 ? "(loop)" : "")错误")
        mp4PlayDoneHandling()
    }
}








#if DEBUG
extension RingerFXPlayer.Mode {
    static var random: RingerFXPlayer.Mode {
        let a = Int.random(in: 0...3)
        switch a {
        case 0:
            return .random_mp4_svga
        case 1:
            return .random_mp4_loopMp4
        case 2:
            return .random_mp4_svga
        default:
            return .mp4_svga(
                mp4Url: "",
                svgaUrl: "https://res-g.resygg.com/awss3_2181270_1727230744080315674_3652981686.png"
            )
        }
    }
    
    static var random_mp4_svga: RingerFXPlayer.Mode {
        let mp4Url = [
            "https://falla-res1.resygg.com/awss3_10000_1695724766351253817_589304919.mp4",
            "https://res-g.resygg.com/awss3_3194919_1713334511778641780_3831139836.mp4",
            "https://res-g.resygg.com/awss3_3194919_1713751596204968921_1227064828.mp4",
        ].randomElement()!
        let svgaUrl: String = [
            "https://res-g.resygg.com/awss3_2181270_1747635248409103265_526331279.svga",
            "https://res-g.resygg.com/awss3_2181270_1746522080367787767_3837099942.svga",
            "https://res-g.resygg.com/awss3_4205041_1744189791364495910_3044406497.svga",
        ].randomElement()!
        return .mp4_svga(
            mp4Url: mp4Url,
            svgaUrl: svgaUrl,
            svgaLoopFrame: 40
        )
    }
    
    static var random_mp4_loopMp4: RingerFXPlayer.Mode {
        let mp4Url = [
            "https://falla-res1.resygg.com/awss3_10000_1695724766351253817_589304919.mp4",
            "https://res-g.resygg.com/awss3_3194919_1713334511778641780_3831139836.mp4",
            "https://res-g.resygg.com/awss3_3194919_1713751596204968921_1227064828.mp4",
        ].randomElement()!
        let loopMp4Url = [
            "https://falla-res1.resygg.com/awss3_10000_1695724766351253817_589304919.mp4",
            "https://res-g.resygg.com/awss3_3194919_1713334511778641780_3831139836.mp4",
            "https://res-g.resygg.com/awss3_3194919_1713751596204968921_1227064828.mp4",
        ].randomElement()!
        return .mp4_loopMp4(
            mp4Url: mp4Url,
            loopMp4Url: loopMp4Url
        )
    }
    
    static var random_svga: RingerFXPlayer.Mode {
        let svgaUrl: String = [
            "https://res-g.resygg.com/awss3_2181270_1747635248409103265_526331279.svga",
            "https://res-g.resygg.com/awss3_2181270_1746522080367787767_3837099942.svga",
            "https://res-g.resygg.com/awss3_4205041_1744189791364495910_3044406497.svga",
        ].randomElement()!
        return .mp4_svga(
            mp4Url: "",
            svgaUrl: svgaUrl,
            svgaLoopFrame: 40
        )
    }
    
    static var feiji_mp4_loopMp4: RingerFXPlayer.Mode {
        .mp4_loopMp4(
            mp4Url: Bundle.main.path(forResource: "feiji1", ofType: "mp4")!,
            loopMp4Url: Bundle.main.path(forResource: "feiji2", ofType: "mp4")!
        )
    }
}
#endif
