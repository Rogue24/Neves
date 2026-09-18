//
//  JKREntryEffect.m
//  Falla
//
//  Created by Howie on 2021/7/19.
//

#import "JKREntryEffect.h"
#import <MJExtension/MJExtension.h>

@implementation JKREntryEffect

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"ID": @"id",
    };
}

MJCodingImplementation

@end
