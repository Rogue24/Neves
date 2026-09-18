//
//  JKRCurrentUser.h
//  Neves
//
//  Created by cc on 2021/2/3.
//

#import <Foundation/Foundation.h>
#import "JKRBubble.h"
#import "JKREntryEffect.h"
#import "EMLProfileTitlesModel.h"
#import "JPHeadEffectCfg.h"
#import "ChatRoomGroupPower.h"
#import "EMLCountryRegionBadgeModel.h"
#import "EMLMysteryInfo.h"
#import "JKRMedalIconV2Model.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKRFamilyNameplateConfig : NSObject
@property (nonatomic, copy) NSString *medalImg;
@property (nonatomic, copy) NSString *bgImg;
@property (nonatomic, copy) NSString *fontColor;
@end

@interface JKRCurrentUser : NSObject <NSCopying, NSCoding>
/// 用户uid
@property (nonatomic, assign) NSInteger uid;
/// 绑定的靓号
@property (nonatomic, assign) NSInteger duid;
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
/// 人工设置是否靓号
@property (nonatomic, assign) NSInteger isduid;
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
/// 勋章图标V2（与 medalsIcon 同级新增，元素含 icon/style；style 1=印记 2=勋章 3=钻章）
@property (nonatomic, copy, nullable) NSArray<JKRMedalIconV2Model *> *medalsIconV2;
/// CP勋章
@property (nonatomic, copy, nullable) NSString *cpMedal;
///// 管理国家
//@property (nonatomic, copy, nullable) NSArray<NSNumber *> *mgrCountries; // 已废弃

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

/// 私聊气泡
@property (nonatomic, strong) JKRBubble *privatBubble;
/// 聊天室气泡
@property (nonatomic, strong) JKRBubble *chatRoomBubble;
/// 进场动效
@property (nonatomic, strong) JKREntryEffect *entryEffect;

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

// MARK: - v6.0.0 新增
/// 称号
@property (nonatomic, copy) NSArray<EMLProfileTitlesModel *> *titles;
/// 经过`region`过滤后的称号
- (NSArray<EMLProfileTitlesResourcesItemModel *> *)getUsedTitles;

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
/// 外管中心
@property (nonatomic, copy) NSString *outerTeamUrl;
/// 房间成员，管理员需要用到的字段 用户级别
@property (nonatomic, assign) ChatRoomGroupPower groupPower;
/// 用户子权限：groupSubPower - 350 房间超级管理员
@property (nonatomic, assign) ChatRoomGroupAdminPower groupSubPower;
/// 当前所在房间（不是指自己创建的房间，不在任何房间则为0）
@property (nonatomic, assign) NSInteger gid;
/// 是否已申请好友
@property (nonatomic, assign) NSInteger isInvited;

// MARK: - v6.4.0 新增
/// 亲密关系的Svga头饰（带小头像的）
@property (nonatomic, copy, nullable) NSString *headSvga;
/// 静态头饰
@property (nonatomic, copy, nullable) NSString *headImage;
/// 亲密关系的用户信息（uid、头像等）
@property (nonatomic, strong, nullable) JPHeadEffectCfg *headEffectCfg;

/// 自己的房间号（本人创建的房间，只作用于单例对象`[JKRUserManager sharedUserManager].user`中）
@property (nonatomic, assign) NSInteger mineGid;

/// 游戏等级
@property (nonatomic, assign) NSInteger gameLv;
/// 最高游戏等级积分
@property (nonatomic, assign) NSInteger gameLvStar;

/// 影响力等级
@property (nonatomic, assign) NSInteger influenceLv;
/// 荣誉积分
@property (nonatomic, assign) NSInteger influencePoint;
/// 是否是国家管理员（新增原因是因为多了个支持经理概念，支持经理与国家管理员power都为3，客户端区分不出来，主要用于房间用户资料卡）
@property (nonatomic, assign) BOOL isCountryAdmin;

/// 国家区域徽章
@property (nonatomic, copy, nullable) NSArray<EMLCountryRegionBadgeModel *> *badgelist;
/// 腾讯云Sig
@property (nonatomic, copy) NSString *userSig;

/// 家族铭牌信息
@property (nonatomic, strong, nullable) JKRFamilyNameplateConfig *familyNameplateConf;
/// 用户信息时间戳，防止旧数据覆盖用
@property (nonatomic, assign) NSTimeInterval timeUnix;

/// 神秘人信息
@property (nonatomic, strong, nullable) EMLMysteryInfo *mysteryInfo;
/// 我是否神秘人
- (BOOL)currentIsMystery;
/// 是否可以查看神秘人信息
@property (nonatomic, assign) BOOL hasMysteryInfoPower;

/// 0-未知（未知情况以及不识别枚举值时展示默认的勋章）；1-展示VIP勋章；2-展示SVIP勋章。
@property (nonatomic, assign) NSInteger micMedalType;
/// 0-不在【APP账号管理】系统名单的用户，才会受到原来做的财富魅力等级展示的限制 1-“展示游戏”，不论财富魅力等级是多少，都可以正常展示下列场景入口、收到相关全服/飞幕、推送 2-“不展示游戏”，不论财富魅力等级是多少，都【不展示】下列场景入口、收不到相关全服/飞幕、推送
@property (nonatomic, assign) NSInteger gameStatus;

/// 是否可显示高级游戏
@property (nonatomic, assign) BOOL relaunchGameShow;

/// 已点亮礼物图鉴数量
@property (nonatomic, assign) NSInteger litAtlasCount;
@end

NS_ASSUME_NONNULL_END
