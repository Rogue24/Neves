//
//  EMLProfileTitlesModel.m
//  Falla
//
//  Created by admin on 2023/4/19.
//

#import "EMLProfileTitlesModel.h"
#import <MJExtension/MJExtension.h>

@implementation EMLProfileTitlesResourcesItemModel

MJCodingImplementation

- (BOOL)isValid {
    if (self.resourceUrl.length == 0 || self.weight == 0 || self.height == 0) {
        return NO;
    }
    return YES;
}

@end

@implementation EMLProfileTitlesResourcesModel

MJCodingImplementation

@end

@implementation EMLProfileTitlesModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"titleId": @"id"
    };
}

- (EMLProfileTitlesResourcesItemModel *)getValidTitlesResourcesItemModelWithRegion:(NSString *)region {
    EMLProfileTitlesResourcesItemModel *itemModel;
    if ([region isEqualToString:@"AR"]) {
        itemModel = self.resources.AR;
    } else if ([region isEqualToString:@"ES"]) {
        itemModel = self.resources.ES;
    } else if ([region isEqualToString:@"TR"]) {
        itemModel = self.resources.TR;
    } else {
        itemModel = self.resources.EN;
    }
    
    if (itemModel.isValid) {
        itemModel.jumpUrl = self.jumpUrl;
        itemModel.effectType = self.effectType;
        return itemModel;
    }
    
    return nil;
}

@end
