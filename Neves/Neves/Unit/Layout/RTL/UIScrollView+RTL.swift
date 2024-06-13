//
//  UIScrollView+RTL.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//
//  Absolute Layout for RTL.

import UIKit

private var contentRefWidthKey: UInt8 = 0

extension UIScrollView {
    /// 内容参照宽度，也就是内容的总宽度：`contentSize.width`。
    /// - `UIScrollView`的子视图、偏移量的参照宽度就是`contentSize.width`。
    /// - 由于`UICollectionView`的`contentSize`设置后依旧会发生变动（不受控），
    /// - 所以如果能提前知道总宽度就最好提前设置给`rtl_contentRefWidth`，不依赖`contentSize.width`。
    @objc var rtl_contentRefWidth: CGFloat {
        set { objc_setAssociatedObject(self, &contentRefWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { objc_getAssociatedObject(self, &contentRefWidthKey) as? CGFloat ?? contentSize.width }
    }
    
    var rtl_contentInset: UIEdgeInsets {
        set {
            guard isRTL else {
                contentInset = newValue
                return
            }
            contentInset = UIEdgeInsets(top: newValue.top,
                                        left: newValue.right,
                                        bottom: newValue.bottom,
                                        right: newValue.left)
        }
        get {
            guard isRTL else {
                return contentInset
            }
            return UIEdgeInsets(top: contentInset.top,
                                left: contentInset.right,
                                bottom: contentInset.bottom,
                                right: contentInset.left)
        }
    }
    
    var rtl_contentOffset: CGPoint {
        set {
            guard isRTL else {
                contentOffset = newValue
                return
            }
            let offetX = rtl_contentRefWidth - bounds.width - newValue.x
            contentOffset = CGPoint(x: offetX, y: newValue.y)
        }
        get {
            guard isRTL else {
                return contentOffset
            }
            let offetX = rtl_contentRefWidth - bounds.width - contentOffset.x
            return CGPoint(x: offetX, y: contentOffset.y)
        }
    }
    
    func rtl_setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        var offset = contentOffset
        if isRTL {
            let offetX = rtl_contentRefWidth - bounds.width - contentOffset.x
            offset = CGPoint(x: offetX, y: contentOffset.y)
        }
        setContentOffset(offset, animated: animated)
    }
    
    /// 相对【自身宽度】的转换值
    /// - PS: 自身宽度在`ScrollView`中是内容参照宽度，也就是内容的总宽度`contentSize.width`
    override func rtl_valueFromSelf(_ v: CGFloat) -> CGFloat {
        isRTL ? (rtl_contentRefWidth - v) : v
    }
    
    /// 相对自身的转换偏移量
    func rtl_contentOffset(_ offset: CGPoint) -> CGPoint {
        guard isRTL else {
            return offset
        }
        let offetX = rtl_contentRefWidth - bounds.width - offset.x
        return CGPoint(x: offetX, y: offset.y)
    }
}

