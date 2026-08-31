//
//  MedalRankingSegmentView.swift
//  Falla
//
//  Created by aa on 2023/6/30.
//

import UIKit
import pop

class MedalRankingSegmentView: UIView {
    private let bottomContainer = TitleContainer()
    private let topContainer = TitleContainer()
    private let selectBox = CALayer()
    
    private(set) var selectedIndex = 0 {
        didSet {
            switchListTypeHandler?(currentType)
        }
    }
    
    var currentType: MedalRanking.ListType {
        MedalRanking.ListType(rawValue: selectedIndex) ?? .quarterly
    }
    
    var switchListTypeHandler: ((_ listType: MedalRanking.ListType) -> Void)?
    
    init() {
        super.init(frame: [0, 0, Env.screenWidth - 50.px, 36.px])
        
        backgroundColor = .rgb(29, 27, 47)
        layer.cornerRadius = 18.px
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = .rgb(116, 108, 184)
        
        bottomContainer.setupUI(bounds,
                                UIFont(name: "PingFangSC-Medium", size: 15.px),
                                UIColor.rgb(141, 139, 165),
                                MedalRanking.ListType.allCases[0].title,
                                MedalRanking.ListType.allCases[1].title)
        addSubview(bottomContainer)
        
        topContainer.setupUI(bounds,
                             UIFont(name: "PingFangSC-Semibold", size: 15.px),
                             UIColor.white,
                             MedalRanking.ListType.allCases[0].title,
                             MedalRanking.ListType.allCases[1].title)
        topContainer.backgroundColor = .rgb(109, 101, 162)
        addSubview(topContainer)
        
        selectBox.rtl_refWidth = bounds.width
        selectBox.rtl_frame = [2.px, 2.px, (bounds.width - 4.px) * 0.5, bounds.height - 4.px]
        selectBox.cornerRadius = (bounds.height - 4.px) * 0.5
        selectBox.masksToBounds = true
        selectBox.backgroundColor = UIColor.black.cgColor
        topContainer.layer.mask = selectBox
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickTitle(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MedalRankingSegmentView {
    @objc func didClickTitle(_ tapGR: UITapGestureRecognizer) {
        let x = rtl_valueFromSelf(tapGR.location(in: self).x)
        updateSelectedIndex(x <= (bounds.width * 0.5) ? 0 : 1)
    }
    
    func updateSelectedIndex(_ index: Int) {
        guard selectedIndex != index else { return }
        selectedIndex = index
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayerPositionX)!
        anim.toValue = rtl_valueFromSelf(2.px + selectBox.bounds.width * 0.5 + selectBox.bounds.width * CGFloat(index))
        anim.duration = 0.3
        selectBox.pop_add(anim, forKey: kPOPLayerPositionX)
    }
}

private extension MedalRankingSegmentView {
    class TitleContainer: UIView {
        let leftLabel = UILabel()
        let rightLabel = UILabel()
        
        func setupUI(_ frame: CGRect,
                     _ titleFont: UIFont?,
                     _ titleColor: UIColor,
                     _ leftTitle: String,
                     _ rightTitle: String)
        {
            self.frame = frame
            
            leftLabel.rtl_refWidth = bounds.width
            leftLabel.rtl_frame = [0, 0, bounds.width * 0.5, bounds.height]
            leftLabel.font = titleFont
            leftLabel.textColor = titleColor
            leftLabel.textAlignment = .center
            leftLabel.text = leftTitle
            addSubview(leftLabel)
            
            rightLabel.rtl_refWidth = bounds.width
            rightLabel.rtl_frame = [bounds.width * 0.5, 0, bounds.width * 0.5, bounds.height]
            rightLabel.font = titleFont
            rightLabel.textColor = titleColor
            rightLabel.textAlignment = .center
            rightLabel.text = rightTitle
            addSubview(rightLabel)
        }
    }
}
