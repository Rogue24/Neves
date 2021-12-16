//
//  CombineTestViewController.swift
//  Neves
//
//  Created by aa on 2021/8/23.
//
//  学自：https://blog.ficowshen.com/page/post/12

import Combine
//import SwiftUI

@objcMembers class Person: NSObject {
    dynamic var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
}

@available(iOS 13.0, *)
class CombineTestViewController: TestBaseViewController {
    
//    @ObservedObject var store = UpdateStore()
    
    let person = Person("hh")
    
    var connection: Combine.Cancellable? // RxSwift也有Cancellable，得加上模块前缀区分
    
    // testObj
    var canceler1: AnyCancellable?
    var canceler2: AnyCancellable?
    
    // testReq
    var canceler3: AnyCancellable?
    
    // testShare
    var canceler4: AnyCancellable?
    var canceler5: AnyCancellable?
    var canceler6: AnyCancellable?
    var canceler7: AnyCancellable?
    
    // testConnectable
    var canceler8: AnyCancellable?
    var canceler9: AnyCancellable?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        person.name = "\(Date())"
        view.backgroundColor = .randomColor
        
        testConnectable()
    }
    
    deinit {
        connection?.cancel()
        canceler1?.cancel()
        canceler2?.cancel()
        canceler3?.cancel()
        canceler4?.cancel()
        canceler5?.cancel()
        canceler6?.cancel()
        canceler7?.cancel()
        canceler8?.cancel()
        canceler9?.cancel()
    }
}

/**
 * Publisher 负责发布内容
 * Subscriber 负责接收内容
 * Subscription 作为中介，协调生产端和消费端的需求
 */

@available(iOS 13.0, *)
extension CombineTestViewController {
    func testObj() {
        let personPublisher = person.publisher(for: \.name, options: .new)
        canceler1 = personPublisher.sink { name in
            JPrint("1 ---", name)
        }
        
        let bgColorPublisher = view.publisher(for: \.backgroundColor, options: .new)
        canceler2 = bgColorPublisher.sink {
            guard let color = $0 else { return }
            JPrint("2 ---", color)
        }
    }
    
    func testReq() {
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: URL(string: "https://v1.hitokoto.cn")!)
        // receiveCompletion 和 receiveValue 都在【同一线程】内回调，一般会先执行 receiveValue 再执行 receiveCompletion
        canceler3 = dataTaskPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            
            switch completion {
            case .finished:
                JPrint("成功 ---", Thread.current)
            case .failure:
                JPrint("失败 ---", Thread.current)
            }
            
        }, receiveValue: { data, response in
            
            guard let dict = JSON(data).dictionary,
                  let hitokoto = dict["hitokoto"] else
            {
                JPrint("文案请求失败: 数据解析失败 ---", Thread.current)
                return
            }
            
            JPrint("文案请求成功:", hitokoto, "---", Thread.current)
            
        })
    }
    
    func testShare() {
        /// 没有`Publisher/share()`操作符，`Stream 1`接收3个随机值，然后`Stream 2`接收3个不同的随机值。
        let pub1 = (1...3).publisher
            .delay(for: 3, scheduler: DispatchQueue.main)
            .map { _ -> Int in
                JPrint("Random1")
                return Int.random(in: 0...100)
            }
//            .print("Random1")
        canceler4 = pub1.sink { JPrint ("Stream 1 received: \($0)")} //  2 26 45
        canceler5 = pub1.sink { JPrint ("Stream 2 received: \($0)")} // 97 40 74
        
        
        /// `Publisher/share()` 将从上游接收的元素【共享】给多个订阅者的类实例。
        let pub2 = (1...3).publisher
            .delay(for: 6, scheduler: DispatchQueue.main)
            .map { _ -> Int in
                JPrint("Random2")
                return Int.random(in: 0...100)
            }
//            .print("Random2")
            .share() // 91 31 86
        canceler6 = pub2.sink { JPrint ("Stream 3 received: \($0)")} // 91 31 86
        canceler7 = pub2.sink { JPrint ("Stream 4 received: \($0)")} // 91 31 86
    }
    
    func testConnectable() {
        /// 使用`sink(receiveValue:)`会立刻开始（网络请求）接收订阅元素
        /// 发起一个网络请求，并为这个请求创建了一个发布者，以及连接了这个发布者的订阅者，
        /// 第一个订阅者的订阅操作触发了实际的网络请求，接着在某个时间点，再将第二个订阅者连接到这个发布者，
        /// 如果在连接第二个订阅者之前，网络请求已经完成，那么第二个订阅者将只会收到完成事件，收不到网络请求的响应结果，
        /// 这个结果将不是所期望的。
        
        /// 使用`makeConnectable()`和`connect()`控制发布
        
        let connectable = URLSession.shared.dataTaskPublisher(for: URL(string: "https://v1.hitokoto.cn")!)
            .map { data, _ -> String in
                guard let dict = JSON(data).dictionary,
                      let hitokoto = dict["hitokoto"]?.stringValue else {
                    return ""
                }
                return hitokoto
            }
            .catch { _ in
                Just("Just是啥")
            }
            .share()
            .makeConnectable() // DataTaskPublisher -> ConnectablePublisher
        
        JPrint("sink1！！！")
        // 如果没有调用makeConnectable()，调用sink后会立马开始网络请求
        canceler8 = connectable
//            .autoconnect() // 自动发布，sink后自动connect，只作用于ConnectablePublisher
            .sink(receiveCompletion: {
            JPrint("111 receiveCompletion ---", $0)
        }, receiveValue: {
            JPrint("111 receiveValue ---", $0)
        })
        
        Asyncs.mainDelay(3) {
            JPrint("sink2！！！")
            // 如果没有调用makeConnectable()，到这里时如果网络请求已经结束了，那调用sink后，只会执行receiveCompletion
            self.canceler9 = connectable
                .sink(receiveCompletion: {
                    JPrint("222 receiveCompletion ---", $0)
                }, receiveValue: {
                    JPrint("222 receiveValue ---", $0)
                })
        }
            
        Asyncs.mainDelay(5) {
            JPrint("connect！！！")
            // 要强引用这个返回值，否则不会发布（网络请求），同时可用于取消发布
            self.connection = connectable.connect()
        }
    }
}
