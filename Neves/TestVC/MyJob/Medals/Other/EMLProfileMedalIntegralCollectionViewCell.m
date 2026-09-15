//
//  EMLProfileMedalIntegralCollectionViewCell.m
//  Neves
//
//  Created by Emily Huang on 2023/7/5.
//

#import "EMLProfileMedalIntegralCollectionViewCell.h"
#import <Neves-Swift.h>

@interface EMLProfileMedalIntegralCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *integralBgImageView;
/// 季度积分
@property (weak, nonatomic) IBOutlet UILabel *quarterlyPointsLabel;
/// 季度排名
@property (weak, nonatomic) IBOutlet UILabel *quarterlyRankingLabel;

@property (weak, nonatomic) IBOutlet UILabel *medalPointsTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *medalRankingTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *pointsArrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondPointsArrowImageView;

@end

@implementation EMLProfileMedalIntegralCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.integralBgImageView.layer.cornerRadius = 8;
    self.integralBgImageView.layer.masksToBounds = YES;
    self.integralBgImageView.image = [self __getGradientImageFromColors:@[
        [UIColor jp_colorWithHexString:@"FCE2EF"],
        [UIColor jp_colorWithHexString:@"FBF0DA"],
    ] isVerGradient:NO imgSize:CGSizeMake(JPPortraitScreenWidth - 32, 54)];
    
    self.medalPointsTitleLabel.text = @"季度积分";
    self.medalRankingTitleLabel.text = @"季度排名";
    
    self.pointsArrowImageView.image = [[UIImage imageNamed:@"moment_arrows_black"] rtl];
    self.secondPointsArrowImageView.image = [[UIImage imageNamed:@"moment_arrows_black"] rtl];
}

- (void)setMedalPoint:(NSInteger)medalPoint {
    self.quarterlyPointsLabel.text = [NSString stringWithFormat:@"%ld", medalPoint];
}

- (void)setIsShowPointsArrowImageView:(BOOL)isShowPointsArrowImageView {
    self.pointsArrowImageView.hidden = !isShowPointsArrowImageView;
}

- (void)setMedalPointRank:(NSInteger)medalPointRank {
    if (medalPointRank > 30) {
        self.quarterlyRankingLabel.text = @"NO.30+";
    } else if (medalPointRank == 0) {
        self.quarterlyRankingLabel.text = @"-";
    } else {
        self.quarterlyRankingLabel.text = [NSString stringWithFormat:@"NO.%ld", medalPointRank];
    }
}

/// 榜单
- (IBAction)rankingButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickMedalRankingButton)]) {
        [self.delegate clickMedalRankingButton];
    }
}

/// 积分
- (IBAction)pointsButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickMedalPointsButton)]) {
        [self.delegate clickMedalPointsButton];
    }
}

- (UIImage *)__getGradientImageFromColors:(NSArray*)colors isVerGradient:(BOOL)isVerGradient imgSize:(CGSize)imgSize {
    NSMutableArray *ar = [NSMutableArray array];
    for (UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    if (isVerGradient) {
        start = CGPointMake(0.0, 0.0);
        end = CGPointMake(0.0, imgSize.height);
    } else {
        start = CGPointMake(0.0, 0.0);
        end = CGPointMake(imgSize.width, 0.0);
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

@end
