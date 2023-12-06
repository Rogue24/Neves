//
//  Buttons.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit

class CustomLayoutButton: UIButton {
    var layoutSubviewsHandler: ((CustomLayoutButton) -> ())?
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler?(self)
    }
}

class NoHighlightButton: CustomLayoutButton {
    override var isHighlighted: Bool {
        set {}
        get { super.isHighlighted }
    }
}

class ExpandButton: CustomLayoutButton {
    var dx: CGFloat = 0
    var dy: CGFloat = 0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        if super.point(inside: point, with: event) {
//            return true
//        }
        return bounds.insetBy(dx: -dx, dy: -dy).contains(point)
    }
}
