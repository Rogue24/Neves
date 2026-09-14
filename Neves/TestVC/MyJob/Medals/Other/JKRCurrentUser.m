//
//  JKRCurrentUser.m
//  Falla
//
//  Created by Howie on 2021/2/3.
//  Copyright © 2021 Falla. All rights reserved.
//

#import "JKRCurrentUser.h"
#import <MJExtension/MJExtension.h>

@implementation JKRCurrentUser

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"blockState": @"block"
    };
}

@end
