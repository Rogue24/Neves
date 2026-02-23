//
//  CAAnimationTestViewController.swift
//  Neves
//
//  Created by aa on 2026/2/24.
//

import UIKit
import FunnyButton

class CAAnimationTestViewController: TestBaseViewController {
    
    private let box = UIView()
    
    private var animCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        box.backgroundColor = .randomColor
        box.size = [50, 50]
        box.center = [100, 200]
        view.addSubview(box)
        
        let line1 = UIView(frame: [0, 400, PortraitScreenWidth, 1])
        line1.backgroundColor = .randomColor
        view.addSubview(line1)
        
        let line2 = UIView(frame: [0, 420, PortraitScreenWidth, 1])
        line2.backgroundColor = .randomColor
        view.addSubview(line2)
        
        let line3 = UIView(frame: [0, 440, PortraitScreenWidth, 1])
        line3.backgroundColor = .randomColor
        view.addSubview(line3)
        
        let line4 = UIView(frame: [0, 460, PortraitScreenWidth, 1])
        line4.backgroundColor = .randomColor
        view.addSubview(line4)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
        addFunnyAction { [weak self] in
            guard let self else { return }
            self.myTest()
        }
    }
}

private extension CAAnimationTestViewController {
    func myTest() {
        if let keys = box.layer.animationKeys(), keys.count > 3 {
            JPrint("移除animationKeys第一个动画！")
            box.layer.removeAnimation(forKey: keys.first!)
            animCount -= 1
            return
        }
        
        let y = 400 + CGFloat(animCount * 20)
        animCount += 1
        
        let anim1 = CABasicAnimation(keyPath: "position")
        anim1.delegate = self
        anim1.fromValue = CGPoint(x: 100, y: 200)
        anim1.toValue = CGPoint(x: 300, y: y)
        anim1.duration = 8
        
        anim1.repeatCount = .infinity
        anim1.isRemovedOnCompletion = false
        anim1.fillMode = .forwards
        
        box.layer.add(anim1, forKey: "anim1_\(Int.random(in: 0...100))")
        JPrint("0000 y: \(y), animationKeys", box.layer.animationKeys() ?? "木有了")
        
        Asyncs.mainDelay(10) {
            JPrint("2222 y: \(y), animationKeys", self.box.layer.animationKeys() ?? "木有了")
        }
    }
}

extension CAAnimationTestViewController: CAAnimationDelegate {
    /// 只要App进入后台，动画都会触发`animationDidStop`，但只是被系统标记为已完成，
    /// 而是否真的会被移除则取决于`isRemovedOnCompletion`：
    /// - 为`true`：动画就会被移除，同时也将其从`animationKeys`移除，等App回到前台时就没有这个动画了；
    /// - 为`false`：动画只是被暂停在当前状态，并且`animationKeys`里还是有这个动画的，等App回到前台时继续执行。
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        JPrint("1111 animationKeys", box.layer.animationKeys() ?? "木有了")
    }
}
