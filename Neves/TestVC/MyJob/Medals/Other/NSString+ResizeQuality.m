//
//  NSString+ResizeQuality.m
//  Falla
//
//  Created by aa on 2024/9/26.
//

#import "NSString+ResizeQuality.h"

#define KOpenResizeQualityLog 0

@implementation NSString (ResizeQuality)

static BOOL ProcessEnabled = YES;
static NSString *const ProcessEnabledKey = @"EMLProcessEnabledKey";
static NSString *const ProcessKey = @"x-oss-process";

#pragma mark - 开关处理

+ (void)configProcessEnabled {
    NSNumber *enabled = [[NSUserDefaults standardUserDefaults] objectForKey:ProcessEnabledKey];
    if (enabled) {
        ProcessEnabled = [enabled boolValue];
    } else {
        ProcessEnabled = YES;
    }
}

+ (void)setProcessEnabled:(BOOL)enabled {
    ProcessEnabled = enabled;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:enabled] forKey:ProcessEnabledKey];
}

#pragma mark - 根据【像素尺寸】

- (NSString *)resizeQualityWithPixelSize:(CGSize)size mode:(EMLResizeMode)mode {
    if (!ProcessEnabled) {
#ifdef DEBUG
        __unresizLog(@"开关已关闭");
#endif
        return self;
    }
    
    if (size.width <= 0 && size.height <= 0) {
#ifdef DEBUG
        __unresizLog(@"宽高不能都为0");
#endif
        return self;
    }
    
    // https://res-g.resygg.com/awss3_4081076_1718245148140020434_3164840898.png
    NSString *urlStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (urlStr.length == 0) return urlStr;
    
    if ([urlStr containsString:ProcessKey]) {
#ifdef DEBUG
        __unresizLog([NSString stringWithFormat:@"原链接已添加process参数，此处不再处理：%@", urlStr]);
#endif
        return urlStr;
    }
    
    NSArray<NSString *> *subStrArr = [urlStr componentsSeparatedByString:@"?"];
    if (subStrArr.count > 2 || subStrArr.count == 0) {
#ifdef DEBUG
        __unresizLog(@"链接格式错误，可能有多个”?“字符");
#endif
        return urlStr;
    }
    
    // 校验能否缩放
    if (![subStrArr.firstObject __resizable]) {
        return urlStr;
    }
    
    // 构建缩放参数
    NSString *processStr = [NSString __buildProcessParameterWithSize:size mode:mode];
    
    // 📢 注意：@"xxx?"这种字符串通过`componentsSeparatedByString`获取的数组数量为2，第二元素是空字符串@""
    if (subStrArr.count == 2 && subStrArr.lastObject.length > 0) {
        // 本来就有参数，增添参数
        urlStr = [NSString stringWithFormat:@"%@?%@&%@", subStrArr.firstObject, subStrArr.lastObject, processStr];
    } else {
        // 本来没有参数，构建参数
        urlStr = [NSString stringWithFormat:@"%@?%@", subStrArr.firstObject, processStr];
    }
    
    // https://res-g.resygg.com/awss3_4081076_1718245148140020434_3164840898.png?x-oss-process=image/resize,m_lfit,w_200,h_200
    return urlStr;
}

- (NSString *)resizeQualityWithPixelSize:(CGSize)size {
    return [self resizeQualityWithPixelSize:size mode:EMLResizeMode_fill];
}

#pragma mark - 根据【自定义尺寸】

- (NSString *)resizeQualityWithCustomSize:(CGSize)size scale:(NSInteger)scale mode:(EMLResizeMode)mode {
    if (scale <= 0) scale = 1;
    return [self resizeQualityWithPixelSize:CGSizeMake(size.width * scale, size.height * scale) mode:mode];
}

- (NSString *)resizeQualityWithCustomSize:(CGSize)size scale:(NSInteger)scale {
    return [self resizeQualityWithCustomSize:size scale:scale mode:EMLResizeMode_fill];
}

#pragma mark - 根据【逻辑尺寸】

- (NSString *)resizeQualityWithDisplaySize:(CGSize)size mode:(EMLResizeMode)mode {
    return [self resizeQualityWithCustomSize:size scale:(NSInteger)[UIScreen mainScreen].scale mode:mode];
}

- (NSString *)resizeQualityWithDisplaySize:(CGSize)size {
    return [self resizeQualityWithCustomSize:size scale:(NSInteger)[UIScreen mainScreen].scale mode:EMLResizeMode_fill];
}

#pragma mark - 根据【逻辑尺寸】的通用API

- (NSString *)resizeQualityForDisplay_20x20 {
    return [self resizeQualityForDisplay_20x20:EMLResizeMode_fill];
}
- (NSString *)resizeQualityForDisplay_20x20:(EMLResizeMode)mode {
    return [self resizeQualityWithDisplaySize:CGSizeMake(20, 20) mode:mode];
}

- (NSString *)resizeQualityForDisplay_40x40 {
    return [self resizeQualityForDisplay_40x40:EMLResizeMode_fill];
}
- (NSString *)resizeQualityForDisplay_40x40:(EMLResizeMode)mode {
    return [self resizeQualityWithDisplaySize:CGSizeMake(40, 40) mode:mode];
}

- (NSString *)resizeQualityForDisplay_64x64 {
    return [self resizeQualityForDisplay_64x64:EMLResizeMode_fill];
}
- (NSString *)resizeQualityForDisplay_64x64:(EMLResizeMode)mode {
    return [self resizeQualityWithDisplaySize:CGSizeMake(64, 64) mode:mode];
}

- (NSString *)resizeQualityForDisplay_80x80 {
    return [self resizeQualityForDisplay_80x80:EMLResizeMode_fill];
}
- (NSString *)resizeQualityForDisplay_80x80:(EMLResizeMode)mode {
    return [self resizeQualityWithDisplaySize:CGSizeMake(80, 80) mode:mode];
}

- (NSString *)resizeQualityForDisplay_100x100 {
    return [self resizeQualityForDisplay_100x100:EMLResizeMode_fill];
}
- (NSString *)resizeQualityForDisplay_100x100:(EMLResizeMode)mode {
    return [self resizeQualityWithDisplaySize:CGSizeMake(100, 100) mode:mode];
}

#pragma mark - 私有方法

#ifdef DEBUG
static void __unresizLog(NSString *info) {
    if (KOpenResizeQualityLog) NSLog(@"ResizeQuality_不可缩放：%@。", info);
}
#endif

/// 链接能否缩放
- (BOOL)__resizable {
    if (self.length == 0) {
#ifdef DEBUG
        __unresizLog(@"链接不能为空");
#endif
        return NO;
    }
    
    if (![self containsString:@"resygg.com"] &&
        ![self containsString:@"falla.live"] &&
        ![self containsString:@"apifalla.com"] &&
        ![self containsString:@"fallalive.com"] &&
        ![self containsString:@"vochat.com"] &&
        ![self containsString:@"vochatapp.com"]) {
#ifdef DEBUG
        __unresizLog(@"不包含可用域名");
#endif
        return NO;
    }
    
    NSString *extension = [self pathExtension];
    if (extension.length == 0) {
#ifdef DEBUG
        __unresizLog(@"后缀不能为空");
#endif
        return NO;
    }
    
    if ([extension caseInsensitiveCompare:@"png"] != NSOrderedSame &&
        [extension caseInsensitiveCompare:@"jpg"] != NSOrderedSame &&
        [extension caseInsensitiveCompare:@"jpeg"] != NSOrderedSame) {
#ifdef DEBUG
        __unresizLog([NSString stringWithFormat:@"后缀格式不符合条件 %@", extension]);
#endif
        return NO;
    }
    
    return YES;
}

/// 构建缩放参数
+ (NSString *)__buildProcessParameterWithSize:(CGSize)size mode:(EMLResizeMode)mode {
    // x-oss-process
    NSMutableString *processStr = [NSMutableString stringWithString:ProcessKey];
    
    // x-oss-process=image/resize
    [processStr appendString:@"=image/resize"];
    
    // x-oss-process=image/resize,m_lfit
    switch (mode) {
        case EMLResizeMode_lfit:
            [processStr appendString:@",m_lfit"];
            break;
        case EMLResizeMode_mfit:
            [processStr appendString:@",m_mfit"];
            break;
        case EMLResizeMode_fill:
            [processStr appendString:@",m_fill"];
            break;
        case EMLResizeMode_pad:
            [processStr appendString:@",m_pad"];
            [processStr appendString:@",color_FFFFFF00"]; // 多余区域使用透明色
            break;
        case EMLResizeMode_fixed:
            [processStr appendString:@",m_fixed"];
            break;
        default:
            break;
    }
    
    // x-oss-process=image/resize,m_lfit,w_200
    if (size.width > 0) {
        [processStr appendFormat:@",w_%.0lf", size.width];
    }
    
    // x-oss-process=image/resize,m_lfit,w_200,h_200
    if (size.height > 0) {
        [processStr appendFormat:@",h_%.0lf", size.height];
    }
    
    return processStr;
}

@end
