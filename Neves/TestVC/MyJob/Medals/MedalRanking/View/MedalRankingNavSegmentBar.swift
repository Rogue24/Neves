//
//  MedalRankingNavSegmentBar.swift
//  Falla
//
//  Created by aa on 2023/7/5.
//

import UIKit
import SnapKit
import pop

protocol MedalRankingNavSegmentBarDelegate: AnyObject {
    func segementBar(_ segementBar: MedalRankingNavSegmentBar, titleDidClickAnimation animateDuration: TimeInterval, selectedIndex: Int)
}

class MedalRankingNavSegmentBar: UIView {
    weak var delegate: MedalRankingNavSegmentBarDelegate? = nil
    
    let toggleBtn = EMLRankingRegionToggleButton(isDark: true)
    
    private var allLabs: [UILabel] = []
    
    private let line: UIView = {
        let l = UIView(frame: [0, 0, 18.px, 4.px])
        l.backgroundColor = .rgb(34, 213, 163)
        l.layer.cornerRadius = 2.px
        l.layer.masksToBounds = true
        return l
    }()
    
    private(set) var selectedIndex = 0
    
    private let norScale: CGFloat = 15.0 / 18.0
    private lazy var diffScale: CGFloat = 1 - norScale
    
    private let selRgba = UIColor.RGBA(r: 51, g: 51, b: 51, a: 1)
    private let norRgba = UIColor.RGBA(r: 153, g: 153, b: 153, a: 1)
    private lazy var diffRgba: UIColor.RGBA = {
        UIColor.RGBA(r: selRgba.r - norRgba.r,
                     g: selRgba.g - norRgba.g,
                     b: selRgba.b - norRgba.b,
                     a: selRgba.a - norRgba.a)
    }()
    
    init(range: MedalRanking.RegionRange) {
        super.init(frame: [0, 0, Env.screenWidth, 52.px])
        backgroundColor = .white
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16.px
        layer.masksToBounds = true
        
        let bottomLine = CALayer()
        bottomLine.backgroundColor = .rgb(233, 233, 233)
        bottomLine.frame = [0, 52.px - 0.5, Env.screenWidth, 0.5]
        layer.addSublayer(bottomLine)
        
        let allType = MedalRanking.ListType.allCases
        let count = CGFloat(allType.count)
        let labH = 44.px
        let labY = 5.px
        let font = UIFont.systemFont(ofSize: 18.px, weight: .medium)
        var labW: CGFloat = 0
        for type in allType {
            let width = type.title.fa.textSize(withFont: font).width + 20.px
            if labW < width { labW = width }
        }
        
        let margin = 16.px
        let totalW = bounds.width - margin - (EMLRankingRegionToggleButton.size.width + margin)
        
        let labMaxW = totalW / count
        if labW > labMaxW {
            labW = labMaxW
        }
        
        let remainW = totalW - labW * count
        
        var space = remainW / (count - 1)
        var labX = margin
        if space > labX {
            space = labX
            labX += (remainW - space * (count - 1)) / 2.0
        }
        
        for type in allType {
            let label = UILabel()
            label.textAlignment = .center
            label.font = font
            label.tag = type.rawValue
            label.text = type.title
            label.rtl_refWidth = bounds.width
            label.rtl_frame = [labX, labY, labW, labH]
            addSubview(label)
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:))))
            allLabs.append(label)
            labX += labW + space
        }
        
        line.rtl_refWidth = bounds.width
        addSubview(line)
        
        for i in 0 ..< allLabs.count {
            let label = allLabs[i]
            if i == 0 {
                label.textColor = .rgba(selRgba)
                line.rtl_frame.origin = [label.rtl_x + HalfDiffValue(label.frame.width, line.frame.width), label.frame.maxY]
            } else {
                label.textColor = .rgba(norRgba)
                label.transform = CGAffineTransform(scaleX: norScale, y: norScale)
            }
        }
        
        addSubview(toggleBtn)
        toggleBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-margin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapLabel(_ tapGR: UITapGestureRecognizer) {
        let index = tapGR.view?.tag ?? 0
        switchPage(index, isAnimated: true)
    }
}

extension MedalRankingNavSegmentBar {
    func getLabel(at index: Int) -> UILabel {
        allLabs.first { $0.tag == index } ?? allLabs[0]
    }
    
    func switchPage(_ index: Int, isAnimated: Bool) {
        guard index < allLabs.count, selectedIndex != index else { return }
        isUserInteractionEnabled = false
        
        let animateDuration: TimeInterval = isAnimated ? (abs(selectedIndex - index) > 1 ? 0.6 : 0.45) : 0
        selectedIndex = index
        
        delegate?.segementBar(self, titleDidClickAnimation: animateDuration, selectedIndex: index)
        
        guard animateDuration > 0 else {
            allLabs.forEach { label in
                if label.tag == index {
                    label.textColor = .rgba(selRgba)
                    label.transform = CGAffineTransform(scaleX: 1, y: 1)
                    line.rtl_center.x = label.rtl_midX
                } else {
                    label.textColor = .rgba(norRgba)
                    label.transform = CGAffineTransform(scaleX: norScale, y: norScale)
                }
            }
            isUserInteractionEnabled = true
            return
        }
        
        var centerX: CGFloat = 0
        allLabs.forEach { label in
            let anim1 = POPBasicAnimation(propertyNamed: kPOPLabelTextColor)!
            anim1.duration = animateDuration
            
            let anim2 = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)!
            anim2.duration = animateDuration
            
            if label.tag == index {
                anim1.toValue = UIColor.rgb(51, 51, 51)
                anim2.toValue = CGPoint(x: 1, y: 1)
                centerX = label.rtl_midX
            } else {
                anim1.toValue = UIColor.rgb(153, 153, 153)
                anim2.toValue = CGPoint(x: norScale, y: norScale)
            }
            
            label.pop_add(anim1, forKey: kPOPLabelTextColor)
            label.pop_add(anim2, forKey: kPOPViewScaleXY)
        }
        
        UIView.animate(withDuration: animateDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.line.rtl_center.x = centerX
        } completion: { _ in
            self.isUserInteractionEnabled = true
        }
    }
    
    func updateLayout(sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        selectedIndex = progress >= 0.5 ? targetIndex : sourceIndex
        
        let sourceLab = getLabel(at: sourceIndex)
        
        let souRgba = UIColor.RGBA.fromSourceToTargetRgba(norRgba, diffRgba, progress: (1 - progress))
        sourceLab.textColor = .rgba(souRgba)
        
        let souScale = norScale + diffScale * (1 - progress)
        sourceLab.transform = CGAffineTransform(scaleX: souScale, y: souScale)
        
        let targetLab = getLabel(at: targetIndex)
        
        let tarRgba = UIColor.RGBA.fromSourceToTargetRgba(norRgba, diffRgba, progress: progress)
        targetLab.textColor = .rgba(tarRgba)
        
        let tarScale = norScale + diffScale * progress
        targetLab.transform = CGAffineTransform(scaleX: tarScale, y: tarScale)
        
        line.rtl_center.x = sourceLab.rtl_center.x + (targetLab.rtl_center.x - sourceLab.rtl_center.x) * progress
    }
}

