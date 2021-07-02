//
//  SublayerTransformTestVC.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/25.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class SublayerTransformTestVC: TestBaseViewController {
    
    var slider: UISlider = UISlider()
    
    var bigLayer: CALayer = CALayer()
    var subLayer1: CALayer = CALayer()
    var subLayer2: CALayer = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        slider.backgroundColor = .randomColor
        slider.x = 16;
        slider.width = PortraitScreenWidth - 32
        slider.y = NavTopMargin + 30
        slider.maximumValue = 1
        slider.minimumValue = 0
        slider.value = 0
        slider.addTarget(self, action: #selector(changeValue), for: .valueChanged)
        view.addSubview(slider)
        
        bigLayer.frame = [16, NavTopMargin + 200, PortraitScreenWidth - 32, PortraitScreenWidth - 32]
        bigLayer.backgroundColor = UIColor.randomColor.cgColor
        view.layer.addSublayer(bigLayer)
        
        subLayer1.frame = [40, 40, 150, 150]
        subLayer1.backgroundColor = UIColor.randomColor.cgColor
        bigLayer.addSublayer(subLayer1)
        
        subLayer2.frame = [bigLayer.frame.width - 150 - 40, bigLayer.frame.height - 150 - 40, 150, 150]
        subLayer2.backgroundColor = UIColor.randomColor.cgColor
        bigLayer.addSublayer(subLayer2)
        
    }
    
    @objc func changeValue() {
        let value: CGFloat = CGFloat(slider.value)
        
        let angle: CGFloat = CGFloat.pi * value
        let scale: CGFloat = 1 + value * 0.5
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        bigLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        bigLayer.sublayerTransform = CATransform3DMakeScale(scale, scale, 1)
        CATransaction.commit()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
