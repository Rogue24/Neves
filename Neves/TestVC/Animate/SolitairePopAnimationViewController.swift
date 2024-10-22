//
//  SolitairePopAnimationViewController.swift
//  Neves
//
//  Created by aa on 2021/10/18.
//

//
//  SolitaireAnimationViewController.swift
//  Neves
//
//  Created by aa on 2021/10/18.
//

import UIKit

class SolitairePopAnimationViewController: TestBaseViewController {
    
    let animLayer = CALayer()
    let userIcon1 = CALayer()
    let userIcon2 = CALayer()
    let userIcon3 = CALayer()
    
    let slider = UISlider()
    let drawView = UIImageView()
        
    let scale: CGFloat = 5.0 / 7.0
    
    var beginTime: TimeInterval = 0
    var pausedTime: TimeInterval = 0
    var isAddedAnim = false
    
    let anim1Duration: TimeInterval = 6
    let anim2Duration: TimeInterval = 8
    let anim3Duration: TimeInterval = 17
    let duration: TimeInterval = 0.6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animLayer.frame = [HalfDiffValue(PortraitScreenWidth, 360), NavTopMargin + 20, 360, 360]
        animLayer.backgroundColor = UIColor.randomColor.cgColor
        animLayer.masksToBounds = true
        view.layer.addSublayer(animLayer)
        
        userIcon1.contents = UIImage(named: "jp_icon")?.cgImage
        userIcon1.contentsGravity = .resizeAspectFill
        userIcon1.frame = [0, 0, 70, 70]
        userIcon1.position = [CGFloat(360 - 83 - 35), 180]
        userIcon1.cornerRadius = 35
        userIcon1.masksToBounds = true
        animLayer.addSublayer(userIcon1)
        
        userIcon2.contents = UIImage(named: "jp_icon")?.cgImage
        userIcon2.contentsGravity = .resizeAspectFill
        userIcon2.frame = [0, 0, 70, 70]
        userIcon2.opacity = 0.5
        userIcon2.transform = CATransform3DMakeScale(scale, scale, 1)
        userIcon2.position = [CGFloat(167 + 25), CGFloat(255 + 25)]
        userIcon2.cornerRadius = 35
        userIcon2.masksToBounds = true
        animLayer.addSublayer(userIcon2)
        
        userIcon3.contents = UIImage(named: "jp_icon")?.cgImage
        userIcon3.contentsGravity = .resizeAspectFill
        userIcon3.frame = [0, 0, 70, 70]
        userIcon3.opacity = 0.5
        userIcon3.transform = CATransform3DMakeScale(scale, scale, 1)
        userIcon3.position = [CGFloat(132 + 25), CGFloat(325 + 25)]
        userIcon3.cornerRadius = 35
        userIcon3.masksToBounds = true
        animLayer.addSublayer(userIcon3)
        
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
        
        let maxTime = anim1Duration + anim2Duration + duration
        if currentTime > maxTime {
            pausedTime = beginTime + maxTime
        } else {
            pausedTime = beginTime + currentTime
        }
        
        userIcon1.timeOffset = pausedTime
        userIcon2.timeOffset = pausedTime
        userIcon3.timeOffset = pausedTime
        
        let an = POPBasicAnimation(propertyNamed: kPOPLayerPosition)
        an?.isPaused = true
    }
    
    @objc func playAnim() {
        guard !isAddedAnim else {
            JPrint("已经加了动画")
            return
        }
        isAddedAnim = true
        JPrint("开始添加动画")
        
        userIcon1.pop_removeAllAnimations()
        userIcon2.pop_removeAllAnimations()
        userIcon3.pop_removeAllAnimations()
        
        userIcon1.speed = 0.0
        userIcon2.speed = 0.0
        userIcon3.speed = 0.0
        
        // 6
        // 8
        // 17
        
        beginTime = CACurrentMediaTime()
        var beginTime = beginTime + anim1Duration
        
        userIcon(userIcon1,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 1,
                 toOpacity: 0.5,
                 fromScale: 1,
                 toScale: scale,
                 fromPosition: CGPoint(x: 360 - 83 - 35, y: 180),
                 toPosition: CGPoint(x: 167 + 25, y: 55 + 25),
                 tag: 1)
        
        userIcon(userIcon2,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 1,
                 fromScale: scale,
                 toScale: 1,
                 fromPosition: CGPoint(x: 167 + 25, y: 255 + 25),
                 toPosition: CGPoint(x: 360 - 83 - 35, y: 180),
                 tag: 1)
        
        userIcon(userIcon3,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 0.5,
                 fromScale: scale,
                 toScale: scale,
                 fromPosition: CGPoint(x: 132 + 25, y: 325 + 25),
                 toPosition: CGPoint(x: 167 + 25, y: 255 + 25),
                 tag: 1)
        
        beginTime += anim2Duration
        
        userIcon(userIcon1,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 0.5,
                 fromScale: scale,
                 toScale: scale,
                 fromPosition: CGPoint(x: 167 + 25, y: 55 + 25),
                 toPosition: CGPoint(x: 132 + 25, y: -15 + 25),
                 tag: 2)
        
        userIcon(userIcon2,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 1,
                 toOpacity: 0.5,
                 fromScale: 1,
                 toScale: scale,
                 fromPosition: CGPoint(x: 360 - 83 - 35, y: 180),
                 toPosition: CGPoint(x: 167 + 25, y: 55 + 25),
                 tag: 2)
        
        userIcon(userIcon3,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 1,
                 fromScale: scale,
                 toScale: 1,
                 fromPosition: CGPoint(x: 167 + 25, y: 255 + 25),
                 toPosition: CGPoint(x: 360 - 83 - 35, y: 180),
                 tag: 2)
        
        pausedTime = userIcon1.convertTime(beginTime, from: nil)
        userIcon1.timeOffset = pausedTime
        userIcon2.timeOffset = pausedTime
        userIcon3.timeOffset = pausedTime
    }
    
    func userIcon(_ userIcon: CALayer,
                  addAnimateWitBeginTime beginTime: TimeInterval,
                  fromOpacity: CGFloat, toOpacity: CGFloat,
                  fromScale: CGFloat, toScale: CGFloat,
                  fromPosition: CGPoint, toPosition: CGPoint,
                  tag: Int) {
        
        let opacityAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)!
        opacityAnim.beginTime = beginTime
        opacityAnim.duration = duration
        opacityAnim.fromValue = fromOpacity
        opacityAnim.toValue = toOpacity
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        userIcon.pop_add(opacityAnim, forKey: "opacityAnim_\(tag)")
        
        let scaleAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)!
        scaleAnim.beginTime = beginTime
        scaleAnim.duration = duration
        scaleAnim.fromValue = CGPoint(x: fromScale, y: fromScale)
        scaleAnim.toValue = CGPoint(x: toScale, y: toScale)
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        userIcon.pop_add(scaleAnim, forKey: "scaleAnim_\(tag)")
        
        let positionAnim = POPBasicAnimation(propertyNamed: kPOPLayerPosition)!
        positionAnim.beginTime = beginTime
        positionAnim.duration = duration
        positionAnim.fromValue = fromPosition
        positionAnim.toValue = toPosition
        positionAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        userIcon.pop_add(positionAnim, forKey: "positionAnim_\(tag)")
    }
    
    @objc func drawAnim() {
        Asyncs.async {
            UIGraphicsBeginImageContextWithOptions(self.animLayer.frame.size, false, 0)
            defer { UIGraphicsEndImageContext() }
            
            guard let ctx = UIGraphicsGetCurrentContext() else {
                JPrint("失败")
                return
            }
            
            DispatchQueue.main.sync {
                self.animLayer.presentation()?.render(in: ctx)
            }
            
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
        
        let maxTime = anim1Duration + anim2Duration + duration
        
        JPHUD.show()
        Asyncs.async {
            
            let size: CGSize = [360, 360]
            
            UIGraphicsBeginImageContextWithOptions(size, false, 1)
            
            guard let ctx = UIGraphicsGetCurrentContext() else {
                UIGraphicsEndImageContext()
                Asyncs.main {
                    JPHUD.showError(withStatus: "失败")
                }
                return
            }
            
            let lock = DispatchSemaphore(value: 0)
            VideoMaker.createVideo(framerate: 24, frameInterval: 24, duration: 31, size: size) { currentFrame, currentTime in
                
                // 画
                ctx.saveGState()
                
                // 渲染
                DispatchQueue.main.sync {
                    if currentTime > maxTime {
                        self.pausedTime = self.beginTime + maxTime
                    } else {
                        self.pausedTime = self.beginTime + currentTime
                    }
                    
                    self.userIcon1.timeOffset = self.pausedTime
                    self.userIcon2.timeOffset = self.pausedTime
                    self.userIcon3.timeOffset = self.pausedTime
                    
                    self.animLayer.presentation()?.render(in: ctx)
                    
                    lock.signal()
                }
                lock.wait()
                
                
                let image = UIGraphicsGetImageFromCurrentImageContext()
                
                ctx.clear(CGRect(origin: .zero, size: size))
                ctx.restoreGState()
                
                return image
                
            } completion: { result in
                UIGraphicsEndImageContext()
                Asyncs.main {
                    switch result {
                    case let .success(path):
                        JPHUD.showSuccess(withStatus: "成功！")
                        JPrint("视频路径", path)
                    case .failure:
                        JPHUD.showError(withStatus: "失败！")
                    }
                }
            }
            
        }
        
    }
}
