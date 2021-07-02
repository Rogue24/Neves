//
//  JPFuncTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/6/9.
//

import Foundation
import RxSwift

protocol JPProcessor {
    var identifier: String { get }
    func process(_ x: Double) -> Double
}
extension JPProcessor {
    func append(another: JPProcessor) -> JPProcessor {
        let newIdentifier = identifier.appending("=>\(another.identifier)")
        return JPGeneralProcessor(identifier: newIdentifier) { x in
            return another.process(self.process(x))
        }
    }
}

infix operator =>: AdditionPrecedence
func => (left: JPProcessor, right: JPProcessor) -> JPProcessor {
    return left.append(another: right)
}

struct JPGeneralProcessor: JPProcessor {
    let identifier: String
    let p: (Double) -> Double
    func process(_ x: Double) -> Double {
        return p(x)
    }
}

struct JPAProcessor: JPProcessor {
    let identifier: String
    let a: Double
    func process(_ x: Double) -> Double {
        return x + a
    }
}
struct JPBProcessor: JPProcessor {
    let identifier: String
    let b: Double
    func process(_ x: Double) -> Double {
        return x - b
    }
}
struct JPCProcessor: JPProcessor {
    let identifier: String
    let c: Double
    func process(_ x: Double) -> Double {
        return x * c
    }
}
class JPDProcessor: JPProcessor {
    let identifier: String
    let d: Double
    func process(_ x: Double) -> Double {
        return x / d
    }
    
    init(identifier: String, d: Double) {
        self.identifier = identifier
        self.d = d
    }
    
    deinit {
        JPrint("d 死了")
    }
}


class JPFuncTestViewController: TestBaseViewController {
    
    var p: JPProcessor! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let a = JPAProcessor(identifier: "a", a: 30) // 50
        let b = JPBProcessor(identifier: "b", b: 20) // 30
        let c = JPCProcessor(identifier: "c", c: 3) // 90
        let d = JPDProcessor(identifier: "d", d: 6) // 15
        
//        p = a.append(another: b).append(another: c).append(another: d)
        p = a => b => c => d
        
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
    
    @objc func tttt() {
        JPrint(p.identifier, p.process(6))
    }
    
}

