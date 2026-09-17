//
//  SweepImageView.swift
//  Falla
//
//  Created by aa on 2025/6/6.
//

import UIKit

@objcMembers
class SweepImageView: UIImageView {
    private(set) var isSweeping = false
    
    var isMultiplex = true {
        didSet {
            guard !isMultiplex, !isSweeping else { return }
            sweepLayer?.removeAllAnimations()
            sweepView?.removeFromSuperview()
            sweepView = nil
        }
    }
    
    private weak var sweepView: UIView?
    private weak var sweepImgView: UIImageView?
    private weak var sweepLayer: CAGradientLayer?
    private var sweepColors: [Any]? = nil
    
    private var mySize: CGSize = .zero {
        didSet {
            guard mySize != oldValue else { return }
            resetSweep()
        }
    }
    
    /// 扫光时长
    var sweepDuration: TimeInterval = 1.8 {
        didSet {
            guard sweepDuration != oldValue else { return }
            resetSweep()
        }
    }
    
    /// 扫光宽度
    var sweepWidth: CGFloat = 20 {
        didSet {
            guard sweepWidth != oldValue else { return }
            resetSweep()
        }
    }
    
    /// 扫光颜色
    var sweepColor: UIColor = .rgb(255, 255, 255, a: 0.55) {
        didSet {
            guard sweepColor != oldValue else { return }
            sweepColors = nil
            resetSweep()
        }
    }
    
    override var alpha: CGFloat {
        get { super.alpha }
        set {
            let isChange = (super.alpha > 0.1) != (newValue > 0.1)
            super.alpha = newValue
            guard isChange else { return }
            resetSweep()
        }
    }
    
    override var isHidden: Bool {
        get { super.isHidden }
        set {
            let isChange = super.isHidden != newValue
            super.isHidden = newValue
            guard isChange else { return }
            resetSweep()
        }
    }
    
    override var image: UIImage? {
        get { super.image }
        set {
            let isChange = (super.image == nil) != (newValue == nil)
            super.image = newValue
            sweepImgView?.image = newValue
            guard isChange else { return }
            resetSweep()
        }
    }
    
    override var contentMode: UIView.ContentMode {
        get { super.contentMode }
        set {
            super.contentMode = newValue
            sweepImgView?.contentMode = newValue
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mySize = bounds.size
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mySize = bounds.size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mySize = bounds.size
    }
}

private extension SweepImageView {
    /// 重置扫光
    func resetSweep() {
        guard isSweeping else { return }
        isSweeping = false
        startSweep()
    }
}

extension SweepImageView {
    // MARK: - 开始扫光
    @objc func startSweep() {
        guard !isSweeping else { return }
        isSweeping = true
        
        guard image != nil, // 要有图片
              bounds.width > 0, bounds.height > 0, // 要有尺寸
              alpha > 0.1, !isHidden, // 要能显示
              sweepDuration > 0, sweepWidth > 0 // 要扫得动
        else {
            // 如果条件不满足，停止扫动
            sweepView?.isHidden = true
            sweepLayer?.removeAllAnimations()
            return
        }
        
        let isRTL = Env.isRTL
        
        let sweepView = self.sweepView ?? {
            let view = UIView()
            addSubview(view)
            return view
        }()
        sweepView.frame = bounds
        self.sweepView = sweepView
        
        let sweepImgView = self.sweepImgView ?? {
            let imgView = UIImageView(image: image)
            imgView.contentMode = contentMode
            sweepView.mask = imgView
            return imgView
        }()
        sweepImgView.frame = sweepView.bounds
        self.sweepImgView = sweepImgView
        
        let sweepLayer = self.sweepLayer ??  {
            let gLayer = CAGradientLayer()
            gLayer.locations = [0.35, 0.43, 0.57, 0.65]
            if isRTL {
                gLayer.startPoint = [-0.13, 0.13]
                gLayer.endPoint = [1.13, 0.87]
            } else {
                gLayer.startPoint = [-0.13, 0.87]
                gLayer.endPoint = [1.13, 0.13]
            }
            sweepView.layer.addSublayer(gLayer)
            return gLayer
        }()
        sweepLayer.frame.size = [sweepWidth, sweepView.bounds.height]
        self.sweepLayer = sweepLayer
        
        let sweepColors: [Any] = self.sweepColors ?? {
            let clearColor = UIColor.rgb(255, 255, 255, a: 0).cgColor
            let sweepColor = self.sweepColor.cgColor
            return [clearColor, sweepColor, sweepColor, clearColor]
        }()
        sweepLayer.colors = sweepColors
        self.sweepColors = sweepColors
        
        let anim = CABasicAnimation(keyPath: "position.x")
        anim.duration = sweepDuration
        if isRTL {
            anim.fromValue = sweepView.bounds.width + sweepWidth * 0.5
            anim.toValue = -(sweepWidth * 0.5)
        } else {
            anim.fromValue = -(sweepWidth * 0.5)
            anim.toValue = sweepView.bounds.width + sweepWidth * 0.5
        }
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false
        anim.fillMode = .forwards
        sweepLayer.add(anim, forKey: "jp_sweep")
        
        sweepView.isHidden = false
    }
    
    // MARK: - 停止扫光
    @objc func stopSweep() {
        isSweeping = false
        
        sweepView?.isHidden = true
        sweepLayer?.removeAllAnimations()
        
        guard !isMultiplex else { return }
        sweepView?.removeFromSuperview()
        sweepView = nil
    }
}
