//
//  JKRUserMedalsList.m
//  Neves
//
//  Created by kk on 2021/1/19.
//

#import "JKRUserMedalsList.h"
#import <MJExtension/MJExtension.h>

@implementation JKRUserMedalsList

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"ID": @"id",
    };
}

@end
