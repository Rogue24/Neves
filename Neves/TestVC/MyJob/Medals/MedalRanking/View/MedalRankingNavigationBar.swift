//
//  MedalRankingNavigationBar.swift
//  Falla
//
//  Created by aa on 2023/6/30.
//

import UIKit
import SnapKit
import pop

class MedalRankingNavigationBar: UIView {
    
    let bgLayer = CALayer()
    let titleLabel = UILabel()
    let backBtn = NoHighlightButton(type: .custom)
    let helpBtn = NoHighlightButton(type: .custom)
    let bottomLine = CALayer()
    let toggleBtn = EMLRankingRegionToggleButton(isDark: false)
    
    private var isTop = false {
        didSet {
            guard isTop != oldValue else { return }
            
            let anim1 = POPBasicAnimation(propertyNamed: kPOPLayerBackgroundColor)!
            anim1.toValue = UIColor.rgb(255, 255, 255, a: isTop ? 1 : 0)
            anim1.duration = 0.2
            bgLayer.pop_add(anim1, forKey: kPOPLayerBackgroundColor)
            
            let anim2 = POPBasicAnimation(propertyNamed: kPOPLabelTextColor)!
            anim2.toValue = isTop ? UIColor.rgb(30, 30, 30) : UIColor.white
            anim2.duration = 0.2
            titleLabel.pop_add(anim2, forKey: kPOPLabelTextColor)
            
            backBtn.setImage(UIImage(named: isTop ? "nav-back" : "icon_nav_back_white")?.rtl.withRenderingMode(.alwaysOriginal), for: .normal)
            helpBtn.setBackgroundImage(UIImage(named: isTop ? "medal_ranking_help_black" : "icon_ranking_help")?.withRenderingMode(.alwaysOriginal), for: .normal)
            toggleBtn.isDark = isTop
            
            bottomLine.opacity = isTop ? 1 : 0
        }
    }
    
    init(range: MedalRanking.RegionRange) {
        super.init(frame: [0, 0, Env.screenWidth, 44])
        clipsToBounds = false
        
        bgLayer.backgroundColor = .rgb(255, 255, 255, a: 0)
        bgLayer.frame = [0, -Env.safeAreaInsets.top, bounds.width, Env.safeAreaInsets.top + bounds.height]
        layer.addSublayer(bgLayer)
        
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.text = "勋章排行榜"
        titleLabel.rtl_refWidth = bounds.width
        titleLabel.rtl_frame = bounds
        addSubview(titleLabel)
        
        backBtn.setImage(UIImage(named: "icon_nav_back_white")?.rtl.withRenderingMode(.alwaysOriginal), for: .normal)
        backBtn.rtl_refWidth = bounds.width
        backBtn.rtl_frame = [8, HalfDiffValue(bounds.height, 45), 53, 45]
        addSubview(backBtn)
        
        helpBtn.setBackgroundImage(UIImage(named: "icon_ranking_help")?.withRenderingMode(.alwaysOriginal), for: .normal)
        helpBtn.rtl_refWidth = bounds.width
        helpBtn.rtl_frame = [bounds.width - 22 - 16, HalfDiffValue(bounds.height, 22), 22, 22]
        addSubview(helpBtn)
        
        addSubview(toggleBtn)
        toggleBtn.snp.makeConstraints { make in
            make.centerY.equalTo(helpBtn)
            make.trailing.equalTo(helpBtn.snp.leading).offset(-16)
        }
        
        bottomLine.backgroundColor = .rgb(241, 241, 241)
        bottomLine.frame = [0, 44 - 0.5, Env.screenWidth, 0.5]
        bottomLine.opacity = 0
        layer.addSublayer(bottomLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateOffsetY(_ offsetY: CGFloat) {
        isTop = offsetY >= 5
    }
}
