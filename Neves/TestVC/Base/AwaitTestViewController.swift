//
//  AwaitTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/6/9.
//

import Foundation

class AwaitTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bbb: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("Tap me", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [100, 150, 100, 80]
            btn.addTarget(self, action: #selector(tttt), for: .touchUpInside)
            return btn
        }()
        view.addSubview(bbb)
    }
    
    @objc func tttt() {//async {
//        let r = await aaa()
//        JPrint("tttt r", r, Thread.current)
    }
//
//    func aaa() async -> Double {
//        let r1 = await abc(6)
//        let r2 = await abc(7)
//        let r3 = await abc(8)
//        let r4 = await abc(9)
//        return r1 + r2 + r3 + r4
//    }
//
//    func abc(_ x: Double) async -> Double {
//        let delay = arc4random_uniform(5)
//
//        JPrint("begin x", x, "delay", delay, Thread.current)
//        sleep(delay)
//
//        let r = p.process(x)
//
//        JPrint("end x", x, "delay", delay, Thread.current)
//        return r
//    }
}

