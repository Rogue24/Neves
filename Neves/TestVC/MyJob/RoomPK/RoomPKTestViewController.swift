//
//  RoomPKTestViewController.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

import UIKit

class RoomPKTestViewController: TestBaseViewController {
    
    let fmPkProgressVM = PKProgressViewModel<PKRankModel>()
    let phPkProgressVM = PlayhousePKProgressViewModel<PKRankModel>()
    let outSideView = PKProgressOutSideView.loadFromNib()
    var isShot = false
    
    weak var foldView: PKChallengeFoldView?
    weak var inviteView: PKChallengeInviteView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fmPkProgressVM.addProgressView(on: view, top: 120)
        phPkProgressVM.addProgressView(on: view, top: 230)
        
        outSideView.put(on: view, top: 340)
        outSideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateOutSideViewLayout)))
        
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.addTarget(self, action: #selector(sliderValueDidChanged(_:)), for: .valueChanged)
        slider.frame = [20.px, PortraitScreenHeight - 220, PortraitScreenWidth - 40.px, slider.height]
        view.addSubview(slider)
        
        makeBtn("胜利", [20.px, 450.px], #selector(shengli))
        makeBtn("失败", [100.px, 450.px], #selector(shibai))
        makeBtn("打平", [180.px, 450.px], #selector(daping))
        
        makeBtn("开始PK", [20.px, 500.px], #selector(kaishipk))
        makeBtn("开始巅峰", [100.px, 500.px], #selector(kaishidianfeng))
        makeBtn("结束PK", [180.px, 500.px], #selector(jiesupk))
        
        makeBtn("收起邀请", [20.px, 550.px], #selector(shouqiyaoqing))
        makeBtn("弹起邀请", [100.px, 550.px], #selector(tanqiyaoqing))
        makeBtn("收到邀请", [180.px, 550.px], #selector(shoudaoyaoqing))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            
            self.fmPkProgressVM.updateRankData(
                leftRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }), rightRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }))
            
            self.fmPkProgressVM.updateProgress(leftValue: Int.random(in: 0...100),
                                               rightValue: Int.random(in: 0...100),
                                               animated: true)
            
            self.phPkProgressVM.updateRankData(
                leftRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }), rightRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }))
            
            self.phPkProgressVM.updateProgress(leftValue: Int.random(in: 0...100),
                                               rightValue: Int.random(in: 0...100),
                                               animated: true)
            
            self.updateOutSideViewProgress(leftValue: Int.random(in: 0...100),
                                           rightValue: Int.random(in: 0...100))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunAction()
    }
    
    func makeBtn(_ title: String, _ origin: CGPoint, _ action: Selector) {
        let btn: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.yellow, for: .normal)
            btn.backgroundColor = .purple
            btn.frame = CGRect(origin: origin, size: [70.px, 30.px])
            btn.addTarget(self, action: action, for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn)
    }
    
    @objc func updateOutSideViewLayout() {
        UIView.animate(withDuration: 0.25) {
            self.outSideView.updateLauout(isShot: !self.outSideView.isShot)
        }
    }
    
    func updateOutSideViewProgress(leftValue: Int, rightValue: Int) {
        let totalValue = leftValue + rightValue
        let progress = totalValue > 0 ? (CGFloat(leftValue) / CGFloat(totalValue)) : 0.5
        UIView.animate(withDuration: 0.25) {
            self.outSideView.update(progress: progress)
        }
    }
}

extension RoomPKTestViewController {
    @objc func sliderValueDidChanged(_ slider: UISlider) {
        let value = CGFloat(slider.value)
        fmPkProgressVM.contentView.update(leftCount: Int(100 * value), rightCount: Int(100 * (1 - value)), progress: value)
        phPkProgressVM.contentView.update(leftCount: Int(100 * value), rightCount: Int(100 * (1 - value)), progress: value)
        outSideView.update(progress: value)
    }
}

extension RoomPKTestViewController {
    @objc func shengli() {
        
    }
    
    @objc func shibai() {
        
    }
    
    @objc func daping() {
        
    }
}

extension RoomPKTestViewController {
    @objc func kaishipk() {
        fmPkProgressVM.startPK()
        phPkProgressVM.startPK()
    }
    
    @objc func kaishidianfeng() {
        fmPkProgressVM.startPeakPK()
        phPkProgressVM.startPeakPK()
    }
    
    @objc func jiesupk() {
        fmPkProgressVM.endPk()
        phPkProgressVM.endPk()
    }
}

extension RoomPKTestViewController {
    @objc func shouqiyaoqing() {
        if let foldView = self.foldView {
            foldView.hide()
        } else {
            foldView = PKChallengeFoldView.show(on: view)
        }
    }
    
    @objc func tanqiyaoqing() {
        PKChallengePopView.show(on: view)
    }
    
    @objc func shoudaoyaoqing() {
        if let inviteView = self.inviteView {
            inviteView.hide()
        } else {
            inviteView = PKChallengeInviteView.show(on: view)
        }
    }
}
