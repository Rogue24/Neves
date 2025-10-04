//
//  CombineTestViewController.swift
//  Neves
//
//  Created by aa on 2021/8/23.
//
//  学自1：https://blog.ficowshen.com/page/category/Combine || https://blog.ficowshen.com/page/post/12 || https://blog.ficowshen.com/page/post/17
//  学自2：https://www.jianshu.com/p/d14748abb911
//  学自3：https://juejin.cn/post/7017623451858894862

import Combine
//import SwiftUI

var abc = 1

class TestMsgView: UIView {
    let label = UILabel()
    
    var text: String = "\(abc)" {
        didSet {
            label.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.randomColor.cgColor
        layer.borderWidth = 8
        
        backgroundColor = .randomColor
        
        label.frame = bounds
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .randomColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = text
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CombineTestView1: UIView {
    let label = UILabel()
    
    @Published var bgColor: UIColor = .randomColor {
        didSet {
            backgroundColor = bgColor
        }
    }
    
    @Published var text: String = "\(abc)" {
        didSet {
            label.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.randomColor.cgColor
        layer.borderWidth = 8
        
        backgroundColor = bgColor
        
        label.frame = bounds
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .randomColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = text
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CombineTestView2: CombineTestView1, ObservableObject {}


@available(iOS 13.0, *)
class CombineTestViewController: TestBaseViewController {
    
    @objc dynamic var name: String = "\(Int(Date().timeIntervalSince1970))"
    
    var connection: Combine.Cancellable? // RxSwift也有Cancellable，得加上模块前缀区分
    
    // testObj
    var canceler1: AnyCancellable?
    var canceler2: AnyCancellable?
    var canceler11: AnyCancellable?
    var canceler22: AnyCancellable?
    
    // testReq
    var canceler3: AnyCancellable?
    var canceler33: AnyCancellable?
    
    // testShare
    var canceler4: AnyCancellable?
    var canceler5: AnyCancellable?
    var canceler6: AnyCancellable?
    var canceler7: AnyCancellable?
    
    // testConnectable
    var canceler8: AnyCancellable?
    var canceler9: AnyCancellable?
    
    let testMsgView = TestMsgView(frame: [20, 150, 150, 150])
    
    let testView1 = CombineTestView1(frame: [20, 320, 150, 150])
    let testView2 = CombineTestView2(frame: [20, 500, 150, 150])
    
    let testMsgView1 = TestMsgView(frame: [190, 320, 150, 150])
    let testMsgView2 = TestMsgView(frame: [190, 500, 150, 150])
    
    var cancelerX1: AnyCancellable?
    var cancelerX2: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(testMsgView)
        
        view.addSubview(testView1)
        view.addSubview(testMsgView1)
        
        view.addSubview(testView2)
        view.addSubview(testMsgView2)
        
        setupKvcKvoPublisher()
        
        // 使用`sink`订阅【特定属性】就会立刻调用一次闭包，
        // 使用`sink`订阅【objectWillChange】不会立刻调用，只会在属性更改前一刻才会调用，所以在闭包内获取到的是旧值
        Asyncs.mainDelay(3) {
            self.setupPublished()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            
            self.name = "\(Int(Date().timeIntervalSince1970))"
            self.view.backgroundColor = .randomColor
            
//            self.testReq()
//            self.testShare()
//            self.testConnectable()
            
            abc += 1
            
            self.testView1.bgColor = .randomColor
            self.testView1.text = "\(abc)"
            
            self.testView2.bgColor = .randomColor
            self.testView2.text = "\(abc)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
    deinit {
        connection?.cancel()
        canceler1?.cancel()
        canceler2?.cancel()
        canceler11?.cancel()
        canceler22?.cancel()
        canceler3?.cancel()
        canceler33?.cancel()
        canceler4?.cancel()
        canceler5?.cancel()
        canceler6?.cancel()
        canceler7?.cancel()
        canceler8?.cancel()
        canceler9?.cancel()
        cancelerX1?.cancel()
        cancelerX2?.cancel()
    }
}

/**
 * Publisher 负责发布内容
 * Subscriber 负责接收内容
 * Subscription 作为中介，协调生产端和消费端的需求
 */

@available(iOS 13.0, *)
extension CombineTestViewController {
    func setupKvcKvoPublisher() {
        // 创建KVC/KVO的发布者
        // Swift的属性想要支持KVC/KVO需要使用`@objc dynamic`修饰符
        let namePublisher = publisher(for: \.name, options: .new)
        canceler1 = namePublisher.sink { name in
            JPrint("1 ---", name)
        }
        
        // 可以创建多个发布者
        let namePublisher2 = publisher(for: \.name, options: .new)
        canceler11 = namePublisher2.sink { name in
            self.testMsgView.text = name
        }
        
        let bgColorPublisher = view.publisher(for: \.backgroundColor, options: .new)
        canceler2 = bgColorPublisher.sink {
            guard let color = $0 else { return }
            let rgba = color.rgba
            JPrint("2 --- r:", rgba.r, "g:", rgba.g, "b:", rgba.b)
        }
        
        let bgColorPublisher2 = view.publisher(for: \.backgroundColor, options: .new)
        canceler22 = bgColorPublisher2.sink {
            self.testMsgView.backgroundColor = $0
        }
    }
    
    func setupPublished() {
        // 使用`@Published`包装的属性，可以通过`$`符号直接访问这个属性的发布者（系统自动生成）
        cancelerX1 = testView1.$bgColor.sink { [weak self] in
            self?.testMsgView1.backgroundColor = $0
        }
        
        // ObservableObject可以通过`objectWillChange`获取到发布者，并订阅来监听所有被`@Published`标记的属性更改的回调
        // 当属性将要发生更改，会在属性更改【前】一刻回调闭包，因此在闭包里面去获取的属性是【旧值】
        // 如果`bgColor`和`text`都修改了，那就会回调两次
        cancelerX2 = testView2.objectWillChange.sink { [weak self] in
            guard let self = self else { return }
            
            let rgba = self.testView2.bgColor.rgba
            JPrint("bbb r:", rgba.r, "g:", rgba.g, "b:", rgba.b)
            JPrint("bbb", self.testView2.text)
            
            self.testMsgView2.backgroundColor = self.testView2.bgColor
            self.testMsgView2.text = self.testView2.text
        }
    }
}
    
@available(iOS 13.0, *)
extension CombineTestViewController {
    func testReq() {
        canceler3?.cancel()
        canceler33?.cancel()
        
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: URL.jp.hitokoto)
            .share() // 使用`Publisher/share()`则接收的都是同一个发布者
        
        /// `receiveCompletion`和`receiveValue`都在【同一队列】内回调（非同一线程），
        /// 一般会先执行`receiveValue`再执行`receiveCompletion`。
        
        canceler3 = dataTaskPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
            switch completion {
            case .finished:
                print("【m】成功 --- \(Thread.current)")
            case .failure:
                print("【m】失败 --- \(Thread.current)")
            }
                
        }, receiveValue: { data, response in
            
            guard let dict = JSON(data).dictionary,
                  let hitokoto = dict["hitokoto"] else {
                print("【m】文案请求失败: 数据解析失败 --- \(Thread.current)")
                return
            }
            print("【m】文案请求成功: \(hitokoto) --- \(Thread.current)")
            
        })
        
        canceler33 = dataTaskPublisher
            .receive(on: DispatchQueue.global())
            .sink(receiveCompletion: { completion in
            
            switch completion {
            case .finished:
                print("【g】成功 --- \(Thread.current)")
            case .failure:
                print("【g】失败 --- \(Thread.current)")
            }
            
        }, receiveValue: { data, response in
            
            guard let dict = JSON(data).dictionary,
                  let hitokoto = dict["hitokoto"] else {
                print("【g】文案请求失败: 数据解析失败 --- \(Thread.current)")
                return
            }
            print("【g】文案请求成功: \(hitokoto) --- \(Thread.current)")
            
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
        
        let connectable = URLSession.shared.dataTaskPublisher(for: URL.jp.hitokoto)
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
