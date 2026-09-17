//
//  FancyIDView.swift
//  Falla
//
//  Created by aa on 2024/9/13.
//

import UIKit
import SnapKit

@objcMembers
class FancyIDView: UIView {
    // 基本图标大小
    static private var baseIconWH: CGFloat { 20.0 }
    // 基本间距（图标和文本）
    static private var baseSpace: CGFloat { 4.0 }
    // 基本描边大小（只作用于静态靓号）
    static private var baseStrokeWidth: CGFloat { 5.0 }
    // 基本字体大小
    static private var baseFontSize: CGFloat { 12.0 }
    // 基本字距（只作用于靓号）
    static private var baseKern: CGFloat { 1.0 }
    
    // 普通字体
    private var normalFont: UIFont {
        let fontSize = Self.baseFontSize * scale
        return UIFont(name: "HelveticaNeue", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .regular)
    }
    
    // 靓号字体
    private var fancyFont: UIFont {
        let fontSize = Self.baseFontSize * scale
        return UIFont(name: "HelveticaNeue-BoldItalic", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .semibold)
    }
    
    // UI控件
    private var iconView: UIImageView? = nil
    private let sLabel = JKRShimmeringLabel()
    private let gLabel = GradientLabel()
    
    // UI属性
    private lazy var scale = iconWH / Self.baseIconWH
    private lazy var space = Self.baseSpace * scale
    private lazy var strokeWidth = Self.baseStrokeWidth * scale
    private lazy var font = normalFont
    private var kern: CGFloat = 0.0
    private lazy var style: NSMutableParagraphStyle = {
        let s = NSMutableParagraphStyle()
        s.firstLineHeadIndent = kern
        return s
    }()
    
    // MARK: - 初始化
    init(defaultColor: UIColor = .white, iconWH: CGFloat = 20.0) {
        super.init(frame: .zero)
        self.defaultColor = defaultColor
        self.iconWH = iconWH
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.defaultColor = .white
        self.iconWH = 20.0
        setupUI()
    }
    
    private func setupUI() {
        clipsToBounds = false
        backgroundColor = .clear
        
        sLabel.isUserInteractionEnabled = false
        sLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel)))
        addSubview(sLabel)
        sLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.height.equalTo(font.lineHeight)
            make.leading.equalTo(0)
        }
        
        gLabel.isUserInteractionEnabled = false
        gLabel.rtl_set(startPoint: [0, 0.5], endPoint: [1, 0.5])
        gLabel.colors = [defaultColor]
        gLabel.textAlignment = .center
        addSubview(gLabel)
        gLabel.snp.makeConstraints { make in
            make.center.size.equalTo(sLabel)
        }
    }
    
    // MARK: - 公开属性
    
    /// 是否显示图标
    private(set) var isShowIcon: Bool = false
    /// 是否正在闪烁
    private(set) var isShimmering: Bool = false
    /// 当前靓号等级
    private(set) var idLv: Int = -1
    /// 当前是否旧靓号（新：1~8；旧：1~5、100、1000）
    private(set) var isOldId = false
    
    /// 点击图标的回调
    var didClickIcon: (() -> Void)? = nil {
        didSet {
            iconView?.isUserInteractionEnabled = didClickIcon != nil
        }
    }
    
    /// 点击文本的回调
    var didClickLabel: ((_ idStr: String?) -> Void)? = nil {
        didSet {
            sLabel.isUserInteractionEnabled = didClickLabel != nil
        }
    }
    
    /// 图标大小
    /// - Note: 修改该值，间距 和 字体大小 会基于 [图标_20]·[间距_4]·[字体大小_12] 的比例进行【等比缩放】
    var iconWH: CGFloat = 20.0 {
        didSet {
            guard iconWH != oldValue else { return }
            
            // 刷新UI属性
            scale = iconWH / Self.baseIconWH
            space = Self.baseSpace * scale
            strokeWidth = Self.baseStrokeWidth * scale
            if isShowIcon {
                font = fancyFont
                kern = Self.baseKern * scale
            } else {
                font = normalFont
                kern = 0
            }
            style.firstLineHeadIndent = kern
            
            // 刷新布局
            iconView?.snp.updateConstraints { make in
                make.width.height.equalTo(iconWH)
            }
            
            sLabel.snp.updateConstraints { make in
                if isShowIcon {
                    make.leading.equalTo(iconWH + space)
                } else {
                    make.leading.equalTo(0)
                }
                make.height.equalTo(viewH)
            }
            
            // 刷新文本
            if let attStr = sLabel.attributedText {
                let mAttStr = NSMutableAttributedString(attributedString: attStr)
                mAttStr.font = font
                mAttStr.kern = NSNumber(floatLiteral: kern)
                mAttStr.paragraphStyle = style
                if mAttStr.strokeWidth != nil {
                    mAttStr.strokeWidth = NSNumber(floatLiteral: -strokeWidth)
                }
                sLabel.attributedText = mAttStr
            }
            
            if let attStr = gLabel.attributedText {
                let mAttStr = NSMutableAttributedString(attributedString: attStr)
                mAttStr.font = font
                mAttStr.kern = NSNumber(floatLiteral: kern)
                mAttStr.paragraphStyle = style
                gLabel.attributedText = mAttStr
            }
        }
    }
    
    /// 默认字体颜色（只作用于非靓号）
    var defaultColor: UIColor = .white {
        didSet {
            if !isShimmering, idLv == 0 {
                gLabel.colors = [defaultColor]
            }
        }
    }
    
    /// 自定义高度
    /// - Note: 默认是自适应宽高，有图标时是图标高度，没图标则是文本高度
    var customH: CGFloat = 0 {
        didSet {
            guard customH != oldValue else { return }
            sLabel.snp.updateConstraints { make in
                make.height.equalTo(viewH)
            }
        }
    }
    
    /// ID文本
    var idStr: String? {
        sLabel.attributedText?.string
    }
    
    /// 当前宽度（计算值）
    var viewW: CGFloat {
        var width = sLabel.attributedText?.boundingRect(with: [999, 999], context: nil).width ?? 0
        width += 2 // 添加额外一点点宽度（苹果算出来的总是差这么一点点！）
        if isShowIcon {
            width += iconWH + space
        }
        return width
    }
    
    /// 当前高度（计算值）
    var viewH: CGFloat {
        if customH > 0 {
            return customH
        } else {
            return isShowIcon ? iconWH : font.lineHeight
        }
    }
}

// MARK: - 点击事件
private extension FancyIDView {
    @objc func tapIcon() {
        didClickIcon?()
    }
    
    @objc func tapLabel() {
        didClickLabel?(idStr)
    }
}

// MARK: - API 设置靓号
extension FancyIDView {
    func updateUI(withId idStr: String?, idLv: Int, nobility: Int, svip: Int) {
        updateUI(withId: idStr, idLv: idLv, nobility: nobility, svip: svip, isOldId: false)
    }
    
    func updateUI(withId idStr: String?, idLv: Int, nobility: Int, svip: Int, isOldId: Bool) {
        updateUI(withId: idStr, idLv: idLv, isEffect: (nobility >= 6 || svip >= 8), isOldId: isOldId)
    }
    
    func updateUI(withId idStr: String?, idLv: Int, isEffect: Bool) {
        updateUI(withId: idStr, idLv: idLv, isEffect: isEffect, isOldId: false)
    }
    
    func updateUI(withId idStr: String?, idLv: Int) {
        updateUI(withId: idStr, idLv: idLv, isEffect: false, isOldId: false)
    }
    
    func updateUI(withId idStr: String?, idLv: Int, isEffect: Bool, isOldId: Bool) {
        let iconImg = UIImage.jkr_getFancyIdIcon(withIdLv: idLv, isOldId: isOldId)
        
        let isShowIcon = iconImg != nil
        let isShimmering = isEffect && idLv > 0
        defer {
            self.isShowIcon = isShowIcon
            self.isShimmering = isShimmering
            self.idLv = idLv
            self.isOldId = isOldId
        }
        
        // 检查是否显示图标
        if self.isShowIcon != isShowIcon {
            if isShowIcon {
                font = fancyFont
                kern = Self.baseKern * scale
            } else {
                font = normalFont
                kern = 0
            }
            style.firstLineHeadIndent = kern
            
            if isShowIcon, iconView == nil {
                let imgView = UIImageView()
                imgView.contentMode = .scaleAspectFit
                imgView.isUserInteractionEnabled = didClickIcon != nil
                imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapIcon)))
                addSubview(imgView)
                imgView.snp.makeConstraints { make in
                    make.leading.centerY.equalToSuperview()
                    make.width.height.equalTo(iconWH)
                }
                iconView = imgView
            }
            
            sLabel.snp.updateConstraints { make in
                if isShowIcon {
                    make.leading.equalTo(iconWH + space)
                    if customH <= 0 {
                        make.height.equalTo(iconWH)
                    }
                } else {
                    make.leading.equalTo(0)
                    if customH <= 0 {
                        make.height.equalTo(font.lineHeight)
                    }
                }
            }
        }
        
        iconView?.isHidden = !isShowIcon
        iconView?.image = iconImg
        
        // 检查是否闪烁
        if self.isShimmering != isShimmering {
            self.idLv = -1
            sLabel.shimmerMask = nil
            gLabel.isHidden = isShimmering
        }
        
        let idStr = idStr ?? ""
        let text = idStr.isEmpty ? "" : (isShowIcon ? idStr : "ID:\(idStr)")
        if isShimmering {
            sLabel.attributedText = _buildAttText(text, .black)
            if self.idLv != idLv || self.isOldId != isOldId {
                if isOldId {
                    sLabel.shimmerMask = JKRShimmeringMask.suidMask(withSuidLv: idLv)
                } else {
                    sLabel.shimmerMask = JKRShimmeringMask.fancyIDMask(withIdLv: idLv)
                }
            } else {
                sLabel.setNeedsLayout()
            }
        } else {
            if !isOldId, let strokeColor = UIColor.fancyIdStroke(withIdLv: idLv) {
                sLabel.attributedText = _buildAttText(text, strokeColor, strokeColor)
            } else {
                sLabel.attributedText = _buildAttText(text, .clear)
            }
            
            gLabel.attributedText = _buildAttText(text, .black)
            if self.idLv != idLv || self.isOldId != isOldId {
                if isOldId {
                    gLabel.colors = [UIColor(idLv: idLv, defaultColor: defaultColor)]
                } else {
                    gLabel.colors = UIColor.fancyIdTextColor(withIdLv: idLv, defaultColor: defaultColor)
                }
            }
        }
        
//        Asyncs.mainDelay(0.1) {
//            EML_DebugLog("emlemleml isShowIcon", isShowIcon)
//            EML_DebugLog("emlemleml isShimmering", isShimmering)
//            EML_DebugLog("emlemleml suidLv", suidLv)
//            EML_DebugLog("emlemleml sLabel", self.sLabel.frame)
//            EML_DebugLog("emlemleml gLabel", self.gLabel.frame)
//            EML_DebugLog("emlemleml ==========================")
//        }
    }
    
    private func _buildAttText(_ text: String,
                               _ textColor: UIColor,
                               _ strokeColor: UIColor? = nil) -> NSAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
        ]
        if kern > 0 {
            attrs[.kern] = kern
            attrs[.paragraphStyle] = style
        }
        if let strokeColor {
            attrs[.strokeColor] = strokeColor
            attrs[.strokeWidth] = -strokeWidth // 描边宽度（负值表示描边和文字颜色同时存在，正值表示只有描边颜色）
        }
        return NSAttributedString(string: text, attributes: attrs)
    }
}
