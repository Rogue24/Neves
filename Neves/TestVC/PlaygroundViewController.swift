//
//  PlaygroundViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  公告：这是【临时游玩】的场所！游玩结束后记得【清空代码】！！！

import UIKit
import FunnyButton
import Combine
import AVFoundation

struct JPTestAction {
    func callAsFunction() {
        print("jpjpjp ssssb")
    }
}

class SomeViewModel {
    @Published var counter: Int = 0 {
        didSet {
            JPrint("Counter is now \(counter), old is \(oldValue)")
        }
    }
}

class TorchTool: ObservableObject {
    let camera: AVCaptureDevice
    
    @Published private(set) var isOpening: Bool
    
    private var cancellable: AnyCancellable?
    
    init(camera: AVCaptureDevice) {
        self.camera = camera
        self.isOpening = camera.torchMode != .off
        
        cancellable = NotificationCenter.default
                .publisher(for: UIApplication.didBecomeActiveNotification)
                .sink() { [weak self] _ in
                    guard let self = self else { return }
                    JPrint("hasTorch", self.camera.hasTorch)
                    JPrint("torchLevel", self.camera.torchLevel)
                    JPrint("isTorchAvailable", self.camera.isTorchAvailable)
                    JPrint("isTorchActive", self.camera.isTorchActive)
                    JPrint("torchMode", self.camera.torchMode.rawValue)
                    JPrint("-----------------------")
                    self.isOpening = self.camera.torchMode != .off
                }
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    // 开启闪光灯
    func open() {
        guard camera.hasTorch, camera.torchMode == .off else { return }
        do {
            try camera.lockForConfiguration()
            camera.torchMode = .on
            camera.unlockForConfiguration()
            isOpening = true
        } catch {
            
        }
    }
    
    // 关闭闪光灯
    func close() {
        guard camera.torchMode == .on else { return }
        do {
            try camera.lockForConfiguration()
            camera.torchMode = .off
            camera.unlockForConfiguration()
            isOpening = false
        } catch {
            
        }
    }
}

class PlaygroundViewController: TestBaseViewController {
    
//    let subVC = SubVC()
    var test = JPTestAction()
    
    
    let viewModel = SomeViewModel()
    
    let torchTool = TorchTool(camera: AVCaptureDevice.default(for: .video)!)
    var cancellable: AnyCancellable?
    
    var mySet: Set<Int> = [6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        addChild(subVC)
//        subVC.view.frame = [100, 150, 200, 200]
//        view.addSubview(subVC.view)
        
//        let btn = UIButton(type: .custom)
//        btn.addTarget(self, action: #selector(PlaygroundViewController.abc(_:e:)), for: <#T##UIControl.Event#>)
        
        let bo = JYXBOTODrawingBoard(frame: [50, 120, PortraitScreenWidth - 100, PortraitScreenHeight - 200])
        bo.backgroundColor = .white
        view.addSubview(bo)
        
        
//        Asyncs.mainDelay(3) {
//            bo.bounds = [50, 50, bo.bounds.width, bo.bounds.height]
//        }
        
        

        // 订阅counter属性的变化
//        cancellable = viewModel.$counter
//            .dropFirst()
//            .removeDuplicates()
//            .sink { JPrint("New value for counter: \($0)") }
        
        cancellable = torchTool.$isOpening
            .dropFirst()
            .removeDuplicates()
            .sink { isOpening in
                if isOpening {
                    JPrint("打开了手电筒")
                } else {
                    JPrint("关闭了手电筒")
                }
            }
        
        
        
        
    }
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }

    func lcm(_ a: Int, _ b: Int) -> Int {
        return a * b / gcd(a, b)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }

            let a = 24
            let b = 36
            JPrint("最大公约数：", self.gcd(a, b))  // 输出：12
            JPrint("最小公倍数：", self.lcm(a, b))  // 输出：72
            JPrint("xx：", 76 % 24)  // 输出：72
            JPrint("xx：", 76 / 24)  // 输出：72
            
//            self.test()
            
//            let num = Int.random(in: 0...3)
//            JPrint("打算变成", num)
//
//            self.viewModel.counter = num
//
//            JPrint("---------------")
            
//            self.viewModel.counter = 3
//
//            JPrint("---------------")
//
//            self.viewModel.counter = 3
//
//            JPrint("---------------")
//
//            self.viewModel.counter = 3
//
//            JPrint("---------------")
//
//            self.viewModel.counter = 5
//
//            JPrint("---------------")
            
//            if self.torchTool.isOpening {
//                self.torchTool.close()
//            } else {
//                self.torchTool.open()
//            }
            
            
            let first = self.mySet.randomElement()
            JPrint("first? ", first)
            
            

        }
        
//        replaceFunnyActions([
//            FunnyAction(work: { [weak self] in
//                guard let self = self else { return }
//                let vc = TestVC()
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true)
//            }),
//            FunnyAction(work: { [weak self] in
//                guard let self = self else { return }
//                let vc = TestVC()
//                vc.modalPresentationStyle = .overFullScreen
//                self.navigationController?.present(vc, animated: true)
//            }),
//            FunnyAction(work: {[weak self] in
//                guard let self = self else { return }
//                self.dismiss(animated: true)
//            }),
//        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
    deinit {
        cancellable?.cancel()
    }

}
