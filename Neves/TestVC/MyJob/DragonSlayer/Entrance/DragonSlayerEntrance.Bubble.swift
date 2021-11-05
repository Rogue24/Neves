//
//  DragonSlayerEntrance.Bubble.swift
//  Neves
//
//  Created by aa on 2021/11/4.
//

import UIKit

extension DragonSlayerEntrance {
    
    class Bubble: UIView {
        static let size: CGSize = [155, 50]
        
        var removeAction: DispatchWorkItem? = nil
        
        init(site: DragonSlayerEntrance.Site, task: DragonSlayer.Task, count: Int) {
            super.init(frame: CGRect(origin: .zero, size: Bubble.size))
            layer.cornerRadius = 5
            layer.masksToBounds = true
            backgroundColor = .rgb(65, 21, 33, a: 0.85)
            isUserInteractionEnabled = false
            
            let knifeBgIcon = UIImageView(frame: [5, 5, 40, 40])
            knifeBgIcon.image = UIImage(named: "dragon_tc_gift_bg")
            addSubview(knifeBgIcon)
            
            let knifeIcon = UIImageView(frame: [4, 4, 32, 32])
            knifeIcon.image = UIImage(named: "dragon_knife")
            knifeBgIcon.addSubview(knifeIcon)
            
            let countLayer = CAShapeLayer()
            countLayer.fillColor = UIColor.rgb(249, 221, 140).cgColor
            let path = UIBezierPath(roundedRect: [25, 31, 10, 9], byRoundingCorners: [.topLeft], cornerRadii: [4, 4])
            path.append(UIBezierPath(roundedRect: [35, 31, 5, 9], byRoundingCorners: [.bottomRight], cornerRadii: [2, 2]))
            countLayer.path = path.cgPath
            knifeBgIcon.layer.addSublayer(countLayer)
            
            let countLabel = UILabel(frame: [25, 31, 15, 9])
            countLabel.font = .systemFont(ofSize: 8.5)
            countLabel.textColor = .rgb(109, 44, 37)
            countLabel.textAlignment = .center
            countLabel.text = "x\(count)"
            knifeBgIcon.addSubview(countLabel)
            
            let contentLabel = UILabel(frame: [53, 0, CGFloat(155 - 8 - 45 - 8), 50])
            contentLabel.font = .systemFont(ofSize: 9)
            contentLabel.textColor = UIColor(white: 1, alpha: 0.9)
            contentLabel.textAlignment = .center
            contentLabel.text = "你已鼓舞一位龙之召唤师，获得打龙刀*\(count)"
            contentLabel.numberOfLines = 0
            addSubview(contentLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            JPrint("死得惨")
        }
    }
    
    func launchBubble() {
        let oldBubbles = bubbles
        oldBubbles.forEach { $0.removeAction?.cancel() }
        bubbles.removeAll()
        
        let bubble = Bubble(site: site, task: .enterRoom, count: 1)
        bubbles.append(bubble)
        updateBubbles()
        bubble.layer.opacity = 0
        bubble.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        addSubview(bubble)
        
        let duration: TimeInterval = 0.4
        
        bubble.removeAction = Asyncs.mainDelay(bubbleStayDuration + duration) { [weak self, weak bubble] in
            guard let self = self, let bubble = bubble else { return }
            UIView.animate(withDuration: 0.2) {
                bubble.layer.opacity = 0
            } completion: { _ in
                self.bubbles.removeAll { $0 == bubble }
                bubble.removeFromSuperview()
            }
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: []) {
            bubble.layer.opacity = 1
            bubble.layer.transform = CATransform3DMakeScale(1, 1, 1)
            oldBubbles.forEach { $0.layer.opacity = 0 }
        } completion: { _ in
            oldBubbles.forEach { $0.removeFromSuperview() }
        }
    }
    
    func updateBubbles() {
        var anchorPoint: CGPoint = .zero
        var position: CGPoint = .zero
        
        let enSize = Self.size
        let buSize = Bubble.size
        
        switch site {
        case .topLeft:
            anchorPoint = [(enSize.width * 0.5) / buSize.width, 0]
            position = [enSize.width * 0.5, enSize.height + bubbleSpace]
        case .topRight:
            anchorPoint = [(buSize.width - enSize.width * 0.5) / buSize.width, 0]
            position = [enSize.width * 0.5, enSize.height + bubbleSpace]
        case .bottomLeft:
            anchorPoint = [(enSize.width * 0.5) / buSize.width, 1]
            position = [enSize.width * 0.5, -bubbleSpace]
        case .bottomRight:
            anchorPoint = [(buSize.width - enSize.width * 0.5) / buSize.width, 1]
            position = [enSize.width * 0.5, -bubbleSpace]
        }
        
        bubbles.forEach {
            $0.layer.anchorPoint = anchorPoint
            $0.layer.position = position
        }
    }
}
