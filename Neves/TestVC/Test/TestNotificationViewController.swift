//
//  TestNotificationViewController.swift
//  Neves
//
//  Created by aa on 2023/10/29.
//

import UIKit
import FunnyButton

class TestNotificationViewController: TestBaseViewController {
    
    private class ABC: NSObject {
        var name: String = ""
        
        @objc func abc(_ no: Notification) {
            JPrint("abc ---", name)
        }
    }
    
    private let a = ABC()
    private let b = ABC()
    
    /**
     - 如果注册时object为某个对象，那么当该通知并非object发出的，就不会接收处理；
     - 如果注册时object为空，那么当该通知不管是谁发出的，都会接收处理。

     🌰🌰🌰：
     NotificationCenter.jp.addObserver(a, selector: #selector(ABC.abc(_:)), name: "wAaa", object: self)
     NotificationCenter.jp.addObserver(b, selector: #selector(ABC.abc(_:)), name: "wAaa", object: nil)

     当object带上self：
     NotificationCenter.jp.post(name: "wAaa", object: self)
     打印：
     jpjpjp [02:34:51:90]: abc --- aaa
     jpjpjp [02:34:51:90]: abc --- bbb

     当object为nil：
     NotificationCenter.jp.post(name: "wAaa", object: nil)
     打印：
     jpjpjp [02:35:36:19]: abc --- bbb

     总结：
     - addObserver的object为xxx，那么只会接收【post的object也为xxx】的通知！
     - 反之，如果【post的object不为xxx或者是nil】，就不会接收该通知！
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        a.name = "aaa"
        b.name = "bbb"
        
        NotificationCenter.jp.addObserver(a, selector: #selector(ABC.abc(_:)), key: .wAaa, object: self)
        NotificationCenter.jp.addObserver(b, selector: #selector(ABC.abc(_:)), key: .wAaa, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        removeFunnyActions()
        
        addFunnyAction(name: "带self") { [weak self] in
            guard let self = self else { return }
            NotificationCenter.jp.post(key: .wAaa, object: self)
        }
        
        addFunnyAction(name: "不带self") {
            NotificationCenter.jp.post(key: .wAaa, object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(a)
        NotificationCenter.default.removeObserver(b)
    }
    
}
