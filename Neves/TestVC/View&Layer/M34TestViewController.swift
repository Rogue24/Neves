//
//  M34TestViewController.swift
//  Neves
//
//  Created by 周健平 on 2022/5/3.
//

import QuartzCore

class M34TestViewController: TestBaseViewController {
    
    let bgLayer = CALayer()
    let m34Layer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgLayer.backgroundColor = UIColor.randomColor.cgColor
        bgLayer.frame = [20.px, NavTopMargin + 50.px, PortraitScreenWidth - 40.px, PortraitScreenWidth - 40.px]
        bgLayer.zPosition = -500
        view.layer.addSublayer(bgLayer)
        
        m34Layer.backgroundColor = UIColor.randomColor.cgColor
        m34Layer.frame = bgLayer.frame
        m34Layer.borderWidth = 3.px
        m34Layer.borderColor = UIColor.randomColor.cgColor
        m34Layer.cornerRadius = 10.px
        view.layer.addSublayer(m34Layer)
        
        let slider = UISlider()
        slider.minimumValue = -1
        slider.maximumValue = 1
        slider.value = 0
        slider.addTarget(self, action: #selector(sliderValueDidChanged(_:)), for: .valueChanged)
        slider.frame = [20.px, PortraitScreenHeight - 220, PortraitScreenWidth - 50.px, slider.height]
        view.addSubview(slider)
    }
    
    @objc func sliderValueDidChanged(_ slider: UISlider) {
        let value = CGFloat(slider.value)
        
        let angle = 45 * value
        let radian = JPAngle2Radian(angle)
        
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / 500.0 // 要先设置m34再设置弧度才有效果
        transform = CATransform3DRotate(transform, radian, 0, 1, 0) // 基于设置好的m34，再根据此时设置的弧度，才能计算出正确的矩阵
//        transform.m34 = 1.0 / 500.0 // 因此如果在设置弧度之后再设置m34是没效果的
        
        // m34的正负代表顺逆时针，正为顺时针，负为逆时针
        // 🌰当作用于y轴，且radian为正：
        // 1.m34大于0，y轴顺时针旋转，效果为：右边变大，左边变小
        // 2.m34小于0，y轴逆时针旋转，效果为：右边变小，左边变大
        
        JPrint("角度", angle)
        JPrint("-------------")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        m34Layer.transform = transform
        CATransaction.commit()
    }
    
}

