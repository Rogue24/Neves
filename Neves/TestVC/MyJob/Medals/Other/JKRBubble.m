//
//  JKRBubble.m
//  Falla
//
//  Created by Howie on 2021/6/21.
//

#import "JKRBubble.h"
#import <UIKit/UIKit.h>
#import <MJExtension/MJExtension.h>
#import "JKRCSSSRemoteModel+Extension.h"
#import "JKREnvironmentConfigManager.h"

@implementation JKRBubble

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isMemberOfClass:[JKRBubble class]]) return NO;
    JKRBubble *compareObject = (JKRBubble *)object;
    return self.ID == compareObject.ID &&
    (self.fromBg ? [self.fromBg isEqualToString:compareObject.fromBg] : !compareObject.fromBg) &&
    (self.fromBgAr ? [self.fromBgAr isEqualToString:compareObject.fromBgAr] : !compareObject.fromBgAr) &&
    (self.fromColour ? [self.fromColour isEqualToString:compareObject.fromColour] : !compareObject.fromColour) &&
    (self.toBg ? [self.toBg isEqualToString:compareObject.toBg] : !compareObject.toBg) &&
    (self.toBgAr ? [self.toBgAr isEqualToString:compareObject.toBgAr] : !compareObject.toBgAr) &&
    (self.toColour ? [self.toColour isEqualToString:compareObject.toColour] : !compareObject.toColour);
}

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"ID": @"id",
    };
}

+ (NSArray *)mj_ignoredPropertyNames {
    return @[
        @"eml_config1",
        @"eml_config2",
        @"eml_config3",
        @"eml_config4",
    ];
}

+ (NSArray *)mj_ignoredCodingPropertyNames {
    return @[
        @"eml_config1",
        @"eml_config2",
        @"eml_config3",
        @"eml_config4",
    ];
}

#pragma mark - 当【字典】转【模型】完毕时调用

- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues {
    if (self.bubbleChartType != 2) {
        return;
    }
    
    NSDictionary *spritesConfigVO = keyValues[@"spritesConfigVO"];
    if (!spritesConfigVO) {
        return;
    }
    
    self.eml_config1 = [self __buildSpritesConfig:spritesConfigVO[@"config1"]];
    self.eml_config2 = [self __buildSpritesConfig:spritesConfigVO[@"config2"]];
    self.eml_config3 = [self __buildSpritesConfig:spritesConfigVO[@"config3"]];
    self.eml_config4 = [self __buildSpritesConfig:spritesConfigVO[@"config4"]];
}

- (JKRCSSSRemoteModel *)__buildSpritesConfig:(NSDictionary *)dict {
    if (!dict) return nil;
    
    NSString *sprite = dict[@"sprite"];
    NSString *spriteAr = dict[@"spriteAr"];
    NSInteger duration = [dict[@"duration"] integerValue];
    NSInteger framesPerRow = [dict[@"framesPerRow"] integerValue];
    NSInteger frameCount = [dict[@"frameCount"] integerValue];
    NSInteger frameHeight = [dict[@"frameHeight"] integerValue];
    NSInteger frameWidth = [dict[@"frameWidth"] integerValue];
    if (frameCount == 0 || frameHeight == 0 || frameWidth == 0) {
        return nil;
    }
    
    JKRCSSSRemoteModel *config = [[JKRCSSSRemoteModel alloc] init];
    config.frameCount = frameCount;
    config.frameSize = CGSizeMake(frameWidth, frameHeight);
    config.duration = duration / 1000.0; // 服务器返回的是毫秒
    config.framesPerRow = framesPerRow;
    if ([JKREnvironmentConfigManager layoutDirectionIsRightToLeft]) {
        config.url = spriteAr;
        config.eml_mirrorUrl = sprite;
    } else {
        config.url = sprite;
        config.eml_mirrorUrl = spriteAr;
    }
    return config;
    
//    JKRCSSSRemoteModel *m = [[JKRCSSSRemoteModel alloc] init];
//    if (idx == 1) {
//        m.url = @"https://raw.githubusercontent.com/Joker-388/MyDocument/refs/heads/master/左上角.png";
//        m.frameCount = 25;
//        m.frameSize = CGSizeMake(96, 102);
//        m.duration = 1.0;
//        m.framesPerRow = 25;
//    }
//    else if (idx == 2) {
//        m.url = @"https://raw.githubusercontent.com/Joker-388/MyDocument/refs/heads/master/右上角.png";
//        m.frameCount = 25;
//        m.frameSize = CGSizeMake(96, 102);
//        m.duration = 1.0;
//        m.framesPerRow = 25;
//    }
//    else if (idx == 3) {
//        m.url = @"https://raw.githubusercontent.com/Joker-388/MyDocument/refs/heads/master/左下角.png";
//        m.frameCount = 25;
//        m.frameSize = CGSizeMake(96, 102);
//        m.duration = 1.0;
//        m.framesPerRow = 25;
//    }
//    else if (idx == 4) {
//        m.url = @"https://raw.githubusercontent.com/Joker-388/MyDocument/refs/heads/master/右下角.png";
//        m.frameCount = 25;
//        m.frameSize = CGSizeMake(96, 102);
//        m.duration = 1.0;
//        m.framesPerRow = 25;
//    }
//    return m;
}

#pragma mark - 当【模型】转【字典】完毕时调用

- (void)mj_objectDidConvertToKeyValues:(NSMutableDictionary *)keyValues {
    if (self.bubbleChartType != 2) {
        return;
    }
    
    if (self.eml_config1 == nil &&
        self.eml_config2 == nil &&
        self.eml_config3 == nil &&
        self.eml_config4 == nil) {
        return;
    }
    
    NSMutableDictionary *spritesConfigVO = [NSMutableDictionary dictionary];
    spritesConfigVO[@"config1"] = [self __buildSpritesDict:self.eml_config1];
    spritesConfigVO[@"config2"] = [self __buildSpritesDict:self.eml_config2];
    spritesConfigVO[@"config3"] = [self __buildSpritesDict:self.eml_config3];
    spritesConfigVO[@"config4"] = [self __buildSpritesDict:self.eml_config4];
    keyValues[@"spritesConfigVO"] = spritesConfigVO.copy;
}

- (NSDictionary *)__buildSpritesDict:(JKRCSSSRemoteModel *)config {
    if (!config) return nil;
    
    NSString *url = config.url;
    if (!url) url = @"";
    
    NSString *mirrorUrl = config.eml_mirrorUrl;
    if (!mirrorUrl) mirrorUrl = @"";
    
    NSString *sprite;
    NSString *spriteAr;
    if ([JKREnvironmentConfigManager layoutDirectionIsRightToLeft]) {
        sprite = mirrorUrl;
        spriteAr = url;
    } else {
        sprite = url;
        spriteAr = mirrorUrl;
    }
    
    return @{
        @"duration": @((NSInteger)(config.duration * 1000.0)), // 服务器存放的是毫秒
        @"framesPerRow": @(config.framesPerRow),
        @"frameCount": @(config.frameCount),
        @"frameHeight": @((NSInteger)config.frameSize.height),
        @"frameWidth": @((NSInteger)config.frameSize.width),
        @"sprite": sprite,
        @"spriteAr": spriteAr,
    };
}

@end
