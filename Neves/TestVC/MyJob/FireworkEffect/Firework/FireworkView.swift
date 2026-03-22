//
//  FireworkView.swift
//  Neves_Example
//
//  Created by aa on 2020/10/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Lottie

class FireworkView: UIView {
    // MARK: - 公开属性
    typealias UpdateDone = () -> Void
    // MARK: 点击回调
    var touchAction: (() -> ())?
    
    // MARK: - 私有属性
    fileprivate var itemView = UIView()
    fileprivate var frontItem: FireworkItem = FireworkItem.loadFromNib()
    fileprivate var backItem: FireworkItem = FireworkItem.loadFromNib()
    
    // MARK: - 初始化&反初始化
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("老子死了吗")
    }
    
    // MARK: - 重写父类方法
    override func didMoveToSuperview() {
        if self.superview != nil { updateItemsLayout() }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 这里的point是相对于自身，用bounds判断
        point.x > 0 && point.y > bounds.height * 0.5 && point.y < bounds.height * 0.85
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchAction?()
    }
}

// MARK: - 初始化UI
extension FireworkView {
    // MARK: 初始化焰火轮播图
    fileprivate func setupUI() {
        addSubview(itemView)
        itemView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        itemView.addSubview(backItem)
        backItem.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        itemView.addSubview(frontItem)
        frontItem.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        itemView.alpha = 0
    }
    
    // MARK: 创建lottie视图
    fileprivate func animationView(_ icon: UIImage, _ dirName: String) -> LottieAnimationView {
        let animView = LottieAnimationView.jp.build(dirName, ["img_0.png": icon.cgImage])
        insertSubview(animView, belowSubview: itemView)
        animView.snp.makeConstraints { $0.edges.equalToSuperview() }
        return animView
    }
}

// MARK: - 公开方法
extension FireworkView {
    // MARK: 第一次显示动画
    func showAnim(_ model: FireworkModel, _ updateDone: UpdateDone?) {
        isUserInteractionEnabled = true
        if itemView.alpha > 0 {
            updateFrontItem(model, true, updateDone)
        } else {
            frontItem.updateSeconds(model)
            UIView.animate(withDuration: 1, animations: {
                self.itemView.alpha = 1
            }) { _ in
                updateDone?()
            }
        }
    }
    
    // MARK: 发射🚀动画
    func launchAnim(_ model: FireworkModel?, _ models: [FireworkModel], index: Int = 0, _ updateDone: UpdateDone?) {
        isUserInteractionEnabled = true
        
        // 预留点时间去拿头像🐶
        let delay = models[index].icon == nil ? 1.0 : 0.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            let launchModel = models[index]
            let launchView = self.animationView(launchModel.icon ?? FireworkModel.defaultIcon, "fire_lottie2")
            
            self.itemView.alpha = 0
            if model != nil { self.updateFrontItem(model!, false) }
            
            launchView.play(toProgress: 1, loopMode: .repeat(Float(launchModel.launchCount))) { [weak self, weak launchView] _ in
                launchView?.removeFromSuperview() // 不弱引用会循环引用
                models[index].launchCount = 0
                
                guard let self = self else {
                    updateDone?()
                    return
                }
                
                if index >= (models.count - 1) {
                    UIView.animate(withDuration: 1, animations: {
                        self.itemView.alpha = 1
                    }) { _ in
                        updateDone?()
                    }
                } else {
                    self.launchAnim(nil, models, index: index + 1, updateDone)
                }
            }
        }
    }
    
    // MARK: 退出动画
    func quitAnim(_ model: FireworkModel, _ updateDone: UpdateDone?) {
        isUserInteractionEnabled = false
        
        frontItem.updateSeconds(model)
        
        let quitView = animationView(model.icon ?? FireworkModel.defaultIcon, "fire_lottie3")
        quitView.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.itemView.alpha = 0
            quitView.alpha = 1
            
            quitView.play { [weak quitView] _ in
                quitView?.removeFromSuperview() // 不弱引用会循环引用
                updateDone?()
            }
        }
    }
    
    // MARK: 秒数刷新+轮换动画
    func updateFrontItem(_ model: FireworkModel, _ isSwitch: Bool, _ updateDone: UpdateDone? = nil) {
        if isSwitch == false {
            frontItem.updateSeconds(model)
            updateDone?()
            return
        }
        frontItem.uid = nil
        backItem.updateSeconds(model)
        updateItemsLayout(forBeforeSwitchItem: true)
        UIView.animate(withDuration: 0.5) {
            self.frontItem.alpha = 0
            self.frontItem.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: -20, y: 0)
        }
        UIView.animate(withDuration: 0.5, delay: 0.25, options: []) {
            self.backItem.alpha = 1
            self.backItem.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { _ in
            self.updateItemsLayout(forBeforeSwitchItem: false, true)
            self.frontItem.updateSeconds(model)
            updateDone?()
        }
    }
}

// MARK: - 私有方法
extension FireworkView {
    // MARK: 交换前后引用
    private func swapItems(_ a: inout FireworkItem, _ b: inout FireworkItem) { (a, b) = (b, a) }
    
    // MARK: 刷新UI
    fileprivate func updateItemsLayout(forBeforeSwitchItem isBefore: Bool = false, _ isSwap: Bool = false) {
        if isBefore == false, isSwap == true { swapItems(&frontItem, &backItem) }
        // itemView.frame是相对于self，外部修改的是self.transform，self.bounds不会受影响，所以itemView.frame也不会变。
        let frame = itemView.frame
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if isBefore {
            frontItem.layer.anchorPoint = .init(x: 0, y: 0.5)
            frontItem.layer.position = .init(x: 0, y: frame.height * 0.5)
            
            backItem.layer.anchorPoint = .init(x: 1, y: 0.5)
            backItem.layer.position = .init(x: frame.width, y: frame.height * 0.5)
            backItem.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 20, y: 0)
        } else {
            backItem.transform = .identity
            backItem.layer.anchorPoint = .init(x: 0.5, y: 0.5)
            backItem.layer.position = .init(x: frame.width * 0.5, y: frame.height * 0.5)
            
            frontItem.transform = .identity
            frontItem.layer.anchorPoint = .init(x: 0.5, y: 0.5)
            frontItem.layer.position = .init(x: frame.width * 0.5, y: frame.height * 0.5)
        }
        backItem.alpha = 0
        CATransaction.commit()
    }
}
