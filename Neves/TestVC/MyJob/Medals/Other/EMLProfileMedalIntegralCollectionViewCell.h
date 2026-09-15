//
//  EMLProfileMedalIntegralCollectionViewCell.h
//  Neves
//
//  Created by Emily Huang on 2023/7/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMLProfileMedalIntegralCollectionViewCellDelegate <NSObject>

@optional
- (void)clickMedalRankingButton;
- (void)clickMedalPointsButton;

@end

@interface EMLProfileMedalIntegralCollectionViewCell : UICollectionViewCell

/// 勋章季度积分
@property (nonatomic, assign) NSInteger medalPoint;
/// 勋章排名
@property (nonatomic, assign) NSInteger medalPointRank;
/// 是否显示可点击箭头
@property (nonatomic, assign) BOOL isShowPointsArrowImageView;

@property (nonatomic, weak) id<EMLProfileMedalIntegralCollectionViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
