//
//  AwaitTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/6/9.
//

import UIKit

@available(iOS 15.0.0, *)
class AwaitTestViewController: TestBaseViewController {
    
    let imgView = UIImageView(frame: [0, 0, PortraitScreenWidth, PortraitScreenWidth])
    
    let lock = DispatchSemaphore(value: 0)
    
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
        
        imgView.y = btn.maxY + 20
        imgView.backgroundColor = .randomColor
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            self.testDownloadImage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
}

@available(iOS 15.0.0, *)
extension AwaitTestViewController {
    @objc func btnDidClick() {
        JPrint("111 \(Thread.current)")
        Asyncs.async {
            JPrint("222 \(Thread.current)")
            Task {
                JPrint("333 \(Thread.current)") // 这里是会去到主线程的，`Task{}`相当于是一个丢到主线程执行的闭包
                let result = await self.testRequestHitokoto() // 有趣的是，如果没执行上面那句打印，`getHitokoto_begin`会在子线程执行，如果执行了那就会在主线程
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
    
    func testRequestHitokoto() async -> String {
        let str = await getHitokoto(0)
        return "获取结果：\(str)"
    }
    
    @discardableResult
    func getHitokoto(_ tag: Int) async -> String {
        JPrint("\(String(format: "%02d", tag)) - getHitokoto_begin", Thread.current)
        
        var str = "null"
        if let (data, _) = try? await URLSession.shared.data(from: URL.jp.hitokoto),
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let dic = json as? [String: Any],
           let hitokoto = dic["hitokoto"] as? String {
            str = hitokoto
        }
        
        JPrint("\(String(format: "%02d", tag)) - getHitokoto_end", str, Thread.current)
        return str
    }
}

@available(iOS 15.0.0, *)
extension AwaitTestViewController {
    func testDownloadImage() {
        Task {
            JPProgressHUD.show()
            defer { JPProgressHUD.dismiss() }
            
            let size: CGSize = [self.imgView.width * ScreenScale, self.imgView.height * ScreenScale]

            guard let data = await requestImageData(size) else {
                JPrint("获取数据失败")
                return
            }
            
            guard let image = await decodeImage(data) else {
                JPrint("图片解码失败")
                return
            }
            
            UIView.transition(with: self.imgView, duration: 0.2, options: .transitionCrossDissolve) {
                self.imgView.image = image
            } completion: { _ in }
        }
    }
    
    func requestImageData(_ size: CGSize) async -> Data? {
        JPrint("开始获取数据 \(Thread.current)")
        guard let (data, _) = try? await URLSession.shared.data(from: LoremPicsum.photoURL(size: size, randomId: 1))
        else { return nil }
        JPrint("数据获取成功 \(Thread.current)")
        return data
    }
    
    
    func decodeImage(_ data: Data) async -> UIImage? {
        JPrint("开始解码图片 \(Thread.current)")
        guard let image = UIImage(data: data),
              let cgImg = image.cgImage,
              let decodeCgImg = DecodeImage(cgImg) else { return nil }
        JPrint("图片解码成功 \(Thread.current)")
        return UIImage(cgImage: decodeCgImg)
    }
}
