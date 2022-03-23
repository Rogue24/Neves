//
//  PlaygroundViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  公告：这是【临时游玩】的场所！游玩结束后记得【清空代码】！！！

import UIKit

class PlaygroundViewController: TestBaseViewController {
    
    let imageView = UIImageView(image: UIImage(named: "jp_icon"))
    let maskLayer = CAShapeLayer()
    
    let maskLayer2 = CAShapeLayer()
    
    let slider = UISlider()
    let testView = TestView()
    
    // https://www.jianshu.com/p/aaa88468d3e0
    let anotherQueue = DispatchQueue(label: "com.appcoda.anotherQueue", qos: .userInitiated, attributes: [.concurrent, .initiallyInactive])
//    let anotherQueue = DispatchQueue(label: "com.appcoda.anotherQueue", qos: .userInitiated, attributes: .initiallyInactive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = [100, 200, 100, 100]
        view.addSubview(imageView)
        
        maskLayer.fillColor = UIColor.randomColor.cgColor
        maskLayer.strokeColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        maskLayer.path = getPath().cgPath
        
        slider.frame = [30, UIScreen.mainHeight - 100 - 40, UIScreen.mainWidth - 60, 20]
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(sliderDidChanged(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        testView.frame = [100, 400, 100, 100]
        testView.backgroundColor = .randomColor
        view.addSubview(testView)
        
        
        anotherQueue.async {
            for i in 0 ..< 10 {
                JPrint("🍌", i)
            }
        }
        
        anotherQueue.async {
            for i in 10 ..< 20 {
                JPrint("🌶", i)
            }
        }
        
        anotherQueue.async {
            for i in 20 ..< 30 {
                JPrint("🍍", i)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if imageView.layer.mask == nil {
            imageView.layer.cornerRadius = 50
            imageView.layer.masksToBounds = true
            imageView.layer.mask = maskLayer
        } else {
            imageView.layer.cornerRadius = 0
            imageView.layer.masksToBounds = false
            imageView.layer.mask = nil
        }
        
        
        anotherQueue.activate()
    }
    
    
    func getPath() -> UIBezierPath {
        let path = UIBezierPath(roundedRect: [0, 0, 100, 100], cornerRadius: 50)
        
        let path2 = UIBezierPath(roundedRect: [80, 0, 100, 100], cornerRadius: 50)
        path.append(path2)
        
        return path
    }
    
    @objc func sliderDidChanged(_ slider: UISlider) {
        let diff = CGFloat(slider.value)
        
        testView.frame.origin = [100 + diff, 400 + diff]
    }



}

extension PlaygroundViewController {
    
    
    
}
 
