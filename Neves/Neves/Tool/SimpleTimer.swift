//
//  SimpleTimer.swift
//  Neves
//
//  Created by aa on 2025/12/23.
//

import Foundation

@objcMembers
class SimpleTimer: NSObject {
    /// 定时器触发时执行的任务
    /// - Parameter delta: 本次触发与上一次触发之间的理论时间间隔（单位：秒）
    typealias Task = (_ delta: TimeInterval) -> Void
    
//    /// 启动后首次触发前的延迟时间（默认1秒）
//    /// - 例如：0 表示立即开始，1.5 表示延迟 1.5 秒后第一次触发
//    var startDelay: TimeInterval = 1
    
    /// 重复间隔时间（默认1秒）
    /// - 若定时器运行中，修改该值则会重启
    var interval: TimeInterval = 1 {
        didSet {
            guard interval != oldValue, isRunning else { return }
            restart()
        }
    }
    
    /// 是否异步执行（默认为false，在主线程）
    /// - 若定时器运行中，修改该值则会重启
    var isAsync = false {
        didSet {
            guard isAsync != oldValue, isRunning else { return }
            restart()
        }
    }
    
    /// 定时器触发时要执行的任务回调
    /// - 若定时器运行中，修改该值则会重启
    var task: Task? {
        get { _task }
        set {
            let isRunning = self.isRunning
            
            stop()
            _task = newValue
            
            guard isRunning else { return }
            start()
        }
    }
    
    private var _task: Task? = nil
    private var timer: DispatchSourceTimer?
    /// GCD定时器不能多次`suspend()`，否则`resume()`会失效，因为`suspend()`是可累积的，
    /// 也就是说每`suspend()`一次，就需要`resume()`回一次。
    /// 在【销毁】之前，确保定时器处于`resume()`状态，否则会引发崩溃！！！
    /// 为了避免多次`suspend()`而导致`resume()`失效，应该要用个布尔值去记录暂停状态。
    private var isRunning = false
    
    /// App进入后台的时间
    /// `CACurrentMediaTime()`返回的是一个「单调递增」的时间戳（秒），不会受到系统时间修改的影响。
    /// PS：防止用户修改系统时间不使用`Date`。
    private var enterBgTime: CFTimeInterval?
    
    override init() {
        super.init()
        setupObservers()
    }
    
    init(task: Task?) {
        self._task = task
        super.init()
        setupObservers()
    }
    
    init(interval: TimeInterval, isAsync: Bool, task: Task?) {
        self.interval = interval
        self.isAsync = isAsync
        self._task = task
        super.init()
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stop()
    }
}

// MARK: - 监听前后台切换
private extension SimpleTimer {
    func setupObservers() {
        NotificationCenter.jp.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification
        )

        NotificationCenter.jp.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification
        )
    }
    
    // MARK: 若定时器运行中，进入后台时暂停定时器
    @objc func appWillResignActive() {
//        JPrint("App进入后台")
        
        // 暂停定时器
        pause()
        
        // 若定时器运行中，记录进入后台的时间
        if timer != nil {
            enterBgTime = CACurrentMediaTime()
//            JPrint("enterBgTime:", enterBgTime ?? "null")
//            JPrint("-----------------------")
        }
    }
    
    // MARK: 若定时器运行中，回到前台时补偿时间并启动定时器
    @objc func appDidBecomeActive() {
//        JPrint("App回到前台")
        
        guard let enterBgTime = self.enterBgTime else { return }
        self.enterBgTime = nil
        
        guard let task else {
            stop()
            return
        }
        
        // 计算后台停留时间
        let diffTime = CACurrentMediaTime() - enterBgTime
//        JPrint("后台停留时间:", diffTime)
        
        // 补偿停留时间
        if isAsync {
            Asyncs.async { task(diffTime) }
        } else {
            Asyncs.main { task(diffTime) }
        }
        
        // enterBgTime有值说明定时器运行中，继续启动定时器
        start()
    }
}

// MARK: - API
extension SimpleTimer {
    /// 重启
    func restart() {
        stop()
        start()
    }
    
    /// 开始/继续
    func start() {
        guard let task else {
            stop()
            return
        }
        
        guard UIApplication.shared.applicationState == .active else {
            pause()
            if enterBgTime == nil {
                enterBgTime = CACurrentMediaTime()
            }
            return
        }
        
        enterBgTime = nil
        
        if let timer = self.timer {
            if !isRunning {
                timer.resume()
                isRunning = true
            }
            return
        }
        
        let queue: DispatchQueue = isAsync ? .global() : .main
        let interval = self.interval
        
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.setEventHandler { task(interval) }
        timer.resume()
        
        self.timer = timer
        self.isRunning = true
    }
    
    /// 暂停
    func pause() {
        guard let timer else {
            isRunning = false
            return
        }
        
        if isRunning {
            timer.suspend()
            isRunning = false
        }
    }
    
    /// 停止
    func stop() {
        enterBgTime = nil
        
        guard let timer else {
            isRunning = false
            return
        }
        
        timer.cancel()
        // ⚠️ 确保在【销毁】之前是`resume`状态，否则会崩溃！
        if !isRunning {
            // 如果是在`cancel`之前`resume`，会立马执行一次回调，但既然要停止那这个回调就没必要调用了。
            // 📢 前提要有`suspend`，才可以在`cancel`之后调用`resume`取消挂起状态，这样才不会执行多余的回调，
            // 否则非挂起状态下`cancel`之后接着`resume`会崩溃！
            timer.resume()
        }
        
        self.timer = nil
        self.isRunning = false
    }
}
