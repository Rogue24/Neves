//
//  JKRChatRoomMedalModel.m
//  Falla
//
//  Created by Howie on 2021/5/28.
//

#import "JKRChatRoomMedalModel.h"
#import <MJExtension/MJExtension.h>
#import "NSString+ResizeQuality.h"

@implementation JKRChatRoomMedalModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"ID": @"id",
    };
}

- (NSString *)rq_icon {
    if (!_rq_icon) {
        _rq_icon = [self.icon resizeQualityForDisplay_100x100];
    }
    return _rq_icon;
}

@end
