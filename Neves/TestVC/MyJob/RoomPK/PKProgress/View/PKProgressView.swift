//
//  PKProgressView.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

import UIKit

class PKProgressView: UIView {
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressBgView: UIView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var leftProgressView: UIImageView!
    @IBOutlet weak var rightProgressView: UIImageView!
    @IBOutlet weak var leftCountLabel: UILabel!
    @IBOutlet weak var rightCountLabel: UILabel!
    @IBOutlet weak var leftCollectionView: PKProgressRankListView!
    @IBOutlet weak var rightCollectionView: PKProgressRankListView!
    @IBOutlet weak var bottomImgView: UIImageView!
    
    @IBOutlet weak var progressBgViewTopConstraint: NSLayoutConstraint!
    
    let totalProgress = PortraitScreenWidth - 50
    let leftProgressMaskView = UIView(frame: [-5, 0, 0, 15])
    let posAnimView = AnimationView(animation: nil, imageProvider: nil)
    var peakingAnimView: AnimationView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        
        progressContainerView.layer.cornerRadius = 7.5
        progressContainerView.layer.masksToBounds = true
        
        rightCollectionView.setupRightAligned()
        
        bottomImgView.alpha = 0
        
        leftProgressMaskView.backgroundColor = .black
        leftProgressView.mask = leftProgressMaskView
        
        posAnimView.backgroundBehavior = .pauseAndRestore
        posAnimView.contentMode = .scaleAspectFill
        posAnimView.frame = [0, 25, 50, 33]
        posAnimView.loopMode = .loop
        addSubview(posAnimView)
        if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_room_progressbar_lottie"),
           let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
            posAnimView.animation = animation
            posAnimView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
            posAnimView.play()
        }
        
        update(leftCount: 0, rightCount: 0, progress: 0.5)
    }
    
    deinit {
        JPrint("PKProgressView 寿寝正终")
    }
    
    func update(leftCount: Int, rightCount: Int, progress: CGFloat) {
        leftCountLabel.text = "\(leftCount)"
        rightCountLabel.text = "\(rightCount)"
        
        let progressValue = progress * totalProgress
        posAnimView.frame.origin.x = progressValue
        leftProgressMaskView.frame.size.width = 25 + progressValue
    }
    
    func showOrHideBottomImgView(_ isShow: Bool) {
        UIView.animate(withDuration: 0.12) {
            self.bottomImgView.alpha = isShow ? 1 : 0
        }
    }
    
    func playStartAnim() {
        playAnim(lottieName: "pk_start_lottie", isOnec: true)
    }
    
    func playStartPeakAnim() {
        playAnim(lottieName: "pk_duel_start_lottie", isOnec: true)
    }
    
    func playPeakingAnim() {
        guard peakingAnimView == nil else { return }
        peakingAnimView = playAnim(lottieName: "pk_duel_lightning_lottie", isOnec: false)
    }
    
    func stopPeakingAnim() {
        peakingAnimView?.stop()
        peakingAnimView?.removeFromSuperview()
        peakingAnimView = nil
    }
    
    @discardableResult
    private func playAnim(lottieName: String, isOnec: Bool) -> AnimationView? {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(lottieName)"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else { return nil }
        
        let animView = AnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
        animView.backgroundBehavior = .pauseAndRestore
        animView.contentMode = .scaleAspectFit
        animView.frame = [0, HalfDiffValue(frame.height, 300), PortraitScreenWidth, 300]
        animView.loopMode = isOnec ? .playOnce : .loop
        animView.isUserInteractionEnabled = false
        addSubview(animView)
        
        if isOnec {
            animView.play { [weak animView] _ in
                animView?.removeFromSuperview()
            }
        } else {
            animView.play()
        }
        
        return animView
    }
}


