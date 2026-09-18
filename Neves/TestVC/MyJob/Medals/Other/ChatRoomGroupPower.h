//
//  ChatRoomGroupPower.h
//  Falla
//
//  Created by aa on 2024/8/7.
//

#import <Foundation/Foundation.h>

/// 房间用户权限
typedef NS_ENUM(NSInteger, ChatRoomGroupPower) {
    /// 未知 0
    ChatRoomGroupPower_Unknow = 0,
    
    /// 游客 1
    ChatRoomGroupPower_Visitor = 1,
    
    /// 会员 2
    ChatRoomGroupPower_Member = 2,
    
    /// 管理员 3
    ChatRoomGroupPower_Admin = 3,
    
    /// 房间创建者 4
    ChatRoomGroupPower_Owner = 4,
};

/// 房间用户【管理员】权限（`ChatRoomGroupPower`为`ChatRoomGroupPower_Admin`才有效）
typedef NS_ENUM(NSInteger, ChatRoomGroupAdminPower) {
    /// 普通管理员 0
    ChatRoomGroupAdminPower_General = 0,
    /// 超级管理员（超管）350
    ChatRoomGroupAdminPower_Super = 350,
};
