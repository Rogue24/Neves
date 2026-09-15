//
//  JKRCurrentUser.h
//  Neves
//
//  Created by cc on 2021/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRCurrentUser : NSObject <NSCoding>
/// 用户uid
@property (nonatomic, assign) NSInteger uid;
/// 昵称
@property (nonatomic, copy, nullable) NSString *nickname;
/// 头像
@property (nonatomic, copy, nullable) NSString *avatarurl;
/// 性别 0未知  1男 2女
@property (nonatomic, assign) NSInteger gender;
/// 财富值等级
@property (nonatomic, assign) NSInteger wealthlv;
/// 魅力值等级
@property (nonatomic, assign) NSInteger charmlv;
/// 活跃值等级
@property (nonatomic, assign) NSInteger activelv;
/// 靓号等级（旧版）
@property (nonatomic, assign) NSInteger suidLv;
/// v9.7.0_新靓号等级_用户：1~8（共8个级别）
@property (nonatomic, assign) NSInteger newSuidLv;
/// 新靓号
@property (nonatomic, copy, nullable) NSString *suid;
/// 头像框id
@property (nonatomic, assign) NSInteger headid;
/// 座驾id
@property (nonatomic, assign) NSInteger horseid;
/// 座驾链接
@property (nonatomic, copy, nullable) NSString *horseSvga;
/// 是否显示头像
@property (nonatomic, assign) NSInteger horseAdditional;
/// 进场飞幕、座驾配置
@property (nonatomic, copy) NSDictionary<NSString *, NSString*> *horseEffectCfg;
/// 1 新用户 2 非新用户
@property (nonatomic, assign) NSInteger newerStatus;
/// 登录token
@property (nonatomic, copy, nullable) NSString *accesstoken;
/// 融云ID
@property (nonatomic, copy, nullable) NSString *rongcloudtoken;

/// 是否没有补充资料 == 1 需要补充
@property (nonatomic, assign) NSInteger first;
/// 账户注册类型
@property (nonatomic, assign) NSInteger accountType;
/// 手机号码  不带国家电话编号
@property (nonatomic, copy, nullable) NSString *mobilephone;
/// 电话号码所在国家区号
@property (nonatomic, assign) NSInteger area;
/// 一级分区
@property (nonatomic, copy, nullable) NSString *region;
/// 9.6.0 精细化小区
@property (nonatomic, copy, nullable) NSString *subRegion;
/// 国家名字
@property (nonatomic, strong) NSString *countryname;
/// 用户所属国家对应的国家编号，这个id也是电话编号
@property (nonatomic, assign) NSInteger countryid;
/// 绑定的email
@property (nonatomic, copy, nullable) NSString *email;
/// facebook的id，注意是字符串
@property (nonatomic, copy, nullable) NSString *facebookid;
/// 苹果token
@property (nonatomic, copy, nullable) NSString *appletoken;
/// 是否是新用户
@property (nonatomic, assign) BOOL isNew;
/// 注册时间
@property (nonatomic, assign) NSTimeInterval createTimeTs;

/// 1普通会员  1以上有各种权限, 3 国家管理员 7超级管理员
@property (nonatomic, assign) NSInteger power;
/// 贵族 1-5
@property (nonatomic, assign) NSInteger nobility;
/// 贵族过期时间
@property (nonatomic, copy, nullable) NSString *nobilityExpire;
/// 贵族勋章
@property (nonatomic, copy, nullable) NSString *nobilityIcon;
/// 管理员图标
@property (nonatomic, copy, nullable) NSArray<NSString *> *managerIcon;
/// 勋章图标
@property (nonatomic, copy, nullable) NSArray<NSString *> *medalsIcon;
/// CP勋章
@property (nonatomic, copy, nullable) NSString *cpMedal;

/// 是否关注了，只有uid唯一查询时出现
@property (nonatomic, assign) BOOL follow;
/// 这个时间点之前是封禁
@property (nonatomic, copy, nullable) NSString *stoptime;
/// 是否把他拉黑了，只有uid唯一查询时出现
@property (nonatomic, assign) BOOL forbid;
/// 是否已被封禁
@property (nonatomic, assign) NSInteger forbidts;

/// 个性签名
@property (nonatomic, copy, nullable) NSString *signature;
/// 生日
@property (nonatomic, copy, nullable) NSString *birthday;
/// 年龄
@property (nonatomic, assign) NSInteger age;
/// 兴趣
@property (nonatomic, copy, nullable) NSString *interest;

/// cpUid
@property (nonatomic, assign) NSInteger cpUid;
/// cpDuid
@property (nonatomic, assign) NSInteger cpDuid;
/// cpState
@property (nonatomic, assign) NSInteger cpState;
/// cpLv
@property (nonatomic, assign) NSInteger cpLv;
/// cpNickname
@property (nonatomic, copy, nullable) NSString *cpNickname;
/// cpAvatarurl
@property (nonatomic, copy, nullable) NSString *cpAvatarurl;
/// cp头饰
@property (nonatomic, assign) NSInteger cpHeadId;
/// cp贵族勋章
@property (nonatomic, copy, nullable) NSString *cpNobilityIcon;
@property (nonatomic, copy) NSString *cpSuid;
@property (nonatomic, assign) NSInteger cpSuidLv;

/// 家族ID
@property (nonatomic, assign) NSInteger familyId;
@property (nonatomic, assign) NSInteger familyOwner;
@property (nonatomic, copy, nullable) NSString *familyName;
@property (nonatomic, copy, nullable) NSString *familyGroupId;
/// 家族等级
@property (nonatomic, assign) NSInteger familyLv;
/// 家族成员权限 1-成员 2- 管理员 3-族长
@property (nonatomic, assign) NSInteger familyPower;
/// 家族铭牌
@property (nonatomic, copy, nullable) NSString *familyNameplate;
@property (nonatomic, copy, nullable) NSString *familySfid;
@property (nonatomic, assign) NSInteger familySfidLv;
/// v9.7.0_新靓号等级_家族：1~8（共8个级别）
@property (nonatomic, assign) NSInteger newFamilySfidLv;
@property (nonatomic, copy) NSString *sfid;
@property (nonatomic, assign) NSInteger sfidLv;
/// v9.7.0_新靓号等级_家族：1~8（共8个级别）
@property (nonatomic, assign) NSInteger newSfidLv;
/// 家族成员-是否是新成员
@property (nonatomic, assign) BOOL isNewMember;

/// 注册天数
@property (nonatomic, assign) NSInteger regDays;
/// 最后一次活跃时间
@property (nonatomic, assign) NSInteger activeTs;
/// 拉黑状态：0-未拉黑，1-拉黑对方，2-被对方拉黑
@property (nonatomic, assign) NSInteger blockState;
/// 主页背景图
@property (nonatomic, copy, nullable) NSArray<NSString *> *homeBg;

// MARK: - v6.1.0 新增
/// svip
@property (nonatomic, assign) NSInteger svip;
/// 历史最高svip级
@property (nonatomic, assign) NSInteger maxSvip;
/// 主页背景图上限张数
@property (nonatomic, assign) NSInteger maxHomeBgNum;

// MARK: - v6.3.0 新增
/// 用户是否已注销
@property (nonatomic, assign) BOOL accountDisabled;
/// 当前所在房间（不是指自己创建的房间，不在任何房间则为0）
@property (nonatomic, assign) NSInteger gid;
/// 是否已申请好友
@property (nonatomic, assign) NSInteger isInvited;

// MARK: - v6.4.0 新增
/// 亲密关系的Svga头饰（带小头像的）
@property (nonatomic, copy, nullable) NSString *headSvga;
/// 静态头饰
@property (nonatomic, copy, nullable) NSString *headImage;

// MARK: - v6.8.0 新增
/// 自己的房间号（本人创建的房间，只作用于单例对象`[JKRUserManager sharedUserManager].user`中）
@property (nonatomic, assign) NSInteger mineGid;

// MARK: - v7.0.0 新增
/// 游戏等级
@property (nonatomic, assign) NSInteger gameLv;
/// 最高游戏等级积分
@property (nonatomic, assign) NSInteger gameLvStar;

// MARK: - v7.8.0 新增
/// 影响力等级
@property (nonatomic, assign) NSInteger influenceLv;
/// 荣誉积分
@property (nonatomic, assign) NSInteger influencePoint;
/// 是否是国家管理员（新增原因是因为多了个支持经理概念，支持经理与国家管理员power都为3，客户端区分不出来，主要用于房间用户资料卡）
@property (nonatomic, assign) BOOL isCountryAdmin;

// MARK: - v8.2.0 新增
/// 腾讯云Sig
@property (nonatomic, copy) NSString *userSig;

// MARK: - v9.1.0 新增
/// 用户信息时间戳，防止旧数据覆盖用
@property (nonatomic, assign) NSTimeInterval timeUnix;

@end

NS_ASSUME_NONNULL_END
