//
//  EMLRankingUsersModel.m
//  Falla
//
//  Created by falla on 2021/2/23.
//  Copyright © 2021 Falla. All rights reserved.
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

