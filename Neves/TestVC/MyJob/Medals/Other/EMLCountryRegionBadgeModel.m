//
//  EMLCountryRegionBadgeModel.m
//  Falla
//
//  Created by aa on 2024/11/14.
//

#import "EMLCountryRegionBadgeModel.h"
#import <MJExtension/MJExtension.h>
#import "NSString+JKRLocalized.h"

@implementation EMLCountryRegionBadgeModel

MJCodingImplementation

- (NSString *)rangeType {
    if (!_rangeType) _rangeType = @"";
    return _rangeType;
}

- (NSString *)rankType {
    if (!_rankType) _rankType = @"";
    return _rankType;
}

- (NSString *)url {
    if (!_url) _url = @"";
    return _url;
}

- (NSString *)getBadgeRangeTitle {
    if ([self.rangeType isEqualToString:@"GLOBAL"]) {
        return [NSString jkr_localizedString:@"str_global"];
    }
    return self.rangeType;
}

- (NSString *)getBadgeRankingTitle {
    if ([self.rankType isEqualToString:@"honor"]) {
        return [NSString jkr_localizedString:@"str_honor_top" Holder:[NSString stringWithFormat:@"%zd", self.topN]];
    }
    
    if ([self.rankType isEqualToString:@"influence"]) {
        return [NSString jkr_localizedString:@"str_influence_top" Holder:[NSString stringWithFormat:@"%zd", self.topN]];
    }
    
    if ([self.rankType isEqualToString:@"regal"]) {
        return [NSString jkr_localizedString:@"str_rich_top" Holder:[NSString stringWithFormat:@"%zd", self.topN]];
    }
    
    return nil;
}

- (UIImage *)getBadgeCardImage {
    if ([self.rankType isEqualToString:@"honor"]) {
        return [UIImage imageNamed:@"country_badge_card_honor"];
    }
    
    if ([self.rankType isEqualToString:@"influence"]) {
        return [UIImage imageNamed:@"country_badge_card_influence"];
    }
    
    if ([self.rankType isEqualToString:@"regal"]) {
        return [UIImage imageNamed:@"country_badge_card_regal"];
    }
    
    return nil;
}

@end
