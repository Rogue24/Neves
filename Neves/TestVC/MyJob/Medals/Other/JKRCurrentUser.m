//
//  JKRCurrentUser.m
//  Neves
//
//  Created by cc on 2021/2/3.
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
