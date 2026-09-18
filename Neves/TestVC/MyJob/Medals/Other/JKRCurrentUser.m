//
//  JKRCurrentUser.m
//  Neves
//
//  Created by cc on 2021/2/3.
//

#import "JKRCurrentUser.h"
#import <MJExtension/MJExtension.h>

@implementation JKRFamilyNameplateConfig
@end

@implementation JKRCurrentUser

MJCodingImplementation

- (id)copyWithZone:(NSZone *)zone {
    NSDictionary *dict = self.mj_keyValues;
    JKRCurrentUser *newUser = [JKRCurrentUser mj_objectWithKeyValues:dict];
    return newUser;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"blockState": @"block"
    };
}

//+ (NSArray *)mj_ignoredPropertyNames {
//    return @[@""];
//}
//
//+ (NSArray *)mj_ignoredCodingPropertyNames {
//    return @[@""];
//}

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"titles": [EMLProfileTitlesModel class],
        @"badgelist": [EMLCountryRegionBadgeModel class],
        @"medalsIconV2": [JKRMedalIconV2Model class],
    };
}

- (NSArray<EMLProfileTitlesResourcesItemModel *> *)getUsedTitles {
    NSString *region = self.region;
    
    NSMutableArray *titleArr = [NSMutableArray array];
    for (EMLProfileTitlesModel *model in self.titles) {
        EMLProfileTitlesResourcesItemModel *itemModel = [model getValidTitlesResourcesItemModelWithRegion:region];
        if (itemModel) [titleArr addObject:itemModel];
    }
    
    return [titleArr copy];
}

//- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues {
//    // JP_Test：v9.5.0
////    if (self.uid == 101610) {
////        self.maxSvip = 11;
////        self.svip = 11;
////    }
//}

- (BOOL)currentIsMystery {
    return self.mysteryInfo != nil && self.mysteryInfo.isMystery;
}

@end
