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
    
    let starBottle = PKStarBottle()
    let leftStatView = UIView()
    let rightStatView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        makeBtn("开始PK", [20.px, 500.px], #selector(kaishipk))
        makeBtn("开始巅峰", [100.px, 500.px], #selector(kaishidianfeng))
        makeBtn("结束PK", [180.px, 500.px], #selector(jiesupk))
        
        makeBtn("收起邀请", [20.px, 550.px], #selector(shouqiyaoqing))
        makeBtn("弹起邀请", [100.px, 550.px], #selector(tanqiyaoqing))
        makeBtn("收到邀请", [180.px, 550.px], #selector(shoudaoyaoqing))
        
        starBottle.origin = [HalfDiffValue(PortraitScreenWidth, starBottle.width), 700.px]
        view.addSubview(starBottle)
        starBottle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickStarBottle)))
        
        leftStatView.frame = [50, 666.px, 33, 14]
        leftStatView.backgroundColor = .orange
        let starIcon1 = UIImageView(image: UIImage(named: "pk_fm_star"))
        starIcon1.frame = [2.5, 1, 13, 13]
        leftStatView.addSubview(starIcon1)
        view.addSubview(leftStatView)
        
        rightStatView.frame = [280, 666.px, 33, 14]
        rightStatView.backgroundColor = .orange
        let starIcon2 = UIImageView(image: UIImage(named: "pk_fm_star"))
        starIcon2.frame = [2.5, 1, 13, 13]
        rightStatView.addSubview(starIcon2)
        view.addSubview(rightStatView)
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
    static let isFm = true
    
    @objc func shengli() {
        PKResultPopView.show(withResult: .victory(Self.isFm), on: view)
    }
    
    @objc func shibai() {
        PKResultPopView.show(withResult: .lose(Self.isFm), on: view)
    }
    
    @objc func daping() {
        PKResultPopView.show(withResult: .draw(Self.isFm), on: view)
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

extension RoomPKTestViewController {
    @objc func didClickStarBottle() {
        starBottle.prepareLaunch()
        
//        2.5 + 6.5 = 9
//        1 + 6.5 = 7.5
        
        let origin: CGPoint = [starBottle.centerX, starBottle.y + 5.5]
        
        let leftTarget: CGPoint = [leftStatView.x + 9, leftStatView.y + 7.5]
        let leftControl: CGPoint = [leftTarget.x + HalfDiffValue(origin.x, leftTarget.x) + 20, leftTarget.y - 70]
        
        let rightTarget: CGPoint = [rightStatView.x + 9, rightStatView.y + 7.5]
        let rightControl: CGPoint = [origin.x + HalfDiffValue(rightTarget.x, origin.x) - 0, rightTarget.y - 70]
        
        playStarAnim(6, from: origin, to: leftTarget, controlPoint: leftControl)
        playStarAnim(6, from: origin, to: rightTarget, controlPoint: rightControl)
        
//        makeShapeLayer(from: origin, to: leftTarget, controlPoint: leftControl)
//        makeShapeLayer(from: origin, to: rightTarget, controlPoint: rightControl)
    }
    
    func playStarAnim(_ count: Int, from: CGPoint, to: CGPoint, controlPoint: CGPoint) {
        guard count > 0 else { return }
        
        let imgViews = Array(0..<count).map { _ -> UIImageView in
            let imgView = UIImageView(image: UIImage(named: "pk_flyingstar"))
            imgView.frame = [starBottle.x + HalfDiffValue(starBottle.width, 11), starBottle.y, 11, 11]
            imgView.alpha = 0
            view.addSubview(imgView)
            return imgView
        }
        
        Asyncs.mainDelay(0.01) {
            for (i, imgView) in imgViews.enumerated() {
                self.playStarAnim(imgView, index: i, from: from, to: to, controlPoint: controlPoint)
            }
        }
    }
    
    func playStarAnim(_ imgView: UIImageView, index: Int, from: CGPoint, to: CGPoint, controlPoint: CGPoint) {
        let delay = TimeInterval(index) * 0.3
        Asyncs.mainDelay(delay) { [weak self] in
            guard let self = self else { return }
            if index < self.starBottle.starImgViews.count {
                let starImgView = self.starBottle.starImgViews[index]
                UIView.animate(withDuration: 0.6) {
                    starImgView.alpha = 0
                }
            }
            UIView.animate(withDuration: 0.12) {
                imgView.alpha = 1
            } completion: { _ in
                let pathAnim = Self.createPathAnimation(from: from, to: to, controlPoint: controlPoint, duration: 0.58)
//                let scaleAnim = Self.createScaleAnimation(0.8, duration: 0.48)
                
                CATransaction.begin()
                CATransaction.setCompletionBlock(nil)
                imgView.layer.add(pathAnim, forKey: "position")
//                imgView.layer.add(scaleAnim, forKey: "scale")
                CATransaction.commit()
                
                Asyncs.mainDelay(0.58) {
                    CATransaction.begin()
                    CATransaction.setCompletionBlock(nil)
                    imgView.layer.removeAllAnimations()
//                    imgView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
                    imgView.layer.position = to
                    CATransaction.commit()
                    
                    UIView.animate(withDuration: 0.12) {
                        imgView.alpha = 0
                    } completion: { _ in
                        imgView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    static func createPathAnimation(from: CGPoint, to: CGPoint, controlPoint: CGPoint, duration: TimeInterval) -> CAKeyframeAnimation {
        let path = UIBezierPath()
        path.move(to: from)
        path.addQuadCurve(to: to, controlPoint: controlPoint)
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.cgPath
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.duration = duration
        return anim
    }
    
    static func createScaleAnimation(_ scale: CGFloat, duration: TimeInterval) -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.toValue = scale
        anim.duration = duration
        return anim
    }
    
    func makeShapeLayer(from: CGPoint, to: CGPoint, controlPoint: CGPoint) {
        let path = UIBezierPath()
        path.move(to: from)
        path.addQuadCurve(to: to, controlPoint: controlPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.randomColor.cgColor
        shapeLayer.lineWidth = 2
        view.layer.addSublayer(shapeLayer)
    }
}
