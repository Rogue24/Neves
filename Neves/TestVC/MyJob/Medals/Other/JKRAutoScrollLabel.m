//
//  JKRAutoScrollLabel.m
//  Neves
//
//  Created by cc on 2021/10/27.
//

#import "JKRAutoScrollLabel.h"
#import <YYText/YYTextWeakProxy.h>
#import "JKRShimmeringLabel.h"
#import <pthread.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

#if DEBUG
    #define JKRAutoScrollLabelAssertMainThread() NSAssert(pthread_main_np() != 0, @"JKRAutoScrollLabel must be used on main thread")
#else
    #define JKRAutoScrollLabelAssertMainThread()
#endif

#define SCROLL_DISTANCE 100

// —— helpers: only measure first visual line, trim zero-width/dir chars —— //
static inline NSAttributedString *jkr_firstVisibleLine(NSAttributedString *src) {
    if (!src) return nil;
    NSString *s = src.string ?: @"";
    NSCharacterSet *breaks = [NSCharacterSet characterSetWithCharactersInString:@"\n\r\u2028\u2029"];
    NSRange br = [s rangeOfCharacterFromSet:breaks];
    NSRange firstRange = (br.location == NSNotFound) ? NSMakeRange(0, s.length)
                                                     : NSMakeRange(0, br.location);
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] initWithAttributedString:[src attributedSubstringFromRange:firstRange]];
    // trim trailing zero-width / bidi control chars
    static NSCharacterSet *zw; static dispatch_once_t once;
    dispatch_once(&once, ^{
        zw = [NSCharacterSet characterSetWithCharactersInString:
              @"\u200B\u200C\u200D\u2060\u200E\u200F\u202A\u202B\u202C\u202D\u202E"];
    });
    while (m.length > 0) {
        unichar c = [[m string] characterAtIndex:m.length - 1];
        if (![zw characterIsMember:c]) break;
        [m deleteCharactersInRange:NSMakeRange(m.length - 1, 1)];
    }
    return [m copy];
}

typedef NS_ENUM(NSUInteger, JKRAutoScrollType) {
    JKRAutoScrollType_Idle = 0,
    JKRAutoScrollType_Scrolling,
    JKRAutoScrollType_Stopped,
};

@interface JKRAutoScrollLabel ()
@property (nonatomic, assign) BOOL isRTL;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<JKRShimmeringLabel *> *playingLabels;

@property (nonatomic, strong) NSAttributedString *myAttr;
@property (nonatomic, assign) CGFloat textWidth;

@property (nonatomic, assign) BOOL hasLayout;
@property (nonatomic, assign) JKRAutoScrollType scrollType;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isInBackground;

@property (nonatomic, assign) CGFloat cachedTextWidth;
@property (nonatomic, assign) CGFloat cachedMeasureHeight;
@property (nonatomic, assign) const void *cachedAttrPtr;
@end

@implementation JKRAutoScrollLabel
{
    BOOL _isFirstScroll;
}

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    super.textColor = [UIColor clearColor];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    UISemanticContentAttribute attr = window.semanticContentAttribute;
    UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:attr];
    _isRTL = layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    
    _scrollType = JKRAutoScrollType_Idle;
    _scrollDelay = 1;
    _canScroll = YES;
    _isShimmerEnabled = YES;
    
    _spacing = 30;
    _leading = 0;
    _trailing = 0;
    _isScrollableWhenInvisible = NO;
    _scrollDurationScale = 1;
    _useCoreTextForTextWidth = YES;
    
    self.isInBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jkr_appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jkr_appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [self removeTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 父类方法

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self checkScrollable];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self checkScrollable];
}

- (void)layoutSubviews {
    JKRAutoScrollLabelAssertMainThread();
    
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    if (self.scrollType == JKRAutoScrollType_Stopped) {
        _playingLabels.firstObject.frame = CGRectMake(self.leading, 0, _scrollView.bounds.size.width - self.leading - self.trailing, _scrollView.bounds.size.height);
    }
    
    [self checkScrollable];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    if (self.scrollType == JKRAutoScrollType_Stopped) {
        _playingLabels.firstObject.textAlignment = textAlignment;
    }
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    [self checkScrollable];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self checkScrollable];
}

#pragma mark - notification

- (void)jkr_appDidEnterBackground {
    self.isInBackground = YES;
    [self pauseScroll];
}

- (void)jkr_appDidBecomeActive {
    self.isInBackground = NO;
    [self resumeScroll];
}

#pragma mark - getter

- (NSTimeInterval)scrollDuration {
    CGFloat w = self.scrollView.contentSize.width;
    if (!isfinite(w) || w <= 0) return 0.0;
    NSTimeInterval d = (w / 2.0) / SCROLL_DISTANCE;
    d *= _scrollDurationScale > 0 ? _scrollDurationScale : 1.0;
    return (d > 0 && isfinite(d)) ? d : 0.0;
}

- (NSMutableArray<JKRShimmeringLabel *> *)playingLabels {
    if (!_playingLabels) {
        _playingLabels = [NSMutableArray array];
    }
    return _playingLabels;
}

- (CGFloat)textWidth {
//    if (_textWidth == 0 && self.myAttr.length > 0) {
//        // 局部强引用，防止测量过程中被替换
//        NSAttributedString *attr = self.myAttr;
//        // 避免 MAXFLOAT*MAXFLOAT 触发 CoreText 断言，给一个合理的高度，iOS26偶发崩溃
//        CGFloat limitH = self.bounds.size.height > 0 ? self.bounds.size.height : 1000.0;
//        CGSize constraint = CGSizeMake(CGFLOAT_MAX, limitH);
//        CGRect rect = [attr boundingRectWithSize:constraint
//                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                         context:nil];
//        CGFloat w = ceil(rect.size.width);
//        if (!isfinite(w) || w <= 0) w = MAX(0.0, self.bounds.size.width);
//        _textWidth = w;
//    }
    
//    if (_textWidth <= 0 && self.myAttr.length > 0) {
//        // 仅测第一行的可见内容，按单行口径测量
//        NSAttributedString *first = jkr_firstVisibleLine(self.myAttr);
//        if (first.length == 0) { _textWidth = 0; return 0; }
//        CGFloat limitH = self.bounds.size.height > 0 ? self.bounds.size.height : [self jkr_maxLineHeight:first];
//        CGSize constraint = CGSizeMake(CGFLOAT_MAX, limitH);
//        // ⚠️ 不使用 UsesLineFragmentOrigin，避免多行导致的虚增
//        CGRect rect = [first boundingRectWithSize:constraint
//                                          options:NSStringDrawingUsesFontLeading
//                                          context:nil];
//        CGFloat w = ceil(rect.size.width);
//        if (!isfinite(w) || w < 0) w = 0;
//        _textWidth = w;
//    }
    
    if (_textWidth <= 0 && self.myAttr.length > 0) {
        const void *ptr = (__bridge const void *)self.myAttr;
        CGFloat h = self.bounds.size.height > 0 ? self.bounds.size.height : [self jkr_maxLineHeight:self.myAttr];
        if (ptr == self.cachedAttrPtr && fabs(h - self.cachedMeasureHeight) < 0.5 && self.cachedTextWidth > 0) {
            _textWidth = self.cachedTextWidth;
            return _textWidth;
        }
        // 仅测第一行的可见内容，按单行口径测量
        NSAttributedString *first = jkr_firstVisibleLine(self.myAttr);
        if (first.length == 0) { _textWidth = 0; return 0; }
        CGFloat w = 0;
        if (_useCoreTextForTextWidth) {
            // 优先 CoreText：更快更稳
            CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)first);
            if (line) {
                double asc=0, des=0, lead=0;
                double width = CTLineGetTypographicBounds(line, &asc, &des, &lead);
                CFRelease(line);
                w = (CGFloat)ceil(width);
            }
            if (!(isfinite(w) && w > 0)) {
                CGFloat limitH = h;
                CGRect rect = [first boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, limitH)
                                                  options:NSStringDrawingUsesFontLeading
                                                  context:nil];
                w = ceil(rect.size.width);
            }
        } else {
            CGRect rect = [first boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, h)
                                              options:NSStringDrawingUsesFontLeading
                                              context:nil];
            w = ceil(rect.size.width);
        }
        if (!isfinite(w) || w < 0) w = 0;
        _textWidth = w;
        self.cachedAttrPtr = ptr;
        self.cachedMeasureHeight = h;
        self.cachedTextWidth = w;
    }
    
    return _textWidth;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

#pragma mark - setter

- (void)setCanScroll:(BOOL)canScroll {
    if (_canScroll == canScroll) return;
    _canScroll = canScroll;
    [self checkScrollable];
}

- (void)setScrollDelay:(NSTimeInterval)scrollDelay {
    _scrollDelay = scrollDelay < 0 ? 0 : scrollDelay;
}

- (void)setShimmerMask:(UIImage *)shimmerMask {
    _shimmerMask = shimmerMask;
    
    switch (self.scrollType) {
        case JKRAutoScrollType_Scrolling:
            for (JKRShimmeringLabel *textLabel in self.playingLabels) {
                textLabel.shimmerMask = shimmerMask;
            }
            break;
            
        case JKRAutoScrollType_Stopped:
            self.playingLabels.firstObject.shimmerMask = shimmerMask;
            break;
            
        default:
            break;
    }
}

- (void)setIsShimmerEnabled:(BOOL)isShimmerEnabled {
    if (_isShimmerEnabled == isShimmerEnabled) return;
    _isShimmerEnabled = isShimmerEnabled;
    for (JKRShimmeringLabel *textLabel in self.playingLabels) {
        textLabel.isShimmerEnabled = isShimmerEnabled;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (!pthread_main_np()) { // 确保主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setAttributedText:attributedText];
        });
        return;
    }
    
    JKRAutoScrollLabelAssertMainThread();
    
    // 本体self不显示富文本，但还是要赋值，要进行隐藏文本+隐藏附件的操作再赋值
    NSMutableAttributedString *attr = nil;
    if (attributedText) {
        attr = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        // 隐藏文本
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, attr.length)];
        // 隐藏附件
        [attr enumerateAttribute:NSAttachmentAttributeName
                         inRange:NSMakeRange(0, attr.length)
                         options:NSAttributedStringEnumerationReverse // 使用倒序遍历，替换不会影响未遍历的部分
                      usingBlock:^(id value, NSRange range, BOOL *stop) {
            if ([value isKindOfClass:[NSTextAttachment class]]) {
                NSTextAttachment *attachment = (NSTextAttachment *)value;
                // 📢：不能在这里直接修改附件，如果这里修改了就会同样影响原attributedText的附件。
//                attachment.image = [[UIImage alloc] init];
                // 因为attr只是对attributedText进行深拷贝，其中的属性值（如NSTextAttachment）还是浅拷贝（引用拷贝）。
                
                // 因此要创建一个新的附件进行修改再替换。
                NSTextAttachment *newAttachment = [[NSTextAttachment alloc] init];
                newAttachment.image = [[UIImage alloc] init]; // 置空图片
                newAttachment.bounds = attachment.bounds; // 保持原来大小
                
                NSAttributedString *newAttrStr = [NSAttributedString attributedStringWithAttachment:newAttachment];
                [attr replaceCharactersInRange:range withAttributedString:newAttrStr];
            }
        }];
    }
    [super setAttributedText:attr];
    
    self.myAttr = attributedText;
    self.textWidth = 0; // 重算
    self.cachedAttrPtr = NULL;
    self.cachedTextWidth = 0;
    
    // 需要重新布局
    self.scrollType = JKRAutoScrollType_Idle;
    [self checkScrollable];
}

- (void)setScrollType:(JKRAutoScrollType)scrollType {
    if (_scrollType == scrollType) return;
    _scrollType = scrollType;
    [self updateLayout];
}

- (void)setSpacing:(CGFloat)spacing {
    if (_spacing == spacing) return;
    _spacing = spacing;
    [self updateLayout];
}

- (void)setLeading:(CGFloat)leading {
    if (_leading == leading) return;
    _leading = leading;
    [self updateLayout];
}

- (void)setTrailing:(CGFloat)trailing {
    if (_trailing == trailing) return;
    _trailing = trailing;
    [self updateLayout];
}

- (void)setIsScrollableWhenInvisible:(BOOL)isScrollableWhenInvisible {
    if (_isScrollableWhenInvisible == isScrollableWhenInvisible) return;
    _isScrollableWhenInvisible = isScrollableWhenInvisible;
    [self checkScrollable];
}

#pragma mark - update layout

- (void)updateLayout {
    [self removeTimer];
    [self resetLayout];
    
    switch (_scrollType) {
        case JKRAutoScrollType_Scrolling:
            [self layoutForScrollPrepare];
            break;
            
        case JKRAutoScrollType_Stopped:
            [self layoutForScrollCancell];
            break;
            
        default:
            break;
    }
}

- (void)resetLayout {
    [_scrollView.layer removeAllAnimations];
    _scrollView.transform = CGAffineTransformIdentity;
    _scrollView.contentOffset = CGPointMake(0, 0);
    
    if (_playingLabels.count) {
        for (JKRShimmeringLabel *textLabel in _playingLabels) {
            [textLabel removeFromSuperview];
            textLabel.transform = CGAffineTransformIdentity;
            textLabel.shimmerMask = nil;
            textLabel.attributedText = nil;
        }
    }
}

- (void)layoutForScrollPrepare {
    NSInteger needCount = 2;
    if (self.playingLabels.count < needCount) {
        for (NSInteger i = self.playingLabels.count; i < needCount; i++) {
            JKRShimmeringLabel *textLabel = [[JKRShimmeringLabel alloc] init];
            textLabel.isShimmerEnabled = self.isShimmerEnabled;
            [self.playingLabels addObject:textLabel];
        }
    }
    
    BOOL isRTL = self.isRTL;
    NSTextAlignment textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    CGFloat labelW = self.textWidth;
    CGFloat labelX = self.leading;
    for (NSInteger i = 0; i < self.playingLabels.count; i++) {
        JKRShimmeringLabel *textLabel = self.playingLabels[i];
        textLabel.shimmerMask = self.shimmerMask;
        textLabel.numberOfLines = 1;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.attributedText = self.myAttr;
        textLabel.textAlignment = textAlignment;
        textLabel.frame = CGRectMake(labelX, 0, labelW, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:textLabel];
        labelX += labelW;
        if (i < (self.playingLabels.count - 1)) {
            labelX += self.spacing;
        }
    }
    CGFloat totalW = labelX + self.trailing;
    self.scrollView.contentSize = CGSizeMake(totalW, 0);
    
    if (isRTL) {
        self.scrollView.transform = CGAffineTransformMakeRotation(M_PI);
        [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
    
    _isFirstScroll = YES;
    [self addTimer];
}

- (void)layoutForScrollCancell {
    if (self.playingLabels.count < 1) {
        JKRShimmeringLabel *textLabel = [[JKRShimmeringLabel alloc] init];
        textLabel.isShimmerEnabled = self.isShimmerEnabled;
        [self.playingLabels addObject:textLabel];
    }
    
    JKRShimmeringLabel *textLabel = self.playingLabels.firstObject;
    textLabel.shimmerMask = self.shimmerMask;
    textLabel.numberOfLines = 1;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.attributedText = self.myAttr;
    textLabel.textAlignment = self.textAlignment;
    textLabel.frame = CGRectMake(self.leading, 0, self.scrollView.bounds.size.width - self.leading - self.trailing, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:textLabel];
    self.scrollView.contentSize = CGSizeMake(0, 0);
    
    if (self.isRTL) {
        self.scrollView.transform = CGAffineTransformMakeRotation(M_PI);
        [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
}

#pragma mark - scroll

- (void)checkScrollable {
    BOOL isVisible = NO;
    if (self.isScrollableWhenInvisible) {
        isVisible = YES;
    } else {
        isVisible = self.window && self.superview && !self.isHidden && self.alpha > 0.0;
    }
    if (isVisible) {
        self.hasLayout = self.bounds.size.width > 0 && self.bounds.size.height > 0;
    } else {
        self.hasLayout = NO;
    }
    [self tryScroll];
}

- (void)tryScroll {
    if (!self.hasLayout || !self.myAttr) {
        self.scrollType = JKRAutoScrollType_Idle;
        return;
    }
    
    if (!self.canScroll || (self.bounds.size.width + 1) >= self.textWidth) {
        self.scrollType = JKRAutoScrollType_Stopped;
    } else {
        self.scrollType = JKRAutoScrollType_Scrolling;
    }
}

- (void)startScroll {
    if (self.scrollType != JKRAutoScrollType_Scrolling) {
        [self removeTimer];
        return;
    }
    
    /// 兼容xib，xib初始化时设置字符串，width不准
    if (!self.canScroll || (self.bounds.size.width + 1) >= self.textWidth) {
        self.scrollType = JKRAutoScrollType_Stopped;
        return;
    }
    
    [self.scrollView.layer removeAllAnimations];
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    NSTimeInterval duration = self.scrollDuration;
    if (duration <= 0 || !isfinite(duration)) return;
    CGFloat offsetX = self.leading + self.playingLabels.firstObject.frame.size.width;
    if (self.spacing > 0) {
        offsetX += self.spacing;
        if (self.leading > 0) {
            offsetX -= self.leading < self.spacing ? self.leading : self.spacing;
        }
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    } completion:nil];
}

#pragma mark - timer

- (void)addTimer {
    [self removeTimer];
    if (self.isInBackground) return;
    
    NSTimeInterval delay = self.scrollDelay;
    if (_isFirstScroll) {
        delay += self.firstScrollExtraDelay;
        if (delay <= 0) {
            [self timerHandling];
            return;
        }
    } else {
        delay += self.scrollDuration;
    }
    
    self.timer = [NSTimer timerWithTimeInterval:delay target:[YYTextWeakProxy proxyWithTarget:self] selector:@selector(timerHandling) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerHandling {
    if (self.isInBackground) {
        [self removeTimer];
        return;
    }
    
    if (_isFirstScroll) {
        _isFirstScroll = NO;
        [self addTimer];
    }
    [self startScroll];
}

#pragma mark - 私有方法

- (CGFloat)jkr_maxLineHeight:(NSAttributedString *)a {
    __block CGFloat h = self.font ? self.font.lineHeight : 17.0;
    [a enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, a.length) options:0 usingBlock:^(UIFont *f, NSRange r, BOOL *stop) {
        if ([f isKindOfClass:UIFont.class]) h = MAX(h, f.lineHeight);
    }];
    return h > 0 ? h : 17.0;
}

#pragma mark - 公开方法

- (void)pauseScroll {
    if (self.scrollType == JKRAutoScrollType_Scrolling) {
        [self removeTimer];
    }
}

- (void)resumeScroll {
    if (self.scrollType == JKRAutoScrollType_Scrolling) {
        [self addTimer];
    }
}

@end
