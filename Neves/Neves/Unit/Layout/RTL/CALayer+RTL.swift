//
//  CALayer+RTL.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//
//  Absolute Layout for RTL.

import UIKit

private var refWidthKey: UInt8 = 0

extension CALayer {
    /// 参照宽度，也就是【父图层】的宽度。
    /// - 如果【父图层】是`CAScrollLayer`最好将其设置为它的`内容宽度`。
    @objc var rtl_refWidth: CGFloat {
        set { objc_setAssociatedObject(self, &refWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { objc_getAssociatedObject(self, &refWidthKey) as? CGFloat ?? superlayer?.bounds.maxX ?? 0 }
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
    
    var rtl_position: CGPoint {
        set {
            guard isRTL else {
                position = newValue
                return
            }
            let positionX = rtl_refWidth - newValue.x
            position = CGPoint(x: positionX, y: newValue.y)
        }
        get {
            guard isRTL else {
                return position
            }
            let positionX = rtl_refWidth - position.x
            return CGPoint(x: positionX, y: position.y)
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
    func rtl_valueFromSelf(_ v: CGFloat) -> CGFloat {
        isRTL ? (bounds.width - v) : v
    }
    
    /// 相对【参照宽度】的转换值
    func rtl_valueFromRef(_ v: CGFloat) -> CGFloat {
        isRTL ? (rtl_refWidth - v) : v
    }
}

extension CALayer {
    /// 沿着Y轴180°翻转（水平镜像）
    func rtl_flip() {
        guard isRTL else { return }
        transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
    }
}
