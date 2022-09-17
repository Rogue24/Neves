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
    var isFm = true
    
    weak var popView: PKChallengePopView?
    weak var inviteView: PKChallengeInviteView?
    
    let starBottle = PKStarBottle()
    let leftStatView = StatView()
    let rightStatView = StatView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fmPkProgressVM.contentView.isFm = true
        phPkProgressVM.contentView.isFm = false
        
        fmPkProgressVM.addProgressView(on: view, top: 120)
        phPkProgressVM.addProgressView(on: view, top: 230)
        
        outSideView.put(on: view, top: 340)
        outSideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickOutSideView)))
        
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.addTarget(self, action: #selector(sliderValueDidChanged(_:)), for: .valueChanged)
        slider.frame = [20.px, PortraitScreenHeight - 220, PortraitScreenWidth - 50.px, slider.height]
        view.addSubview(slider)
        
        makeBtn("胜利", [20.px, 450.px], #selector(shengli))
        makeBtn("失败", [100.px, 450.px], #selector(shibai))
        makeBtn("打平", [180.px, 450.px], #selector(daping))
        
        let sOn = UISwitch()
        sOn.origin = [270.px, 450.px]
        sOn.isOn = isFm
        sOn.addTarget(self, action: #selector(sOnDidClick(_:)), for: .touchUpInside)
        view.addSubview(sOn)
        
        makeBtn("开始PK", [20.px, 500.px], #selector(kaishipk))
        makeBtn("开始巅峰", [100.px, 500.px], #selector(kaishidianfeng))
        makeBtn("结束PK", [180.px, 500.px], #selector(jiesupk))
        
        makeBtn("发起邀请" , [20.px, 550.px], #selector(faqiyaoqing))
        makeBtn("取消邀请", [100.px, 550.px], #selector(qvxiaoyaoqing))
        makeBtn("收到邀请", [180.px, 550.px], #selector(shoudaoyaoqing))
        
        starBottle.backgroundColor = .black
        view.addSubview(starBottle)
        starBottle.snp.makeConstraints { make in
            make.size.equalTo(PKStarBottle.size)
            make.centerX.equalToSuperview()
            make.top.equalTo(700.px)
        }
        starBottle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickStarBottle)))
        
        leftStatView.origin = [50.px, 666.px]
        view.addSubview(leftStatView)
        
        rightStatView.origin = [280.px, 666.px]
        view.addSubview(rightStatView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
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
        removeFunnyActions()
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
}

extension RoomPKTestViewController {
    @objc func didClickOutSideView() {
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
    @objc func sOnDidClick(_ sender: UISwitch) {
        isFm = sender.isOn
    }
    
    @objc func shengli() {
        PKResultPopView.show(withResult: .victory(isFm), on: view)
    }
    
    @objc func shibai() {
        PKResultPopView.show(withResult: .lose(isFm), on: view)
    }
    
    @objc func daping() {
        PKResultPopView.show(withResult: .draw(isFm), on: view)
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
    @objc func faqiyaoqing() {
        guard popView == nil else {
            JPrint("已经发起了！！！")
            return
        }
        popView = PKChallengePopView.show(on: view)
    }
    
    @objc func qvxiaoyaoqing() {
        popView?.close()
    }
    
    @objc func shoudaoyaoqing() {
        if let inviteView = self.inviteView {
            inviteView.hide()
        } else {
            inviteView = PKChallengeInviteView.show(on: view)
        }
    }
}

extension RoomPKTestViewController {
    @objc func didClickStarBottle() {
        if starBottle.starCount == 6 {
            starBottle.launchStar(on: view, to: isFm ? leftStatView : rightStatView)
            return
        }
        
        let count = starBottle.starCount + 1
        let isActivated = count >= 5
        starBottle.updateStar(count: count, isActivate: isActivated)
    }
}

class StatView: UIView, PKStarTerminal {
    var starCenter: CGPoint { starIcon.center }
    
    let starIcon = UIImageView(image: UIImage(named: "pk_fm_star"))
    
    init() {
        super.init(frame: [0, 0, 33, 14])
        backgroundColor = .orange
        
        starIcon.frame = [2.5, 1, 13, 13]
        addSubview(starIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
