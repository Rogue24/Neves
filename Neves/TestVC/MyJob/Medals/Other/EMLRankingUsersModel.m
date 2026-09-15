//
//  EMLRankingUsersModel.m
//  Neves
//
//  Created by cc on 2021/2/23.
//

#import "EMLRankingUsersModel.h"
#import <MJExtension/MJExtension.h>

@implementation EMLRankingUsersModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"list": [EMLRankingUserModel class]
    };
}

@end

