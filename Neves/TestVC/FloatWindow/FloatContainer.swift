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
        for subview in subviews where !subview.isHidden && subview.alpha > 0.01 && subview.frame.contains(point) {
            return subview
        }
        return nil
    }
    
}
