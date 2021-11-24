//
//  TestLockViewController.swift
//  Neves
//
//  Created by aa on 2021/11/24.
//
//  结论：同一把🔐，只要锁上了，就可以拦截任何线程。
//  因此，尽量不要在【主线程】上锁，例如在其他线程上锁去处理耗时操作时，接着回到主线程上锁就会造成卡顿（那是在等上一把🔐解锁）

class TestLockViewController: TestBaseViewController {
    
    let lock: UnsafeMutablePointer<pthread_mutex_t> = {
        let attrPtr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 3)
        pthread_mutexattr_init(attrPtr)
        // PTHREAD_MUTEX_DEFAULT 默认
        // PTHREAD_MUTEX_RECURSIVE 递归：允许【同一个线程】对一把🔐进行【重复】加🔐，注意是【同一个线程】才阔以！！！
        pthread_mutexattr_settype(attrPtr, PTHREAD_MUTEX_RECURSIVE)
        
        let mutexPtr = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 3)
        pthread_mutex_init(mutexPtr, attrPtr)
        
        pthread_mutexattr_destroy(attrPtr)
        attrPtr.deallocate()
        
        return mutexPtr
    }()
    
    let tv = UITextView(frame: [20, 300, 300, 150])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("异步任务1", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [20, 100, 80, 60]
            btn.addTarget(self, action: #selector(btn1DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn1)
        
        let btn2: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("异步任务2", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [120, 100, 80, 60]
            btn.addTarget(self, action: #selector(btn2DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn2)
        
        let btn3: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("UI任务", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [220, 100, 80, 60]
            btn.addTarget(self, action: #selector(btn3DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn3)
        
        let tvLabel = UILabel(frame: [20, 280, 400, 20])
        tvLabel.font = .boldSystemFont(ofSize: 15)
        tvLabel.textColor = .randomColor
        tvLabel.text = "用来看有木有阻塞主线程（运行时来回拖动）"
        view.addSubview(tvLabel)
        
        
        tv.backgroundColor = .randomColor
        tv.text = "seoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejfseoifseiofjseoijfisoejfoisejfjsefjsoejf"
        view.addSubview(tv)
    }
    
    deinit {
        pthread_mutex_destroy(lock)
        lock.deallocate()
        
        JPrint("死废了")
    }
    
    @objc func btn1DidClick() {
        Asyncs.async {
            JPrint("准备 111")
            
            pthread_mutex_lock(self.lock)
            JPrint("开始 111")
            
            sleep(5)
            
            pthread_mutex_unlock(self.lock)
            JPrint("结束 111")
        }
    }
    
    @objc func btn2DidClick() {
        Asyncs.async {
            JPrint("准备 222")
            
            pthread_mutex_lock(self.lock)
            JPrint("开始 222")
            
            sleep(3)
            
            // 下面这样会死锁，因为不是【同一个线程】加的🔐
//            DispatchQueue.main.sync {
//                self.btn3DidClick()
//            }
            
            pthread_mutex_unlock(self.lock)
            JPrint("结束 222")
        }
    }
    
    @objc func btn3DidClick() {
        JPrint("准备 333")
        
        pthread_mutex_lock(lock)
        JPrint("开始 333")
        
        tv.backgroundColor = .randomColor
        
        pthread_mutex_unlock(lock)
        JPrint("结束 333")
    }
}
