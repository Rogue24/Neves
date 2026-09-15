//
//  JKRAutoScrollLabel.h
//  Neves
//
//  Created by cc on 2021/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRAutoScrollLabel : UILabel

/// 是否使用`CoreText`计算文本宽度（默认 YES，PS：使用`CoreText`计算会忽略`Attachment`的宽度）
@property (nonatomic, assign) BOOL useCoreTextForTextWidth;

/// 可否滚动（默认 YES）
@property (nonatomic, assign) BOOL canScroll;

/// 滚动延时（默认 1s，不能小于0）
@property (nonatomic, assign) NSTimeInterval scrollDelay;

/// 首次滚动额外延时（默认 0s）
/// - 首次滚动开始时间为`scrollDelay`，可以设置该值额外延迟；如果希望首次滚动立即开始，可以设置为`-scrollDelay`。
@property (nonatomic, assign) NSTimeInterval firstScrollExtraDelay;

/// 滚动时长
@property (readonly) NSTimeInterval scrollDuration;

/// 滚动时长比例（默认1，滚动时长会乘以这个值，小于等于0将无效）
@property (nonatomic, assign) CGFloat scrollDurationScale;

/// 闪烁蒙版（由渐变图层生成的图片，设置后作为文本的蒙版，循环滚动以实现闪烁效果）
/// - 原名是`mask`，但由于OC中的`maskView`在Swift中名为`mask`，如果还使用`mask`这个名字就无法使用该属性了（变成设置`maskView`了），因此改成`shimmerMask`。
@property (nonatomic, strong, nullable) UIImage *shimmerMask;

/// 是否开启闪烁动效（默认`YES`，会透传给内部的`JKRShimmeringLabel`）
/// - 设为`NO`时蒙版会静止不动，文字依然保留`shimmerMask`的渐变配色，只是不再流动（未设置`shimmerMask`时该属性无意义）。
/// - 与文本滚动无关，文本能否滚动由`canScroll`控制。
@property (nonatomic, assign) BOOL isShimmerEnabled;

/// 可滚动时，相邻 label 的间距（默认 30）
@property (nonatomic, assign) CGFloat spacing;

/// 开头边距（不要比 spacing 大！！！）
@property (nonatomic, assign) CGFloat leading;

/// 结尾边距（不可滚动时才有效果）
@property (nonatomic, assign) CGFloat trailing;

/// 视图不可见时，是否仍允许响应滚动（默认 NO）
@property (nonatomic, assign) BOOL isScrollableWhenInvisible;

/// 暂停滚动
- (void)pauseScroll;

/// 恢复滚动
- (void)resumeScroll;

@end

NS_ASSUME_NONNULL_END
