//
//  PopViewCompatible.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/12/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

enum PopStyle {
    case sheet, alert
}

protocol PopViewCompatible {
    var style: PopStyle { get }
    var contentView: UIView { get }
    
    func show()
    func close()
}

extension PopViewCompatible where Self: UIView {
    // MARK: - 创建+弹出
    @discardableResult
    static func show(onView view: UIView? = nil, insertAt index: Int? = nil, builder: () -> Self) -> Self? {
        guard let superview = view ?? UIApplication.shared.windows.first else { return nil }
        let popView = builder()
        if let idx = index {
            superview.insertSubview(popView, at: idx)
        } else {
            superview.addSubview(popView)
        }
        popView.show()
        return popView
    }
    
    // MARK: - 弹出动画
    func show() {
        switch style {
        case .sheet:
            var contentFrame = contentView.frame
            if contentFrame.origin.y != PortraitScreenHeight {
                contentFrame.origin.y = PortraitScreenHeight
                contentView.frame = contentFrame
            }
            contentFrame.origin.y -= contentFrame.height
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
                self.contentView.frame = contentFrame
                self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0.4).cgColor
            }, completion: nil)
            
        case .alert:
            contentView.center = [bounds.width * 0.5, bounds.height * 0.5]
            contentView.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            contentView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 1.0, options: [], animations: {
                self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.contentView.alpha = 1
                self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0.4).cgColor
            }, completion: nil)
        }
    }
    
    // MARK: - 关闭动画
    func close() {
        isUserInteractionEnabled = false
        switch style {
        case .sheet:
            var contentFrame = contentView.frame
            contentFrame.origin.y = PortraitScreenHeight + 20 // + 20 为了确保完全离开屏幕
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
                self.contentView.frame = contentFrame
                self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
            } completion: { _ in
                self.removeFromSuperview()
            }
            
        case .alert:
            UIView.animate(withDuration: 0.2) {
                self.contentView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                self.contentView.alpha = 0
                self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}

protocol PopActionCompatible {
    associatedtype PopView: PopViewCompatible
    
    /// 标题
    var title: String { get }
    /// 是否点击选项后关闭弹窗
    var isAfterExecToClose: Bool { get }
    /// 点击事件
    var execute: ((PopView, Self, Int) -> ())? { get }
}
extension PopActionCompatible {
    var title: String { "" }
    var isAfterExecToClose: Bool { true }
}

struct PopBaseAction<PopView: PopViewCompatible>: PopActionCompatible {
    typealias Execute = (PopView, Self, Int) -> ()
    
    /// 标题
    let title: String
    /// 是否点击选项后关闭弹窗
    let isAfterExecToClose: Bool
    /// 点击事件
    let execute: Execute?
    
    /// 构造器
    init(title: String, isAfterExecToClose: Bool = true, execute: Execute?) {
        self.title = title
        self.isAfterExecToClose = isAfterExecToClose
        self.execute = execute
    }
}

protocol PopActionViewCompatible: PopViewCompatible {
    associatedtype Action: PopActionCompatible
    var actions: [Action] { get }
}

extension PopActionViewCompatible {
    // MARK: - 执行Action
    func execAction(_ index: Int) {
        guard let popView = self as? Self.Action.PopView,
              index < actions.count else { return }
        let action = actions[index]
        if action.isAfterExecToClose { close() }
        action.execute?(popView, action, index)
    }
}
