//
//  CosmicExplorationHostView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit

class CosmicExplorationHostView: UIView {
    
    var bgLottieName: String = ""
    let bgAnimView: LottieAnimationView = LottieAnimationView(animation: nil, imageProvider: nil)
    
    let countdownView = CountdownView()
    
    init() {
        super.init(frame: [0, 0, PortraitScreenWidth, PortraitScreenWidth])
        
        bgAnimView.backgroundBehavior = .pauseAndRestore
        bgAnimView.contentMode = .scaleAspectFill
        bgAnimView.frame = bounds
        bgAnimView.alpha = 0
        addSubview(bgAnimView)
        
        addSubview(countdownView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func updateStage(_ stage: CosmicExploration.Stage, _ oldStage: CosmicExploration.Stage, animated: Bool) {
        updateBgAnim(stage, oldStage)
        countdownView.updateStage(stage, oldStage)
    }
}

// MARK: - 背景动画
extension CosmicExplorationHostView {
    func updateBgAnim(_ stage: CosmicExploration.Stage, _ oldStage: CosmicExploration.Stage) {
        var bgLottieName = ""
        switch stage {
        case .supplying:
            bgLottieName = "spaceship_normal_lottie"
        case let .exploring(second):
            bgLottieName = self.bgLottieName
            switch oldStage {
            case .exploring:
                break
            default:
                if second == 5 {
                    bgLottieName = "spaceship_launch_lottie"
                } else {
                    countdownView.alpha = 1
                }
            }
        default:
            break
        }
        guard self.bgLottieName != bgLottieName else { return }
        self.bgLottieName = bgLottieName
        
        bgAnimView.stop()
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(bgLottieName)"),
              let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else {
            UIView.animate(withDuration: 0.18) {
                self.bgAnimView.alpha = 0
            }
            return
        }
        bgAnimView.animation = animation
        bgAnimView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        if bgLottieName == "spaceship_launch_lottie" {
            UIView.animate(withDuration: 0.12) {
                self.countdownView.alpha = 0
            }
            bgAnimView.loopMode = .playOnce
            bgAnimView.play { [weak self] _ in
                guard let self = self, self.bgLottieName == "spaceship_launch_lottie" else { return }
                self.bgAnimView.alpha = 0
                UIView.animate(withDuration: 0.12) {
                    self.countdownView.alpha = 1
                }
            }
        } else {
            bgAnimView.loopMode = .loop
            bgAnimView.play()
        }
        bgAnimView.alpha = 1
    }
}

// MARK: - 倒计时
extension CosmicExplorationHostView {
    class CountdownView: UIView {
        var lottieName: String = ""
        let animView: LottieAnimationView = LottieAnimationView(animation: nil, imageProvider: nil)
        
        var second: Int? = nil
        let s1ImgView = UIImageView()
        let s2ImgView = UIImageView()
        let sImgView = UIImageView()
        
        var titleImgName: String = ""
        let titleImgView = UIImageView()
        
        var subtitle = ""
        let subtitleLabel = UILabel()
        
        init() {
            super.init(frame: [HalfDiffValue(PortraitScreenWidth, 200.px), 100.px, 200.px, 200.px])
            
            subtitleLabel.font = .systemFont(ofSize: 9.px)
            subtitleLabel.textColor = .rgb(187, 236, 255)
            subtitleLabel.textAlignment = .center
            
            sImgView.image = UIImage(named: "spaceship_num_s")
            
            addSubview(animView)
            addSubview(s1ImgView)
            addSubview(s2ImgView)
            addSubview(sImgView)
            addSubview(titleImgView)
            addSubview(subtitleLabel)
            
            alpha = 0
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateStage(_ stage: CosmicExploration.Stage, _ oldStage: CosmicExploration.Stage) {
            var alpha: CGFloat
            
            var lottieName = self.lottieName
            var titleImgName = self.titleImgName
            var subtitle = self.subtitle
            var second = self.second
            
            var animViewFrame = animView.frame
            var s1ImgViewFrame = s1ImgView.frame
            var s2ImgViewFrame = s2ImgView.frame
            var sImgViewFrame = sImgView.frame
            var titleImgViewFrame = titleImgView.frame
            var subtitleLabelFrame = subtitleLabel.frame
            var subtitleLabelAlpha = subtitleLabel.alpha
            
            switch stage {
            case .idle:
                alpha = 0

            case let .supplying(s):
                alpha = 1
                second = Int(s)
                
                switch oldStage {
                case .supplying: break
                default:
                    lottieName = "spaceship_countdown_lottie"
                    titleImgName = "spaceship_ supply_txt"
                    subtitle = "飞船即将出发，请选择目的地填充补给"
                    animViewFrame = [HalfDiffValue(frame.width, 135.px), 36.px, 135.px, 70.px]
                    s1ImgViewFrame = [75.px, 64.px, 16.px, 27.px]
                    s2ImgViewFrame = [92.px, 64.px, 16.px, 27.px]
                    sImgViewFrame = [109.px, 64.px, 16.px, 27.px]
                    titleImgViewFrame = [HalfDiffValue(frame.width, 135.px), 108.px, 135.px, 27.px]
                    subtitleLabelFrame = [0, 138.px, frame.width, 12.px]
                    subtitleLabelAlpha = 1
                }
                
            case let .exploring(s):
                alpha = self.alpha
                second = Int(s)
                
                switch oldStage {
                case .exploring: break
                default:
                    lottieName = "spaceship_countdown_lottie"
                    titleImgName = "spaceship_ start_txt"
                    subtitle = "飞船正在宇宙中探索…"
                    animViewFrame = [HalfDiffValue(frame.width, 135.px), 36.px, 135.px, 70.px]
                    s1ImgViewFrame = [75.px, 64.px, 16.px, 27.px]
                    s2ImgViewFrame = [92.px, 64.px, 16.px, 27.px]
                    sImgViewFrame = [109.px, 64.px, 16.px, 27.px]
                    titleImgViewFrame = [HalfDiffValue(frame.width, 135.px), 108.px, 135.px, 27.px]
                    subtitleLabelFrame = [0, 138.px, frame.width, 12.px]
                    subtitleLabelAlpha = 1
                }
                
            case let .finish(isDiscover, s):
                alpha = 1
                second = Int(s)
                
                switch oldStage {
                case .finish: break
                default:
                    lottieName = "spaceship_countdown_s_lottie"
                    titleImgName = isDiscover ? "spaceship_result_txt04" : "spaceship_fail_txt"
                    animViewFrame = [HalfDiffValue(frame.width, 135.px), 99.px, 135.px, 60.px]
                    s1ImgViewFrame = [82.px, 125.px, 11.5.px, 20.px]
                    s2ImgViewFrame = [(94.5).px, 125.px, 11.5.px, 20.px]
                    sImgViewFrame = [107.px, 125.px, 11.5.px, 20.px]
                    titleImgViewFrame = [HalfDiffValue(frame.width, 150.px), 44.px, 150.px, 50.px]
                    subtitleLabelAlpha = 0
                }
            }
            
            if lottieName != self.lottieName {
                self.lottieName = lottieName
                animView.stop()
                if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(lottieName)"),
                   let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
                    animView.animation = animation
                    animView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
                    animView.loopMode = .playOnce
                    animView.play()
                    animView.alpha = 1
                } else {
                    animView.alpha = 0
                }
            }
            
            if titleImgName != self.titleImgName {
                self.titleImgName = titleImgName
                self.titleImgView.image = UIImage(named: titleImgName)
            }
            
            if subtitle != self.subtitle {
                self.subtitle = subtitle
                self.subtitleLabel.text = subtitle
            }
            
            if second != self.second {
                self.second = second
                updateSecond()
            }
            
            animView.frame = animViewFrame
            s1ImgView.frame = s1ImgViewFrame
            s2ImgView.frame = s2ImgViewFrame
            sImgView.frame = sImgViewFrame
            titleImgView.frame = titleImgViewFrame
            subtitleLabel.frame = subtitleLabelFrame
            subtitleLabel.alpha = subtitleLabelAlpha
            
            if alpha != self.alpha {
                UIView.animate(withDuration: 0.18) {
                    self.alpha = alpha
                }
            }
        }
        
        func updateSecond() {
            guard let second = self.second else {
                s1ImgView.alpha = 0
                s2ImgView.alpha = 0
                sImgView.alpha = 0
                return
            }
            
            s1ImgView.image = numImg(second / 10)
            s2ImgView.image = numImg(second % 10)
            
            s1ImgView.alpha = 1
            s2ImgView.alpha = 1
            sImgView.alpha = 1
        }
        
        func numImg(_ num: Int) -> UIImage? {
            switch num {
            case 0:
                return UIImage(named: "spaceship_num_0")
            case 1:
                return UIImage(named: "spaceship_num_1")
            case 2:
                return UIImage(named: "spaceship_num_2")
            case 3:
                return UIImage(named: "spaceship_num_3")
            case 4:
                return UIImage(named: "spaceship_num_4")
            case 5:
                return UIImage(named: "spaceship_num_5")
            case 6:
                return UIImage(named: "spaceship_num_6")
            case 7:
                return UIImage(named: "spaceship_num_7")
            case 8:
                return UIImage(named: "spaceship_num_8")
            case 9:
                return UIImage(named: "spaceship_num_9")
            default:
                return nil
            }
        }
    }
}
