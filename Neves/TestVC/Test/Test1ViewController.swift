//
//  Test1ViewController.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class Test1ViewController: TestBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let wh = PortraitScreenWidth
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 200, width: wh, height: wh)
        layer.backgroundColor = UIColor.randomColor.cgColor
        view.layer.addSublayer(layer)
        
        let mLayer = CALayer()
        mLayer.frame = CGRect(x: 0, y: 0, width: wh, height: wh)
        mLayer.backgroundColor = UIColor.clear.cgColor
        
        let mLayer1 = CALayer()
        mLayer1.frame = CGRect(x: 0, y: 20, width: wh, height: wh - 40)
        mLayer1.backgroundColor = UIColor.black.cgColor
        mLayer.addSublayer(mLayer1)
        
        let gLayer1 = CAGradientLayer()
        gLayer1.frame = CGRect(x: 0, y: 0, width: wh, height: 20)
        gLayer1.colors = [UIColor.rgb(0, 0, 0, a: 0).cgColor, UIColor.rgb(0, 0, 0, a: 1).cgColor]
        gLayer1.startPoint = .init(x: 0.5, y: 0)
        gLayer1.endPoint = .init(x: 0.5, y: 1)
        mLayer.addSublayer(gLayer1)
        
        let gLayer2 = CAGradientLayer()
        gLayer2.frame = CGRect(x: 0, y: wh - 20, width: wh, height: 20)
        gLayer2.colors = [UIColor.rgb(0, 0, 0, a: 1).cgColor, UIColor.rgb(0, 0, 0, a: 0).cgColor]
        gLayer2.startPoint = .init(x: 0.5, y: 0)
        gLayer2.endPoint = .init(x: 0.5, y: 1)
        mLayer.addSublayer(gLayer2)
        
        layer.mask = mLayer
        
    }
    
    deinit {
        JPrint("死了")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        JPrint(self, "viewWillAppear")
    }
}
