//
//  JKRShimmeringMask.m
//  Neves
//
//  Created by hh on 2022/12/7.
//

#import "JKRShimmeringMask.h"
#import "UIColor+JPExtension.h"

@implementation JKRShimmeringMask

+ (UIImage *)nickNameMaskWithVip:(NSInteger)vip svip:(NSInteger)svip {
    if (vip >= 6 || svip >= 8) {
        static UIImage *img;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIColor *c1 = [UIColor colorWithRed:101/255.0 green:241/255.0 blue:255/255.0 alpha:1];  // 青
            UIColor *c2 = [UIColor colorWithRed:246/255.0 green:202/255.0 blue:59/255.0 alpha:1];   // 黄
            UIColor *c3 = [UIColor colorWithRed:255/255.0 green:48/255.0 blue:173/255.0 alpha:1];   // 红
            img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:CGSizeMake(100, 45)];
        });
        return img;
    } else {
        return nil;
    }
}

+ (UIImage *)mysteryNicknameMask {
    static UIImage *img;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *c1 = [UIColor jp_colorWithHexString:@"8200EC"];
        UIColor *c2 = [UIColor jp_colorWithHexString:@"FFCC00"];
        UIColor *c3 = c1;
        img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:CGSizeMake(100, 45)];
    });
    return img;
}

+ (UIImage *)suidMaskWithSuidLv:(NSInteger)suidLv {
    if (suidLv <= 0) return nil;
    
    if (suidLv > 5 && suidLv < 100) {
        suidLv = 5;
    } else if (suidLv > 100 && suidLv < 1000) {
        suidLv = 100;
    } else if (suidLv > 1000) {
        suidLv = 1000;
    }
    
    CGSize imgSize = CGSizeMake(100, 40);
    switch (suidLv) {
        case 5:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor jp_colorWithHexString:@"FF577A"]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
            
        case 4:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor jp_colorWithHexString:@"9F70FF"]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
            
        case 3:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor jp_colorWithHexString:@"0081FF"]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
            
        case 2:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor jp_colorWithHexString:@"009A54"]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
            
        case 1:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor jp_colorWithHexString:@"FF7C26"]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
            
        case 100:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor jp_colorWithHexString:@"EE2EFF"]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
            
        case 1000:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor jp_colorWithHexString:@"FB1313"]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
            
        default:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 青
                UIColor *c2 = [UIColor blackColor]; // 黄
                UIColor *c3 = c2; // 红
                img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:imgSize];
            });
            return img;
        }
    }
}

+ (UIImage *)fancyIDMaskWithIdLv:(NSInteger)idLv {
    if (idLv <= 0) {
        return nil;
    }
    
    switch (idLv) {
        case 1: {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:1];
            });
            return img;
        }
            
        case 2: {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:2];
            });
            return img;
        }
            
        case 3: {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:3];
            });
            return img;
        }
            
        case 4:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:4];
            });
            return img;
        }
            
        case 5: {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:5];
            });
            return img;
        }
            
        case 6:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:6];
            });
            return img;
        }
            
        case 7:
        {
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:7];
            });
            return img;
        }
            
        default: { // 8+
            static UIImage *img;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                img = [self __getFancyIdGradientImageWithIdLv:8];
            });
            return img;
        }
    }
}

+ (UIImage *)onlyWhiteMask {
    static UIImage *img;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *c1 = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];
        UIColor *c2 = [UIColor whiteColor];
        UIColor *c3 = c1;
        img = [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:CGSizeMake(100, 45)];
    });
    return img;
}

#pragma mark - 私有方法

+ (UIImage *)__getFancyIdGradientImageWithIdLv:(NSInteger)idLv {
    UIColor *c1 = [UIColor jp_colorWithHexString:@"FFF74D"]; // 主要扫光色（金色）
    UIColor *c2 = [self __fancyIdTextColorWithIdLv:idLv defaultColor:[UIColor blackColor]].firstObject;
    UIColor *c3 = c2;
    return [self __getBaseGradientImageFromColor1:c1 color2:c2 color3:c3 imgSize:CGSizeMake(100, 40)];
}

+ (NSArray<UIColor *> *)__fancyIdTextColorWithIdLv:(NSInteger)idLv defaultColor:(UIColor *)defaultColor {
    if (idLv <= 0) {
        return @[(defaultColor ? defaultColor : JPRGBColor(102, 102, 102))];
    }
    
    switch (idLv) {
        case 1:
            return @[JPRGBColor(255, 143, 45)];
        case 2:
            return @[JPRGBColor(121, 214, 210)];
        case 3:
            return @[JPRGBColor(113, 219, 123)];
        case 4:
            return @[JPRGBColor(88, 205, 255)];
        case 5:
            return @[JPRGBColor(173, 112, 255)];
        case 6:
            return @[JPRGBColor(111, 152, 255)];
        case 7:
            return @[JPRGBColor(255, 49, 52)];
        default: // 8+
            return @[JPRGBColor(255, 192, 6), JPRGBColor(255, 248, 83), JPRGBColor(255, 192, 6)];
    }
}

+ (UIImage *)__getBaseGradientImageFromColor1:(UIColor *)c1
                                       color2:(UIColor *)c2
                                       color3:(UIColor *)c3
                                      imgSize:(CGSize)imgSize {
    NSArray<UIColor *> *colors = @[c3, c1, c2, c3, c1, c3, c2, c1, c3, c1, c2, c3, c1, c3, c2, c1, c3];
    return [self __getGradientImageFromColors:colors
                                isVerGradient:NO
                                      imgSize:imgSize];
}

+ (UIImage *)__getGradientImageFromColors:(NSArray*)colors isVerGradient:(BOOL)isVerGradient imgSize:(CGSize)imgSize {
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
