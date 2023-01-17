//
//  Penetrable.swift
//  Neves
//
//  Created by aa on 2023/1/17.
//

import UIKit

@objc protocol Penetrable {}

extension UIView {
    static let penetrateHook: Void = { swizzlingHitTest() }()
    
    private static func swizzlingHitTest() {
        guard let originalMethod = class_getInstanceMethod(self, #selector(hitTest(_:with:))),
              let swizzledMethod = class_getInstanceMethod(self, #selector(penetrate_hitTest(_:with:))) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc private func penetrate_hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard conforms(to: Penetrable.self) else {
            // 自己调用`penetrate_hitTest` -> 执行【原方法】hitTest
            return penetrate_hitTest(point, with: event)
        }
        
        // MARK: 拦截点击 => 自己不响应，触碰的子视图响应。
        guard !isHidden, subviews.count > 0 else { return nil }
        for subview in subviews.reversed() where subview.isUserInteractionEnabled && !subview.isHidden && subview.alpha > 0.01 && subview.frame.contains(point) {
            let childP = convert(point, to: subview)
            // 其他对象调用`hitTest` -> 执行【交换后的方法】penetrate_hitTest
            guard let rspView = subview.hitTest(childP, with: event) else { continue }
            return rspView
        }
        return nil
    }
}
