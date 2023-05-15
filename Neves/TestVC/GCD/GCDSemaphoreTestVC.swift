//
//  GCDSemaphoreTestVC.swift
//  GCD_Demo
//
//  Created by 周健平 on 2020/3/21.
//  Copyright © 2020 周健平. All rights reserved.
//

import UIKit

class GCDSemaphoreTestVC: TestBaseViewController {
    
    var ticketTotal = 15
    let ticketLocker = DispatchSemaphore(value: 1)
    
    let group = DispatchGroup()
    
    let semaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        saleTicket()
        
        semaphoreTest()
    }
    
    // MARK: - 卖票演示
    func saleTicket() {
        print("\(Date()) 一开始总共有\(ticketTotal)张")

        print("\(Date()) 第一次卖5张票")
        __saleTicket(5)

        print("\(Date()) 第二次卖5张票")
        __saleTicket(5)

        print("\(Date()) 第三次卖5张票")
        __saleTicket(5)

        group.notify(queue: .main) {
            print("\(Date()) 理论上全部卖完了，实际上剩\(self.ticketTotal)张")
        }
    }
    
    func __saleTicket(_ saleCount: Int) {
        DispatchQueue.global().async(group: group, qos: .default, flags: []) {
            for _ in 0..<saleCount {
                sleep(1)
                
                self.ticketLocker.wait()
                self.ticketTotal -= 1
                self.ticketLocker.signal()
            }
        }
    }
    
    // MARK: - 信号量测试
    func semaphoreTest() {
        guard !Thread.isMainThread else {
            DispatchQueue.global().async {
                self.semaphoreTest()
            }
            return
        }
        
        let result1 = semaphore.signal() // 0 + 1 = 1
        print("\(Date()) \(Thread.current) signal result: \(result1)")
        
        let result2 = semaphore.signal() // 1 + 1 = 2
        print("\(Date()) \(Thread.current) signal result: \(result2)")
        
        let result3 = semaphore.signal() // 2 + 1 = 3
        print("\(Date()) \(Thread.current) signal result: \(result3)")

        semaphore.wait() // 3 - 1 = 2
        print("\(Date()) \(Thread.current) hello_1")

        semaphore.wait() // 2 - 1 = 1
        print("\(Date()) \(Thread.current) hello_2")

        semaphore.wait() // 1 - 1 = 0
        print("\(Date()) \(Thread.current) hello_3")

        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("\(Date()) \(Thread.current) 信号量+1")
            
            let result = self.semaphore.signal() // 0 + 1 = 1
            print("\(Date()) \(Thread.current) signal result: \(result)")
            
            /**
             * PS: `signal()`会返回一个结果，文档解释为：
             * `This function returns non-zero if a thread is woken. Otherwise, zero is returned.`
             * 意思是：如果线程被唤醒，则此函数返回非零，否则，返回零。
             * 这里`signal()`执行后会有一条线程被唤醒，所以返回1，而开头那三次`signal()`返回的都是0，说明那会没有线程需要被唤醒，不过信号量的确是有+1的。
             */
        }

        semaphore.wait() //
        print("\(Date()) \(Thread.current) hello_4") // 1 - 1 = 0
    }
}

