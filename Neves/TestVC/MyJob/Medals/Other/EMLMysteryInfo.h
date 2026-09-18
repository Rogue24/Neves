//
//  EMLMysteryInfo.h
//  Falla
//
//  Created by aa on 2025/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMLMysteryInfo : NSObject

/// 用户ID（用不着的吧？）
//@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, assign) NSInteger level;

/// 卡片ID？
@property (nonatomic, assign) NSInteger cardId;

/// 是否神秘人
@property (nonatomic, assign) BOOL isMystery;

/// 是否在有效期间 1-在 2-不在
@property (nonatomic, assign) NSInteger isValid;

/// 神秘人过期时间
@property (nonatomic, assign) NSInteger expireTime;

/// 神秘人昵称
@property (nonatomic, copy) NSString *mysteryName;

/// 神秘人头像
@property (nonatomic, copy) NSString *mysteryAvatar;

/// 神秘人头饰
@property (nonatomic, copy) NSString *headSvga;

/// 神秘人徽章
@property (nonatomic, copy) NSArray<NSString *> *medals;

/// 聊天室公屏气泡
@property (nonatomic, copy) NSString *chatRoomBubble;

/// 聊天室公屏气泡（阿语）
@property (nonatomic, copy) NSString *chatRoomBubbleAr;

/// 进场飞幕
@property (nonatomic, copy) NSString *entryEffect;

/// 进场飞幕（阿语）
@property (nonatomic, copy) NSString *entryEffectAr;

/// 进场座驾ID
@property (nonatomic, assign) NSInteger entryHorseId;

@end

NS_ASSUME_NONNULL_END
