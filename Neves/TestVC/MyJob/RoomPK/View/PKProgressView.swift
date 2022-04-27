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
        
        bottomImgView.isHidden = true
        
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
    
    func update(leftCount: Int, rightCount: Int, progress: CGFloat) {
        leftCountLabel.text = "\(leftCount)"
        rightCountLabel.text = "\(rightCount)"
        
        let progressValue = progress * totalProgress
        posAnimView.frame.origin.x = progressValue
        leftProgressMaskView.frame.size.width = 25 + progressValue
    }
    
    func playStartAnim() {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_start_lottie"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else { return }
        
        let startAnimView = AnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
        startAnimView.backgroundBehavior = .pauseAndRestore
        startAnimView.contentMode = .scaleAspectFit
        startAnimView.frame = [0, HalfDiffValue(frame.height, 300), PortraitScreenWidth, 300]
        startAnimView.loopMode = .playOnce
        startAnimView.isUserInteractionEnabled = false
        addSubview(startAnimView)
        startAnimView.play { [weak startAnimView] _ in
            startAnimView?.removeFromSuperview()
        }
    }
    
    func playStartPeakAnim() {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_duel_start_lottie"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else { return }
        
        let startPeakAnimView = AnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
        startPeakAnimView.backgroundBehavior = .pauseAndRestore
        startPeakAnimView.contentMode = .scaleAspectFit
        startPeakAnimView.frame = [0, HalfDiffValue(frame.height, 300), PortraitScreenWidth, 300]
        startPeakAnimView.loopMode = .playOnce
        startPeakAnimView.isUserInteractionEnabled = false
        addSubview(startPeakAnimView)
        startPeakAnimView.play { [weak startPeakAnimView] _ in
            startPeakAnimView?.removeFromSuperview()
        }
    }
    
    func playPeakingAnim() {
        guard peakingAnimView == nil,
              let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_duel_lightning_lottie"),
              let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else { return }
        
        let peakingAnimView = AnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
        peakingAnimView.backgroundBehavior = .pauseAndRestore
        peakingAnimView.contentMode = .scaleAspectFit
        peakingAnimView.frame = [0, HalfDiffValue(frame.height, 300), PortraitScreenWidth, 300]
        peakingAnimView.loopMode = .loop
        peakingAnimView.isUserInteractionEnabled = false
        addSubview(peakingAnimView)
        peakingAnimView.play()
        self.peakingAnimView = peakingAnimView
    }
    
    func stopAnim() {
        peakingAnimView?.stop()
        peakingAnimView?.removeFromSuperview()
        peakingAnimView = nil
    }
}



