//
//  EMLChatRoomUserInfoCard+Model.swift
//  Falla
//
//  Created by aa on 2025/6/23.
//

import Foundation

extension EMLChatRoomUserInfoCard {
    @objcMembers
    class UserInfo: JKRCurrentUser {
        /// 是否在座位
        var isInSeat: Bool = false
        /// 用户mic是否打开
        var isMicOpen: Bool = false
        /// 是否被禁言
        var isForbidMsg: Bool = false
        /// 是否已关注
        var isFollow: Bool = false
        /// 座位是否静音
        var isSeatMute: Bool = false

        var isFriend: Bool = false
        
        var hasForbidPower: Bool = false

        var dataCardSkin: CardSkin? = nil

        /// v6.3.0新增
        ///  勋章积分
        var medalPoint: Int = 0

        /// v6.6.0新增
        /// cp戒指信息
        var cpRingInfo: EMLCPRingInfoModel? = nil
        
        /// 隐藏个人信息 1-隐藏，2-展示（国家、注册天数、关注数、粉丝数和访客数）
        var hidePrivacyInfo: Int = 0
        
        /// 是否在房
        var isInRoom: Bool = false
        
        // 父类的ringInfo是EMLRingInfoModel类型，换名字为cpRingInfo，并使用EMLCPRingInfoModel类型
        override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
            var replacedMap = super.mj_replacedKeyFromPropertyName() ?? [:]
            replacedMap["cpRingInfo"] = "ringInfo"
            return replacedMap
        }
    }
    
    @objcMembers
    class CardSkin: NSObject {
        var svga: String = ""
        var topImage: String = ""
        var borderColor: String = ""
        var gradientColor: [String] = []
        var bgImage: String = ""
    }
}
