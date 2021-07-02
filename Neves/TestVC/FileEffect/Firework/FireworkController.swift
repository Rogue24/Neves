//
//  FireworkManager.swift
//  Neves_Example
//
//  Created by aa on 2020/10/13.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Lottie

@objcMembers class FireworkController: NSObject {
    // MARK:- 公开属性
    let fwView: FireworkView = FireworkView()
    weak var superview: UIView?
    weak var operationView: UIView?
    
    // MARK:- 私有属性
    
    // MARK: 任务队列
    fileprivate let dataQueue = DispatchQueue(label: "Firework.data.SerialQueue")
    fileprivate let animQueue = DispatchQueue(label: "Firework.anim.SerialQueue")
    fileprivate let animLock = DispatchSemaphore(value: 1)
    
    // MARK: 计时器
    fileprivate var timer: DispatchSourceTimer?
    fileprivate var isPause = false
    fileprivate var switchSecond = 10
    
    // MARK: 焰火信息模型
    fileprivate var models: [FireworkModel] = []
    fileprivate weak var myModel: FireworkModel? = nil
    // MARK: 当前焰火信息模型&下标
    fileprivate var _frontIndex: Int = 0
    fileprivate var frontIndex: Int {
        set {
            if newValue >= models.count || newValue < 0 {
                _frontIndex = 0
            } else {
                _frontIndex = newValue
            }
        }
        get {
            if _frontIndex >= models.count {
                _frontIndex = models.count - 1
            }
            return _frontIndex
        }
    }
    fileprivate var frontModel: FireworkModel? { models.count > 0 ? models[frontIndex] : nil }
    
    // MARK: 发射焰火信息
    fileprivate typealias FireworkGain = (uid: UInt32, launchCount: UInt)
    fileprivate var fireworkGains: [FireworkGain] = []
    
    // MARK: 焰火动画样式
    fileprivate enum QueueAnim {
        case show(_ model: FireworkModel, _ launchModels: [FireworkModel])
        case launch(_ model: FireworkModel, _ launchModels: [FireworkModel])
        case update(_ model: FireworkModel, _ isSwitch: Bool)
        case quit(_ model: FireworkModel?)
    }
    fileprivate var isAnimating: Bool = false
    
    fileprivate let myUid: UInt32
    
    // MARK:- 初始化&反初始化
    override init() {
        self.myUid = 184669029
        super.init()
    }
    
    deinit {
        JPrint("老子死了吗")
    }
}

// MARK:- 公开方法
extension FireworkController {
    // MARK: 初始化焰火UI
    func setupFireworkView(onView superview: UIView, operationView: UIView, isMinigameMode: Bool) {
        self.superview = superview
        self.operationView = operationView
        
        operationView.backgroundColor = .randomColor()
        fwView.backgroundColor = .randomColor()
        
        fwView.touchAction = { [weak self] in
            guard let self = self, self.models.count > 0 else { return }
            FireworkPopView.show(self.models)
        }
        
        superview.insertSubview(fwView, belowSubview: operationView)
        updateLayout(isMinigameMode)
    }
    
    // MARK: 刷新布局：小游戏/普通
    func updateLayout(_ isMinigameMode: Bool) {
        guard let _ = self.superview,
              let operationView = self.operationView else { return }
        
        let w: CGFloat = 65
        let h: CGFloat = w * (200.0 / 65.0)
        let scale: CGFloat = isMinigameMode ? (44.0 / 65.0) : 1
        
        fwView.snp.remakeConstraints {
            $0.width.equalTo(w)
            $0.height.equalTo(h)
            if isMinigameMode {
                let diffW: CGFloat = w * (1 - scale) * 0.5
                let diffH: CGFloat = h * (1 - scale) * 0.5
                $0.right.equalTo(operationView.snp.left).offset(-5 + diffW)
                $0.bottom.equalTo(operationView.snp.bottom).offset(diffH)
            } else {
                $0.right.equalToSuperview().offset(-5)
                $0.bottom.equalTo(operationView.snp.top).offset(20)
            }
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fwView.layer.transform = CATransform3DMakeScale(scale, scale, 1)
        CATransaction.commit()
    }
    
    // MARK: 退出房间：停止计时&清除缓存
    func stopAll() {
        stopTiming()
        superview = nil
        operationView = nil
//        FireworkModel.cleanAllItems()
    }
    
    // MARK: 接收并处理发射🚀消息
    func launchFirework(_ gainListArray: [UU_FireworkGainInfo]) {
        dataQueue.async { [weak self] in
            guard let self = self else { return }
            self.fireworkGains.removeAll()
            for gainInfo in gainListArray {
                self.fireworkGains.append((gainInfo.uid, gainInfo.infoListArray_Count))
            }
        }
    }
    
    // MARK: 刷新焰火列表
    func updateModels(_ infoList: [UU_FireworkLauncherInfo]) {
        JPrint("有多少个呢 ----", infoList.count)
        
        self.pauseTiming()
        
        dataQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.models.count == 0, infoList.count == 0 {
                DispatchQueue.main.async { self.stopTiming() }
                return
            }
            
            self.myModel = nil
            let myUid = self.myUid
            let lastModel = self.frontModel
            
            var models: [FireworkModel] = []
            var frontIndex = self.frontIndex
            for i in 0..<infoList.count {
                let info = infoList[i]
                let model = FireworkModel(info)
                model.isMe = info.uid == myUid
                if self.myModel == nil, model.isMe {
                    self.myModel = model
                    frontIndex = i
                }
                if self.myModel == nil, let uid = lastModel?.uid, model.uid == uid {
                    frontIndex = i
                }
                models.append(model)
            }
            self.models = models
            self.frontIndex = frontIndex
            let launchModels = self.matchFireworkGains()
            
            guard let frontModel = self.frontModel else {
                self.execAnim(.quit(lastModel))
                return
            }
            if let lm = lastModel {
                if launchModels.count > 0 {
                    self.execAnim(.launch(frontModel, launchModels))
                } else {
                    self.execAnim(.update(frontModel, frontModel.uid != lm.uid))
                }
            } else {
                self.execAnim(.show(frontModel, launchModels))
            }
        }
    }
    
    // MARK: 焰火列表计时处理
    fileprivate func fireworkTiming() {
        if models.count > 1 && self.myModel == nil && !isAnimating { switchSecond -= 1 }
        
        var isToSwitch = switchSecond == 0
        if isToSwitch { frontIndex += 1 }
        
        var lastRmModel: FireworkModel? = nil
        let curModels = models
        for model in curModels {
            model.seconds -= 1
            if model.seconds <= 0, let index = models.firstIndex(where: { $0 == model }) {
                JPrint("现在下标！->", frontIndex)
                JPrint("删除下标！->", index)
                
                if model.isMe { self.myModel = nil }
                lastRmModel = model
                
                var newIndex = frontIndex
                if self.models.count > 1 {
                    if index < frontIndex {
                        newIndex = frontIndex - 1
                    } else if index == frontIndex {
                        isToSwitch = true
                    }
                }
                models.remove(at: index)
                frontIndex = newIndex
            }
        }
        let launchModels = self.matchFireworkGains()
        
        if let frontModel = self.frontModel {
            if launchModels.count > 0 {
                execAnim(.launch(frontModel, launchModels))
                return
            }
            if isToSwitch { switchSecond = 10 }
            DispatchQueue.main.async {
                self.fwView.updateFrontItem(frontModel, isToSwitch)
            }
        } else {
            execAnim(.quit(lastRmModel))
        }
        
        if models.count > 1 {
            JPrint("倒计时切换", switchSecond, "剩多少个", models.count, Thread.current)
            if self.myModel == nil, switchSecond == 10 {
                JPrint("怎么回事", isAnimating)
            }
        } else {
            JPrint("数量不够切换", models.count, Thread.current)
        }
    }
}

// MARK:- 私有方法
extension FireworkController {
    // MARK: 匹配/找出要发射🚀的模型
    fileprivate func matchFireworkGains(_ lastUid: UInt32? = nil) -> [FireworkModel] {
        guard fireworkGains.count > 0, models.count > 0 else { return [] }
        var launchModels: [FireworkModel] = []
        var lastLaunchIndex = 0
        var frontIndex = self.frontIndex
        for i in 0..<models.count {
            let model = models[i]
            if model.isMe {
                self.myModel = model
                frontIndex = i
            }
            for gain in fireworkGains where model.uid == gain.uid {
                model.launchCount = gain.launchCount
                launchModels.append(model)
                lastLaunchIndex = i
                break
            }
        }
        fireworkGains.removeAll()
        if self.myModel == nil, launchModels.count > 0 { frontIndex = lastLaunchIndex }
        self.frontIndex = frontIndex
        return launchModels
    }
    
    // MARK: 执行动画
    fileprivate func execAnim(_ anim: QueueAnim) {
        animQueue.async { [weak self] in
            guard let self = self else { return }
            self.animLock.wait()
            DispatchQueue.main.async {
                let execDone: () -> () = {
                    self.animLock.signal()
                    self.isAnimating = false
                }
                self.isAnimating = true
                switch anim {
                case let .show(model, launchModels):
                    if launchModels.count == 0 { self.isAnimating = false }
                    self.startTiming()
                    self.fwView.showAnim(model) {
                        if launchModels.count > 0 {
                            self.fwView.launchAnim(model, launchModels, execDone)
                        } else {
                            execDone()
                        }
                    }
                case let .launch(model, launchModels):
                    self.startTiming()
                    self.fwView.launchAnim(model, launchModels, execDone)
                case let .update(model, isSwitch):
                    self.fwView.updateFrontItem(model, isSwitch) {
                        self.startTiming()
                        execDone()
                    }
                case let .quit(model?):
                    self.stopTiming()
                    self.fwView.quitAnim(model, execDone)
                case .quit(.none):
                    self.stopTiming()
                    execDone()
                }
            }
        }
    }
}

// MARK:- 计时器相关方法
extension FireworkController {
    // MARK: 开始&继续计时
    fileprivate func startTiming() {
        switchSecond = 10
        
        if models.count == 0 {
            stopTiming()
            return
        }
        
        let isPause = self.isPause
        self.isPause = false
        
        if self.timer != nil {
            if isPause == true {
                self.timer!.resume()
            }
            return
        }
        
        let timer = DispatchSource.makeTimerSource(queue: self.dataQueue)
        self.timer = timer
        
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler(handler: { [weak self] in
            self?.fireworkTiming()
        })
        timer.resume()
    }
    
    // MARK: 暂停计时
    fileprivate func pauseTiming() {
        guard let timer = self.timer, isPause == false else { return }
        timer.suspend()
        isPause = true
    }
    
    // MARK: 停止计时
    fileprivate func stopTiming() {
        let isPause = self.isPause
        self.isPause = false
        guard let timer = self.timer else { return }
        if isPause { timer.resume() }
        timer.cancel()
        self.timer = nil
    }
}
