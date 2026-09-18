//
//  EdgeMaskView.swift
//  Falla
//
//  Created by aa on 2026/7/18.
//

import UIKit

@objcMembers
class EdgeMaskView: UIView {
    let maskInset: UIEdgeInsets
    
    private let midMaskView = UIView()
    private var leftMaskView: UIImageView? = nil
    private var rightMaskView: UIImageView? = nil
    private var topMaskView: UIImageView? = nil
    private var bottomMaskView: UIImageView? = nil
    
    private var mySize: CGSize = .zero
    
    init(size: CGSize, maskInset: UIEdgeInsets) {
        self.maskInset = maskInset
        
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = .clear
        clipsToBounds = false
        
        midMaskView.backgroundColor = .black
        addSubview(midMaskView)
        
        if maskInset.left > 0 {
            let leftMaskView = "matte_shadow".fa.imageView
            leftMaskView.contentMode = .scaleToFill
            leftMaskView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5 * (Env.isRTL ? -1.0 : 1.0))
            addSubview(leftMaskView)
            self.leftMaskView = leftMaskView
        }
        
        if maskInset.right > 0 {
            let rightMaskView = "matte_shadow".fa.imageView
            rightMaskView.contentMode = .scaleToFill
            rightMaskView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5 * (Env.isRTL ? 1.0 : -1.0))
            addSubview(rightMaskView)
            self.rightMaskView = rightMaskView
        }
        
        if maskInset.top > 0 {
            let topMaskView = "matte_shadow".fa.imageView
            topMaskView.contentMode = .scaleToFill
            topMaskView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            addSubview(topMaskView)
            self.topMaskView = topMaskView
        }
        
        if maskInset.bottom > 0 {
            let bottomMaskView = "matte_shadow".fa.imageView
            bottomMaskView.contentMode = .scaleToFill
            addSubview(bottomMaskView)
            self.bottomMaskView = bottomMaskView
        }
        
        layoutSubviewsIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsIfNeeded()
    }
    
    func layoutSubviewsIfNeeded() {
        guard mySize != bounds.size else { return }
        mySize = bounds.size
        
        let isRTL = Env.isRTL
        let viewW = max(bounds.width, maskInset.left + maskInset.right)
        let viewH = max(bounds.height, maskInset.top + maskInset.bottom)
        
        midMaskView.frame = CGRect(
            x: isRTL ? maskInset.right : maskInset.left,
            y: maskInset.top,
            width: viewW - maskInset.left - maskInset.right,
            height: viewH - maskInset.top - maskInset.bottom
        )
        
        leftMaskView?.frame = CGRect(
            x: isRTL ? midMaskView.frame.maxX : 0,
            y: midMaskView.frame.origin.y,
            width: maskInset.left,
            height: midMaskView.frame.height,
        )
        
        rightMaskView?.frame = CGRect(
            x: isRTL ? 0 : midMaskView.frame.maxX,
            y: midMaskView.frame.origin.y,
            width: maskInset.right,
            height: midMaskView.frame.height,
        )
        
        topMaskView?.frame = CGRect(
            x: midMaskView.frame.origin.x,
            y: 0,
            width: midMaskView.frame.width,
            height: maskInset.top,
        )
        
        bottomMaskView?.frame = CGRect(
            x: midMaskView.frame.origin.x,
            y: midMaskView.frame.maxY,
            width: midMaskView.frame.width,
            height: maskInset.bottom,
        )
    }
}
