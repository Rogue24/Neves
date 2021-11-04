//
//  DragonSlayerEntrance.Content.swift
//  Neves
//
//  Created by aa on 2021/11/4.
//

import UIKit

extension DragonSlayerEntrance {
    
    class ContentView: UIView {
        
        let knifeIcon = UIImageView(image: UIImage(named: "dragon_knife"))
        let countLabel = UILabel()
        let contentLabel = UILabel()
        let space: CGFloat = 5
        
        var task: DragonSlayer.Task = .stayRoom {
            didSet {
                updateContent()
            }
        }
        
        init() {
            super.init(frame: DragonSlayerEntrance.infoFrame)
            clipsToBounds = true
            
            knifeIcon.frame = [20, 11, 20, 20]
            addSubview(knifeIcon)
            
            countLabel.font = .systemFont(ofSize: 12)
            countLabel.textColor = .rgb(255, 233, 147)
            countLabel.text = "x1"
            countLabel.frame = [knifeIcon.frame.maxX + 4, knifeIcon.frame.origin.y + 1.75, 30, 16.5]
            addSubview(countLabel)
            
            contentLabel.font = .systemFont(ofSize: 9)
            contentLabel.textColor = UIColor(white: 1, alpha: 0.7)
            contentLabel.textAlignment = .center
            contentLabel.numberOfLines = 0
            contentLabel.frame = [0, knifeIcon.frame.maxY + space, frame.width, 0]
            addSubview(contentLabel)
            
            updateContent()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func updateContent() {
            var content = ""
            var topAlpha: CGFloat = 1
            
            switch task {
            case .enterRoom:
                topAlpha = 0
            case .stayRoom:
                content = "再看2分钟"
            case .giveGift:
                content = "再送1000\n金币礼物"
            case .inspire:
                content = "鼓舞\n龙之召唤师"
            default:
                content = "已完成今日\n所有任务"
                topAlpha = 0
            }
            
            let contentH = content.jp.textSize(withFont: contentLabel.font).height
            let totalH = contentH + (topAlpha == 0 ? 0 : (knifeIcon.frame.height + space))
            
            let iconY = HalfDiffValue(frame.height, totalH)
            let countY = iconY + 1.75
            let contentY = iconY + (topAlpha == 0 ? 0 : (knifeIcon.frame.height + space))
            
            knifeIcon.frame.origin.y = iconY
            knifeIcon.alpha = topAlpha
            
            countLabel.frame.origin.y = countY
            countLabel.alpha = topAlpha
            
            contentLabel.frame = [contentLabel.frame.origin.x, contentY, contentLabel.frame.width, contentH]
            contentLabel.text = content
        }
    }
    
}
