//
//  JPHeadEffectCfg.h
//  Falla
//
//  Created by aa on 2023/8/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPHeadEffectCfg : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger toUid;
@property (nonatomic, assign) NSInteger eType;
@property (nonatomic, copy) NSString *avatarurl2;

@end

NS_ASSUME_NONNULL_END
