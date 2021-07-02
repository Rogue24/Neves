//
//  OptionPopView.swift
//  Neves_Example
//
//  Created by 周健平 on 2021/4/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

// MARK:- 选项类型
enum OptionType {
    case remarks // 备注
    case blacklist(_ isCancel: Bool) // 拉黑
    case report // 举报
    case secondCreation // 二创
    case uninterested // 不感兴趣
    case delete // 删除
    case theTop(_ isCancel: Bool) // 置顶
    case recommend(_ isCancel: Bool) // 推荐
    case shield(_ isCancel: Bool) // 屏蔽
    
    var iconName: String {
        switch self {
        case .remarks: return "pop_setnotes"
        case let .blacklist(isCancel): return isCancel ? "pop_cancelblock" : "pop_block"
        case .report: return "pop_slog_report"
        case .secondCreation: return "pop_slog_redesign"
        case .uninterested: return "pop_slog_uninterst"
        case .delete: return "pop_slog_delete"
        case let .theTop(isCancel): return isCancel ? "pop_slog_top_cancel" : "pop_slog_top"
        case let .recommend(isCancel): return isCancel ? "pop_slog_recommend_cancel" : "pop_slog_recommend"
        case let .shield(isCancel): return isCancel ? "pop_slog_block_cancel" : "pop_slog_block"
        }
    }
    
    var title: String {
        switch self {
        case .remarks: return "设置备注名"
        case let .blacklist(isCancel): return isCancel ? "取消拉黑" : "拉黑"
        case .report: return"举报"
        case .secondCreation: return "二次创作"
        case .uninterested: return "不感兴趣"
        case .delete: return "删除"
        case let .theTop(isCancel): return isCancel ? "取消置顶" : "置顶"
        case let .recommend(isCancel): return isCancel ? "取消推荐" : "推荐"
        case let .shield(isCancel): return isCancel ? "取消屏蔽" : "屏蔽内容"
        }
    }
}

// MARK:- 选项事件模型
struct OptionAction: PopActionCompatible {
    typealias Execute = (OptionPopView, Self, Int) -> ()
    
    let type: OptionType
    let execute: Execute?
    
    let iconName: String
    let title: String
    let isAfterExecToClose: Bool
    
    /// 构造器
    init(_ type: OptionType,
         _ iconName: String? = nil,
         _ title: String? = nil,
         _ isAfterExecToClose: Bool = true,
         _ execute: Execute?) {
        self.type = type
        self.iconName = iconName ?? type.iconName
        self.title = title ?? type.title
        self.isAfterExecToClose = isAfterExecToClose
        self.execute = execute
    }
    
    static func action(_ type: OptionType,
                       iconName: String? = nil,
                       title: String? = nil,
                       isAfterExecToClose: Bool = true,
                       _ execute: Execute?) -> OptionAction {
        .init(type, iconName, title, isAfterExecToClose, execute)
    }
}

// MARK:- 选项弹窗
class OptionPopView: UIView, PopActionViewCompatible {
    static let maxCol = 4
    static let contentInset: UIEdgeInsets = .init(top: 27.px, left: 39.px, bottom: 30.px + DiffTabBarH, right: 39.px)
    static let itemHorSpace = (PortraitScreenWidth - contentInset.left - contentInset.right - CGFloat(maxCol) * OptionItem.size.width) / CGFloat(maxCol - 1)
    static let itemVerSpace = 29.5.px
    
    // MARK: 公开属性
    let style: PopStyle = .sheet
    let actions: [OptionAction]
    let contentView = UIView()
    
    // MARK: 初始化&反初始化
    init(title: String?, _ actions: [OptionAction]) {
        self.actions = actions
        super.init(frame: PortraitScreenBounds)
        layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
        
        var contentInset = Self.contentInset
        if let title = title {
            contentInset.top += 21.px
            
            let titleLabel = UILabel(frame: [0, 10.px, PortraitScreenWidth, 18.5.px])
            titleLabel.textAlignment = .center
            titleLabel.font = .systemFont(ofSize: 13.px)
            titleLabel.textColor = .rgb(168, 162, 179)
            titleLabel.text = title
            contentView.addSubview(titleLabel)
        }
        
        let itemW = OptionItem.size.width
        let itemH = OptionItem.size.height
        
        for i in 0..<actions.count {
            let action = actions[i]
            
            let row = i / Self.maxCol
            let col = i % Self.maxCol
            let x = contentInset.left + (itemW + Self.itemHorSpace) * CGFloat(col)
            let y = contentInset.top + (itemH + Self.itemVerSpace) * CGFloat(row)
            
            let item = OptionItem(action: action, origin: [x, y])
            item.tag = i
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapItem(_:))))
            contentView.addSubview(item)
            
            guard i == actions.count - 1 else { continue }
            contentView.frame = [0, PortraitScreenHeight, PortraitScreenWidth, item.frame.maxY + contentInset.bottom]
        }
        
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.rgb(51, 46, 68).cgColor
        bgLayer.borderWidth = 0
        bgLayer.path = UIBezierPath(roundedRect: contentView.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: [20.px, 20.px]).cgPath
        contentView.layer.insertSublayer(bgLayer, at: 0)
        
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("弹窗小姐姐死了")
    }
    
    // MARK: 创建+弹出
    @discardableResult
    static func show(onView view: UIView? = nil, title: String? = nil, actions: [OptionAction]) -> OptionPopView? {
        show(onView: view) { OptionPopView(title: title, actions) }
    }
    
    // MARK: 点击空白关闭
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        if contentView.frame.contains(point) == false { close() }
    }
    
    // MARK: 监听按钮点击
    @objc func tapItem(_ tapGR: UITapGestureRecognizer) {
        let item = tapGR.view
        execAction(item?.tag ?? 0)
    }
}

// MARK:- 选项按钮
class OptionItem: UIView {
    static let size: CGSize = [45.px, (45 + 8 + 15).px]
    
    let iconView = UIImageView()
    let titleLabel = UILabel()
    
    init(action: OptionAction, origin: CGPoint) {
        super.init(frame: .init(origin: origin, size: Self.size))
        clipsToBounds = false
        
        iconView.frame = [0, 0, Self.size.width, Self.size.width]
        iconView.contentMode = .scaleAspectFill
        iconView.layer.cornerRadius = Self.size.width * 0.5
        iconView.layer.masksToBounds = true
        addSubview(iconView)
        
        titleLabel.frame = [HalfDiffValue(Self.size.width, Self.size.width * 2),
                            iconView.frame.maxY + 8.px,
                            Self.size.width * 2,
                            15.px]
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 11.px)
        titleLabel.textColor = .rgb(168, 162, 179)
        addSubview(titleLabel)
        
        updateUI(action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(_ action: OptionAction, animated: Bool = false) {
        let image = UIImage(named: action.iconName)
        let title = action.title
        
        if !animated {
            iconView.image = image
            titleLabel.text = title
            return
        }
        
        UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve, .overrideInheritedDuration]) {
            self.iconView.image = image
            self.titleLabel.text = title
        } completion: { _ in }
    }
}
