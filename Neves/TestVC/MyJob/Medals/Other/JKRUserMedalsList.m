//
//  JKRUserMedalsList.m
//  Falla
//
//  Created by Lucky on 2021/1/19.
//  Copyright © 2021 Falla. All rights reserved.
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
