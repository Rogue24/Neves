//
//  EMLRankingUserModel.h
//  Falla
//
//  Created by aa on 2026/5/21.
//

#import <Foundation/Foundation.h>
#import "JKRCurrentUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMLRankingUserModel : JKRCurrentUser
/// 排名
@property (nonatomic, assign) NSInteger rank;
/// 流水值
@property (nonatomic, assign) NSInteger val;
/// 用户是否在房间：房间号为0时表示不在房间
@property (nonatomic, assign) NSInteger inGid;
/// true-匿名用户，false
@property (nonatomic, assign) BOOL anonymous;
@end

NS_ASSUME_NONNULL_END
