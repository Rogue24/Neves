//
//  GCDAttributesViewController.swift
//  Neves
//
//  Created by aa on 2022/3/24.
//
//  参考：https://www.jianshu.com/p/aaa88468d3e0


class GCDAttributesViewController: TestBaseViewController {
    
    /// 默认`attributes`啥都不加就是【同步】队列
    /// 往`attributes`加上`.concurrent`就是【异步】队列
    /// 往`attributes`加上`.initiallyInactive`就是个需要【手动启动执行】的队列
    ///   - 可以重复调用`activate`多次执行，但已经执行过的任务只会执行一次，不会重复执行；
    ///   - 添加新的任务可以再次调用`activate`执行；
    ///   - 一定要确保队列已经执行了！否则当持有该队列的对象销毁时会崩溃！
    
    // 同步+手动启动
//    let anotherQueue = DispatchQueue(label: "com.appcoda.anotherQueue", qos: .userInitiated, attributes: .initiallyInactive)
    
    // 异步+手动启动
    let anotherQueue = DispatchQueue(label: "com.appcoda.anotherQueue", qos: .userInitiated, attributes: [.concurrent, .initiallyInactive])
    
    var activateTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQueue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            
            // 手动执行
            self.anotherQueue.activate()
            // 可以调用多次执行，但已经执行过的任务只会执行一次，不会重复执行
            self.anotherQueue.activate()
            self.anotherQueue.activate()
            
            // 添加新的任务可以再次调用`activate`执行
            self.setupQueue()
            // 已经执行过的任务只会执行一次，不会重复执行
            self.anotherQueue.activate()
            self.anotherQueue.activate()
            self.anotherQueue.activate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }
    
    deinit {
        // 一定要确保队列已经执行了！否则当持有该队列的对象销毁时会崩溃！
        anotherQueue.activate()
    }
    
    func setupQueue() {
        activateTag += 1
        let thisTag = activateTag
        
        anotherQueue.async {
            for i in 0 ..< 10 {
                JPrint("tag ---", thisTag, "🍌", i)
            }
        }
        
        anotherQueue.async {
            for i in 10 ..< 20 {
                JPrint("tag ---", thisTag, "🌶", i)
            }
        }
        
        anotherQueue.async {
            for i in 20 ..< 30 {
                JPrint("tag ---", thisTag, "🍍", i)
            }
        }
    }
}
