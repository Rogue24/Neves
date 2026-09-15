//
//  JKRShimmeringMask.h
//  Neves
//
//  Created by hh on 2022/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRShimmeringMask : NSObject

+ (nullable UIImage *)nickNameMaskWithVip:(NSInteger)vip svip:(NSInteger)svip;

/// 神秘人昵称
+ (nullable UIImage *)mysteryNicknameMask;

/// 贵族靓号不使用已方法，应该用 jkr_setSuidWithSuid方法
+ (nullable UIImage *)suidMaskWithSuidLv:(NSInteger)suidLv;

/// 靓号（用户/房间）
+ (nullable UIImage *)fancyIDMaskWithIdLv:(NSInteger)idLv;

/// 纯白色扫光
+ (UIImage *)onlyWhiteMask;

@end

NS_ASSUME_NONNULL_END
