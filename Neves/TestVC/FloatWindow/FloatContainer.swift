//
//  FloatContainer.swift
//  Neves
//
//  Created by aa on 2021/11/2.
//

class FloatContainer: UIView {
    
    // MARK: 拦截点击
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, subviews.count > 0 else { return nil }
        for subview in subviews.reversed() where !subview.isHidden && subview.alpha > 0.01 && subview.frame.contains(point) {
            let subPoint = convert(point, to: subview)
            return subview.hitTest(subPoint, with: event)
        }
        return nil
    }
    
}
