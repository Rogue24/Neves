//
//  GCDWorkItemTestVC.swift
//  Neves
//
//  Created by aa on 2020/11/5.
//

class GCDWorkItemTestVC: TestBaseViewController {
    
    var workItem: DispatchWorkItem? = nil
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        JPrint("开始了~")
        
//        var abc = 1
//        workItem = Asyncs.asyncDelay(5) {
//            // 不想这个 workItem 会被再次调用，就调用 cancel，workItem 就会废掉。
//            self.workItem?.cancel()
//            abc += 1
//            JPrint("执行了~ \(abc)")
//        } mainTask: {
//            JPrint("执行完？\(abc)")
//        }
        
        workItem = Asyncs.asyncDelay(5) {
            JPrint("执行了~")
        } mainTask: { (isCanceled) in
//            self?.workItem = nil
            JPrint("执行完？\(isCanceled)")
        }

        
//        workItem = Asyncs.mainDelay(5) {
//            // 不想这个 workItem 会被再次调用，就调用 cancel，workItem 就会废掉。
////            self.workItem?.cancel()
//            JPrint("执行了~")
//        }
//        workItem?.notify(queue: DispatchQueue.main, execute: {
//            JPrint("执行完？")
//        })
    }
    
    deinit {
        JPrint("我死了")
    }
    
    // 只要执行过 cancel 或 perform，都会执行 notify，并且一个 workItem 只会执行【一次】notify
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        JPrint("点了屏幕")
        
        if workItem?.isCancelled ?? true {
            // 只要调用了 perform，就会【立即】接着执行 notify
            // 即便在此之前已经调用了 cancel，那也只是不会执行 perform 里面的代码，但 notify 还是会执行
            workItem?.perform()
        } else {
            // 延时来到前【只】调用 cancel（不管调用几次）都【不会】接着执行 notify，会等到延时到了才会执行 notify
            workItem?.cancel()
            workItem?.cancel()
            workItem?.cancel()
        }
        
        // 只要不调用 cancel，perform 就可以执行多次（即便 notify 已经执行了）
//        workItem?.perform()
//        workItem?.perform()
//        workItem?.perform()
        
        // 只要【执行过】cancel，就不可以再执行 perform（废掉 workItem）
//        workItem?.cancel()
//        workItem?.perform()
//        workItem?.perform()
//        workItem?.perform()
        
        // 所以，如果想 perform 只执行一次，那么就在 perform 的函数体内对 workItem 执行 cancel，那么这个 workItem 就会废掉了。
        
        // 想【提前】完整地执行整个任务，即 perform + notify 都会调用，并且只会调用一次，最好的做法就是在外部 perform + cancel
//        workItem?.perform()
//        workItem?.cancel()
    }
    
}
