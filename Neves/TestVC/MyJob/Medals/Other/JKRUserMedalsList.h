//
//  JKRUserMedalsList.h
//  Neves
//
//  Created by kk on 2021/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRUserMedalsList : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger medalStyle;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *iconS;
@property (nonatomic, strong) NSString *iconM;
@property (nonatomic, strong) NSString *iconL;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *svga;

/// v6.3.0新增
/// 积分
@property (nonatomic, assign) NSInteger point;
/// 等级
@property (nonatomic, strong) NSString *lv;
/// 获得时间
@property (nonatomic, assign) NSInteger createTs;

/// 0未知（编辑排序），1可编辑排序，2不可编辑排序
@property (nonatomic, assign) NSInteger editSort;

@end

NS_ASSUME_NONNULL_END
