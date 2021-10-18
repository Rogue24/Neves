//
//  OperationQueueTestViewController.swift
//  Neves
//
//  Created by aa on 2021/9/29.
//

import Foundation

@available(iOS 13.0, *)
class OperationQueueTestViewController: TestBaseViewController {
    
    let queue = OperationQueue()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard queue.operationCount == 0 else {
            JPrint("正在执行任务")
            return
        }
        abc()
    }
    
    func abc() {
        JPrint("begin")
        
        queue.addOperation {
            sleep(5)
            JPrint("111 end", Thread.current)
        }

        queue.addOperation {
            sleep(1)
            JPrint("222 end", Thread.current)
        }

        queue.addOperation {
            sleep(3)
            JPrint("333 end", Thread.current)
        }

        queue.addBarrierBlock {
            sleep(2)
            JPrint("444 end", Thread.current)
        }

        queue.addOperation {
            sleep(6)
            JPrint("555 end", Thread.current)
        }

        queue.addOperation {
            sleep(2)
            JPrint("666 end", Thread.current)
        }

        queue.addBarrierBlock {
            sleep(1)
            JPrint("777 end", Thread.current)
        }

        queue.addOperation {
            sleep(3)
            JPrint("888 end", Thread.current)
        }
        
        queue.addOperation {
            sleep(3)
            JPrint("999 end", Thread.current)
        }

        queue.addBarrierBlock {
            sleep(6)
            JPrint("XXX end", Thread.current)
        }
        
        // MARK: 这样会卡死队列
//        queue.addOperation {
//            self.queue.waitUntilAllOperationsAreFinished()
//            JPrint("ffffxck", Thread.current)
//        }
        
        Asyncs.async {
            JPrint("wait all done", Thread.current)
            self.queue.waitUntilAllOperationsAreFinished()
            JPrint("all done", Thread.current)
        }
        
        /// begin
        /// wait all done
        /// 222
        /// 333
        /// 111
        /// 444
        /// 666
        /// 555
        /// 777
        /// 888 or 999
        /// XXX
        /// all done
    }
}
