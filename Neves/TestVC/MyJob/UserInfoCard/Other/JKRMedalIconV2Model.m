//
//  JKRMedalIconV2Model.m
//  Falla
//

#import "JKRMedalIconV2Model.h"
#import <MJExtension/MJExtension.h>
#import "NSString+ResizeQuality.h"

@implementation JKRMedalIconV2Model

MJCodingImplementation

- (BOOL)isDisplayable {
    // 仅 2=勋章 / 3=钻章 可展示；印记(1) 及其它非 2/3（含未来新增）一律过滤（PF-003）
    return (self.style == 2 || self.style == 3);
}

- (CGFloat)medalWH:(CGFloat)baseWH {
    // 钻章 = round(基线×1.2)；勋章 = 本位基线（PF-004）
    if (self.style == 3) {
        return round(baseWH * 1.2);
    } else {
        return baseWH;
    }
}

- (NSString *)resizedIconURL:(CGFloat)baseWH {
    if (self.icon.length == 0) return self.icon;
    CGFloat wh = [self medalWH:baseWH];
    return [self.icon resizeQualityWithDisplaySize:CGSizeMake(wh, wh)];
}

+ (BOOL)isDisplayableMedalV2Style:(NSInteger)style {
    // 仅 2=勋章 / 3=钻章 可展示；印记(1) 及其它非 2/3（含未来新增）一律过滤（PF-003）
    return (style == 2 || style == 3);
}

+ (NSArray<JKRMedalIconV2Model *> *)displayableMedalsIconV2:(NSArray<JKRMedalIconV2Model *> *)medalsIconV2 {
    if (medalsIconV2.count == 0) return @[];
    NSMutableArray<JKRMedalIconV2Model *> *result = [NSMutableArray arrayWithCapacity:medalsIconV2.count];
    // 按服务端下发顺序过滤保留，不排序、不重排（AF-001/AF-004）
    for (JKRMedalIconV2Model *model in medalsIconV2) {
        if ([model isKindOfClass:[JKRMedalIconV2Model class]] && model.isDisplayable) {
            [result addObject:model];
        }
    }
    return result.copy;
}

+ (CGFloat)medalWHForV2Style:(NSInteger)style baseWH:(CGFloat)baseWH {
    // 钻章 = round(基线×1.2)；勋章 = 本位基线（PF-004）
    if (style == 3) {
        return round(baseWH * 1.2);
    }
    return baseWH;
}

+ (NSString *)resizedIconURLForV2:(NSString *)icon style:(NSInteger)style baseWH:(CGFloat)baseWH {
    if (icon.length == 0) return icon;
    CGFloat wh = [self medalWHForV2Style:style baseWH:baseWH];
    // 逻辑尺寸→按屏幕 scale 生成精确边长 resize 后缀（与旧 resizeQualityForDisplay_20x20 同一底层路径，泛化到逐位基线）
    return [icon resizeQualityWithDisplaySize:CGSizeMake(wh, wh)];
}

@end
