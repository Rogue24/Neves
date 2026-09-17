//
//  JKRMedalIconV2Model.h
//  Falla
//
//  勋章 V2 元素模型（与 medalsIcon 同级新增 medalsIconV2 数组的元素类型）。
//  style: 1=印记 2=勋章 3=钻章；排序由服务端保证，客户端不重排。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRMedalIconV2Model : NSObject <NSCoding>

/// 勋章图标 url
@property (nonatomic, copy, nullable) NSString *icon;

/// 勋章样式：1=印记 2=勋章 3=钻章
@property (nonatomic, assign) NSInteger style;

/// 是否可展示（仅 style 是 2=勋章 / 3=钻章；印记(1) 及其它非 2/3 一律过滤，PF-003）。
- (BOOL)isDisplayable;

/// 在给定基线下的展示边长：钻章 = round(基线×1.2)，勋章 = 本位基线（PF-004）。
- (CGFloat)medalWH:(CGFloat)baseWH;

/// 按 style 生成随尺寸变化的 resize 后缀 url：钻章按放大后精确边长请求、勋章按本位基线（PF-005/AG-004）。
- (nullable NSString *)resizedIconURL:(CGFloat)baseWH;

/// 该 style 是否可展示（仅 2=勋章 / 3=钻章；印记(1) 及其它非 2/3 一律过滤，PF-003）。
+ (BOOL)isDisplayableMedalV2Style:(NSInteger)style;

/// 过滤印记及非 2/3 的 style，**按服务端下发顺序返回，客户端不排序、不重排**（AF-001/AF-004）。
+ (NSArray<JKRMedalIconV2Model *> *)displayableMedalsIconV2:(nullable NSArray<JKRMedalIconV2Model *> *)medalsIconV2;

/// 单个 style 在给定基线下的展示边长：钻章 = round(基线×1.2)，勋章 = 本位基线（PF-004）。
+ (CGFloat)medalWHForV2Style:(NSInteger)style baseWH:(CGFloat)baseWH;

/// 按 style 生成随尺寸变化的 resize 后缀 url：钻章按放大后精确边长请求、勋章按本位基线（PF-005/AG-004）。
+ (nullable NSString *)resizedIconURLForV2:(nullable NSString *)icon style:(NSInteger)style baseWH:(CGFloat)baseWH;

@end

NS_ASSUME_NONNULL_END
