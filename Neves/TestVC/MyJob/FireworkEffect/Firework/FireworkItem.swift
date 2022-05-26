//
//  FireworkItem.swift
//  Neves_Example
//
//  Created by aa on 2020/10/13.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class FireworkItem: UIView {
    // MARK: - 公开属性
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var countDownLabel: UILabel!
    // MARK: 用户标识，用于刷新头像
    var uid: UInt32?
    
    // MARK: - 初始化&反初始化
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(getUserInfo), name: FireworkModel.UserInfoGetedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        JPrint("老子死了吗")
    }
    
    // MARK: - 监听获取到用户信息的通知
    @objc fileprivate func getUserInfo(_ notification: Notification) {
        guard let uid = self.uid,
              let userInfo = notification.object as? FireworkModel.UserInfo,
              userInfo.uid == uid else { return }
        iconView.image = userInfo.icon ?? FireworkModel.defaultIcon
    }
    
    // MARK: - 刷新秒数&闪烁动画
    func updateSeconds(_ model: FireworkModel) {
        uid = model.uid
        iconView.image = model.icon ?? FireworkModel.defaultIcon
        
        let seconds = model.seconds
        let secondsText = model.secondsText
        
        if countDownLabel.text == secondsText { return }
        
        let isTwinkle = seconds <= 10
        if isTwinkle {
            
            UIView.animate(withDuration: 0.48, delay: 0, options: .curveLinear, animations: {
                self.countDownLabel.alpha = 0
            }, completion: { finish in
                if !finish { return }
                
                self.countDownLabel.text = secondsText
                self.countDownLabel.textColor = .red
                
                UIView.animate(withDuration: 0.48, delay: 0, options: .curveLinear, animations: {
                    self.countDownLabel.alpha = 1
                }, completion: nil)
            })
            
        } else {
            countDownLabel.text = secondsText
            countDownLabel.textColor = seconds <= 30 ? .red : .white
            
            if countDownLabel.alpha < 1 {
                UIView.animate(withDuration: 0.48, delay: 0, options: .curveLinear, animations: {
                    self.countDownLabel.alpha = 1
                }, completion: nil)
            }
        }
    }
}
