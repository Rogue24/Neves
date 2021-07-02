//
//  AlertView.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/12/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

class AlertView: UIView, PopActionViewCompatible {
    // MARK:- 公开属性
    let style: PopStyle = .alert
    let contentView = UIView()
    let actions: [PopBaseAction<AlertView>]
    
    // MARK:- 初始化&反初始化
    init(_ title: String,
         _ message: String?,
         _ cancelTitle: String? = nil,
         _ cancelTitleColor: UIColor? = nil,
         _ cancelBgColor: UIColor? = nil,
         _ confirmTitle: String? = nil,
         _ confirmTitleColor: UIColor? = nil,
         _ confirmBgColor: UIColor? = nil,
         _ isCancelOnLeft: Bool = true,
         _ isAfterConfirmToClose: Bool,
         _ confirm: @escaping PopBaseAction<AlertView>.Execute) {
        
        let cancelAction = PopBaseAction<AlertView>(title: cancelTitle ?? "取消", execute: nil)
        let confirmAction = PopBaseAction<AlertView>(title: confirmTitle ?? "确认", isAfterExecToClose: isAfterConfirmToClose, execute: confirm)
        
        self.actions = isCancelOnLeft ? [cancelAction, confirmAction] : [confirmAction, cancelAction]
        
        super.init(frame: PortraitScreenBounds)
        layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
        
        let x: CGFloat = 25.px
        let w: CGFloat = PortraitScreenWidth - 2 * x
        
        let textX: CGFloat = 15.px
        let textW: CGFloat = w - textX * 2
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 17.px)
        titleLabel.textColor = .white
        titleLabel.frame = [textX, 25.px, textW, 17.px]
        titleLabel.text = title
        contentView.addSubview(titleLabel)
        
        var btnX = textX
        let btnY: CGFloat
        
        if let obMessage = message {
            let messageLabel = UILabel()
            messageLabel.textAlignment = .center
            messageLabel.font = .systemFont(ofSize: 15.px)
            messageLabel.textColor = .rgb(168, 162, 179)
            messageLabel.numberOfLines = 0
            let msgH = (obMessage as NSString).boundingRect(with: [textW, 999], options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: messageLabel.font!], context: nil).size.height
            messageLabel.frame = [textX, titleLabel.frame.maxY + 19.px, textW, msgH]
            messageLabel.text = message
            contentView.addSubview(messageLabel)
            
            btnY = messageLabel.frame.maxY + 30.px
        } else {
            btnY = titleLabel.frame.maxY + 30.px
        }
        
        let btnW: CGFloat = (w - btnX * 3) / 2.0
        let btnH: CGFloat = 39.px
        var h: CGFloat = 0
        
        for i in 0..<actions.count {
            let action = actions[i]
            
            let btn = UIButton(type: .system)
            btn.tag = i
            btn.addTarget(self, action: #selector(didClickBtn(_:)), for: .touchUpInside)
            
            btn.frame = [btnX, btnY, btnW, btnH]
            btn.layer.cornerRadius = btnH * 0.5
            btn.layer.masksToBounds = true
            
            btn.setTitle(action.title, for: .normal)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15.px)
            
            if (isCancelOnLeft && i == 0) || (!isCancelOnLeft && i == 1) {
                btn.setTitleColor(cancelTitleColor ?? .white, for: .normal)
                btn.backgroundColor = cancelBgColor ?? .rgb(63, 59, 84)
            } else {
                btn.setTitleColor(confirmTitleColor ?? .white, for: .normal)
                btn.backgroundColor = confirmBgColor ?? .rgb(126, 126, 255)
            }
            contentView.addSubview(btn)
            
            if i == (actions.count - 1) {
                h = btn.maxY + 20.px
            } else {
                btnX += (btnW + textX)
            }
        }
        
        let y: CGFloat = HalfDiffValue(PortraitScreenHeight, h)
        contentView.frame = [x, y, w, h]
        
        let bgLayer = CALayer()
        bgLayer.frame = contentView.bounds
        bgLayer.backgroundColor = UIColor.rgb(51, 46, 68).cgColor
        bgLayer.cornerRadius = 12.px
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
    static func show(onView view: UIView? = nil,
                     title: String,
                     message: String?,
                     cancelTitle: String? = nil,
                     cancelTitleColor: UIColor? = nil,
                     cancelBgColor: UIColor? = nil,
                     confirmTitle: String? = nil,
                     confirmTitleColor: UIColor? = nil,
                     confirmBgColor: UIColor? = nil,
                     isCancelOnLeft: Bool = true,
                     isAfterConfirmToClose: Bool,
                     confirm: @escaping PopBaseAction<AlertView>.Execute) -> AlertView? {
        show(onView: view) { AlertView(title, message, cancelTitle, cancelTitleColor, cancelBgColor, confirmTitle, confirmTitleColor, confirmBgColor, isCancelOnLeft, isAfterConfirmToClose, confirm) }
    }
    
    // MARK:- 监听按钮点击
    @objc func didClickBtn(_ sender: UIButton) { execAction(sender.tag) }
}
