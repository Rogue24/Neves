//
//  JKRShimmeringLabel.m
//  Neves
//
//  Created by hh on 2022/12/7.
//

#import "JKRShimmeringLabel.h"

@interface JKRShimmeringLabel ()
@property (nonatomic, assign) BOOL isRTL;
@property (nonatomic, strong) UILabel *innerLabel;
@property (nonatomic, strong) UIImageView *colorBg;
@end

@implementation JKRShimmeringLabel

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self __setup];
}

- (void)dealloc {
//    NSLog(@"JKRShimmeringLabel dealloc");
}

#pragma mark - setter

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [super setLineBreakMode:lineBreakMode];
    [self.innerLabel setLineBreakMode:lineBreakMode];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self.innerLabel setTextAlignment:textAlignment];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self.innerLabel setText:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self.innerLabel setAttributedText:attributedText];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self.innerLabel setTextColor:textColor];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self.innerLabel setFont:font];
}

- (void)setShimmerMask:(UIImage *)shimmerMask {
    _shimmerMask = shimmerMask;
    [self setNeedsLayout];
}

- (void)setIsShimmerEnabled:(BOOL)isShimmerEnabled {
    if (_isShimmerEnabled == isShimmerEnabled) return;
    _isShimmerEnabled = isShimmerEnabled;
    [self setNeedsLayout];
}

#pragma mark - 系统方法

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    if (!_shimmerMask || width == 0 || height == 0) {
        [self __removeAnimForSubviewsWithIsHidden:YES];
        self.colorBg.image = nil;
        return;
    }
    
    [self __removeAnimForSubviewsWithIsHidden:NO];
    self.colorBg.image = _shimmerMask;
    
    if (!_isShimmerEnabled) {
        self.colorBg.frame = CGRectMake(0, 0, width, height);
        self.innerLabel.frame = self.colorBg.bounds;
        return;
    }
    
    if (self.isRTL) {
        [self __addPosAnimForView:self.innerLabel
                        fromFrame:CGRectMake(width, 0, width, height)
                          byValue:(width * 2)];
        [self __addPosAnimForView:self.colorBg
                        fromFrame:CGRectMake(-width, 0, width * 4, height)
                          byValue:(-width * 2)];
    } else {
        [self __addPosAnimForView:self.innerLabel
                        fromFrame:CGRectMake(width * 2, 0, width, height)
                          byValue:(-width * 2)];
        [self __addPosAnimForView:self.colorBg
                        fromFrame:CGRectMake(-width * 2, 0, width * 4, height)
                          byValue:(width * 2)];
    }
}

#pragma mark - 私有方法

- (void)__setup {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    UISemanticContentAttribute attr = window.semanticContentAttribute;
    UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:attr];
    _isRTL = layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    
    _isShimmerEnabled = YES;
    
    self.colorBg = [[UIImageView alloc] init];
    self.colorBg.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.colorBg];
    
    self.innerLabel = [[UILabel alloc] init];
    self.innerLabel.font = self.font;
    self.innerLabel.lineBreakMode = self.lineBreakMode;
    self.innerLabel.textAlignment = self.textAlignment;
    self.innerLabel.textColor = self.textColor;
    self.innerLabel.text = self.text;
    self.innerLabel.attributedText = self.attributedText;
    [self.colorBg addSubview:self.innerLabel];
    
    /// 📢📢📢【动态RTL】的注意点：
    /// 当`label.layer`作为另一个图层的`mask`时，如果【用户界面布局方向】与【系统语言方向】不一致，
    /// 默认情况下，`mask`会按照【系统语言方向】进行布局。
    /// - 用户界面布局方向，也就是自己设置的`[UIView appearance].semanticContentAttribute`。
    ///
    /// 原因：
    /// `UILabel`默认的`semanticContentAttribute`是`UISemanticContentAttributeUnspecified`，
    /// 作为另一个图层的`mask`时，由于`mask`是纯图形图层（`CALayer`）操作，语义信息（如方向）不会传递过去，
    /// 所以行为表现不一样，会按照【系统语言方向】进行布局。
    ///
    /// 解决方法：必须在【拿来做`mask`之前】【手动】处理方向。
    /// - 这时候确实改了`UILabel`的排版方向，它重新`layout`后，`layer`的内容就按新的方向排了。这时候再拿这个排好方向的图层去做`mask`就好了。
    self.innerLabel.semanticContentAttribute = self.isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    
    self.colorBg.layer.mask = self.innerLabel.layer;
}

- (void)__removeAnimForSubviewsWithIsHidden:(BOOL)isHidden {
    [self.innerLabel.layer removeAllAnimations];
    self.innerLabel.hidden = isHidden;
    
    [self.colorBg.layer removeAllAnimations];
    self.colorBg.hidden = isHidden;
}

- (void)__addPosAnimForView:(UIView *)view fromFrame:(CGRect)frame byValue:(CGFloat)value {
    view.frame = frame;
    
    CABasicAnimation *base = [CABasicAnimation animationWithKeyPath:@"position.x"];
    base.beginTime = 0.f;
    base.fillMode = kCAFillModeForwards;
    base.removedOnCompletion = NO;
    base.byValue = @(value);
    base.duration = 2;
    base.repeatCount = CGFLOAT_MAX;
    [view.layer addAnimation:base forKey:@"123213123"];
}

@end
