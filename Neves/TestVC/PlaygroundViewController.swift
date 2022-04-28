//
//  PlaygroundViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  公告：这是【临时游玩】的场所！游玩结束后记得【清空代码】！！！

import UIKit

class PlaygroundViewController: TestBaseViewController {
    
    let locker = NSLock()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        JPProgressHUD.show(true)
        
        addFunAction { [weak self] in
            guard let self = self else { return }
//            JPrint("replaceMe", self)
            
            
            self.abc()
            
            Asyncs.asyncDelay(2) {
                JPrint("async 0")
                self.abc()
                JPrint("async 1")
            }
        }
    }
    
    func abc() {
        JPrint("lock")
        locker.lock()
        Asyncs.mainDelay(5) {
            JPrint("unlock 0")
            self.locker.unlock()
            JPrint("unlock 1")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
        
        JPProgressHUD.dismiss()
    }

}

extension PlaygroundViewController {
    
}
 
