//
//  EMLCountryRegionBadgeModel.h
//  Falla
//
//  Created by aa on 2024/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMLCountryRegionBadgeModel : NSObject <NSCoding>

/// 全服：GLOBAL，国家：国家名称
@property (nonatomic, copy) NSString *rangeType;

/// 荣誉：honor，影响力：influence，富豪：regal
@property (nonatomic, copy) NSString *rankType;

/// 排名
@property (nonatomic, assign) NSInteger topN;

/// 徽章url
@property (nonatomic, copy) NSString *url;

- (nullable NSString *)getBadgeRangeTitle;

- (nullable NSString *)getBadgeRankingTitle;

- (nullable UIImage *)getBadgeCardImage;

@end

NS_ASSUME_NONNULL_END
