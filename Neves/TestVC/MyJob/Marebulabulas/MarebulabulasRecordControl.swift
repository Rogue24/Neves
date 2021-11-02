//
//  MarebulabulasRecordControl.swift
//  Neves_Example
//
//  Created by aa on 2020/10/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class MarebulabulasRecordControl: UIView {
    
    let totalTime: TimeInterval
    let minTime: TimeInterval
    let minProgress: CGFloat
    
    // 录制按钮和图标
    let recordView = UIView()
    let recordImgView = UIImageView(image: UIImage(named: "record_btn_ing"))
    // 底部文字
    let recordLabel = UILabel()
    // 圆环
    var recordLayer: CALayer?
    var recordingLayer: CAShapeLayer!
    // 扩散动画
    var recordAnimView: AnimationView?
    // 重录按钮
    var reRecordView: UIImageView?
    
    var recordStateDidChanged: ((RecordState) -> ())?
    
    typealias RecordResultHandler = (Bool) -> ()
    var recordDoneHandler: ((RecordResultHandler) -> ())?
    
    var reRecordHandler: (() -> ())?
    var recordSendHandler: (() -> ())?
    
    fileprivate(set) var state: RecordState = .idle {
        didSet {
            var recordText = recordLabel.text
            var reRecordEnabled = false
            
            switch state {
            case .idle:
                recordText = "点击录音"
            case .readyRecord:
                recordText = "点击录音"
            case .recording:
                recordText = "点击完成"
            case .recordDone:
                recordText = nil
            case .recordSuccess:
                recordText = nil
                reRecordEnabled = true
            }
            
            reRecordView?.isUserInteractionEnabled = reRecordEnabled
            
            UIView.transition(with: recordLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                self.recordLabel.text = recordText
            }, completion: nil)

            recordStateDidChanged?(state)
        }
    }
    
    
    
    init(totalTime: TimeInterval, minTime: TimeInterval) {
        self.totalTime = totalTime
        self.minTime = minTime
        self.minProgress = CGFloat(minTime / totalTime)
        
        super.init(frame: [0, 0, 190, 85])
        
        let wh: CGFloat = frame.height
        let x: CGFloat = HalfDiffValue(frame.width, wh)
        recordView.frame = [x, 0, wh, wh]
        recordView.backgroundColor = .white
        recordView.layer.cornerRadius = wh * 0.5
        recordView.layer.masksToBounds = true
        recordView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recordViewDidClick)))
        addSubview(recordView)
        
        recordImgView.frame = recordView.bounds
        recordView.addSubview(recordImgView)
        
        recordLabel.frame = [0, frame.height + 19.5, frame.width, 21]
        recordLabel.textAlignment = .center
        recordLabel.textColor = .rgb(255, 255, 255, a: 0.6)
        recordLabel.font = .systemFont(ofSize: 15)
        recordLabel.text = "点击录音"
        addSubview(recordLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildRecordLayer() {
        if recordLayer != nil { return }
        recordLayer = CALayer()
        guard let recordLayer = self.recordLayer else { return }
        
        recordLayer.frame = recordView.bounds
        recordLayer.opacity = 0
        recordView.layer.addSublayer(recordLayer)
        
        // 初始弧度
        let startRadian = -CGFloat.pi * 0.5
        
        // 至少时间的弧度
        let radian: CGFloat = CGFloat.pi * 2 * minProgress + startRadian
//        JPrint((radian * 180.0) / CGFloat.pi)
        
        let lineW: CGFloat = 5
        let halfLineW: CGFloat = lineW * 0.5
        
        // 圆点
        let arcCenter = CGPoint(x: recordLayer.frame.width * 0.5, y: recordLayer.frame.height * 0.5)
        // 半径
        let radius: CGFloat = recordLayer.frame.width * 0.5 - halfLineW
        
        // 至少时间的圆点
        let x: CGFloat = radius * cos(radian)
        let y: CGFloat = radius * sin(radian)
        let minArcCenter = CGPoint(x: arcCenter.x + x, y: arcCenter.y + y)
        // 起始点、至少时间的点
        let locationPath = UIBezierPath(ovalIn: [arcCenter.x - halfLineW, 0, lineW, lineW])
        locationPath.append(UIBezierPath(ovalIn: [minArcCenter.x - halfLineW, minArcCenter.y - halfLineW, lineW, lineW]))
        // 绘制
        let locationLayer = CAShapeLayer()
        locationLayer.fillColor = UIColor.rgb(255, 87, 169).cgColor
        locationLayer.path = locationPath.cgPath
        recordLayer.addSublayer(locationLayer)
        
        recordingLayer = CAShapeLayer()
        recordingLayer.lineWidth = lineW
        recordingLayer.strokeColor = UIColor.rgb(255, 87, 169).cgColor
        recordingLayer.fillColor = UIColor.clear.cgColor
        recordingLayer.lineCap = .round
        recordingLayer.lineJoin = .round
        recordingLayer.path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startRadian, endAngle: (startRadian + CGFloat.pi * 2), clockwise: true).cgPath
        recordingLayer.strokeEnd = 0
        recordLayer.addSublayer(recordingLayer)
    }

    func buildRecordAnimView() {
        if recordAnimView != nil { return }
        recordAnimView = AnimationView.jp.build("lottie_recordingmotion")
        guard let recordAnimView = self.recordAnimView else { return }
        
        let wh: CGFloat = 175
        let x: CGFloat = HalfDiffValue(frame.width, wh)
        let y: CGFloat = HalfDiffValue(frame.height, wh)
        recordAnimView.frame = [x, y, wh, wh]
        recordAnimView.alpha = 0
        insertSubview(recordAnimView, at: 0)
    }
    
    func buildReRecordView() {
        if reRecordView != nil { return }
        reRecordView = UIImageView(image: UIImage(named: "record_btn_back"))
        guard let reRecordView = self.reRecordView else { return }
        
        let wh: CGFloat = 70
        let x: CGFloat = HalfDiffValue(frame.width, wh)
        let y: CGFloat = HalfDiffValue(frame.height, wh)
        reRecordView.frame = [x, y, wh, wh]
        reRecordView.alpha = 0
        reRecordView.isUserInteractionEnabled = true
        reRecordView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reRecordViewDidClick)))
        insertSubview(reRecordView, at: 0)
    }
}

//var isSuccess: Bool = false
extension MarebulabulasRecordControl {
    @objc func recordViewDidClick() {
        
        if state == .idle {
            prepareRecord()
            return
        }
        
//        if state == .readyRecord {
//            startRecord()
//            return
//        }
        
        
        if state == .recording {
            recordDone()
            return
        }
        
//        if state == .recordDone {
//            isSuccess = !isSuccess
//            if isSuccess {
//                recordSuccess()
//            } else {
//                recovery()
//            }
//            return
//        }
        
        if state == .recordSuccess {
            JPrint("录制成功，发送")
            recordSendHandler?()
            return
        }
    }
    
    func prepareRecord() {
        guard state == .idle else { return }
        state = .readyRecord
        JPrint("准备录制 --- 倒数")
        
        buildRecordAnimView()
        buildRecordLayer()
        
        UIView.animate(withDuration: 0.15) {
            self.recordImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.recordImgView.alpha = 0
        } completion: { _ in
            self.recordImgView.image = UIImage(named: "record_btn_stop")
            UIView.animate(withDuration: 0.15) {
                self.recordImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.recordImgView.alpha = 1
            }
        }
    }
    
    func startRecord() {
        guard state == .readyRecord else { return }
        state = .recording
        JPrint("开始录制")
        
        self.recordAnimView?.play()
        UIView.animate(withDuration: 0.15) {
            self.recordLayer?.opacity = 1
            self.recordAnimView?.alpha = 1
        }
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = totalTime
        anim.toValue = 1
        anim.isRemovedOnCompletion = false
        anim.fillMode = .forwards
        anim.delegate = self
        recordingLayer.add(anim, forKey: "strokeEnd")
    }
    
    func recordDone() {
        guard state == .recording else { return }
        
        if let pLayer = recordingLayer.presentation(), pLayer.strokeEnd >= minProgress {
            state = .recordDone
            JPrint("录制完成，去生成录制文件")
            
            UIView.animate(withDuration: 0.15) {
                self.recordAnimView?.alpha = 0
                self.recordLayer?.opacity = 0
            } completion: { _ in
                self.recordAnimView?.stop()
                self.recordingLayer?.removeAllAnimations()
            }
            
            if let recordDoneHandler = self.recordDoneHandler {
                let resultHandler: RecordResultHandler = { [weak self] in
                    guard let self = self else { return }
                    if $0 {
                        self.recordSuccess()
                    } else {
                        self.recovery()
                    }
                }
                recordDoneHandler(resultHandler)
            }
            
        } else {
            recovery()
        }
    }
    
    func recovery() {
        guard state == .recording || state == .recordDone else { return }
        if state == .recording {
            JPrint("录制时长还不够")
        } else {
            JPrint("录制失败")
        }
        state = .idle
        
        UIView.animate(withDuration: 0.15) {
            self.recordImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.recordImgView.alpha = 0
            
            self.recordAnimView?.alpha = 0
            self.recordLayer?.opacity = 0
            
        } completion: { _ in
            
            self.recordAnimView?.stop()
            self.recordingLayer?.removeAllAnimations()
            self.recordImgView.image = UIImage(named: "record_btn_ing")
            
            UIView.animate(withDuration: 0.15) {
                self.recordImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.recordImgView.alpha = 1
            }
        }
    }
    
    func recordSuccess() {
        guard state == .recordDone else { return }
        state = .recordSuccess
        JPrint("录制成功！")
        
        buildReRecordView()
        
        let wh: CGFloat = 70
        let scale: CGFloat = 70.0 / 85.0
        let centerX = frame.width - wh * 0.5
        
        UIView.animate(withDuration: 0.15) {
            self.recordImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.recordImgView.alpha = 0
            
            self.recordAnimView?.alpha = 0
            self.recordLayer?.opacity = 0
            
            self.recordView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.reRecordView?.alpha = 1
            
        } completion: { _ in
            
            self.recordAnimView?.stop()
            self.recordingLayer?.removeAllAnimations()
            self.recordImgView.image = UIImage(named: "record_btn_send1")
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
                self.recordImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.recordImgView.alpha = 1
                
                self.recordView.centerX = centerX
                self.reRecordView?.x = 0
            } completion: { _ in
                
            }
        }
    }
    
    @objc func reRecordViewDidClick() {
        guard state == .recordSuccess else { return }
        state = .idle
        JPrint("重录")
        
        reRecordHandler?()
        
        let centerX = frame.width * 0.5
        UIView.animate(withDuration: 0.15) {
            self.recordImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.recordImgView.alpha = 0
            
            self.recordView.centerX = centerX
            self.reRecordView?.centerX = centerX
        } completion: { _ in
            self.recordImgView.image = UIImage(named: "record_btn_ing")
            
            UIView.animate(withDuration: 0.15) {
                self.recordImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.recordImgView.alpha = 1
                
                self.recordView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.reRecordView?.alpha = 1
            }
        }
    }
}

extension MarebulabulasRecordControl: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            // 要判断是否录制成功
            recordDone()
        }
    }
}
