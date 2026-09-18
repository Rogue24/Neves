//
//  UIView.Extension.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIView {
    var jp_x: CGFloat {
        set { frame.origin.x = newValue }
        get { frame.origin.x }
    }
    var jp_midX: CGFloat {
        set { frame.origin.x += (newValue - frame.midX) }
        get { frame.midX }
    }
    var jp_maxX: CGFloat {
        set { frame.origin.x += (newValue - frame.maxX) }
        get { frame.maxX }
    }
    
    var jp_y: CGFloat {
        set { frame.origin.y = newValue }
        get { frame.origin.y }
    }
    var jp_midY: CGFloat {
        set { frame.origin.y += (newValue - frame.midY) }
        get { frame.midY }
    }
    var jp_maxY: CGFloat {
        set { frame.origin.y += (newValue - frame.maxY) }
        get { frame.maxY }
    }
    
    var jp_width: CGFloat {
        set { frame.size.width = newValue }
        get { frame.width }
    }
    
    var jp_height: CGFloat {
        set { frame.size.height = newValue }
        get { frame.height }
    }
    
    var jp_centerX: CGFloat {
        set { center.x = newValue }
        get { center.x }
    }
    var jp_centerY: CGFloat {
        set { center.y = newValue }
        get { center.y }
    }
    
    var jp_origin: CGPoint {
        set { frame.origin = newValue }
        get { frame.origin }
    }
    
    var jp_size: CGSize {
        set { frame.size = newValue }
        get { frame.size }
    }
    
    var jp_right: CGFloat {
        set {
            guard let superview = self.superview else { return }
            jp_x = superview.jp_width - jp_width - newValue
        }
        get {
            guard let superview = self.superview else { return 0 }
            return superview.jp_width - jp_maxX
        }
    }
    
    var jp_bottom: CGFloat {
        set {
            guard let superview = self.superview else { return }
            jp_y = superview.jp_height - jp_height - newValue
        }
        get {
            guard let superview = self.superview else { return 0 }
            return superview.jp_height - jp_maxY
        }
    }
    
    var jp_radian: CGFloat { CGFloat(atan2(Double(transform.b), Double(transform.a))) }
    
    var jp_angle: CGFloat { (jp_radian * 180.0) / CGFloat.pi }
    
    var jp_scaleX: CGFloat { CGFloat(sqrt(pow(transform.a, 2) + pow(transform.c, 2))) }
    
    var jp_scaleY: CGFloat { CGFloat(sqrt(pow(transform.b, 2) + pow(transform.d, 2))) }
    
    var jp_scale: CGPoint { .init(x: jp_scaleX, y: jp_scaleY) }
    
    var jp_translationX: CGFloat { transform.tx }
    
    var jp_translationY: CGFloat { transform.ty }
    
    var jp_translation: CGPoint { .init(x: jp_translationX, y: jp_translationY) }
    
    static func jp_loadFromNib(_ nibName: String? = nil, bundle: Bundle = Bundle.main) -> Self {
        let nibNamed = nibName ?? "\(self)"
        return bundle.loadNibNamed(nibNamed, owner: nil, options: nil)?.first as! Self
    }
    
    static func jp_nib(_ nibName: String? = nil, bundle: Bundle = Bundle.main) -> UINib? {
        let nibNamed = nibName ?? "\(self)"
        return UINib(nibName: nibNamed, bundle: bundle)
    }
}

extension UIView: JPCompatible {}
extension JP where Base: UIView {
    var topVC: UIViewController? { base.window?.jp.topVC }
    var topNavCtr: UINavigationController? { topVC?.navigationController }
    
    func addFade(duration: TimeInterval = 0.12) {
        guard duration > 0 else { return }
        let transition = CATransition()
        transition.type = .fade
        transition.duration = duration
        base.layer.add(transition, forKey: "jp_fade")
    }
}
