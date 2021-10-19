//
//  SolitaireCalculationViewController.swift
//  Neves
//
//  Created by aa on 2021/10/19.
//

import UIKit

class SolitaireCalculationViewController: TestBaseViewController {
    
    let animLayer = UIView()
    let userIcon1 = UIImageView()
    let userIcon2 = UIImageView()
    let userIcon3 = UIImageView()
    
    let slider = UISlider()
    let drawView = UIImageView()
        
    let scale: CGFloat = 5.0 / 7.0
    
    let duration: TimeInterval = 0.6
    let anim1Duration: TimeInterval = 6
    let anim2Duration: TimeInterval = 8
    let anim3Duration: TimeInterval = 17
    lazy var totalDuration: TimeInterval = anim1Duration + anim2Duration + anim3Duration
    
    let frameInterval: Int = 24
    lazy var anim1Range: ClosedRange =
        Int(anim1Duration * TimeInterval(frameInterval)) ...
        Int((anim1Duration + duration) * TimeInterval(frameInterval))
    
    lazy var anim2Range: ClosedRange =
        Int((anim1Duration + anim2Duration) * TimeInterval(frameInterval)) ...
        Int(((anim1Duration + anim2Duration) + duration) * TimeInterval(frameInterval))
    
    lazy var totalFrame: Int = Int((anim1Duration + anim2Duration + anim3Duration) * TimeInterval(frameInterval))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animLayer.frame = [HalfDiffValue(PortraitScreenWidth, 360), NavTopMargin + 20, 360, 360]
        animLayer.backgroundColor = .randomColor
        animLayer.clipsToBounds = true
        view.addSubview(animLayer)
        
        userIcon1.image = UIImage(named: "jp_icon")
        userIcon1.contentMode = .scaleAspectFill
        userIcon1.frame = [0, 0, 70, 70]
        userIcon1.center = [CGFloat(360 - 83 - 35), 180]
        userIcon1.layer.cornerRadius = 35
        userIcon1.layer.masksToBounds = true
        animLayer.addSubview(userIcon1)
        
        userIcon2.image = UIImage(named: "jp_icon")
        userIcon2.contentMode = .scaleAspectFill
        userIcon2.frame = [0, 0, 70, 70]
        userIcon2.alpha = 0.5
        userIcon2.transform = CGAffineTransform(scaleX: scale, y: scale)
        userIcon2.center = [CGFloat(167 + 25), CGFloat(255 + 25)]
        userIcon2.layer.cornerRadius = 35
        userIcon2.layer.masksToBounds = true
        animLayer.addSubview(userIcon2)
        
        userIcon3.image = UIImage(named: "jp_icon")
        userIcon3.contentMode = .scaleAspectFill
        userIcon3.frame = [0, 0, 70, 70]
        userIcon3.alpha = 0.5
        userIcon3.transform = CGAffineTransform(scaleX: scale, y: scale)
        userIcon3.center = [CGFloat(132 + 25), CGFloat(325 + 25)]
        userIcon3.layer.cornerRadius = 35
        userIcon3.layer.masksToBounds = true
        animLayer.addSubview(userIcon3)
        
        slider.frame = [30, animLayer.frame.maxY + 20, PortraitScreenWidth - 60, 20]
        slider.minimumValue = 0
        slider.maximumValue = Float(anim1Duration + anim2Duration + anim3Duration)
        slider.addTarget(self, action: #selector(sliderDidChanged(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        let btn1 = UIButton(type: .system)
        btn1.titleLabel?.font = .systemFont(ofSize: 15)
        btn1.setTitle("播放动画", for: .normal)
        btn1.setTitleColor(.randomColor, for: .normal)
        btn1.backgroundColor = .randomColor
        btn1.frame = [30, slider.maxY + 20, 80, 40]
        btn1.addTarget(self, action: #selector(playAnim), for: .touchUpInside)
        view.addSubview(btn1)
        
        let btn2 = UIButton(type: .system)
        btn2.titleLabel?.font = .systemFont(ofSize: 15)
        btn2.setTitle("截取一帧", for: .normal)
        btn2.setTitleColor(.randomColor, for: .normal)
        btn2.backgroundColor = .randomColor
        btn2.frame = [CGFloat(80 + 10 + 30), slider.maxY + 20, 80, 40]
        btn2.addTarget(self, action: #selector(drawAnim), for: .touchUpInside)
        view.addSubview(btn2)
        
        let btn3 = UIButton(type: .system)
        btn3.titleLabel?.font = .systemFont(ofSize: 15)
        btn3.setTitle("制作视频", for: .normal)
        btn3.setTitleColor(.randomColor, for: .normal)
        btn3.backgroundColor = .randomColor
        btn3.frame = [CGFloat(CGFloat(80 + 10) * 2 + 30), slider.maxY + 20, 80, 40]
        btn3.addTarget(self, action: #selector(makeVideo), for: .touchUpInside)
        view.addSubview(btn3)
        
        drawView.frame = [HalfDiffValue(PortraitScreenWidth, 150), btn2.maxY + 20, 150, 150]
        drawView.backgroundColor = .randomColor
        drawView.contentMode = .scaleAspectFit
        view.addSubview(drawView)
    }
    
    @objc func sliderDidChanged(_ slider: UISlider) {
        let currentTime = CGFloat(slider.value)
        JPrint(currentTime)
        
        let currentFrame = Int(currentTime * CGFloat(frameInterval))
        updateUserIcons(currentFrame)
    }
     
    func updateUserIcons(_ currentFrame: Int) {
        var sourceAlpha1: CGFloat = 1
        var targetAlpha1: CGFloat = 1
        var sourceScale1: CGFloat = 1
        var targetScale1: CGFloat = 1
        var sourceCenter1: CGPoint = [CGFloat(360 - 83 - 35), 180]
        var targetCenter1: CGPoint = [CGFloat(360 - 83 - 35), 180]
        
        var sourceAlpha2: CGFloat = 0.5
        var targetAlpha2: CGFloat = 0.5
        var sourceScale2: CGFloat = scale
        var targetScale2: CGFloat = scale
        var sourceCenter2: CGPoint = [CGFloat(167 + 25), CGFloat(255 + 25)]
        var targetCenter2: CGPoint = [CGFloat(167 + 25), CGFloat(255 + 25)]
        
        var sourceAlpha3: CGFloat = 0.5
        var targetAlpha3: CGFloat = 0.5
        var sourceScale3: CGFloat = scale
        var targetScale3: CGFloat = scale
        var sourceCenter3: CGPoint = [CGFloat(132 + 25), CGFloat(325 + 25)]
        var targetCenter3: CGPoint = [CGFloat(132 + 25), CGFloat(325 + 25)]
        
        var progress: CGFloat = 1
        
        switch currentFrame {
        case anim1Range:
            let lowerFrame = CGFloat(anim1Range.lowerBound)
            let upperFrame = CGFloat(anim1Range.upperBound)
            progress = (CGFloat(currentFrame) - lowerFrame) / (upperFrame - lowerFrame)
            
            sourceAlpha1 = 1
            targetAlpha1 = 0.5
            sourceScale1 = 1
            targetScale1 = scale
            sourceCenter1 = [CGFloat(360 - 83 - 35), 180]
            targetCenter1 = CGPoint(x: 167 + 25, y: 55 + 25)
            
            sourceAlpha2 = 0.5
            targetAlpha2 = 1
            sourceScale2 = scale
            targetScale2 = 1
            sourceCenter2 = [CGFloat(167 + 25), CGFloat(255 + 25)]
            targetCenter2 = [CGFloat(360 - 83 - 35), 180]
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 0.5
            sourceScale3 = scale
            targetScale3 = scale
            sourceCenter3 = [CGFloat(132 + 25), CGFloat(325 + 25)]
            targetCenter3 = [CGFloat(167 + 25), CGFloat(255 + 25)]
            
        case anim2Range:
            let lowerFrame = CGFloat(anim2Range.lowerBound)
            let upperFrame = CGFloat(anim2Range.upperBound)
            progress = (CGFloat(currentFrame) - lowerFrame) / (upperFrame - lowerFrame)
            
            sourceAlpha1 = 0.5
            targetAlpha1 = 0.5
            sourceScale1 = scale
            targetScale1 = scale
            sourceCenter1 = CGPoint(x: 167 + 25, y: 55 + 25)
            targetCenter1 = CGPoint(x: 132 + 25, y: -15 + 25)
            
            sourceAlpha2 = 1
            targetAlpha2 = 0.5
            sourceScale2 = 1
            targetScale2 = scale
            sourceCenter2 = [CGFloat(360 - 83 - 35), 180]
            targetCenter2 = CGPoint(x: 167 + 25, y: 55 + 25)
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 1
            sourceScale3 = scale
            targetScale3 = 1
            sourceCenter3 = [CGFloat(167 + 25), CGFloat(255 + 25)]
            targetCenter3 = [CGFloat(360 - 83 - 35), 180]
            
        case 0 ... anim1Range.lowerBound:
            sourceAlpha1 = 1
            targetAlpha1 = 1
            sourceScale1 = 1
            targetScale1 = 1
            sourceCenter1 = [CGFloat(360 - 83 - 35), 180]
            targetCenter1 = [CGFloat(360 - 83 - 35), 180]
            
            sourceAlpha2 = 0.5
            targetAlpha2 = 0.5
            sourceScale2 = scale
            targetScale2 = scale
            sourceCenter2 = [CGFloat(167 + 25), CGFloat(255 + 25)]
            targetCenter2 = [CGFloat(167 + 25), CGFloat(255 + 25)]
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 0.5
            sourceScale3 = scale
            targetScale3 = scale
            sourceCenter3 = [CGFloat(132 + 25), CGFloat(325 + 25)]
            targetCenter3 = [CGFloat(132 + 25), CGFloat(325 + 25)]
            
            
        case anim1Range.upperBound ... anim2Range.lowerBound:
            sourceAlpha1 = 0.5
            targetAlpha1 = 0.5
            sourceScale1 = scale
            targetScale1 = scale
            sourceCenter1 = CGPoint(x: 167 + 25, y: 55 + 25)
            targetCenter1 = CGPoint(x: 167 + 25, y: 55 + 25)
            
            sourceAlpha2 = 1
            targetAlpha2 = 1
            sourceScale2 = 1
            targetScale2 = 1
            sourceCenter2 = [CGFloat(360 - 83 - 35), 180]
            targetCenter2 = [CGFloat(360 - 83 - 35), 180]
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 0.5
            sourceScale3 = scale
            targetScale3 = scale
            sourceCenter3 = [CGFloat(167 + 25), CGFloat(255 + 25)]
            targetCenter3 = [CGFloat(167 + 25), CGFloat(255 + 25)]
            
            
        case anim2Range.upperBound... :
            sourceAlpha1 = 0.5
            targetAlpha1 = 0.5
            sourceScale1 = scale
            targetScale1 = scale
            sourceCenter1 = CGPoint(x: 132 + 25, y: -15 + 25)
            targetCenter1 = CGPoint(x: 132 + 25, y: -15 + 25)
            
            sourceAlpha2 = 0.5
            targetAlpha2 = 0.5
            sourceScale2 = scale
            targetScale2 = scale
            sourceCenter2 = CGPoint(x: 167 + 25, y: 55 + 25)
            targetCenter2 = CGPoint(x: 167 + 25, y: 55 + 25)
            
            sourceAlpha3 = 1
            targetAlpha3 = 1
            sourceScale3 = 1
            targetScale3 = 1
            sourceCenter3 = [CGFloat(360 - 83 - 35), 180]
            targetCenter3 = [CGFloat(360 - 83 - 35), 180]
            
        default: break
        }
        
        updateUserIcon(userIcon1,
                       sourceAlpha: sourceAlpha1, targetAlpha: targetAlpha1,
                       sourceScale: sourceScale1, targetScale: targetScale1,
                       sourceCenter: sourceCenter1, targetCenter: targetCenter1,
                       progress: progress)
        
        updateUserIcon(userIcon2,
                       sourceAlpha: sourceAlpha2, targetAlpha: targetAlpha2,
                       sourceScale: sourceScale2, targetScale: targetScale2,
                       sourceCenter: sourceCenter2, targetCenter: targetCenter2,
                       progress: progress)
        
        updateUserIcon(userIcon3,
                       sourceAlpha: sourceAlpha3, targetAlpha: targetAlpha3,
                       sourceScale: sourceScale3, targetScale: targetScale3,
                       sourceCenter: sourceCenter3, targetCenter: targetCenter3,
                       progress: progress)
    }
    
    @objc func playAnim() {
        
    }
    
    
    
    func updateUserIcon(_ userIcon: UIView,
                        sourceAlpha: CGFloat, targetAlpha: CGFloat,
                        sourceScale: CGFloat, targetScale: CGFloat,
                        sourceCenter: CGPoint, targetCenter: CGPoint,
                        progress: CGFloat) {
        
        let alpha = sourceAlpha + (targetAlpha - sourceAlpha) * progress
        let scale = sourceScale + (targetScale - sourceScale) * progress
        let centerX = sourceCenter.x + (targetCenter.x - sourceCenter.x) * progress
        let centerY = sourceCenter.y + (targetCenter.y - sourceCenter.y) * progress
        
        userIcon.alpha = alpha
        userIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
        userIcon.center = [centerX, centerY]
    }
    
    @objc func drawAnim() {
        let animLayer = animLayer.layer
        let size = animLayer.frame.size
        Asyncs.async {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            defer { UIGraphicsEndImageContext() }
            
            guard let ctx = UIGraphicsGetCurrentContext() else {
                JPrint("失败")
                return
            }
            
//            DispatchQueue.main.sync {
            animLayer.render(in: ctx)
//            }
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                JPrint("失败")
                return
            }
            
            Asyncs.main {
                self.drawView.backgroundColor = .randomColor
                self.drawView.image = image
            }
        }
    }
    
    @objc func makeVideo() {
        
        JPProgressHUD.show()
        
//        Asyncs.async {
//
//            let size: CGSize = [360, 360]
//
//            UIGraphicsBeginImageContextWithOptions(size, false, 1)
//
//            guard let ctx = UIGraphicsGetCurrentContext() else {
//                UIGraphicsEndImageContext()
//                Asyncs.main {
//                    JPProgressHUD.showError(withStatus: "失败", userInteractionEnabled: true)
//                }
//                return
//            }
//
//            let lock = DispatchSemaphore(value: 0)
//            VideoMaker.createVideo(framerate: self.frameInterval, frameInterval: self.frameInterval, duration: self.totalDuration, size: size) { currentFrame, _ in
//
//                // 画
//                ctx.saveGState()
//
//                // 渲染
//                DispatchQueue.main.sync {
//                    self.updateUserIcons(currentFrame)
//                    self.animLayer.layer.render(in: ctx)
//                    lock.signal()
//                }
//                lock.wait()
//
//
//                let image = UIGraphicsGetImageFromCurrentImageContext()
//
//                ctx.clear(CGRect(origin: .zero, size: size))
//                ctx.restoreGState()
//
//                return image
//
//            } completion: { result in
//                UIGraphicsEndImageContext()
//                Asyncs.main {
//                    switch result {
//                    case let .success(path):
//                        JPProgressHUD.showSuccess(withStatus: "成功！", userInteractionEnabled: true)
//                        JPrint("视频路径", path)
//                    case .failure:
//                        JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
//                    }
//                }
//            }
//
//        }
        
        VideoMaker.makeVideo(framerate: frameInterval, frameInterval: frameInterval, duration: totalDuration, size: [360, 360]) { currentFrame, _, _ in
            JPrint(currentFrame)
            self.updateUserIcons(currentFrame)
            return [self.animLayer.layer]
        } completion: { result in
            switch result {
            case let .success(path):
                JPProgressHUD.showSuccess(withStatus: "成功！", userInteractionEnabled: true)
                JPrint("视频路径", path)
            case .failure:
                JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
            }
        }
        
    }
}

