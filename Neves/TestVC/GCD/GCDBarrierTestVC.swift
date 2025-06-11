//
//  GCDBarrierTestVC.swift
//  Neves
//
//  Created by aa on 2024/12/8.
//

import UIKit
import FunnyButton

class GCDBarrierTestVC: TestBaseViewController {
    
    private var _value: Int = 0
    private let queue = DispatchQueue(label: "com.example.queue", attributes: .concurrent)
    
//    private var lock = os_unfair_lock()
    private var mutex: pthread_mutex_t = {
        var m = pthread_mutex_t()
        pthread_mutex_init(&m, nil)
        return m
    }()
    
    var value: Int {
        get {
            // 使用 sync 来读取数据，保证可以读取到最新值
//            queue.sync { _value }
//            let v = queue.sync {
//                print("getter~ \(_value) \(Thread.current)")
//                return _value
//            }
//            return v
            
//            os_unfair_lock_lock(&lock)
//            defer { os_unfair_lock_unlock(&lock) }
            pthread_mutex_lock(&mutex)
            defer { pthread_mutex_unlock(&mutex) }
            print("getter~ \(_value) \(Thread.current)")
            return _value
        }
        set {
            // 使用 async + barrier 来写入，确保写入操作的独占性
//            queue.async(flags: .barrier) {
//                print("setter~ \(newValue) \(Thread.current)")
//                self._value = newValue
//            }
            
//            os_unfair_lock_lock(&lock)
//            defer { os_unfair_lock_unlock(&lock) }
            pthread_mutex_lock(&mutex)
            defer { pthread_mutex_unlock(&mutex) }
            print("setter~ \(newValue) \(Thread.current)")
            _value = newValue
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        removeFunnyActions()
        addFunnyAction {
            let _ = self.value
        }
        
        for i in 0..<1000 {
            Asyncs.async {
                print("test~ \(Thread.current)")
//                self.value = i
                self.value += 1 // ==> self.value = self.value + 1，所以会先getter后setter
                Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.1...0.5))
            }
        }
    }
    
    
}

