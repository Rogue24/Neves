//
//  DragonSlayerEntrance.CountingDown.swift
//  Neves
//
//  Created by aa on 2021/11/4.
//

import UIKit

extension DragonSlayerEntrance {
    
    
    
    class CountingDownView: UIView {
        
        let bgAnimView = AnimationView.jp.build("dragon_enter_lottie_2")
        let secondLabel = UILabel()
        let titleLabel = UILabel()
        
        var second: DragonSlayer.CountingDown = .prepare(0) {
            didSet {
                switch second {
                case let .prepare(second):
                    secondLabel.text = "\(String(format: "%.0f", second))s"
                    titleLabel.text = "即将打龙"
                case let .fight(second):
                    secondLabel.text = "\(String(format: "%.0f", second))s"
                    titleLabel.text = "打龙激战中"
                }
            }
        }
        
        init() {
            super.init(frame: CGRect(origin: .zero, size: DragonSlayerEntrance.size))
            isUserInteractionEnabled = false
           
            bgAnimView.isUserInteractionEnabled = false
            bgAnimView.loopMode = .loop
            bgAnimView.frame = bounds
            addSubview(bgAnimView)
            
            let totalH: CGFloat = 16.5 + 5 + 12.5
            let y = DragonSlayerEntrance.infoFrame.origin.y + HalfDiffValue(DragonSlayerEntrance.infoFrame.height, totalH)
            
            secondLabel.frame = [0, y, bounds.width, 16.5]
            secondLabel.font = .systemFont(ofSize: 12)
            secondLabel.textColor = .rgb(255, 233, 147)
            secondLabel.textAlignment = .center
            addSubview(secondLabel)
            
            titleLabel.frame = [0, secondLabel.frame.maxY + 5, bounds.width, 12.5]
            titleLabel.font = .systemFont(ofSize: 9)
            titleLabel.textColor = UIColor(white: 1, alpha: 0.7)
            titleLabel.textAlignment = .center
            addSubview(titleLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func playAnim() {
            guard !bgAnimView.isAnimationPlaying else { return }
            bgAnimView.play()
        }
        
        func stopAnim() {
            guard bgAnimView.isAnimationPlaying else { return }
            bgAnimView.stop()
        }
        
    }
    
}
