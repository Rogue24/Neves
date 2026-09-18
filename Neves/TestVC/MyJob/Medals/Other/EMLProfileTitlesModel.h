//
//  EMLProfileTitlesModel.h
//  Falla
//
//  Created by admin on 2023/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMLProfileTitlesResourcesItemModel : NSObject <NSCoding>

@property (nonatomic, strong)   NSString *resourceUrl;

@property (nonatomic, assign)   NSInteger weight;

@property (nonatomic, assign)   NSInteger height;

@property (nonatomic, strong)   NSString *jumpUrl;

@property (nonatomic, assign)   NSInteger effectType;  // 是否支持扫光特效：0-无特效，1-扫光

- (BOOL)isValid;

@end

@interface EMLProfileTitlesResourcesModel : NSObject <NSCoding>

@property (nonatomic, strong)   EMLProfileTitlesResourcesItemModel *AR;

@property (nonatomic, strong)   EMLProfileTitlesResourcesItemModel *EN;

@property (nonatomic, strong)   EMLProfileTitlesResourcesItemModel *ES;

@property (nonatomic, strong)   EMLProfileTitlesResourcesItemModel *TR;

@end

@interface EMLProfileTitlesModel : NSObject <NSCoding>

@property (nonatomic, assign)   NSInteger titleId;

@property (nonatomic, strong)   NSString *jumpUrl;

@property (nonatomic, assign)   NSInteger effectType;  // 是否支持扫光特效：0-无特效，1-扫光

@property (nonatomic, strong)   EMLProfileTitlesResourcesModel *resources;

- (nullable EMLProfileTitlesResourcesItemModel *)getValidTitlesResourcesItemModelWithRegion:(NSString *)region;

@end

NS_ASSUME_NONNULL_END
