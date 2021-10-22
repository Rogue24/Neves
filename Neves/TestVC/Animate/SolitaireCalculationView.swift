//
//  SolitaireCalculationView.swift
//  Neves
//
//  Created by aa on 2021/10/19.
//

class SolitaireCalculationView: UIView {
    
    let userIcon1 = UIImageView()
    let userIcon2 = UIImageView()
    let userIcon3 = UIImageView()
    
    let otherScale: CGFloat = 5.0 / 7.0
    
    let duration: TimeInterval = 0.6
    let anim1Duration: TimeInterval = 6
    let anim2Duration: TimeInterval = 8
    let anim3Duration: TimeInterval = 17
    lazy var totalDuration: TimeInterval = anim1Duration + anim2Duration + anim3Duration
    
    let frameInterval: Int
    lazy var anim1Range: ClosedRange =
        Int(anim1Duration * TimeInterval(frameInterval)) ...
        Int((anim1Duration + duration) * TimeInterval(frameInterval))
    
    lazy var anim2Range: ClosedRange =
        Int((anim1Duration + anim2Duration) * TimeInterval(frameInterval)) ...
        Int(((anim1Duration + anim2Duration) + duration) * TimeInterval(frameInterval))
    
    lazy var totalFrame: Int = Int((anim1Duration + anim2Duration + anim3Duration) * TimeInterval(frameInterval))
    
    init(frameInterval: Int) {
        self.frameInterval = frameInterval
        super.init(frame: [0, 0, 720, 720])
        clipsToBounds = true
        backgroundColor = .clear
        
        let label = UILabel(frame: [60, 300, 300, 62])
        label.textColor = .white
        label.text = "传奇的美男平"
        label.font = .systemFont(ofSize: 44, weight: .semibold)
        addSubview(label)
        
        let userIcon = UIImageView(frame: [60, 389, 34, 34])
        userIcon.image = UIImage(named: "jp_icon")
        userIcon.contentMode = .scaleAspectFill
        userIcon.layer.cornerRadius = 17
        userIcon.layer.masksToBounds = true
        addSubview(userIcon)
        
        let label2 = UILabel(frame: [110, 386, 300, 40])
        label2.textColor = .rgb(255, 217, 163)
        label2.text = "哥叫美男平"
        label2.font = .systemFont(ofSize: 28)
        addSubview(label2)
        
        userIcon1.image = UIImage(named: "jp_icon")
        userIcon1.contentMode = .scaleAspectFill
        userIcon1.frame = [0, 0, 140, 140]
        userIcon1.center = [CGFloat(720 - 166 - 70), 360]
        userIcon1.layer.cornerRadius = 70
        userIcon1.layer.masksToBounds = true
        addSubview(userIcon1)
        
        userIcon2.image = UIImage(named: "jp_icon")
        userIcon2.contentMode = .scaleAspectFill
        userIcon2.frame = [0, 0, 140, 140]
        userIcon2.alpha = 0.5
        userIcon2.transform = CGAffineTransform(scaleX: otherScale, y: otherScale)
        userIcon2.center = [CGFloat(334 + 50), CGFloat(510 + 50)]
        userIcon2.layer.cornerRadius = 70
        userIcon2.layer.masksToBounds = true
        addSubview(userIcon2)
        
        userIcon3.image = UIImage(named: "jp_icon")
        userIcon3.contentMode = .scaleAspectFill
        userIcon3.frame = [0, 0, 140, 140]
        userIcon3.alpha = 0.5
        userIcon3.transform = CGAffineTransform(scaleX: otherScale, y: otherScale)
        userIcon3.center = [CGFloat(264 + 50), CGFloat(650 + 50)]
        userIcon3.layer.cornerRadius = 70
        userIcon3.layer.masksToBounds = true
        addSubview(userIcon3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update(_ currentFrame: Int) {
        var sourceAlpha1: CGFloat = 1
        var targetAlpha1: CGFloat = 1
        var sourceScale1: CGFloat = 1
        var targetScale1: CGFloat = 1
        var sourceCenter1: CGPoint = [CGFloat(720 - 166 - 70), 360]
        var targetCenter1: CGPoint = [CGFloat(720 - 166 - 70), 360]
        
        var sourceAlpha2: CGFloat = 0.5
        var targetAlpha2: CGFloat = 0.5
        var sourceScale2: CGFloat = otherScale
        var targetScale2: CGFloat = otherScale
        var sourceCenter2: CGPoint = [CGFloat(334 + 50), CGFloat(510 + 50)]
        var targetCenter2: CGPoint = [CGFloat(334 + 50), CGFloat(510 + 50)]
        
        var sourceAlpha3: CGFloat = 0.5
        var targetAlpha3: CGFloat = 0.5
        var sourceScale3: CGFloat = otherScale
        var targetScale3: CGFloat = otherScale
        var sourceCenter3: CGPoint = [CGFloat(264 + 50), CGFloat(650 + 50)]
        var targetCenter3: CGPoint = [CGFloat(264 + 50), CGFloat(650 + 50)]
        
        var progress: CGFloat = 1
        
        switch currentFrame {
        case anim1Range:
            let lowerFrame = CGFloat(anim1Range.lowerBound)
            let upperFrame = CGFloat(anim1Range.upperBound)
            progress = (CGFloat(currentFrame) - lowerFrame) / (upperFrame - lowerFrame)
            
            sourceAlpha1 = 1
            targetAlpha1 = 0.5
            sourceScale1 = 1
            targetScale1 = otherScale
            sourceCenter1 = [CGFloat(720 - 166 - 70), 360]
            targetCenter1 = CGPoint(x: 334 + 50, y: 110 + 50)
            
            sourceAlpha2 = 0.5
            targetAlpha2 = 1
            sourceScale2 = otherScale
            targetScale2 = 1
            sourceCenter2 = [CGFloat(334 + 50), CGFloat(510 + 50)]
            targetCenter2 = [CGFloat(720 - 166 - 70), 360]
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 0.5
            sourceScale3 = otherScale
            targetScale3 = otherScale
            sourceCenter3 = [CGFloat(264 + 50), CGFloat(650 + 50)]
            targetCenter3 = [CGFloat(334 + 50), CGFloat(510 + 50)]
            
        case anim2Range:
            let lowerFrame = CGFloat(anim2Range.lowerBound)
            let upperFrame = CGFloat(anim2Range.upperBound)
            progress = (CGFloat(currentFrame) - lowerFrame) / (upperFrame - lowerFrame)
            
            sourceAlpha1 = 0.5
            targetAlpha1 = 0.5
            sourceScale1 = otherScale
            targetScale1 = otherScale
            sourceCenter1 = CGPoint(x: 334 + 50, y: 110 + 50)
            targetCenter1 = CGPoint(x: 264 + 50, y: -30 + 50)
            
            sourceAlpha2 = 1
            targetAlpha2 = 0.5
            sourceScale2 = 1
            targetScale2 = otherScale
            sourceCenter2 = [CGFloat(720 - 166 - 70), 360]
            targetCenter2 = CGPoint(x: 334 + 50, y: 110 + 50)
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 1
            sourceScale3 = otherScale
            targetScale3 = 1
            sourceCenter3 = [CGFloat(334 + 50), CGFloat(510 + 50)]
            targetCenter3 = [CGFloat(720 - 166 - 70), 360]
            
        case 0 ... anim1Range.lowerBound:
            sourceAlpha1 = 1
            targetAlpha1 = 1
            sourceScale1 = 1
            targetScale1 = 1
            sourceCenter1 = [CGFloat(720 - 166 - 70), 360]
            targetCenter1 = [CGFloat(720 - 166 - 70), 360]
            
            sourceAlpha2 = 0.5
            targetAlpha2 = 0.5
            sourceScale2 = otherScale
            targetScale2 = otherScale
            sourceCenter2 = [CGFloat(334 + 50), CGFloat(510 + 50)]
            targetCenter2 = [CGFloat(334 + 50), CGFloat(510 + 50)]
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 0.5
            sourceScale3 = otherScale
            targetScale3 = otherScale
            sourceCenter3 = [CGFloat(264 + 50), CGFloat(650 + 50)]
            targetCenter3 = [CGFloat(264 + 50), CGFloat(650 + 50)]
            
            
        case anim1Range.upperBound ... anim2Range.lowerBound:
            sourceAlpha1 = 0.5
            targetAlpha1 = 0.5
            sourceScale1 = otherScale
            targetScale1 = otherScale
            sourceCenter1 = CGPoint(x: 334 + 50, y: 110 + 50)
            targetCenter1 = CGPoint(x: 334 + 50, y: 110 + 50)
            
            sourceAlpha2 = 1
            targetAlpha2 = 1
            sourceScale2 = 1
            targetScale2 = 1
            sourceCenter2 = [CGFloat(720 - 166 - 70), 360]
            targetCenter2 = [CGFloat(720 - 166 - 70), 360]
            
            sourceAlpha3 = 0.5
            targetAlpha3 = 0.5
            sourceScale3 = otherScale
            targetScale3 = otherScale
            sourceCenter3 = [CGFloat(334 + 50), CGFloat(510 + 50)]
            targetCenter3 = [CGFloat(334 + 50), CGFloat(510 + 50)]
            
            
        case anim2Range.upperBound... :
            sourceAlpha1 = 0.5
            targetAlpha1 = 0.5
            sourceScale1 = otherScale
            targetScale1 = otherScale
            sourceCenter1 = CGPoint(x: 264 + 50, y: -30 + 50)
            targetCenter1 = CGPoint(x: 264 + 50, y: -30 + 50)
            
            sourceAlpha2 = 0.5
            targetAlpha2 = 0.5
            sourceScale2 = otherScale
            targetScale2 = otherScale
            sourceCenter2 = CGPoint(x: 334 + 50, y: 110 + 50)
            targetCenter2 = CGPoint(x: 334 + 50, y: 110 + 50)
            
            sourceAlpha3 = 1
            targetAlpha3 = 1
            sourceScale3 = 1
            targetScale3 = 1
            sourceCenter3 = [CGFloat(720 - 166 - 70), 360]
            targetCenter3 = [CGFloat(720 - 166 - 70), 360]
            
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
    
    private func updateUserIcon(_ userIcon: UIView,
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
}
