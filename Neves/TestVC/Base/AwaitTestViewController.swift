//
//  AwaitTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/6/9.
//

@available(iOS 15.0.0, *)
class AwaitTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn: UIButton = {
            let b = UIButton(type: .system)
            b.setTitle("Tap me", for: .normal)
            b.setTitleColor(.randomColor, for: .normal)
            b.backgroundColor = .randomColor
            b.frame = [100, 150, 100, 80]
            b.addTarget(self, action: #selector(btnDidClick), for: .touchUpInside)
            return b
        }()
        view.addSubview(btn)
    }
    
    let lock = DispatchSemaphore(value: 0)
    
    @objc func btnDidClick() {
        JPrint("111 \(Thread.current)")
        Asyncs.async {
            JPrint("222 \(Thread.current)")
            Task {
                JPrint("333 \(Thread.current)") // 这里是会去到主线程的，`Task{}`相当于是一个丢到主线程执行的闭包
                let result = await self.test() // 有趣的是，如果没执行上面那句打印，`getHitokoto_begin`会在子线程执行，如果执行了那就会在主线程
                JPrint(result) // 回到调用函数的那个线程（主线程）
                JPrint("444 \(Thread.current)")
                self.lock.signal()
            }
            JPrint("555 \(Thread.current)")
            self.lock.wait()
            JPrint("666 \(Thread.current)")
        }
        JPrint("777 \(Thread.current)")
        
//        JPrint("111 \(Thread.current)")
//        Task {
//            Asyncs.async {
//                JPrint("222 \(Thread.current)")
//                self.lock.wait()
//                JPrint("333 \(Thread.current)")
//            }
//
//            let result = await self.test()
//            JPrint(result) // 回到调用函数的那个线程（主线程）
//            JPrint("444 \(Thread.current)")
//            self.lock.signal()
//        }
//        JPrint("555 \(Thread.current)")
    }
    
    
    func test() async -> String {
        let str = await getHitokoto(0)
        return "获取结果：\(str)"
    }
    
    @discardableResult
    func getHitokoto(_ tag: Int) async -> String {
        JPrint("\(String(format: "%02d", tag)) - getHitokoto_begin", Thread.current)
        
        var str = "null"
        if let url = URL(string: "https://v1.hitokoto.cn"),
           let (data, _) = try? await URLSession.shared.data(from: url),
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let dic = json as? [String: Any],
           let hitokoto = dic["hitokoto"] as? String {
            str = hitokoto
        }
        
        JPrint("\(String(format: "%02d", tag)) - getHitokoto_end", str, Thread.current)
        return str
    }
    
}

