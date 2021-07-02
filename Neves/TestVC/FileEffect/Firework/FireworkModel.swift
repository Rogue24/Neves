//
//  FireworkModel.swift
//  Neves_Example
//
//  Created by aa on 2020/10/15.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher

class FireworkModel: Equatable {
    // MARK:- 公开属性
    struct UserInfo {
        let uid: UInt32
        var icon: UIImage? = FireworkModel.defaultIcon
    }
    /** 源模型 */
    let launcherInfo: UU_FireworkLauncherInfo
    /** 用户模型 */
    var userInfo: UserInfo
    var uid: UInt32 { userInfo.uid }
    var icon: UIImage? { userInfo.icon }
    var nickName: String? { "帅哥平" }
    /** 是不是自己本人 */
    var isMe: Bool = false
    /** 🚀发射次数 */
    var launchCount: UInt = 0
    /** 剩余秒数 */
    var seconds: UInt32 { didSet { updateSecondsText() } }
    /** 剩余秒数文本 */
    fileprivate(set) var secondsText: String = "00:00"
    
    private func updateSecondsText() {
        if seconds > 0 {
            let min = seconds / 60
            let sec = seconds % 60
            secondsText = String(format: "%02d:%02d", min, sec)
        } else {
            secondsText = "00:00"
        }
    }
    
    // MARK:- 初始化&反初始化
    init(_ launcherInfo: UU_FireworkLauncherInfo) {
        self.launcherInfo = launcherInfo
        
        seconds = launcherInfo.remainSeconds
        
        userInfo = UserInfo(uid: launcherInfo.uid)
        
        updateSecondsText()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- 监听获取到用户信息的通知
    @objc func getUserInfo(_ notification: Notification) {
        guard let userInfo = notification.object as? FireworkModel.UserInfo,
              userInfo.uid == uid else { return }
        self.userInfo = userInfo
    }
    
    // MARK:- Equatable
    static func == (lhs: FireworkModel, rhs: FireworkModel) -> Bool {
        lhs.uid == rhs.uid
    }
}

// MARK:- 获取&缓存用户模型
extension FireworkModel {
    // MARK: 更新用户模型通知
    static let UserInfoGetedNotification: NSNotification.Name = NSNotification.Name(rawValue: "FireworkModel.UserInfoGetedNotification")
    // MARK: 默认用户头像
    static let defaultIcon = UIImage(named: "jp_icon")!.clipRound()
}
//
//    /** 用户模型缓存 */
//    private static var userInfos: [UInt32: UserInfo] = [:]
//    /** 请求标识的缓存（防止重复请求）*/
//    private static var workingItems: [UInt32: UInt32] = [:]
//    /** 重复请求的缓存（请求失败的重请求）*/
//    private static var repeatItems: [UInt32: DispatchWorkItem] = [:]
//
//    // MARK: 清除缓存
//    static func cleanAllItems() {
//        repeatItems.forEach { (_, repeatItem) in
//            repeatItem.cancel()
//        }
//        repeatItems.removeAll()
//        workingItems.removeAll()
//        userInfos.removeAll()
//    }
//
//    // MARK: 获取用户信息
//    private static func getUserInfo(_ uid: UInt32) {
//        if let repeatItem = repeatItems[uid] {
//            repeatItem.cancel()
//            repeatItems[uid] = nil
//        }
//
//        if workingItems[uid] != nil { return }
//        workingItems[uid] = uid
//
//        GetService(SDAccountService.self).reqGetUserInfo(byUid: uid) { (dataModel: SDUserDataModel?) in
//            guard workingItems[uid] != nil else { return }
//
//            guard let model = dataModel else {
//                getedUserInfo(uid, nil, Self.defaultIcon)
//                workingItems[uid] = nil
//                return
//            }
//
//            getedUserInfo(uid, model, nil)
//            workingItems[uid] = nil
//
//            getUserIcon(uid)
//
//        } errorHandler: { error in
//            guard workingItems[uid] != nil else { return }
//            if error != nil { repeatToGet(uid) }
//            workingItems[uid] = nil
//        }
//    }
//
//    // MARK: 获取用户头像（切圆）
//    private static func getUserIcon(_ uid: UInt32) {
//        if let repeatItem = repeatItems[uid] {
//            repeatItem.cancel()
//            repeatItems[uid] = nil
//        }
//
//        guard let userInfo = userInfos[uid], let model = userInfo.userDataModel else { return }
//        guard userInfo.icon == nil else { return }
//
//        guard let imgURL = URL(string: model.imgURL) else {
//            getedUserInfo(uid, model, Self.defaultIcon)
//            workingItems[uid] = nil
//            return
//        }
//
//        if workingItems[uid] != nil { return }
//        workingItems[uid] = uid
//
//        KingfisherManager.shared.downloader.downloadImage(with: imgURL, completionHandler:  { result in
//            guard workingItems[uid] != nil else { return }
//
//            switch result {
//            case let .success(imgResult):
//                let scale = imgResult.image.size.width > 50.0 ? (50.0 / imgResult.image.size.width) : 1
//                let image = imgResult.image.clipRound(scale)
//                getedUserInfo(uid, model, image)
//            case .failure(_):
//                repeatToGet(uid)
//            }
//
//            workingItems[uid] = nil
//        })
//    }
//
//    // MARK: 缓存用户信息&发出通知
//    private static func getedUserInfo(_ uid: UInt32, _ model: SDUserDataModel?, _ icon: UIImage?) {
//        let userInfo = UserInfo(uid: uid, icon: icon, userDataModel: model)
//        userInfos[uid] = userInfo
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: UserInfoGetedNotification, object: userInfo)
//        }
//    }
//
//    // MARK: 再次获取用户信息
//    private static func repeatToGet(_ uid: UInt32) {
//        if let repeatItem = repeatItems[uid] { repeatItem.cancel() }
//        let repeatItem: DispatchWorkItem
//        if let _ = userInfos[uid] {
//            repeatItem = DispatchWorkItem {
//                repeatItems[uid] = nil
//                getUserIcon(uid)
//            }
//        } else {
//            repeatItem = DispatchWorkItem {
//                repeatItems[uid] = nil
//                getUserInfo(uid)
//            }
//        }
//        repeatItems[uid] = repeatItem
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: repeatItem)
//    }
//}


