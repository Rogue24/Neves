//
//  SheetView.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/12/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

// MARK:- 事件模型
struct SheetAction: PopActionCompatible {
    typealias Execute = (SheetView, Self, Int) -> ()
    
    /// 标题
    let title: String
    /// 是否点击选项后关闭弹窗
    let isAfterExecToClose: Bool
    /// 点击事件
    let execute: Execute?
    
    /// 标题颜色
    let titleColor: UIColor
    /// 构造器
    init(title: String, titleColor: UIColor = .rgb(212, 209, 216), isAfterExecToClose: Bool = true, execute: Execute?) {
        self.title = title
        self.titleColor = titleColor
        self.isAfterExecToClose = isAfterExecToClose
        self.execute = execute
    }
}

class SheetView: UIView, PopActionViewCompatible {
    // MARK:- 公开属性
    let style: PopStyle = .sheet
    let contentView = UIView()
    let actions: [SheetAction]
    
    // MARK:- 初始化&反初始化
    init(_ actions: [SheetAction]) {
        
        self.actions = actions
        super.init(frame: PortraitScreenBounds)
        layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
        
        let contentInserts = UIEdgeInsets(top: 25, left: 25, bottom: 25 + DiffTabBarH, right: 25)
        let itemBgColor: UIColor = .rgb(63, 59, 84)
        let itemTitleFont: UIFont = .systemFont(ofSize: 15)
        let itemWidth: CGFloat = PortraitScreenWidth - contentInserts.left - contentInserts.right
        let itemHeight: CGFloat = 40
        let itemSpace: CGFloat = 15
        
        var y: CGFloat = contentInserts.top
        for i in 0..<actions.count {
            let action = actions[i]
            let btn = UIButton(type: .system)
            btn.frame = CGRect(origin: [contentInserts.left, y], size: [itemWidth, itemHeight])
            btn.layer.cornerRadius = itemHeight * 0.5
            btn.layer.masksToBounds = true
            btn.backgroundColor = itemBgColor
            btn.setTitle(action.title, for: .normal)
            btn.setTitleColor(action.titleColor, for: .normal)
            btn.titleLabel?.font = itemTitleFont
            btn.tag = i
            btn.addTarget(self, action: #selector(didClickBtn(_:)), for: .touchUpInside)
            contentView.addSubview(btn)
            y += itemHeight
            if i == (actions.count - 1) {
                y += contentInserts.bottom
            } else {
                y += itemSpace
            }
        }
        
        contentView.frame = [0, PortraitScreenHeight, PortraitScreenWidth, y]
        
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.rgb(51, 46, 68).cgColor
        bgLayer.borderWidth = 0
        bgLayer.path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: [10, 10]).cgPath
        contentView.layer.insertSublayer(bgLayer, at: 0)
        
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("弹窗小妹死了")
    }
    
    // MARK:- 创建+弹出
    @discardableResult
    static func show(onView view: UIView? = nil, actions: [SheetAction]) -> SheetView? {
        show(onView: view) { SheetView(actions) }
    }
    
    // MARK:- 点击空白关闭
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        if contentView.frame.contains(point) == false { close() }
    }
    
    // MARK:- 监听按钮点击
    @objc func didClickBtn(_ sender: UIButton) { execAction(sender.tag) }
}
