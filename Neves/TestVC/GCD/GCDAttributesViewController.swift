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
    ///   - 可以调用多次执行，但实际之后执行一次；
    ///   - 一定要保证执行了！否则当持有该队列的对象销毁时会崩溃！
    
    // 同步+手动启动
//    let anotherQueue = DispatchQueue(label: "com.appcoda.anotherQueue", qos: .userInitiated, attributes: .initiallyInactive)
    
    // 异步+手动启动
    let anotherQueue = DispatchQueue(label: "com.appcoda.anotherQueue", qos: .userInitiated, attributes: [.concurrent, .initiallyInactive])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            self.anotherQueue.activate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }
    
    deinit {
        // 一定要保证执行了！否则当持有该队列的对象销毁时会崩溃！
        anotherQueue.activate()
    }
    
}
