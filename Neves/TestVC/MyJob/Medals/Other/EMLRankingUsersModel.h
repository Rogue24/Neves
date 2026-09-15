//
//  EMLRankingUsersModel.h
//  Neves
//
//  Created by cc on 2021/2/23.
//

#import <Foundation/Foundation.h>
#import "EMLRankingUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMLRankingUsersModel : NSObject
///// 返回数量
//@property (nonatomic, copy) NSString *count;
///// 翻页参数，翻页需要回传，第一页不传或传空
//@property (nonatomic, copy) NSString *scroll;
/// 返回数据列表
@property (nonatomic, copy) NSArray<EMLRankingUserModel *> *list;
/// 最大排名
@property (nonatomic, assign) NSInteger maxRank;
/// 周期时间
@property (nonatomic, copy) NSString *quarter;
/// 我的榜单信息
@property (nonatomic, strong) EMLRankingUserModel *myRank;
/// 活动链接
@property (nonatomic, copy) NSString *activityUrl;
/// 活动图标
@property (nonatomic, copy) NSString *iconUrl;
/// 1-国家，2-地区
@property (nonatomic, assign) NSInteger rangeType;
/// 是否可以切换数据维度
@property (nonatomic, assign) BOOL chooseData;
/// 国旗资源地址
@property (nonatomic, copy) NSString *nationalFlag;
@end


NS_ASSUME_NONNULL_END
