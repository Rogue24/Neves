//
//  TestLockViewController.swift
//  Neves
//
//  Created by aa on 2021/11/24.
//
//  结论：同一把🔐，只要锁上了，就可以拦截任何线程。
//  因此，尽量不要在【主线程】上锁，例如在其他线程上锁去处理耗时操作时，接着回到主线程上锁就会造成卡顿（那是在等上一把🔐解锁）

import Foundation

class TestLockViewController: TestBaseViewController {
    
    let lock: UnsafeMutablePointer<pthread_mutex_t> = {
        let attrPtr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        pthread_mutexattr_init(attrPtr)
        // PTHREAD_MUTEX_DEFAULT 默认
        // PTHREAD_MUTEX_RECURSIVE 递归：允许【同一个线程】对同一把🔐进行【重复】加🔐 --- 特别之处是可以是对【同一个线程】重复加🔐（也就是上一次加的🔐还没解开前再次加🔐的情景），要是普通的🔐就会造成【死锁】了！！！
        pthread_mutexattr_settype(attrPtr, PTHREAD_MUTEX_RECURSIVE)
        
        let mutexPtr = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        pthread_mutex_init(mutexPtr, attrPtr)
        
        pthread_mutexattr_destroy(attrPtr)
        attrPtr.deallocate()
        
        return mutexPtr
    }()
    
    let tv = UITextView()
    
    static var tag4 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("异步任务1", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [20, 120, 80, 60]
            btn.addTarget(self, action: #selector(btn1DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn1)
        
        let btn2: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("异步任务2", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [120, 120, 80, 60]
            btn.addTarget(self, action: #selector(btn2DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn2)
        
        let btn3: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("UI任务", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [20, 200, 80, 60]
            btn.addTarget(self, action: #selector(btn3DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn3)
        
        let btn4: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("主线程任务", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [120, 200, 80, 60]
            btn.addTarget(self, action: #selector(btn4DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn4)
        
        let tvLabel = UILabel(frame: [20, 300, 400, 20])
        tvLabel.font = .boldSystemFont(ofSize: 15)
        tvLabel.textColor = .randomColor
        tvLabel.text = "用来看有木有阻塞主线程（运行时来回拖动）"
        view.addSubview(tvLabel)
        
        tv.frame = [20, 320, 300, 150]
        tv.backgroundColor = .randomColor
        tv.text = "seoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejf"
        view.addSubview(tv)
    }
    
    deinit {
        pthread_mutex_destroy(lock)
        lock.deinitialize(count: 1)
        lock.deallocate()
        
        JPrint("死废了")
    }
    
    /// `异步任务1`
    /// 如果执行过程中调用`异步任务1`或`异步任务2`，会排队执行（卡住那条子线程）
    /// 如果执行过程中调用`UI任务`或`主线程任务`，同样也会排队执行，但是会卡住主线程的！建议尽量不要在【主线程】上锁！
    @objc func btn1DidClick() {
        Asyncs.async {
            JPrint("准备 111", Thread.current)
            
            pthread_mutex_lock(self.lock)
            JPrint("开始 111", Thread.current)
            
            sleep(5)
            
            JPrint("结束 111", Thread.current)
            pthread_mutex_unlock(self.lock)
        }
    }
    
    /// `异步任务2`
    /// 如果执行过程中调用`异步任务1`或`异步任务2`，会排队执行（卡住那条子线程）
    /// 如果执行过程中调用`UI任务`或`主线程任务`，同样也会排队执行，但是会卡住主线程的！建议尽量不要在【主线程】上锁！
    @objc func btn2DidClick() {
        Asyncs.async {
            JPrint("准备 222", Thread.current)
            
            pthread_mutex_lock(self.lock)
            JPrint("开始 222", Thread.current)
            
            sleep(3)
            
            JPrint("结束 222", Thread.current)
            pthread_mutex_unlock(self.lock)
        }
    }
    
    /// `UI任务`
    @objc func btn3DidClick() {
        JPrint("准备 333", Thread.current)
        
        pthread_mutex_lock(lock)
        JPrint("开始 333", Thread.current)
        
        tv.backgroundColor = .randomColor
        
        JPrint("结束 333", Thread.current)
        pthread_mutex_unlock(lock)
    }
    
    /// `主线程任务`
    /// 因为使用的是【递归🔐】，所以内部循环重复调用该方法n次都没问题，要是普通的🔐就会造成【死锁】了！
    /// 递归任务和其他线程的任务还是能照样排队执行的，前提使用的是同一把【递归🔐】。
    /**
     * 递归🔐：允许【同一个线程】对同一把🔐进行【重复】加🔐
     * 属性设置为PTHREAD_MUTEX_RECURSIVE
     * How to work？
        线程1：
            btn4DidClick（加🔐）--- 1（加锁次数）
                btn4DidClick（加🔐）--- 2
                    btn4DidClick（加🔐）--- 3
                    btn4DidClick（解🔐）--- 3
                btn4DidClick（解🔐）--- 2
            btn4DidClick（解🔐）--- 1
        线程2：当其他线程也需要用到这把🔐，发现这把🔐已经被别的线程使用着，就会等待这把🔐被解开才会继续
            btn4DidClick（先休眠，等线程1的🔐全部解开才工作）--- 1
     * 注意：重复加锁的操作仅支持【同一个线程】内，【其他线程】还是得等待
     */
    @objc func btn4DidClick() {
        pthread_mutex_lock(lock)
        
        let currentTag = Self.tag4
        JPrint("开始 444 ---", currentTag, Thread.current)
        
        if currentTag < 10 {
            Self.tag4 += 1
            btn4DidClick()
        } else {
            Self.tag4 = 0
        }
        
        JPrint("结束 444 ---", currentTag, Thread.current)
        pthread_mutex_unlock(lock)
    }
}
