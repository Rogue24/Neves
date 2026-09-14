//
//  NSString+ResizeQuality.h
//  Falla
//
//  Created by aa on 2024/9/26.
//
//  文档：https://help.aliyun.com/zh/oss/user-guide/resize-images-4?spm=a2c4g.11186623.0.0.7df0793cfd38hH#3f61d68474t3x
//
//  1.图片格式目前只能是：`JPG`、`JPEG`、`PNG`
//  2.缩放模式默认使用`EMLResizeMode_fill`
//  3.缩放系数默认使用`[UIScreen mainScreen].scale`
//  4.如果构建的尺寸比原图尺寸大将返回原图
//
//  项目常用场景尺寸选择建议：
//  1.用户头像/房间头像：100x100（大）、40x40（小）
//  2.贵族图标/国家图标：40x40
//  3.勋章图标：100x100（大）、20x20（小）
//  ...其他后续补充
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 缩放模式
 * 🌰：原图尺寸为 750 x 1334，传入尺寸为 200 x 200
 *
 * EMLResizeMode_lfit
 *  - 保持宽高比，不会超出 200 x 200
 *  - 750 x 1334 ~> 112 x 200
 *
 * EMLResizeMode_mfit
 *  - 相当于【没有裁剪】的`UIViewContentModeScaleAspectFit`，保持宽高比，延伸铺满 200 x 200
 *  - 750 x 1334 ~> 200 x 356
 *
 * EMLResizeMode_fill
 *  - 相当于`UIViewContentModeScaleAspectFill`
 *  - 750 x 1334 ~> 200 x 200
 *
 * EMLResizeMode_pad
 *  - 相当于`UIViewContentModeScaleAspectFit`，目标尺寸保持不变，把图片等比缩放至目标尺寸内，会有多余空间
 *  - 750 x 1334 ~> 200 x 200
 *
 * EMLResizeMode_fixed
 *  - 相当于`UIViewContentModeScaleToFill`
 *  - 750 x 1334 ~> 200 x 200
 *
 */
typedef enum : NSUInteger {
    EMLResizeMode_lfit,
    EMLResizeMode_mfit,
    EMLResizeMode_fill,
    EMLResizeMode_pad,
    EMLResizeMode_fixed,
} EMLResizeMode;

@interface NSString (ResizeQuality)

#pragma mark - 开关处理

/// 初始化「图片缩放链接处理」的开关
+ (void)configProcessEnabled;

/// 更新「图片缩放链接处理」的开关
+ (void)setProcessEnabled:(BOOL)enabled;

#pragma mark - 根据【像素尺寸】
/*!
 @method
 @brief 根据【像素尺寸】构建图片缩放链接
 @param size  指定缩放的像素尺寸，如果构建的尺寸比原图尺寸大将返回原图。
 @param mode  指定缩放的模式：lfit、mfit、fill、pad、fixed。
 @discussion 图片格式目前只能是：`JPG`、`JPEG`、`PNG`。
 */
- (NSString *)resizeQualityWithPixelSize:(CGSize)size mode:(EMLResizeMode)mode;

/*!
 @method
 @brief 根据【像素尺寸】构建图片缩放链接
 @param size  指定缩放的像素尺寸，如果构建的尺寸比原图尺寸大将返回原图。
 @discussion 图片格式目前只能是：`JPG`、`JPEG`、`PNG`，缩放模式使用`fill`。
 */
- (NSString *)resizeQualityWithPixelSize:(CGSize)size;

#pragma mark - 根据【自定义尺寸】
/*!
 @method
 @brief 根据【自定义尺寸】构建图片缩放链接
 @param size  自定义缩放尺寸，宽高值将乘以缩放系数，如果构建的尺寸比原图尺寸大将返回原图。
 @param scale  缩放系数，size的宽高值将乘以该值（至少为1）。
 @param mode  指定缩放的模式：lfit、mfit、fill、pad、fixed。
 @discussion 图片格式目前只能是：`JPG`、`JPEG`、`PNG`。
 */
- (NSString *)resizeQualityWithCustomSize:(CGSize)size scale:(NSInteger)scale mode:(EMLResizeMode)mode;

/*!
 @method
 @brief 根据【自定义尺寸】构建图片缩放链接
 @param size  自定义缩放尺寸，宽高值将乘以缩放系数，如果构建的尺寸比原图尺寸大将返回原图。
 @param scale  缩放系数，size的宽高值将乘以该值（至少为1）。
 @discussion 图片格式目前只能是：`JPG`、`JPEG`、`PNG`，缩放模式使用`fill`。
 */
- (NSString *)resizeQualityWithCustomSize:(CGSize)size scale:(NSInteger)scale;

#pragma mark - 根据【逻辑尺寸】
/*!
 @method
 @brief 根据【逻辑尺寸】构建图片缩放链接
 @param size  指定缩放的逻辑尺寸，宽高值将乘以系统的缩放系数，如果构建的尺寸比原图尺寸大将返回原图。
 @param mode  指定缩放的模式：lfit、mfit、fill、pad、fixed。
 @discussion 图片格式目前只能是：`JPG`、`JPEG`、`PNG`，缩放系数使用`[UIScreen mainScreen].scale`。
 */
- (NSString *)resizeQualityWithDisplaySize:(CGSize)size mode:(EMLResizeMode)mode;

/*!
 @method
 @brief 根据【逻辑尺寸】构建图片缩放链接
 @param size  指定缩放的逻辑尺寸，宽高值将乘以系统的缩放系数，如果比原图尺寸大时，返回原图。
 @discussion 图片格式目前只能是：`JPG`、`JPEG`、`PNG`，缩放模式使用`fill`，缩放系数使用`[UIScreen mainScreen].scale`。
 */
- (NSString *)resizeQualityWithDisplaySize:(CGSize)size;

#pragma mark - 根据【逻辑尺寸】的通用API

- (NSString *)resizeQualityForDisplay_20x20;
- (NSString *)resizeQualityForDisplay_20x20:(EMLResizeMode)mode;

- (NSString *)resizeQualityForDisplay_40x40;
- (NSString *)resizeQualityForDisplay_40x40:(EMLResizeMode)mode;

- (NSString *)resizeQualityForDisplay_80x80;
- (NSString *)resizeQualityForDisplay_80x80:(EMLResizeMode)mode;

- (NSString *)resizeQualityForDisplay_100x100;
- (NSString *)resizeQualityForDisplay_100x100:(EMLResizeMode)mode;

- (NSString *)resizeQualityForDisplay_64x64;
- (NSString *)resizeQualityForDisplay_64x64:(EMLResizeMode)mode;
@end

NS_ASSUME_NONNULL_END
