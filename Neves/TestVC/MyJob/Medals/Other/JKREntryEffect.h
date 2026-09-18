//
//  JKREntryEffect.h
//  Falla
//
//  Created by Howie on 2021/7/19.
//

#import <Foundation/Foundation.h>
#import "JKRNewCPContentUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JKREntryEffectType) {
    /// 等级进场动效
    JKREntryEffectType_Level = 1,
    
    /// 贵族进场动效
    JKREntryEffectType_Noble = 2,
    
    /// cp进场动效
    JKREntryEffectType_CP = 3,
    
    /// 亲密关系进场动效(6.4.0新增)
    JKREntryEffectType_Intimate = 4,
};

typedef NS_ENUM(NSUInteger, JKRIntimacyType) {
    /// 未知
    JKRIntimacyType_Unknown = 0,
    
    /// CP
    JKRIntimacyType_CP = 1,
    
    /// 不强调性别的好友关系，挚友
    JKRIntimacyType_Soulmate = 2,
    
    /// 强调女性的好友关，闺蜜
    JKRIntimacyType_Bestie = 3,
    
    /// 强调男性的好友关系，兄弟
    JKRIntimacyType_Homie = 4,
};

@interface JKREntryEffect : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) JKREntryEffectType eType;
@property (nonatomic, assign) JKRIntimacyType intimacyType;
@property (nonatomic, strong) NSString *effect;
@property (nonatomic, strong) NSString *effectAr;

@property (nonatomic, strong) JKRNewCPContentUser *toUser;
@end

NS_ASSUME_NONNULL_END
