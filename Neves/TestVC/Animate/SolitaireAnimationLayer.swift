//
//  SolitaireAnimationLayer.swift
//  Neves
//
//  Created by aa on 2021/10/21.
//

import QuartzCore
import AVKit

class SolitaireAnimationLayer: CALayer, VideoAnimationLayer {
    
    let userIcon1 = CALayer()
    let userIcon2 = CALayer()
    let userIcon3 = CALayer()
    
    let otherScale: CGFloat = 5.0 / 7.0
    
    let animDuration: TimeInterval = 0.6
    let anim1Duration: TimeInterval = 6
    let anim2Duration: TimeInterval = 8
    let anim3Duration: TimeInterval = 5//17
    lazy var totalDuration: TimeInterval = anim1Duration + anim2Duration + anim3Duration
    
    override init() {
        super.init()
        frame = [0, 0, 720, 720]
        masksToBounds = true
        backgroundColor = UIColor.clear.cgColor
        
        let text1 = CATextLayer()
        text1.frame = [60, 300, 300, 62]
        text1.foregroundColor = UIColor.white.cgColor
        text1.alignmentMode = .left
        text1.contentsScale = 1
        text1.font = CGFont(UIFont.systemFont(ofSize: 44, weight: .semibold).fontName as CFString)
        text1.fontSize = 44
        text1.string = "传奇的美男平"
        addSublayer(text1)
        
        let userIcon = CALayer()
        userIcon.frame = [60, 389, 34, 34]
        userIcon.contents = UIImage(named: "jp_icon")?.cgImage
        userIcon.contentsGravity = .resizeAspectFill
        userIcon.cornerRadius = 17
        userIcon.masksToBounds = true
        addSublayer(userIcon)
        
        let text2 = CATextLayer()
        text2.frame = [110, 386, 300, 40]
        text2.foregroundColor = UIColor.rgb(255, 217, 163).cgColor
        text2.alignmentMode = .left
        text2.contentsScale = 1
        text2.font = CGFont(UIFont.systemFont(ofSize: 28).fontName as CFString)
        text2.fontSize = 28
        text2.string = "哥叫美男平"
        addSublayer(text2)
        
        userIcon1.contents = UIImage(named: "jp_icon")?.cgImage
        userIcon1.contentsGravity = .resizeAspectFill
        userIcon1.frame = [0, 0, 140, 140]
        userIcon1.position = [CGFloat(720 - 166 - 70), 360]
        userIcon1.cornerRadius = 70
        userIcon1.masksToBounds = true
        addSublayer(userIcon1)
        
        userIcon2.contents = UIImage(named: "jp_icon")?.cgImage
        userIcon2.contentsGravity = .resizeAspectFill
        userIcon2.frame = [0, 0, 140, 140]
        userIcon2.opacity = 0.5
        userIcon2.transform = CATransform3DMakeScale(otherScale, otherScale, 1)
        userIcon2.position = [CGFloat(334 + 50), CGFloat(510 + 50)]
        userIcon2.cornerRadius = 70
        userIcon2.masksToBounds = true
        addSublayer(userIcon2)
        
        userIcon3.contents = UIImage(named: "jp_icon")?.cgImage
        userIcon3.contentsGravity = .resizeAspectFill
        userIcon3.frame = [0, 0, 140, 140]
        userIcon3.opacity = 0.5
        userIcon3.transform = CATransform3DMakeScale(otherScale, otherScale, 1)
        userIcon3.position = [CGFloat(264 + 50), CGFloat(650 + 50)]
        userIcon3.cornerRadius = 70
        userIcon3.masksToBounds = true
        addSublayer(userIcon3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addAnimate() {
        var beginTime = AVCoreAnimationBeginTimeAtZero + anim1Duration
        
        userIcon(userIcon1,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 1,
                 toOpacity: 0.5,
                 fromScale: 1,
                 toScale: otherScale,
                 fromPosition: CGPoint(x: 720 - 166 - 70, y: 360),
                 toPosition: CGPoint(x: 334 + 50, y: 110 + 50),
                 tag: 1)
        
        userIcon(userIcon2,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 1,
                 fromScale: otherScale,
                 toScale: 1,
                 fromPosition: CGPoint(x: 334 + 50, y: 510 + 50),
                 toPosition: CGPoint(x: 720 - 166 - 70, y: 360),
                 tag: 1)
        
        userIcon(userIcon3,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 0.5,
                 fromScale: otherScale,
                 toScale: otherScale,
                 fromPosition: CGPoint(x: 264 + 50, y: 650 + 50),
                 toPosition: CGPoint(x: 334 + 50, y: 510 + 50),
                 tag: 1)
        
        beginTime += anim2Duration
        
        userIcon(userIcon1,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 0.5,
                 fromScale: otherScale,
                 toScale: otherScale,
                 fromPosition: CGPoint(x: 334 + 50, y: 110 + 50),
                 toPosition: CGPoint(x: 264 + 50, y: -30 + 50),
                 tag: 2)
        
        userIcon(userIcon2,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 1,
                 toOpacity: 0.5,
                 fromScale: 1,
                 toScale: otherScale,
                 fromPosition: CGPoint(x: 720 - 166 - 70, y: 360),
                 toPosition: CGPoint(x: 334 + 50, y: 110 + 50),
                 tag: 2)
        
        userIcon(userIcon3,
                 addAnimateWitBeginTime: beginTime,
                 fromOpacity: 0.5,
                 toOpacity: 1,
                 fromScale: otherScale,
                 toScale: 1,
                 fromPosition: CGPoint(x: 334 + 50, y: 510 + 50),
                 toPosition: CGPoint(x: 720 - 166 - 70, y: 360),
                 tag: 2)
    }
    
    private func userIcon(_ userIcon: CALayer,
                          addAnimateWitBeginTime beginTime: TimeInterval,
                          fromOpacity: CGFloat, toOpacity: CGFloat,
                          fromScale: CGFloat, toScale: CGFloat,
                          fromPosition: CGPoint, toPosition: CGPoint,
                          tag: Int) {
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.beginTime = beginTime
        opacityAnim.duration = animDuration
        opacityAnim.fromValue = fromOpacity
        opacityAnim.toValue = toOpacity
        opacityAnim.fillMode = .forwards
        opacityAnim.isRemovedOnCompletion = false
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        userIcon.add(opacityAnim, forKey: "opacityAnim_\(tag)")
        
        let scaleAnim = CABasicAnimation(keyPath: "transform")
        scaleAnim.beginTime = beginTime
        scaleAnim.duration = animDuration
        scaleAnim.fromValue = CATransform3DMakeScale(fromScale, fromScale, 1)
        scaleAnim.toValue = CATransform3DMakeScale(toScale, toScale, 1)
        scaleAnim.fillMode = .forwards
        scaleAnim.isRemovedOnCompletion = false
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        userIcon.add(scaleAnim, forKey: "scaleAnim_\(tag)")
        
        let positionAnim = CABasicAnimation(keyPath: "position")
        positionAnim.beginTime = beginTime
        positionAnim.duration = animDuration
        positionAnim.fromValue = fromPosition
        positionAnim.toValue = toPosition
        positionAnim.fillMode = .forwards
        positionAnim.isRemovedOnCompletion = false
        positionAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        userIcon.add(positionAnim, forKey: "positionAnim_\(tag)")
    }
}

