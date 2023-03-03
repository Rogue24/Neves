//
//  AttributeString.swift
//  XBHDBaseUIKit
//
//  Created by xy_yanfa_imac_samsung on 2020/11/3.
//

import Foundation

private var kXBMutableParagraphStyle: Void?

public extension String {
    func xb_range(of otherString: String) -> NSRange {
        if let range = self.range(of: otherString) {
            return NSRange(range, in: self)
        }
        return NSRange(location: NSNotFound, length: 0)
    }
}

public extension String {
    /// 字符串转富文本
    func xb_toAttribute() -> NSMutableAttributedString {
        NSMutableAttributedString(string: self)
    }
}

public extension NSAttributedString {
    /// 获取范围
    func xb_allRange() -> NSRange {
        NSRange(location: 0, length: length)
    }
}

// 用法  https://www.jianshu.com/p/f2ec98acb13b
public extension NSMutableAttributedString {
    /// 添加中划线
    @discardableResult
    func xb_addMidline(_ lineHeght: Int) -> NSMutableAttributedString {
        addAttributes([.strikethroughStyle: lineHeght,
                       .baselineOffset: NSUnderlineStyle.single.rawValue], range: xb_allRange())
        return self
    }

    /// 中划线颜色
    @discardableResult
    func xb_midlineColor(_ color: UIColor) -> NSMutableAttributedString {
        addAttributes([.strikethroughColor: color,
                       .baselineOffset: NSUnderlineStyle.single.rawValue], range: xb_allRange())
        return self
    }

    /// 给文字添加描边
    ///
    /// - Parameter width: 描边宽带
    /// - Returns:
    @discardableResult
    func xb_addStroke(_ width: CGFloat) -> NSMutableAttributedString {
        addAttributes([.strokeWidth: width], range: xb_allRange())
        return self
    }

    /// 描边颜色
    @discardableResult
    func xb_strokeColor(_ color: UIColor) -> NSMutableAttributedString {
        addAttributes([.strokeColor: color], range: xb_allRange())
        return self
    }

    /// 添加字间距
    @discardableResult
    func xb_addSpace(_ space: CGFloat) -> NSMutableAttributedString {
        addAttributes([.kern: space], range: xb_allRange())
        return self
    }

    /// 文字颜色
    @discardableResult
    func xb_color(_ color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttributes([.foregroundColor: color], range: range ?? xb_allRange())
        return self
    }

    /// 添加下划线
    ///
    /// - Parameter style: <#style description#>
    /// - Returns: <#return value description#>
    @discardableResult
    func xb_addUnderLine(_ style: NSUnderlineStyle) -> NSMutableAttributedString {
        addAttributes([.underlineStyle: style.rawValue], range: xb_allRange())
        return self
    }

    /// 下划线颜色
    @discardableResult
    func xb_underLineColor(_ color: UIColor) -> NSMutableAttributedString {
        addAttributes([.underlineColor: color], range: xb_allRange())
        return self
    }

    /// 字体
    @discardableResult
    func xb_font(_ font: UIFont) -> NSMutableAttributedString {
        addAttributes([.font: font], range: xb_allRange())
        return self
    }

    /// 添加行间距
    @discardableResult
    func xb_addLineSpace(_ space: CGFloat) -> NSMutableAttributedString {
        tmpStyle.lineSpacing = space
        tmpStyle.lineBreakMode = .byCharWrapping
        addAttribute(.paragraphStyle, value: tmpStyle, range: xb_allRange())
        return self
    }

    /// 添加行高
    @discardableResult
    func xb_addLineHeight(_ height: CGFloat) -> NSMutableAttributedString {
        tmpStyle.minimumLineHeight = height
        tmpStyle.maximumLineHeight = height
        addAttribute(.paragraphStyle, value: tmpStyle, range: xb_allRange())
        return self
    }

    /// 添加BaseLineOffset
    @discardableResult
    func xb_addBaseLineOffset(_ offset: CGFloat) -> NSMutableAttributedString {
        addAttribute(.baselineOffset, value: offset, range: xb_allRange())
        return self
    }

    var tmpStyle: NSMutableParagraphStyle {
        get {
            var style = objc_getAssociatedObject(self, &kXBMutableParagraphStyle)
            if style == nil {
                style = NSMutableParagraphStyle()
                tmpStyle = style as! NSMutableParagraphStyle
            }
            return style as! NSMutableParagraphStyle
        }
        set {
            objc_setAssociatedObject(self, &kXBMutableParagraphStyle, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// 设置行首不出现符号, 设置为true是不要设置lineBreakMode
    @discardableResult
    func xb_allowsTightening(_ mode: Bool) -> NSMutableAttributedString {
        tmpStyle.allowsDefaultTighteningForTruncation = mode
        return self
    }

    /// Line Break Mode
    @discardableResult
    func xb_lineBreakMode(_ mode: NSLineBreakMode) -> NSMutableAttributedString {
        tmpStyle.lineBreakMode = mode
        return self
    }

    /// 添加 aliment
    @discardableResult
    func xb_addAlignment(_ alignment: NSTextAlignment) -> NSMutableAttributedString {
        tmpStyle.alignment = alignment
        addAttribute(.paragraphStyle, value: tmpStyle, range: xb_allRange())
        return self
    }

    /// 拼接富文本
    @discardableResult
    func xb_addAttribute(_ attribute: NSMutableAttributedString) -> NSMutableAttributedString {
        append(attribute)
        return self
    }

    /// 添加阴影
    @discardableResult
    func xb_addShadow(_ shadowOffset: CGSize? = nil, _ color: UIColor? = nil) -> NSMutableAttributedString {
        let shadow = NSShadow.init()
        shadow.shadowColor = color == nil ? UIColor.black : color!
        shadow.shadowOffset = shadowOffset == nil ? CGSize.init(width: 2, height: 2) : shadowOffset!
        addAttributes([NSAttributedString.Key.shadow: shadow], range: xb_allRange())
        return self
    }

    /// 布局风格
    @discardableResult
    func xb_setupParaStyle(_ block: (_ style: NSMutableParagraphStyle) -> Void) -> NSMutableAttributedString {
        block(tmpStyle)
        addAttribute(.paragraphStyle, value: tmpStyle, range: xb_allRange())
        return self
    }

    func xb_size(forMaxH maxH: CGFloat) -> CGSize {
        boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,
                height: maxH),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                context: nil).size
    }

    func xb_height(forMaxW maxW: CGFloat) -> CGFloat {
        boundingRect(with: CGSize(width: maxW,
                height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                context: nil).height.rounded(.up)
    }

    func xb_width(forMaxH maxH: CGFloat) -> CGFloat {
        boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,
                height: maxH),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                context: nil).width.rounded(.up)
    }

}
