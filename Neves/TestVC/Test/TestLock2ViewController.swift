//
//  TestLock2ViewController.swift
//  Neves
//
//  Created by aa on 2022/5/26.
//

class TestLock2ViewController: TestBaseViewController {
    let locker = NSLock()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        JPProgressHUD.show(true)
        
        addFunAction { [weak self] in
            guard let self = self else { return }
            
            self.abc(0)
            
            Asyncs.asyncDelay(2) {
                JPrint("async 0")
                self.abc(1)
                JPrint("async 1")
            }
        }
    }
    
    func abc(_ x: Int) {
        JPrint("\(x)_lock 0")
        locker.lock()
        JPrint("\(x)_lock 1")
        
        Asyncs.mainDelay(5) {
            JPrint("\(x)_unlock 0")
            self.locker.unlock()
            JPrint("\(x)_unlock 1")
        }
    }
    
//    [03:54:20:69]: 0_lock 0
//    [03:54:20:69]: 0_lock 1
//    [03:54:22:82]: async 0
//    [03:54:22:82]: 1_lock 0 // `1_lock 1`要等`0_unlock`后才能打印
//    [03:54:25:69]: 0_unlock 0
//    [03:54:25:69]: 0_unlock 1
//    [03:54:25:69]: 1_lock 1
//    [03:54:25:69]: async 1
//    [03:54:30:69]: 1_unlock 0
//    [03:54:30:69]: 1_unlock 1
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
        
        JPProgressHUD.dismiss()
    }
}
