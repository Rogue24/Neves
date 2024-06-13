//
//  UIView+RTL.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//
//  Absolute Layout for RTL.

import UIKit

private var refWidthKey: UInt8 = 0

extension UIView {
    /// 参照宽度，也就是【父视图】的宽度。
    /// - 如果【父视图】是`UIScrollView`最好将其设置为它的`contentSize.width`。
    @objc var rtl_refWidth: CGFloat {
        set { objc_setAssociatedObject(self, &refWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { objc_getAssociatedObject(self, &refWidthKey) as? CGFloat ?? superview?.bounds.maxX ?? 0 }
    }
    
    var rtl_frame: CGRect {
        set {
            guard isRTL else {
                frame = newValue
                return
            }
            let x = rtl_refWidth - newValue.maxX
            frame = CGRect(origin: CGPoint(x: x, y: newValue.origin.y), size: newValue.size)
        }
        get {
            guard isRTL else {
                return frame
            }
            let x = rtl_refWidth - frame.maxX
            return CGRect(origin: CGPoint(x: x, y: frame.origin.y), size: frame.size)
        }
    }
    
    var rtl_center: CGPoint {
        set {
            guard isRTL else {
                center = newValue
                return
            }
            let centerX = rtl_refWidth - newValue.x
            center = CGPoint(x: centerX, y: newValue.y)
        }
        get {
            guard isRTL else {
                return center
            }
            let centerX = rtl_refWidth - center.x
            return CGPoint(x: centerX, y: center.y)
        }
    }
    
    var rtl_x: CGFloat {
        set {
            guard isRTL else {
                frame.origin.x = newValue
                return
            }
            let x = rtl_refWidth - frame.width - newValue
            frame.origin.x = x
        }
        get {
            guard isRTL else {
                return frame.origin.x
            }
            let x = rtl_refWidth - frame.maxX
            return x
        }
    }
    
    var rtl_midX: CGFloat {
        guard isRTL else {
            return frame.midX
        }
        let midX = rtl_refWidth - frame.midX
        return midX
    }
    
    var rtl_maxX: CGFloat {
        guard isRTL else {
            return frame.maxX
        }
        return rtl_refWidth - frame.origin.x
    }
    
    /// 相对【自身宽度】的转换值
    @objc func rtl_valueFromSelf(_ v: CGFloat) -> CGFloat {
        isRTL ? (bounds.width - v) : v
    }
    
    /// 相对【参照宽度】的转换值
    func rtl_valueFromRef(_ v: CGFloat) -> CGFloat {
        isRTL ? (rtl_refWidth - v) : v
    }
}

extension UIView {
    /// 沿着Y轴180°翻转（水平镜像）
    func rtl_flip() {
        guard isRTL else { return }
        layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
    }
}

