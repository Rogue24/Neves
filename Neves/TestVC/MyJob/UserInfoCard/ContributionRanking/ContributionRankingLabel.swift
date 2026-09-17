//
//  ContributionRankingLabel.swift
//  Falla
//
//  Created by aa on 2026/4/23.
//

import UIKit

@objcMembers
class ContributionRankingLabel: UIView {
    static var baseW: CGFloat { 24 }
    static var baseH: CGFloat { 12 }
    static var baseFontSize: CGFloat { 9 }
    static var baseStrokeWidth: CGFloat { 10 }
    
    static let foregroundColor: UIColor = .white
    static let strokeColor: UIColor = .rgb(218, 62, 0)
    
    static func getScale(_ height: CGFloat) -> CGFloat {
        return height / Self.baseH
    }
    
    static func getLabelWidth(_ height: CGFloat) -> CGFloat {
        let scale = getScale(height)
        return baseW * scale
    }
    
    static func makeRankingStrokeAttStr(_ ranking: Int, scale: CGFloat) -> NSAttributedString? {
        guard ranking > 0, scale > 0 else { return nil }
        return NSAttributedString(string: "\(ranking)", attributes: [
            .font: UIFont.systemFont(ofSize: baseFontSize * scale, weight: .bold),
            .foregroundColor: strokeColor,
            .strokeColor: strokeColor,
            .strokeWidth: -(baseStrokeWidth * scale) // 描边宽度（负值表示描边和文字颜色同时存在，正值表示只有描边颜色）
        ])
    }
    
    private let font: UIFont
    private let strokeWidth: CGFloat
    
    private lazy var bgImgView = SweepImageView(frame: bounds)
    private let label1 = UILabel()
    private let label2 = UILabel()
    
    init(height: CGFloat) {
        let scale = Self.getScale(height)
        let width = Self.baseW * scale
        self.font = .systemFont(ofSize: Self.baseFontSize * scale, weight: .bold)
        self.strokeWidth = Self.baseStrokeWidth * scale
        super.init(frame: [0, 0, width, height])
        isUserInteractionEnabled = false
        clipsToBounds = false
        
        bgImgView.image = UIImage(named: "chatroom_contribution_ranking_bg")?.rtl
        bgImgView.contentMode = .scaleToFill
        bgImgView.sweepWidth = 15.0 * scale
        bgImgView.isHidden = true
        addSubview(bgImgView)
        
        let labelW = 14.0 * scale
        let labelF: CGRect = [width - labelW, -0.4 * scale, labelW, height]
        
        label1.textAlignment = .center
        label1.rtl_refWidth = width
        label1.rtl_frame = labelF
        bgImgView.addSubview(label1)
        
        label2.font = font
        label2.textColor = Self.foregroundColor
        label2.textAlignment = .center
        label2.rtl_refWidth = width
        label2.rtl_frame = labelF
        bgImgView.addSubview(label2)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapMe() {
//        guard CrShared.isInRoom else { return }
//        EMLChatRoomRankingContainerController.show(from: .fa_topMostVC)
    }
    
    private var _ranking: Int = 0
    var ranking: Int {
        get { _ranking }
        set {
            guard _ranking != newValue else { return }
            _ranking = newValue
            
            guard _ranking > 0 else {
                bgImgView.isHidden = true
                label1.attributedText = nil
                label2.text = nil
                isUserInteractionEnabled = false
                return
            }
            
            let text = "\(_ranking)"
            
            label1.attributedText = NSAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: Self.strokeColor,
                .strokeColor: Self.strokeColor,
                .strokeWidth: -strokeWidth // 描边宽度（负值表示描边和文字颜色同时存在，正值表示只有描边颜色）
            ])
            
            label2.text = text
            
            if _ranking <= 3 {
                bgImgView.startSweep()
            } else {
                bgImgView.stopSweep()
            }
            bgImgView.isHidden = false
            
            isUserInteractionEnabled = true
        }
    }
    
    func customSetRanking(_ ranking: Int, stroke strokeAttStr: NSAttributedString?) {
        guard _ranking != ranking else { return }
        _ranking = ranking
        
        guard ranking > 0 else {
            bgImgView.isHidden = true
            label1.attributedText = nil
            label2.text = nil
            isUserInteractionEnabled = false
            return
        }
        
        label1.attributedText = strokeAttStr
        label2.text = "\(ranking)"
        
        if ranking <= 3 {
            bgImgView.startSweep()
        } else {
            bgImgView.stopSweep()
        }
        bgImgView.isHidden = false
        
        isUserInteractionEnabled = true
    }
}
