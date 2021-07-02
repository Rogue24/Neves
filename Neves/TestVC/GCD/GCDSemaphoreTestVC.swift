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
    let group: DispatchGroup = DispatchGroup()
    
    let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    func __saleTicket(_ saleCount: Int) {
        DispatchQueue.global().async(group: group, qos: .default, flags: []) {
            for _ in 0..<saleCount {
                sleep(1)
                
                self.semaphore.wait()
                self.ticketTotal -= 1
                self.semaphore.signal()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    
        
//        semaphore.signal() // 0 + 1 = 1
//        semaphore.signal() // 1 + 1 = 2
//        semaphore.signal() // 2 + 1 = 3
//
//        semaphore.wait() // 3 - 1 = 2
//        print("\(Date()) \(Thread.current) hello_1")
//
//        semaphore.wait() // 2 - 1 = 1
//        print("\(Date()) \(Thread.current) hello_2")
//
//        semaphore.wait() // 1 - 1 = 0
//        print("\(Date()) \(Thread.current) hello_2")
//
//        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
//            print("\(Date()) \(Thread.current) 信号量+1")
//            let result = self.semaphore.signal() // 0 + 1 = 1
//            print("\(Date()) \(Thread.current) result: \(result)");
//            /*
//             * PS: signal() 会返回一个结果，文档解释为：
//             * This function returns non-zero if a thread is woken. Otherwise, zero is returned. 如果线程被唤醒，则此函数返回非零。否则，返回零。
//             * 这里执行后会有一条线程被唤醒，所以返回1，前面的3次signal()返回的都是0，说明没有线程被唤醒，不过信号量的确是有+1的。
//             */
//        }
//
//        semaphore.wait() //
//        print("\(Date()) \(Thread.current) hello_4") // 1 - 1 = 0
    }


}

