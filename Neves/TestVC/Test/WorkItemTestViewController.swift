//
//  WorkItemTestViewController.swift
//  Neves
//
//  Created by aa on 2021/2/3.
//

import Dispatch

class WorkItemTestViewController: TestBaseViewController {
    
    /*
     1.会循环引用 ❌
     var workItem: DispatchWorkItem? = nil
     +
     workItem = Asyncs.asyncDelay(3) {
         JPrint("Test2ViewController \(self.content).")
     }
     
     2.不会循环引用，不过要等到workItem执行完才死 ❌
     weak var workItem: DispatchWorkItem? = nil
     +
     workItem = Asyncs.asyncDelay(3) {
         JPrint("Test2ViewController \(self.content).")
     }
     
     3.不会循环引用，可以立即死
     var workItem: DispatchWorkItem? = nil ✅
     or
     weak var workItem: DispatchWorkItem? = nil ❌
     +
     workItem = Asyncs.asyncDelay(3) { [weak self] in
         JPrint("Test2ViewController \(self?.content ?? "null").")
     }
     
     But，workItem不可以用weak引用！！！！，返回赋值是无法存储的！！！
     也就是说，weak引用的workItem是空值！！！简直无用功！！！想取消时就无法取消了！！！
     
     不用担心GCD的内存管理，会自动释放workItem
     
     */
    
    let content = "work"
    
    var workItem: DispatchWorkItem? = nil
//    weak var workItem: DispatchWorkItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JPrint("Test2ViewController born.")
        
//        workItem = Asyncs.asyncDelay(3) {
//            JPrint("Test2ViewController \(self.content).")
//        }
        workItem = Asyncs.asyncDelay(3) { [weak self] in
            JPrint("Test2ViewController \(self?.content ?? "nothing").")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let lastWords = workItem == nil ? "null" : "workItem"
        JPrint("Test2ViewController disappear.", lastWords)
        
        // workItem不能weak引用，否则保存不了，会是个空值，导致无法取消
//        workItem?.cancel()
    }
    
    deinit {
        let lastWords = workItem == nil ? "null" : "workItem"
        JPrint("Test2ViewController die.", lastWords)
    }
}
