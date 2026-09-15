//
//  JKRShimmeringLabel.h
//  Neves
//
//  Created by hh on 2022/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRShimmeringLabel : UILabel

/// 闪烁蒙版（由渐变图层生成的图片，设置后作为文本的蒙版，循环滚动以实现闪烁效果）
/// - 原名是`mask`，但由于OC中的`maskView`在Swift中名为`mask`，如果还使用`mask`这个名字就无法使用该属性了（变成设置`maskView`了），因此改成`shimmerMask`。
@property (nonatomic, strong, nullable) UIImage *shimmerMask;

/// 是否开启闪烁动效（默认`YES`）
/// - 设为`NO`时蒙版会静止不动，文字依然保留`shimmerMask`的渐变配色，只是不再流动（未设置`shimmerMask`时该属性无意义）。
@property (nonatomic, assign) BOOL isShimmerEnabled;

@end

NS_ASSUME_NONNULL_END
