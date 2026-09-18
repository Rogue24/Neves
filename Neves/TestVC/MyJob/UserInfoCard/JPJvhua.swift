//
//  JPJvhua.swift
//  Falla
//
//  Created by aa on 2024/4/24.
//

import UIKit
import SnapKit
import pop

@objcMembers
class JPJvhua: UIView {
    var maskColor: UIColor = .rgb(0, 0, 0, a: 0.7) {
        didSet {
            idleRgba = maskColor.rgba
            idleRgba.a = 0
        }
    }
    
    var isAnimatingInteractionEnabled = false
    
    private(set) var isAnimating: Bool = false {
        didSet {
            if isAnimatingInteractionEnabled {
                isUserInteractionEnabled = false
            } else {
                isUserInteractionEnabled = isAnimating
            }
        }
    }
    
    private let jvhua: UIActivityIndicatorView
    private var idleRgba = UIColor.RGBA(a: 0)
    
    init(style: UIActivityIndicatorView.Style = .medium) {
        self.jvhua = UIActivityIndicatorView(style: style)
        super.init(frame: .zero)
        layer.backgroundColor = .rgba(idleRgba)
        isUserInteractionEnabled = false
        
        addSubview(jvhua)
        jvhua.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        jvhua.hidesWhenStopped = false
        jvhua.stopAnimating()
        
        jvhua.alpha = 0
        jvhua.transform = CGAffineTransformMakeScale(0.2, 0.2)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        
        jvhua.layer.removeAllAnimations()
        layer.removeAllAnimations()
        
        jvhua.startAnimating()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1) {
            self.jvhua.alpha = 1
            self.jvhua.transform = CGAffineTransformIdentity
        }
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayerBackgroundColor)!
        anim.toValue = maskColor
        anim.duration = 0.3
        layer.pop_add(anim, forKey: kPOPLayerBackgroundColor)
    }

    func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        
        jvhua.layer.removeAllAnimations()
        layer.pop_removeAllAnimations()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1) {
            self.jvhua.alpha = 0
            self.jvhua.transform = CGAffineTransformMakeScale(0.2, 0.2)
            self.layer.backgroundColor = .rgba(self.idleRgba)
        } completion: { finished in
            guard finished else { return }
            self.jvhua.stopAnimating()
        }
    }
}
