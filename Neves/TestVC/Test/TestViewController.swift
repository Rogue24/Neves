//
//  TestViewController.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class TestViewController: TestBaseViewController {
    
    let box: UIView = UIView()
    
    let demoLabel = HYLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        box.frame = [100, 100, 100, 100]
        box.backgroundColor = .randomColor()
        view.addSubview(box)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        navigationController?.pushViewController(ManyLayerToMaskViewController(), animated: true)
        navigationController?.pushViewController(WorkItemTestViewController(), animated: true)
    }

}

extension TestViewController {
    func testSet() {
        let set1: Set = [1, 2, 3, 4, 5]
        let set2: Set = [2, 3, 4]
        
        let set3 = set1.intersection(set2) // 交集
        let set4 = set1.subtracting(set2) // 差集
        
        let set5 = set1.subtracting([3, 4])
        let set6 = set1.subtracting([])
        
//        JPrint(set3)
//        JPrint(set3)
        
        JPrint(set5)
        JPrint(set6)
        
        for obj in set1 {
            JPrint("set1", obj)
        }
        JPrint("------")
        
        for obj in set2 {
            JPrint("set2", obj)
        }
        JPrint("------")
        
        for obj in set3 {
            JPrint("set3", obj)
        }
        JPrint("------")
        
        for obj in set4 {
            JPrint("set4", obj)
        }
        JPrint("------")
        
        JPrint(set1.contains(6))
        JPrint(set1.contains(2))
    }
}

extension TestViewController {
    func testHYLabel() {
        demoLabel.text = "作者:@coderwhy 话题:#Label字符串识别# 网址:http://www.520it.com"
        demoLabel.size = .init(width: 200, height: 200)
        demoLabel.origin = .init(x: 20, y: 200)
        view.addSubview(demoLabel)
        
        demoLabel.userTapHandler = { (label, user, range) in
            JPrint(label)
            JPrint(user)
            JPrint(range)
        }
        
        demoLabel.linkTapHandler = { (label, link, range) in
            JPrint(label)
            JPrint(link)
            JPrint(range)
        }
        
        demoLabel.topicTapHandler = { (label, topic, range) in
            JPrint(label)
            JPrint(topic)
            JPrint(range)
        }
    }
}

extension TestViewController {
    func testLayer() {
        let recordLayer = CALayer()
        recordLayer.frame = [100, 300, 85, 85]
        recordLayer.backgroundColor = UIColor.randomColor.cgColor
        view.layer.addSublayer(recordLayer)
        
        
        let radian: CGFloat = CGFloat.pi * 2 * CGFloat(10.0 / 15.0) - CGFloat.pi * 0.5
        JPrint((radian * 180.0) / CGFloat.pi)
        
        let lineW: CGFloat = 5
        let halfLineW: CGFloat = lineW * 0.5
        
        let center1 = CGPoint(x: 85 * 0.5, y: 85 * 0.5)
        
        let radius: CGFloat = 85 * 0.5 - halfLineW
        
        let x: CGFloat = radius * cos(radian)
        let y: CGFloat = radius * sin(radian)
        let center2 = CGPoint(x: center1.x + x, y: center1.y + y)
        
        let locationPath = UIBezierPath(ovalIn: [center1.x - halfLineW, 0, lineW, lineW])
        locationPath.append(UIBezierPath(ovalIn: [center2.x - halfLineW, center2.y - halfLineW, lineW, lineW]))
        
        
        let locationLayer = CAShapeLayer()
        locationLayer.fillColor = UIColor.rgb(255, 87, 169).cgColor
        locationLayer.path = locationPath.cgPath
        recordLayer.addSublayer(locationLayer)
    }
}
